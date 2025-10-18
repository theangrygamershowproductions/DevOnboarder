#!/bin/bash
# Quick fix for AAR system token permissions.
#
# This script helps identify and fix the immediate issue with AAR system
# by testing token permissions and providing actionable guidance.

set -euo pipefail

# Source virtual environment and load environment
cd "$(dirname "${BASH_SOURCE[0]}")/.."
source .venv/bin/activate

# Load tokens using Token Architecture v2.1
if [ -f "scripts/load_token_environment.sh" ]; then
    # shellcheck source=scripts/load_token_environment.sh disable=SC1091
    source scripts/load_token_environment.sh
fi

# Legacy fallback: Load environment variables from .env file if it exists
if [ -f .env ]; then
    # shellcheck source=.env disable=SC1091
    source .env
fi

echo "AAR System Token Fix Assistant"
echo "==============================="
echo

# Check if AAR_TOKEN exists
if [ -z "${AAR_TOKEN:-}" ]; then
    echo " AAR_TOKEN not found in environment"
    echo "SOLUTION: Please ensure AAR_TOKEN is set in your .tokens file"
    echo "ALTERNATIVE: Or run: python3 scripts/token_loader.py validate AAR_TOKEN"
    exit 1
fi

printf " AAR_TOKEN found (length: %d)\n" "${#AAR_TOKEN}"

# Test current permissions
echo
echo "Testing current AAR_TOKEN permissions..."

# Test actions:read
echo -n "   actions:read: "
if GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder/actions/workflows >/dev/null 2>&1; then
    echo "WORKING"
    # shellcheck disable=SC2034  # Variable used for diagnostic purposes
    ACTIONS_READ=true
else
    echo "MISSING"
    # shellcheck disable=SC2034  # Variable used for diagnostic purposes
    ACTIONS_READ=false
fi

# Test issues:write (read-only test)
echo -n "   issues:read: "
if GH_TOKEN="$AAR_TOKEN" gh api 'repos/theangrygamershowproductions/DevOnboarder/issues?per_page=1' >/dev/null 2>&1; then
    echo "WORKING"
    # shellcheck disable=SC2034  # Variable used for diagnostic purposes
    ISSUES_ACCESS=true
else
    echo "MISSING"
    # shellcheck disable=SC2034  # Variable used for diagnostic purposes
    ISSUES_ACCESS=false
fi

# Test workflow runs specifically
echo -n "   workflow runs: "
if GH_TOKEN="$AAR_TOKEN" gh api 'repos/theangrygamershowproductions/DevOnboarder/actions/runs?per_page=1' >/dev/null 2>&1; then
    echo "WORKING"
    # shellcheck disable=SC2034  # Variable used for diagnostic purposes
    WORKFLOW_RUNS=true
else
    echo "MISSING - THIS IS THE AAR SYSTEM BLOCKER"
    # shellcheck disable=SC2034  # Variable used for diagnostic purposes
    WORKFLOW_RUNS=false
fi

echo
echo "Diagnosis:"
if [ "$ACTIONS_READ" = true ] && [ "$WORKFLOW_RUNS" = true ]; then
    echo " AAR_TOKEN has sufficient permissions for Actions API"
    echo "READY: You can now run: make aar-generate WORKFLOW_ID=17464386031"
else
    echo " AAR_TOKEN missing required permissions"
    echo

    # Check if this might be a propagation delay
    echo "Checking for GitHub API propagation delay..."
    if GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder >/dev/null 2>&1; then
        echo "Repository access: WORKING"
        echo "This appears to be a GitHub Fine-Grained Token propagation delay"
        echo
        echo "GitHub Fine-Grained Token permissions can take 2-5 minutes to propagate"
        echo "   especially for Actions API access on organization repositories."
        echo
        echo "Since your token has 'actions: read & write' to all organization repos:"
        echo "   1. Wait 2-3 minutes for propagation to complete"
        echo "   2. Re-run this script: bash scripts/fix_aar_tokens.sh"
        echo "   3. Once propagation completes, all tests should pass"
        echo
        echo "Alternative: Try refreshing token environment:"
        echo "   source scripts/load_token_environment.sh"
    else
        echo "Repository access also failed - check token configuration"
        echo
    fi

    echo "If issue persists after 5 minutes, verify token setup:"
    echo "   1. Go to: https://github.com/settings/personal-access-tokens/fine-grained"
    echo "   2. Find and edit your AAR_TOKEN"
    echo "   3. Confirm Repository permissions:"
    echo "      - Actions: Read & Write (CONFIRMED IN YOUR SETUP)"
    echo "      - Issues: Read & Write (recommended)"
    echo "      - Contents: Read (keep existing)"
    echo "      - Metadata: Read (recommended)"
    echo
    echo "   4. Save changes and wait for propagation"
fi

echo
echo "Alternative: Check other tokens for actions:read"
echo "Run: python scripts/token_manager.py"
echo
echo "Full documentation: docs/token-setup-guide.md"
