#!/usr/bin/env bash
# Enhanced test runner with comprehensive logging for CI troubleshooting
set -euo pipefail

# Create logs directory if it doesn't exist
mkdir -p logs
mkdir -p test-results

# Generate timestamp for log files
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEST_LOG="logs/test_run_${TIMESTAMP}.log"
COVERAGE_LOG="logs/coverage_${TIMESTAMP}.log"

echo "🧪 DevOnboarder Test Suite with Logging"
echo "========================================"
echo "Timestamp: $(date)"
echo "Log file: $TEST_LOG"
echo "" | tee "$TEST_LOG"

# Function to log and display
log_and_display() {
    echo "$1" | tee -a "$TEST_LOG"
}

log_and_display "📋 Installing development requirements..."
if ! pip install -e ".[test]" 2>&1 | tee -a "$TEST_LOG"; then
    log_and_display "❌ Failed to install development requirements"
    exit 1
fi

log_and_display "🔍 Checking pip dependencies..."
if ! pip check 2>&1 | tee -a "$TEST_LOG"; then
    log_and_display "⚠️  Pip dependency check failed"
fi

log_and_display "🔧 Running ruff linting..."
if ! ruff check . 2>&1 | tee -a "$TEST_LOG"; then
    log_and_display "⚠️  Ruff linting found issues"
fi

log_and_display "🐍 Running Python tests with coverage..."
set +e
pytest --cov=src --cov-fail-under=95 \
    --junitxml=test-results/pytest-results.xml \
    -v 2>&1 | tee -a "$TEST_LOG"
pytest_exit=${PIPESTATUS[0]}
set -e

# Copy coverage data to logs for persistence
if [ -f .coverage ]; then
    cp .coverage "logs/coverage_data_${TIMESTAMP}"
    log_and_display "📊 Coverage data saved to logs/coverage_data_${TIMESTAMP}"
fi

# Save detailed coverage report
if command -v coverage > /dev/null 2>&1; then
    coverage report 2>&1 | tee "$COVERAGE_LOG"
    log_and_display "📊 Coverage report saved to $COVERAGE_LOG"
fi

if [ "$pytest_exit" -eq 0 ]; then
    log_and_display "✅ Python tests passed!"
else
    log_and_display "❌ Python tests failed with exit code: $pytest_exit"

    # Check for common issues and log troubleshooting hints
    if grep -q "ModuleNotFoundError" "$TEST_LOG"; then
        log_and_display ""
        log_and_display "🔧 TROUBLESHOOTING: ModuleNotFoundError detected"
        log_and_display "   Solution: pip install -e .[test]"
        log_and_display "   See docs/README.md for details"
    fi

    if grep -q "import file mismatch" "$TEST_LOG"; then
        log_and_display ""
        log_and_display "🔧 TROUBLESHOOTING: Pytest import file mismatch"
        log_and_display "   Solution: Remove duplicate directories or __pycache__"
        log_and_display "   Command: find . -name '__pycache__' -type d -exec rm -rf {} +"
    fi
fi

# Run bot tests if available
if [ -d bot ] && [ -f bot/package.json ]; then
    log_and_display "🤖 Running bot tests..."
    if npm ci --prefix bot 2>&1 | tee -a "$TEST_LOG"; then
        if (cd bot && npm run coverage 2>&1 | tee -a "$TEST_LOG"); then
            log_and_display "✅ Bot tests passed!"
        else
            log_and_display "❌ Bot tests failed"
            pytest_exit=1
        fi
    else
        log_and_display "❌ Bot dependency installation failed"
        pytest_exit=1
    fi
fi

# Run frontend tests if available
if [ -d frontend ] && [ -f frontend/package.json ]; then
    if grep -q "\"test\"" frontend/package.json; then
        log_and_display "🌐 Running frontend tests..."
        if npm ci --prefix frontend 2>&1 | tee -a "$TEST_LOG"; then
            if (cd frontend && npm run coverage 2>&1 | tee -a "$TEST_LOG"); then
                log_and_display "✅ Frontend tests passed!"
            else
                log_and_display "❌ Frontend tests failed"
                pytest_exit=1
            fi
        else
            log_and_display "❌ Frontend dependency installation failed"
            pytest_exit=1
        fi
    fi
fi

# Final summary
if [ "$pytest_exit" -eq 0 ]; then
    log_and_display ""
    log_and_display "🎉 All tests completed successfully!"
    log_and_display "📊 Test results: test-results/pytest-results.xml"
    log_and_display "📝 Full log: $TEST_LOG"
else
    log_and_display ""
    log_and_display "💥 Tests failed - check log for details: $TEST_LOG"
fi

exit "$pytest_exit"
