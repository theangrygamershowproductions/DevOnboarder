#!/usr/bin/env bash
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
    echo "SUCCESS gh command available"

    # Test auth status
    if gh auth status 2>/dev/null; then
        echo "SUCCESS GitHub authentication working"
    else
        echo "FAILED GitHub authentication issue"
    fi
else
    echo "FAILED gh command not available"
fi

echo ""
echo "Test complete"
