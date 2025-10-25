#!/bin/bash
# Classic GitHub Token Permissions Checker
# Specifically designed for Classic Personal Access Tokens

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit
source .venv/bin/activate
source scripts/load_token_environment.sh > /dev/null 2>&1

echo "Checking: Classic GitHub Token Permissions Analysis"
echo "============================================"
echo ""

check_classic_token() {
    local token_name="$1"
    local token_value="${!token_name:-}"

    printf "Value: %s\n" "$"
    echo "─────────────────────────────────────────────────────"

    if [ -z "$token_value" ]; then
        echo "Error: Token not found"
        return 1
    fi

    printf "Length: %d\n" "${#token_value}"
    echo ""

    # Check basic authentication
    echo "Authentication Test:"
    if user_data=$(GH_TOKEN="$token_value" gh api user 2>/dev/null); then
        username=$(echo "$user_data" | jq -r '.login' 2>/dev/null || echo "unknown")
        printf "   Authenticated as: %s\n" "$username"
    else
        echo "   Error: Authentication failed"
        return 1
    fi

    echo ""
    echo "List: Classic Token Scope Testing:"
    echo "   Testing specific permissions for DevOnboarder repository..."

    # Test repository access
    echo ""
    echo "   HOME: Repository Access:"
    if GH_TOKEN="$token_value" gh api repos/theangrygamershowproductions/DevOnboarder >/dev/null 2>&1; then
        echo "      Success: Repository metadata: Accessible"
    else
        echo "      Error: Repository metadata: Failed"
    fi

    # Test actions scope
    echo ""
    echo "   FAST: Actions Scope (workflow scope):"
    if GH_TOKEN="$token_value" gh api repos/theangrygamershowproductions/DevOnboarder/actions/workflows >/dev/null 2>&1; then
        echo "      Success: Workflows: Accessible"
    else
        echo "      Error: Workflows: Failed - Missing 'workflow' scope"
    fi

    if GH_TOKEN="$token_value" gh api repos/theangrygamershowproductions/DevOnboarder/actions/runs >/dev/null 2>&1; then
        echo "      Success: Workflow runs: Accessible"
    else
        echo "      Error: Workflow runs: Failed - Missing 'workflow' scope"
    fi

    if GH_TOKEN="$token_value" gh api repos/theangrygamershowproductions/DevOnboarder/actions >/dev/null 2>&1; then
        echo "      Success: Actions API: Accessible"
    else
        echo "      Error: Actions API: Failed - Missing 'workflow' or 'actions:read' scope"
    fi

    # Test issues scope
    echo ""
    echo "   🐛 Issues Scope:"
    if GH_TOKEN="$token_value" gh api repos/theangrygamershowproductions/DevOnboarder/issues >/dev/null 2>&1; then
        echo "      Success: Issues: Accessible"
    else
        echo "      Error: Issues: Failed - Missing 'repo' scope"
    fi

    # Test pull requests
    echo ""
    echo "   🔀 Pull Requests Scope:"
    if GH_TOKEN="$token_value" gh api repos/theangrygamershowproductions/DevOnboarder/pulls >/dev/null 2>&1; then
        echo "      Success: Pull requests: Accessible"
    else
        echo "      Error: Pull requests: Failed - Missing 'repo' scope"
    fi

    # Check rate limits
    echo ""
    echo "   Rate Limit Status:"
    if rate_data=$(GH_TOKEN="$token_value" gh api rate_limit 2>/dev/null); then
        core_remaining=$(echo "$rate_data" | jq -r '.resources.core.remaining' 2>/dev/null || echo "unknown")
        core_limit=$(echo "$rate_data" | jq -r '.resources.core.limit' 2>/dev/null || echo "unknown")
        printf "      API calls: %s/%s remaining\n" "$core_remaining" "$core_limit"
    else
        echo "      Error: Cannot check rate limits"
    fi

    echo ""
}

# Check AAR_TOKEN
check_classic_token "AAR_TOKEN"

echo ""
echo " Classic Token Troubleshooting Guide:"
echo "======================================="
echo ""
echo "For Classic Personal Access Tokens, you need these scopes:"
echo ""
echo "Required Scopes for AAR System:"
echo "   Success: repo - Full repository access"
echo "   Success: workflow - Workflow management"
echo "   Success: admin:org - Organization access (for org repos)"
echo ""
echo "Link: To check/update your Classic token scopes:"
echo "   1. Go to: https://github.com/settings/tokens"
echo "   2. Find your token (not Fine-Grained tokens)"
echo "   3. Click 'Update scopes' or regenerate"
echo "   4. Ensure these scopes are selected:"
echo "      • repo (Full control of private repositories)"
echo "      • workflow (Update GitHub Action workflows)"
echo "      • admin:org (if working with organization repos)"
echo ""
echo "Warning:  Note: Classic tokens don't have propagation delays like Fine-Grained tokens"
echo "    If permissions fail, the token likely needs scope updates"
