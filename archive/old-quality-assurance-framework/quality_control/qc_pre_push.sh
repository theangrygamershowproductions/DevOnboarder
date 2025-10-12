#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# DevOnboarder Quality Control Pre-Push Script
# Validates 95% quality threshold across 8 metrics
# ZERO TOLERANCE: Must pass all checks before push
# Copilot shebang comment: ADDRESSED - removed duplicate shebang lines

set -euo pipefail

echo "Running 95% QC Pre-Push Validation..."
# This script ensures all code meets DevOnboarder quality standards before pushing

# CRITICAL: Branch workflow validation to prevent main branch commits
current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
if [[ "$current_branch" == "main" ]]; then
    echo
    echo "🚨 WARNING: You're about to push to main branch!"
    echo "   DevOnboarder requires feature branch workflow"
    echo "   Consider: git checkout -b feat/your-feature-name"
    echo
    read -r -p "Continue anyway? [y/N]: " continue_main
    if [[ ! "$continue_main" =~ ^[Yy]$ ]]; then
        echo "Aborted. Create feature branch first."
        exit 1
    fi
fi

# Template variable validation (before other checks)
if [[ -f "scripts/validate_template_variables.sh" ]]; then
    echo "Validating template variables..."
    bash scripts/validate_template_variables.sh

    echo "Template variable validation passed"
fi

# Validation blind spot detection
echo "Checking for validation blind spots..."
UNTRACKED_IMPORTANT=$(git ls-files --others --exclude-standard | grep -E '\.(md|py|js|ts|sh|yml|yaml)$' || true)
if [[ -n "$UNTRACKED_IMPORTANT" ]]; then
    warning "Untracked files bypass quality checks"
    echo "$UNTRACKED_IMPORTANT" | while IFS= read -r file; do
        echo "   - $file"
    done
    read -r -p "Add files to git tracking for validation? [Y/n]: " track_files
    if [[ ! "$track_files" =~ ^[Nn]$ ]]; then
        git ls-files --others --exclude-standard | grep -E '\.(md|py|js|ts|sh|yml|yaml)$' | while IFS= read -r file; do git add "$file"; done
        echo "Files tracked - validation will include all files"
    else
        echo "Continuing with validation blind spots present"
    fi
fi

# Ensure we're in virtual environment
if [[ "${VIRTUAL_ENV:-}" == "" ]]; then
    if [[ -f ".venv/bin/activate" ]]; then
        python "Activating virtual environment..."
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
echo "STEP 1: Checking YAML files..."
if yamllint -c .github/.yamllint-config .github/workflows/ 2>/dev/null; then
    CHECKS+=("success "YAML lint")
else
    CHECKS+=("FAILED: YAML lint")
    FAILURES+=("YAML files have linting errors")
fi

# 2. Python Code Quality
echo "STEP 2: Checking Python code quality..."
if python -m ruff check . --quiet 2>/dev/null; then
    CHECKS+=("success "Ruff lint")
else
    CHECKS+=("FAILED: Ruff lint")
    FAILURES+=("Python code has linting errors")
fi

# 3. Python Formatting
echo "🖤 Checking Python formatting..."
if python -m black --check . --quiet 2>/dev/null; then
    CHECKS+=("success "Black format")
else
    CHECKS+=("FAILED: Black format")
    FAILURES+=("Python code formatting issues")
fi

# 4. Type Checking
echo "Type checking with MyPy..."
export MYPY_CACHE_DIR="logs/.mypy_cache"
mkdir -p logs/.mypy_cache
if python -m mypy src/devonboarder 2>/dev/null; then
    CHECKS+=("success "MyPy types")
else
    CHECKS+=("FAILED: MyPy types")
    FAILURES+=("Type checking errors")
fi

# 5. Test Coverage Check (service-specific coverage masking solution)
if [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]]; then
    echo "🧪 Checking test coverage (service-specific)..."

    # Initialize coverage tracking
    COVERAGE_SUCCESS=true
    COVERAGE_DETAILS=""

    # Test XP service with isolated coverage (95% threshold)
    if COVERAGE_FILE=logs/.coverage_xp python -m pytest \
        --cov --cov-config=config/.coveragerc.xp \
        --cov-fail-under=95 --quiet \
        tests/test_xp_api.py 2>/dev/null; then
        COVERAGE_DETAILS+="success "XP: 95%+ "
    else
        COVERAGE_SUCCESS=false
        COVERAGE_DETAILS+="error "XP: <95% "
    fi

    # Test Discord service with isolated coverage (95% threshold)
    if COVERAGE_FILE=logs/.coverage_discord python -m pytest \
        --cov --cov-config=config/.coveragerc.discord \
        --cov-fail-under=95 --quiet \
        tests/test_discord_integration.py 2>/dev/null; then
        COVERAGE_DETAILS+="success "Discord: 95%+ "
    else
        COVERAGE_SUCCESS=false
        COVERAGE_DETAILS+="error "Discord: <95% "
    fi

    # Test Auth service with isolated coverage (95% threshold)
    if COVERAGE_FILE=logs/.coverage_auth python -m pytest \
        --cov --cov-config=config/.coveragerc.auth \
        --cov-fail-under=95 --quiet \
        tests/test_auth_service.py tests/test_server.py 2>/dev/null; then
        COVERAGE_DETAILS+="success "Auth: 95%+"
    else
        COVERAGE_SUCCESS=false
        COVERAGE_DETAILS+="error "Auth: <95%"
    fi

    if $COVERAGE_SUCCESS; then
        CHECKS+=("success "Service coverage $COVERAGE_DETAILS")
    else
        CHECKS+=("FAILED: Service coverage $COVERAGE_DETAILS")
        FAILURES+=("Service-specific coverage thresholds not met")
    fi
fi

# 6. Documentation Quality
docs "Checking documentation..."
if [[ -x "scripts/check_docs.sh" ]]; then
    if bash scripts/check_docs.sh >/dev/null 2>&1; then
        CHECKS+=("success "Documentation")
    else
        CHECKS+=("FAILED: Documentation")
        FAILURES+=("Documentation quality issues")
    fi
else
    CHECKS+=("warning " Documentation check skipped")
fi

# 7. Commit Message Quality
echo "STEP 3: Checking commit messages..."
if bash scripts/check_commit_messages.sh >/dev/null 2>&1; then
    CHECKS+=("success "Commit messages")
else
    CHECKS+=("FAILED: Commit messages")
    FAILURES+=("Commit message format issues")
fi

# 8. Security Scan
secure "Running security scan..."
if python -m bandit -r src -ll --quiet 2>/dev/null; then
    CHECKS+=("success "Security scan")
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
    success "PASS: Quality score meets 95% threshold"
    success "Ready to push!"
    exit 0
else
    echo "FAILED: FAIL: Quality score below 95% threshold"
    echo ""
    tool "Issues to fix:"
    for failure in "${FAILURES[@]}"; do
        echo "  • $failure"
    done
    echo ""
    echo "RECOMMENDATION: Fix these issues before pushing:"
    echo "  • Run: python -m ruff check . && python -m ruff check . --fix"
    echo "  • Run: python -m black ."
    echo "  • Run: python -m mypy src/devonboarder"
    echo "  • Run: yamllint -c .github/.yamllint-config .github/workflows/"
    echo "  • Run: python -m pytest --cov=src --cov-fail-under=95"
    exit 1
fi
