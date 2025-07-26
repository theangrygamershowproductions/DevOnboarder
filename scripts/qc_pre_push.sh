#!/bin/bash
# 95% Quality Control Pre-Push Validation Script
# This script ensures all code meets DevOnboarder quality standards before pushing

set -euo pipefail

echo "🔍 Running 95% QC Pre-Push Validation..."

# Ensure we're in virtual environment
if [[ "${VIRTUAL_ENV:-}" == "" ]]; then
    if [[ -f ".venv/bin/activate" ]]; then
        echo "🐍 Activating virtual environment..."
        source .venv/bin/activate
    else
        echo "❌ Virtual environment not found. Run: python -m venv .venv && source .venv/bin/activate"
        exit 1
    fi
fi

# Quality checks array
declare -a CHECKS=()
declare -a FAILURES=()

# 1. YAML Linting
echo "📋 Checking YAML files..."
if yamllint .github/workflows/ 2>/dev/null; then
    CHECKS+=("✅ YAML lint")
else
    CHECKS+=("❌ YAML lint")
    FAILURES+=("YAML files have linting errors")
fi

# 2. Python Code Quality
echo "🐍 Checking Python code quality..."
if python -m ruff check . --quiet 2>/dev/null; then
    CHECKS+=("✅ Ruff lint")
else
    CHECKS+=("❌ Ruff lint")
    FAILURES+=("Python code has linting errors")
fi

# 3. Python Formatting
echo "🖤 Checking Python formatting..."
if python -m black --check . --quiet 2>/dev/null; then
    CHECKS+=("✅ Black format")
else
    CHECKS+=("❌ Black format")
    FAILURES+=("Python code formatting issues")
fi

# 4. Type Checking
echo "🔤 Checking type hints..."
if python -m mypy src/devonboarder --quiet 2>/dev/null; then
    CHECKS+=("✅ MyPy types")
else
    CHECKS+=("❌ MyPy types")
    FAILURES+=("Type checking errors")
fi

# 5. Test Coverage Check (if tests exist)
if [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]]; then
    echo "🧪 Checking test coverage..."
    if python -m pytest --cov=src --cov-fail-under=95 --quiet 2>/dev/null; then
        CHECKS+=("✅ Test coverage ≥95%")
    else
        CHECKS+=("❌ Test coverage <95%")
        FAILURES+=("Test coverage below 95%")
    fi
fi

# 6. Documentation Quality
echo "📚 Checking documentation..."
if [[ -x "scripts/check_docs.sh" ]]; then
    if bash scripts/check_docs.sh >/dev/null 2>&1; then
        CHECKS+=("✅ Documentation")
    else
        CHECKS+=("❌ Documentation")
        FAILURES+=("Documentation quality issues")
    fi
else
    CHECKS+=("⚠️  Documentation check skipped")
fi

# 7. Commit Message Quality
echo "📝 Checking commit messages..."
if bash scripts/check_commit_messages.sh >/dev/null 2>&1; then
    CHECKS+=("✅ Commit messages")
else
    CHECKS+=("❌ Commit messages")
    FAILURES+=("Commit message format issues")
fi

# 8. Security Scan
echo "🔒 Running security scan..."
if python -m bandit -r src -ll --quiet 2>/dev/null; then
    CHECKS+=("✅ Security scan")
else
    CHECKS+=("❌ Security scan")
    FAILURES+=("Security vulnerabilities detected")
fi

# Calculate success rate
TOTAL_CHECKS=${#CHECKS[@]}
SUCCESS_COUNT=$(printf '%s\n' "${CHECKS[@]}" | grep -c "✅" || echo "0")
PERCENTAGE=$((SUCCESS_COUNT * 100 / TOTAL_CHECKS))

echo ""
echo "📊 QC Results Summary:"
echo "======================"
for check in "${CHECKS[@]}"; do
    echo "$check"
done

echo ""
echo "📈 Quality Score: $SUCCESS_COUNT/$TOTAL_CHECKS ($PERCENTAGE%)"

# Check if we meet 95% threshold
if [[ $PERCENTAGE -ge 95 ]]; then
    echo "✅ PASS: Quality score meets 95% threshold"
    echo "🚀 Ready to push!"
    exit 0
else
    echo "❌ FAIL: Quality score below 95% threshold"
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
    echo "  • Run: yamllint .github/workflows/"
    echo "  • Run: python -m pytest --cov=src --cov-fail-under=95"
    exit 1
fi
