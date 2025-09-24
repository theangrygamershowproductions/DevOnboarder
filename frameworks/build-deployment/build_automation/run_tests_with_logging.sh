#!/usr/bin/env bash
# Enhanced test runner with comprehensive logging for CI troubleshooting
set -euo pipefail

# Centralized logging setup
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Establish PROJECT_ROOT for reliable operation
if [ -z "${PROJECT_ROOT:-}" ]; then
    export PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
fi

# Validate PROJECT_ROOT and change to it
if [ -z "${PROJECT_ROOT:-}" ] || [ ! -d "$PROJECT_ROOT" ]; then
    echo "ERROR: PROJECT_ROOT not set or invalid: ${PROJECT_ROOT:-<unset>}"
    exit 1
fi
cd "$PROJECT_ROOT"

# Create logs directory if it doesn't exist
mkdir -p logs
mkdir -p test-results

# Function to log and display
log_and_display() {
    echo "$1"
}

# Check if we're in CI or if dependencies are already installed
if [ "${CI:-false}" = "true" ] || [ -n "${VIRTUAL_ENV:-}" ]; then
    log_and_display "Running in CI or virtual environment - skipping dependency installation"
    log_and_display "Virtual environment: ${VIRTUAL_ENV:-<not set>}"
    log_and_display "CI environment: ${CI:-false}"
else
    log_and_display "Installing development requirements..."
    if ! pip install -e ".[test]" 2>&1; then
        log_and_display "FAILED to install development requirements"
        exit 1
    fi
fi

log_and_display "Checking pip dependencies..."
if command -v pip >/dev/null 2>&1; then
    if ! pip check 2>&1; then
        log_and_display "WARNING: Pip dependency check failed"
    fi
else
    log_and_display "WARNING: pip not found, skipping dependency check"
fi

log_and_display "Running ruff linting..."
if command -v ruff >/dev/null 2>&1; then
    if ! ruff check . 2>&1; then
        log_and_display "WARNING: Ruff linting found issues"
    fi
else
    log_and_display "WARNING: ruff not found, skipping linting"
fi

log_and_display "Running Python tests with centralized cache configuration..."
set +e
pytest --junitxml=test-results/pytest-results.xml -v 2>&1
pytest_exit=${PIPESTATUS[0]}
set -e

# Verify coverage report was generated
if [ ! -d "logs/htmlcov" ]; then
    log_and_display "WARNING: Coverage HTML report not found in logs/htmlcov"
    log_and_display "Coverage configuration in pyproject.toml may need verification"
fi

# Clean up any root pollution that might have been created
if [ -d ".pytest_cache" ]; then
    log_and_display "Cleaning up pytest cache pollution from root"
    rm -rf .pytest_cache
fi

if [ -d ".mypy_cache" ]; then
    log_and_display "Cleaning up mypy cache pollution from root"
    rm -rf .mypy_cache
fi

# Copy coverage data to logs for persistence
if [ -f .coverage ]; then
    cp .coverage "logs/coverage_data_${TIMESTAMP}"
    log_and_display "Coverage data saved to logs/coverage_data_${TIMESTAMP}"
fi

# Save detailed coverage report
if command -v coverage > /dev/null 2>&1; then
    coverage report 2>&1
    log_and_display "Coverage report saved to $COVERAGE_LOG"
fi

if [ "$pytest_exit" -eq 0 ]; then
    log_and_display "SUCCESS: Python tests passed!"
else
    log_and_display "FAILED: Python tests failed with exit code: $pytest_exit"

    # Check for common issues and log troubleshooting hints
    if grep -q "ModuleNotFoundError" "$TEST_LOG"; then
        log_and_display ""
        log_and_display "TROUBLESHOOTING: ModuleNotFoundError detected"
        log_and_display "   Solution: pip install -e .[test]"
        log_and_display "   See docs/README.md for details"
    fi

    if grep -q "import file mismatch" "$TEST_LOG"; then
        log_and_display ""
        log_and_display "TROUBLESHOOTING: Pytest import file mismatch"
        log_and_display "   Solution: Remove duplicate directories or __pycache__"
        log_and_display "   Command: find . -name '__pycache__' -type d -exec rm -rf {} +"
    fi
fi

# Run bot tests if available
if [ -d bot ] && [ -f bot/package.json ]; then
    log_and_display "Running bot tests..."
    if npm ci --prefix bot 2>&1; then
        if (cd bot && npm run coverage 2>&1); then
            log_and_display "SUCCESS: Bot tests passed!"
        else
            log_and_display "FAILED: Bot tests failed"
            pytest_exit=1
        fi
    else
        log_and_display "FAILED: Bot dependency installation failed"
        pytest_exit=1
    fi
fi

# Run frontend tests if available
if [ -d frontend ] && [ -f frontend/package.json ]; then
    if grep -q "\"test\"" frontend/package.json; then
        log_and_display "Running frontend tests..."
        if npm ci --prefix frontend 2>&1; then
            if (cd frontend && npm run coverage 2>&1); then
                log_and_display "SUCCESS: Frontend tests passed!"
            else
                log_and_display "FAILED: Frontend tests failed"
                pytest_exit=1
            fi
        else
            log_and_display "FAILED: Frontend dependency installation failed"
            pytest_exit=1
        fi
    fi
fi

# Final summary
if [ "$pytest_exit" -eq 0 ]; then
    log_and_display ""
    log_and_display "SUCCESS: All tests completed successfully!"
    log_and_display "Test results: test-results/pytest-results.xml"
    log_and_display "Full log: $TEST_LOG"
else
    log_and_display ""
    log_and_display "FAILURE: Tests failed - check log for details: $TEST_LOG"
fi

exit "$pytest_exit"
