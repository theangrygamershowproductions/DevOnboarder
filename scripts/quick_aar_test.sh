#!/bin/bash
# Simple AAR Token Test

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit
source .venv/bin/activate
source scripts/load_token_environment.sh > /dev/null 2>&1

echo "Quick AAR Token Test"
echo "======================"
echo "Token length: ${#AAR_TOKEN}"
echo ""

# Test basic repo access
echo "1. Testing basic repository access..."
if GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder > /tmp/repo_test.json 2>&1; then
    echo "   Repository access: SUCCESS"
    echo "   Repo: $(grep '"name"' < /tmp/repo_test.json | head -1)"
else
    echo "   Repository access: FAILED"
    echo "   Error: $(head -2 < /tmp/repo_test.json)"
fi

echo ""
echo "2. Testing actions API..."
if GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder/actions > /tmp/actions_test.json 2>&1; then
    echo "   Actions API: SUCCESS"
else
    echo "   Actions API: FAILED"
    echo "   Error: $(head -2 < /tmp/actions_test.json)"
fi

# Cleanup
rm -f /tmp/repo_test.json /tmp/actions_test.json
