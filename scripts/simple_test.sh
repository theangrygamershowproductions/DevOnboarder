#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Simple CI Infrastructure Test

echo "CI INFRASTRUCTURE QUICK TEST"
echo "=========================="
echo "Timestamp: $(date)"
echo ""

# Test basic commands
echo "Testing basic commands:"
echo "- pwd: $(pwd)"
echo "- whoami: $(whoami)"
echo "- uname: $(uname -a)"
echo ""

# Test GitHub CLI
echo "Testing GitHub CLI:"
if command -v gh >/dev/null 2>&1; then
    success "gh command available"

    # Test auth status
    if gh auth status 2>/dev/null; then
        success "GitHub authentication working"
    else
        error "GitHub authentication issue"
    fi
else
    error "gh command not available"
fi

echo ""
echo "Test complete"
