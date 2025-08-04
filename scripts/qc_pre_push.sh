#!/bin/bash
# 95% Quality Control Pre-Push Validation Script
# This script ensures all code meets DevOnboarder quality standards before pushing

set -euo pipefail

echo "🔍 Running 95% QC Pre-Push Validation..."

# Ensure we're in virtual environment
if [[ "${VIRTUAL_ENV:-}" == "" ]]; then
    if [[ -f ".venv/bin/activate" ]]; then
        echo "🐍 Activating virtual environment..."
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
echo "📋 Checking YAML files..."
if yamllint -c .github/.yamllint-config .github/workflows/ 2>/dev/null; then
    CHECKS+=("SUCCESS: YAML lint")
else
    CHECKS+=("FAILED: YAML lint")
    FAILURES+=("YAML files have linting errors")
fi

# 2. Python Code Quality
echo "🐍 Checking Python code quality..."
if python -m ruff check . --quiet 2>/dev/null; then
    CHECKS+=("SUCCESS: Ruff lint")
else
    CHECKS+=("FAILED: Ruff lint")
    FAILURES+=("Python code has linting errors")
fi

# 3. Python Formatting
echo "🖤 Checking Python formatting..."
if python -m black --check . --quiet 2>/dev/null; then
    CHECKS+=("SUCCESS: Black format")
else
    CHECKS+=("FAILED: Black format")
    FAILURES+=("Python code formatting issues")
fi

# 4. Type Checking
echo "Type checking with MyPy..."
export MYPY_CACHE_DIR="logs/.mypy_cache"
mkdir -p logs/.mypy_cache
if python -m mypy src/devonboarder 2>/dev/null; then
    CHECKS+=("SUCCESS: MyPy types")
else
    CHECKS+=("FAILED: MyPy types")
    FAILURES+=("Type checking errors")
fi

# 5. Test Coverage Check (if tests exist)
if [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]]; then
    echo "🧪 Checking test coverage..."
    if python -m pytest --cov=src --cov-fail-under=95 --quiet 2>/dev/null; then
        CHECKS+=("SUCCESS: Test coverage ≥95%")
    else
        CHECKS+=("FAILED: Test coverage <95%")
        FAILURES+=("Test coverage below 95%")
    fi
fi

# 6. Documentation Quality
echo "📚 Checking documentation..."
if [[ -x "scripts/check_docs.sh" ]]; then
    if bash scripts/check_docs.sh >/dev/null 2>&1; then
        CHECKS+=("SUCCESS: Documentation")
    else
        CHECKS+=("FAILED: Documentation")
        FAILURES+=("Documentation quality issues")
    fi
else
    CHECKS+=("WARNING:  Documentation check skipped")
fi

# 7. Commit Message Quality
echo "📝 Checking commit messages..."
if bash scripts/check_commit_messages.sh >/dev/null 2>&1; then
    CHECKS+=("SUCCESS: Commit messages")
else
    CHECKS+=("FAILED: Commit messages")
    FAILURES+=("Commit message format issues")
fi

# 8. Security Scan
echo "🔒 Running security scan..."
if python -m bandit -r src -ll --quiet 2>/dev/null; then
    CHECKS+=("SUCCESS: Security scan")
else
    CHECKS+=("FAILED: Security scan")
    FAILURES+=("Security vulnerabilities detected")
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
echo "📈 Quality Score: $SUCCESS_COUNT/$TOTAL_CHECKS ($PERCENTAGE%)"

# Check if we meet 95% threshold
if [[ $PERCENTAGE -ge 95 ]]; then
    echo "SUCCESS: PASS: Quality score meets 95% threshold"
    echo "🚀 Ready to push!"
    exit 0
else
    echo "FAILED: FAIL: Quality score below 95% threshold"
    echo ""
    echo "🔧 Issues to fix:"
    for failure in "${FAILURES[@]}"; do
        echo "  • $failure"
    done
    echo ""
    echo "💡 Fix these issues before pushing:"
    echo "  • Run: python -m ruff check . && python -m ruff check . --fix"
    echo "  • Run: python -m black ."
    echo "  • Run: python -m mypy src/devonboarder"
    echo "  • Run: yamllint -c .github/.yamllint-config .github/workflows/"
    echo "  • Run: python -m pytest --cov=src --cov-fail-under=95"
    exit 1
fi
