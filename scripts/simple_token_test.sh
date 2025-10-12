#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Simple AAR Token Test

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit
# shellcheck disable=SC1091
source .venv/bin/activate
# shellcheck disable=SC1091
source scripts/load_token_environment.sh > /dev/null 2>&1

echo "🔍 Updated Token Test"
echo "===================="
echo ""
echo "Token length: ${#AAR_TOKEN}"
echo ""
echo "Testing Actions API..."

# Test Actions API
GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder/actions > /tmp/actions_result.json 2>&1

if GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder/actions > /dev/null 2>&1; then
    success "SUCCESS! Actions API is now working!"
    echo "🎉 Token permissions have fully propagated!"
    echo ""
    echo "You can now run AAR system commands:"
    echo "  make aar-generate WORKFLOW_ID=<workflow_id>"
else
    error "Still not working. Error:"
    head -3 /tmp/actions_result.json
    echo ""
    if grep -q "Not Found" /tmp/actions_result.json; then
        report "Status: GitHub API propagation delay continuing"
        echo "⏰ This is normal - can take up to 5-10 minutes for organization tokens"
    else
        report "Status: Different error - may need token reconfiguration"
    fi
fi

rm -f /tmp/actions_result.json
