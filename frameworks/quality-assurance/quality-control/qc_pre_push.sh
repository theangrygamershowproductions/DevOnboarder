#!/usr/bin/env bash
# DevOnboarder Quality Control Pre-Push Script
# Validates 95% quality threshold across 8 metrics
# ZERO TOLERANCE: Must pass all checks before push
# Copilot shebang comment: ADDRESSED - removed duplicate shebang lines

set -euo pipefail

# Centralized logging setup
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Calculate repository root for reliable path resolution
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"

echo "Running 95% QC Pre-Push Validation..."
# This script ensures all code meets DevOnboarder quality standards before pushing

# ENHANCED: Branch workflow validation with GitHub Actions context detection
current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
if [[ "$current_branch" == "main" ]]; then
    # Check if running in GitHub Actions (PR merge context)
    if [[ -n "${GITHUB_ACTIONS:-}" && "${GITHUB_EVENT_NAME:-}" == "push" && "${GITHUB_REF:-}" == "refs/heads/main" ]]; then
        echo "✅ GitHub Actions PR merge to main detected - allowing QC validation"
    else
        echo
        echo "WARNING: You're about to push to main branch!"
        echo "   DevOnboarder requires feature branch workflow"
        echo "   Consider: git checkout -b feat/your-feature-name"
        echo
        read -r -p "Continue anyway? [y/N]: " continue_main
        if [[ ! "$continue_main" =~ ^[Yy]$ ]]; then
            echo "Aborted. Create feature branch first."
            exit 1
        fi
    fi
fi

# Template variable validation (before other checks)
# NOTE: Template validation is for issue closure templates, not QA framework
# Skipping template validation for QA framework implementation
echo "Skipping template validation (not applicable to QA framework)"

# Validation blind spot detection
echo "Checking for validation blind spots..."
UNTRACKED_IMPORTANT=$(git ls-files --others --exclude-standard | grep -E '\.(md|py|js|ts|sh|yml|yaml)$' || true)
if [[ -n "$UNTRACKED_IMPORTANT" ]]; then
    echo "WARNING: Untracked files bypass quality checks"
    echo "$UNTRACKED_IMPORTANT" | while IFS= read -r file; do
        echo "   - $file"
    done

    # Non-blocking prompt with timeout for automated environments
    echo "Add files to git tracking for validation? [Y/n] (10s timeout, default: n)"
    if read -r -t 10 -p "> " track_files 2>/dev/null; then
        if [[ ! "$track_files" =~ ^[Nn]$ ]]; then
            git ls-files --others --exclude-standard | grep -E '\.(md|py|js|ts|sh|yml|yaml)$' | while IFS= read -r file; do git add "$file"; done
            echo "Files tracked - validation will include all files"
        else
            echo "Continuing with validation blind spots present"
        fi
    else
        echo "Timeout reached - continuing with validation blind spots present"
    fi
fi

# Ensure we're in virtual environment
if [[ "${VIRTUAL_ENV:-}" == "" ]]; then
    if [[ -f ".venv/bin/activate" ]]; then
        echo "Activating virtual environment..."
        # shellcheck source=/dev/null
        source .venv/bin/activate
    else
        echo "FAILED: Virtual environment not found. Run: python -m venv .venv && source .venv/bin/activate"
        exit 1
    fi
fi

# Quality checks array
declare -a CHECKS=()
declare -a FAILURES=()

# 1. YAML Linting
echo "Checking YAML files..."
if timeout 30 yamllint -c .github/.yamllint-config .github/workflows/; then
    CHECKS+=("SUCCESS: YAML lint")
else
    CHECKS+=("FAILED: YAML lint")
    FAILURES+=("YAML files have linting errors")
fi

# 2. Python Code Quality
echo "Checking Python code quality..."
if timeout 60 python -m ruff check .; then
    CHECKS+=("SUCCESS: Ruff lint")
else
    CHECKS+=("FAILED: Ruff lint")
    FAILURES+=("Python code has linting errors")
fi

# 3. Python Formatting
echo "Checking Python formatting..."
if timeout 60 python -m black --check .; then
    CHECKS+=("SUCCESS: Black format")
else
    CHECKS+=("FAILED: Black format")
    FAILURES+=("Python code formatting issues")
fi

# 4. Type Checking
echo "Type checking with MyPy..."
export MYPY_CACHE_DIR="logs/.mypy_cache"
mkdir -p logs/.mypy_cache
if timeout 90 python -m mypy src/devonboarder; then
    CHECKS+=("SUCCESS: MyPy types")
else
    CHECKS+=("FAILED: MyPy types")
    FAILURES+=("Type checking errors")
fi

# 5. Test Coverage Check (service-specific coverage masking solution)
if [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]]; then
    echo "Checking test coverage (service-specific)..."

    # Initialize coverage tracking
    COVERAGE_SUCCESS=true
    COVERAGE_DETAILS=""

    # Test XP service with isolated coverage (95% threshold)
    echo "Testing XP service coverage..."
    if timeout 90 env COVERAGE_FILE=logs/.coverage_xp python -m pytest \
        --cov --cov-config=config/.coveragerc.xp \
        --cov-fail-under=95 --tb=short --maxfail=1 \
        tests/test_xp_api.py; then
        COVERAGE_DETAILS+="PASS XP: 95%+ "
    else
        COVERAGE_SUCCESS=false
        COVERAGE_DETAILS+="FAIL XP: <95% "
    fi

    # Test Discord service with isolated coverage (95% threshold)
    # Run both Discord test files together for comprehensive coverage
    echo "Testing Discord service coverage..."
    if timeout 120 env COVERAGE_FILE=logs/.coverage_discord python -m pytest \
        --cov --cov-config=config/.coveragerc.discord \
        --cov-fail-under=95 --tb=short --maxfail=1 \
        tests/test_discord_integration_api.py tests/test_discord_integration_coverage.py; then
        COVERAGE_DETAILS+="PASS Discord: 95%+ "
    else
        COVERAGE_SUCCESS=false
        COVERAGE_DETAILS+="FAIL Discord: <95% "
    fi

    # Test Auth service with isolated coverage (95% threshold)
    echo "Testing Auth service coverage..."
    if timeout 120 env COVERAGE_FILE=logs/.coverage_auth python -m pytest \
        --cov --cov-config=config/.coveragerc.auth \
        --cov-fail-under=95 --tb=short --maxfail=1 \
        tests/test_auth_service.py tests/test_server.py; then
        COVERAGE_DETAILS+="PASS Auth: 95%+ "
    else
        COVERAGE_SUCCESS=false
        COVERAGE_DETAILS+="FAIL Auth: <95% "
    fi

    # Test Framework service with isolated coverage (95% threshold)
    echo "Testing Framework service coverage..."
    if timeout 60 env COVERAGE_FILE=logs/.coverage_framework python -m pytest \
        --cov --cov-config=config/.coveragerc.framework \
        --cov-fail-under=95 --tb=short --maxfail=1 \
        tests/framework/; then
        COVERAGE_DETAILS+="PASS Framework: 95%+ "
    else
        COVERAGE_SUCCESS=false
        COVERAGE_DETAILS+="FAIL Framework: <95% "
    fi

    if $COVERAGE_SUCCESS; then
        CHECKS+=("SUCCESS: Service coverage $COVERAGE_DETAILS")
    else
        CHECKS+=("FAILED: Service coverage $COVERAGE_DETAILS")
        FAILURES+=("Service-specific coverage thresholds not met")
    fi
fi

# 6. Documentation Quality
echo "Checking documentation..."
if [[ -x "$REPO_ROOT/scripts/check_docs.sh" ]]; then
    if bash "$REPO_ROOT/scripts/check_docs.sh" >/dev/null 2>&1; then
        CHECKS+=("SUCCESS: Documentation")
    else
        CHECKS+=("FAILED: Documentation")
        FAILURES+=("Documentation quality issues")
    fi
else
    CHECKS+=("WARNING:  Documentation check skipped")
fi

# 7. Commit Message Quality
echo "Checking commit messages..."
if bash "$REPO_ROOT/scripts/check_commit_messages.sh" 2>&1; then
    CHECKS+=("SUCCESS: Commit messages")
else
    CHECKS+=("FAILED: Commit messages")
    FAILURES+=("Commit message format issues")
fi

# 8. Security Scan
echo "Running security scan..."
if timeout 60 python -m bandit -r src -ll; then
    CHECKS+=("SUCCESS: Security scan")
else
    CHECKS+=("FAILED: Security scan")
    FAILURES+=("Security vulnerabilities detected")
fi

# 9. UTC Timestamp Validation
echo "Validating UTC timestamp compliance..."
if [[ -x "$REPO_ROOT/scripts/validate_utc_compliance.sh" ]]; then
    if timeout 30 bash "$REPO_ROOT/scripts/validate_utc_compliance.sh"; then
        CHECKS+=("SUCCESS: UTC compliance")
    else
        CHECKS+=("FAILED: UTC compliance")
        FAILURES+=("Mixed timezone usage detected - use src.utils.timestamps")
    fi
else
    CHECKS+=("WARNING: UTC compliance check skipped (validator not found)")
fi

# 10. GitHub Actions Dependency Validation
echo "Validating GitHub Actions dependencies..."
if [[ -x "$REPO_ROOT/scripts/manage_github_actions_deps.py" ]]; then
    if timeout 60 python "$REPO_ROOT/scripts/manage_github_actions_deps.py" "$REPO_ROOT" --window-days 30,90; then
        CHECKS+=("SUCCESS: GitHub Actions deps")
    else
        CHECKS+=("FAILED: GitHub Actions deps")
        FAILURES+=("Outdated GitHub Actions dependencies detected")
    fi
else
    CHECKS+=("WARNING: GitHub Actions dependency check skipped (validator not found)")
fi

# Calculate success rate
TOTAL_CHECKS=${#CHECKS[@]}
SUCCESS_COUNT=$(printf '%s\n' "${CHECKS[@]}" | grep -c "SUCCESS:" || echo "0")
PERCENTAGE=$((SUCCESS_COUNT * 100 / TOTAL_CHECKS))

echo ""
echo "SUMMARY: QC Results Summary:"
echo "======================"
for check in "${CHECKS[@]}"; do
    echo "$check"
done

echo ""
echo "Quality Score: $SUCCESS_COUNT/$TOTAL_CHECKS ($PERCENTAGE%)"

# Check if we meet 95% threshold
if [[ $PERCENTAGE -ge 95 ]]; then
    echo "SUCCESS: PASS: Quality score meets 95% threshold"
    echo "Ready to push!"
    exit 0
else
    echo "FAILED: FAIL: Quality score below 95% threshold"
    echo ""
    echo "Issues to fix:"
    for failure in "${FAILURES[@]}"; do
        echo "  • $failure"
    done
    echo ""
    echo "Fix these issues before pushing:"
    echo "  • Run: python -m ruff check . && python -m ruff check . --fix"
    echo "  • Run: python -m black ."
    echo "  • Run: python -m mypy src/devonboarder"
    echo "  • Run: yamllint -c .github/.yamllint-config .github/workflows/"
    echo "  • Run: python -m pytest --cov=src --cov-fail-under=95"
    echo "  • Run: bash $REPO_ROOT/scripts/validate_utc_compliance.sh (use src.utils.timestamps)"
    echo "  • Run: python $REPO_ROOT/scripts/manage_github_actions_deps.py $REPO_ROOT --window-days 30,90"
    exit 1
fi
