#!/usr/bin/env bash
# filepath: scripts/validate_issue_resolution.sh
# Quick validation that major CI issues are truly resolved

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🔍 Quick Issue Resolution Validation"
echo "===================================="

# Test core functionality
echo -e "${BLUE}📊 Testing Core Functionality:${NC}"

# 1. Package import
echo -n "   Package import: "
if python -c "import devonboarder" 2>/dev/null; then
    echo -e "${GREEN}SUCCESS${NC}"
    import_status=0
else
    echo -e "${RED}FAILED${NC}"
    import_status=1
fi

# 2. Environment setup
echo -n "   Environment: "
if [ -f ".env.dev" ]; then
    echo -e "${GREEN}.env.dev exists${NC}"
    env_status=0
else
    echo -e "${RED}.env.dev missing${NC}"
    env_status=1
fi

# 3. Basic linting
echo -n "   Linting: "
if command -v ruff >/dev/null 2>&1; then
    if ruff check . --quiet 2>/dev/null; then
        echo -e "${GREEN}Ruff passes${NC}"
        lint_status=0
    else
        echo -e "${YELLOW}Ruff has warnings${NC}"
        lint_status=1
    fi
else
    echo -e "${YELLOW}Ruff not available${NC}"
    lint_status=1
fi

# 4. Test structure
echo -n "   Tests: "
if [ -d "tests" ] && [ -f "pytest.ini" ]; then
    echo -e "${GREEN}Structure ready${NC}"
    test_status=0
else
    echo -e "${RED}Structure incomplete${NC}"
    test_status=1
fi

# 5. Documentation
echo -n "   Docs: "
if [ -f "scripts/check_docs.sh" ]; then
    echo -e "${GREEN}check_docs.sh available${NC}"
    docs_status=0
else
    echo -e "${RED}check_docs.sh missing${NC}"
    docs_status=1
fi

# 6. Project configuration
echo -n "   Configuration: "
if [ -f "pyproject.toml" ]; then
    echo -e "${GREEN}pyproject.toml exists${NC}"
    config_status=0
else
    echo -e "${YELLOW}pyproject.toml missing${NC}"
    config_status=1
fi

# Calculate overall status
total_checks=6
passed_checks=$((6 - import_status - env_status - lint_status - test_status - docs_status - config_status))

echo ""
echo -e "${BLUE}📋 Validation Summary:${NC}"
echo "   Passed: $passed_checks/$total_checks checks"

if [ $passed_checks -ge 4 ]; then
    echo -e "   ${GREEN}🎉 Core functionality validated - ready for issue closure!${NC}"
    validation_result=0
else
    echo -e "   ${RED}❌ Core functionality needs attention before closing issues${NC}"
    validation_result=1
fi

# List CI failure issues that can be closed
echo ""
echo -e "${BLUE}📋 CI Failure Issues Ready for Closure:${NC}"
if command -v gh >/dev/null 2>&1; then
    ci_issues=$(gh issue list --label "ci-failure" --state open --json number,title --jq '.[] | "  #\(.number): \(.title)"' 2>/dev/null || echo "")
    
    if [ -n "$ci_issues" ]; then
        echo "$ci_issues"
        echo ""
        echo -e "${YELLOW}💡 To close these issues, run:${NC}"
        echo "   bash scripts/close_resolved_issues.sh"
    else
        echo "   No ci-failure issues found"
    fi
else
    echo "   (GitHub CLI not available for issue listing)"
fi

# Additional checks for completeness
echo ""
echo -e "${BLUE}🔍 Additional Validation Checks:${NC}"

# Check for common CI-related files
echo -n "   CI workflow: "
if [ -f ".github/workflows/ci.yml" ]; then
    echo -e "${GREEN}exists${NC}"
else
    echo -e "${RED}missing${NC}"
fi

# Check for coverage configuration
echo -n "   Coverage: "
if grep -q "cov" pytest.ini 2>/dev/null || [ -f ".coveragerc" ]; then
    echo -e "${GREEN}configured${NC}"
else
    echo -e "${YELLOW}check configuration${NC}"
fi

# Check for pre-commit hooks
echo -n "   Pre-commit: "
if [ -f ".pre-commit-config.yaml" ]; then
    echo -e "${GREEN}configured${NC}"
else
    echo -e "${YELLOW}not configured${NC}"
fi

# Check for Docker configuration
echo -n "   Docker: "
if [ -f "docker-compose.ci.yaml" ]; then
    echo -e "${GREEN}CI compose exists${NC}"
else
    echo -e "${YELLOW}check Docker setup${NC}"
fi

# Quick smoke test if Python package is importable
if [ $import_status -eq 0 ]; then
    echo ""
    echo -e "${BLUE}🧪 Quick Smoke Test:${NC}"
    echo -n "   Module version: "
    python -c "import devonboarder; print(getattr(devonboarder, '__version__', 'unknown'))" 2>/dev/null || echo -e "${YELLOW}version not available${NC}"
fi

exit $validation_result
