#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Test script for external PR welcome system
# POTATO APPROVAL: test-external-pr-welcome-20251002

set -euo pipefail

echo "🧪 Testing External PR Welcome System"
echo "======================================"

# Test 1: Template exists and is valid
echo "Test 1: Checking template file..."
if [ -f "templates/external-pr-welcome.md" ]; then
    success "Template file exists"

    # Check for required content
    if grep -q "External PR Security Notice" "templates/external-pr-welcome.md"; then
        success "Contains security notice"
    else
        error "Missing security notice"
        exit 1
    fi

    if grep -q "first-time external contributors" "templates/external-pr-welcome.md"; then
        success "Contains first-time contributor context"
    else
        error "Missing first-time contributor context"
        exit 1
    fi
else
    error "Template file missing"
    exit 1
fi

# Test 2: YAML syntax validation
echo ""
echo "Test 2: Validating workflow YAML..."
if python -c "import yaml; yaml.safe_load(open('.github/workflows/pr-automation.yml'))" >/dev/null 2>&1; then
    success "YAML syntax is valid"
else
    error "YAML syntax error"
    exit 1
fi

# Test 3: Terminal output policy compliance
echo ""
echo "Test 3: Checking terminal output policy compliance..."
VIOLATIONS=0

# Check for forbidden patterns in the new welcome step
if grep -A 20 "Welcome external contributors" .github/workflows/pr-automation.yml | grep -q 'echo.*\$'; then
    error "Found variable expansion in echo statement"
    ((VIOLATIONS++))
fi

if grep -A 20 "Welcome external contributors" .github/workflows/pr-automation.yml | grep -q 'echo.*emoji'; then
    error "Found emoji usage in echo statement"
    ((VIOLATIONS++))
fi

if [ $VIOLATIONS -eq 0 ]; then
    success "Terminal output policy compliant"
else
    error "$VIOLATIONS terminal output policy violations found"
    exit 1
fi

# Test 4: Check for proper GitHub Actions syntax
echo ""
echo "Test 4: Validating GitHub Actions syntax..."
if grep -q "github.event.pull_request.head.repo.fork == true" .github/workflows/pr-automation.yml; then
    success "Fork detection logic present"
else
    error "Fork detection logic missing"
    exit 1
fi

if grep -q "github.event.action == 'opened'" .github/workflows/pr-automation.yml; then
    success "'opened' action filter present"
else
    error "'opened' action filter missing"
    exit 1
fi

echo ""
echo "🎉 All tests passed! External PR welcome system is ready."
echo ""
tool "Manual testing steps:"
echo "1. Create a test fork of the repository"
echo "2. Open a PR from the fork"
echo "3. Verify the welcome message appears on first PR only"
echo "4. Open a second PR from the same fork"
echo "5. Verify no welcome message on subsequent PRs"
