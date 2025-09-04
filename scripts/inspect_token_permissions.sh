#!/bin/bash
# GitHub Token Permissions Inspector - Fixed Version
# Uses GitHub CLI to check actual token permissions per official documentation

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit
# shellcheck disable=SC1091 # External dependency
source .venv/bin/activate
# shellcheck disable=SC1091 # External dependency
source scripts/load_token_environment.sh > /dev/null 2>&1

echo "GitHub Token Permissions Inspector (GitHub CLI Documentation Compliant)"
echo "======================================================================="
echo ""

# Function to detect token type
detect_token_type() {
    local token_value="$1"

    # Check token format to determine type
    if [[ $token_value == github_pat_* ]]; then
        echo "Fine-Grained Personal Access Token"
    elif [[ $token_value == ghp_* ]]; then
        echo "Classic Personal Access Token"
    elif [[ $token_value == ghs_* ]]; then
        echo "GitHub App Installation Token"
    else
        echo "Unknown Token Type"
    fi
}

# Function to inspect token permissions
inspect_token_permissions() {
    local token_name="$1"
    local token_value="${!token_name:-}"

    if [ -z "$token_value" ]; then
        echo "Token not found: $token_name"
        return 1
    fi

    echo "Inspecting $token_name:"
    echo "  Length: ${#token_value} characters"
    echo "  Type: $(detect_token_type "$token_value")"
    echo ""

    # Test authentication
    echo "  Authentication Test:"
    local user_info
    if user_info=$(GH_TOKEN="$token_value" gh api user 2>/dev/null); then
        local username
        username=$(echo "$user_info" | jq -r '.login' 2>/dev/null || echo "$user_info" | grep '"login"' | cut -d'"' -f4)
        echo "    Username: $username"
        echo "    Status: Authenticated"
    else
        echo "    Status: Authentication failed"
        return 1
    fi
    echo ""

    # Test Fine-Grained token repository access (correct endpoint)
    if [[ $token_value == github_pat_* ]]; then
        echo "  Fine-Grained Token Repository Access:"
        if GH_TOKEN="$token_value" gh api user/installations/repositories >/dev/null 2>&1; then
            echo "    Installation repositories: Accessible"
        else
            echo "    Installation repositories: Not accessible (may be normal)"
        fi
        echo ""
    fi

    # Test specific API endpoints that AAR system needs
    echo "  API Endpoint Tests (AAR System Requirements):"

    # Repository access (should work first)
    echo "    Repository API:"
    if GH_TOKEN="$token_value" gh api repos/theangrygamershowproductions/DevOnboarder >/dev/null 2>&1; then
        echo "      Basic access: Working"
    else
        echo "      Basic access: Failed"
        return 1
    fi

    # Issues API (proper URL parameter syntax)
    echo "    Issues API:"
    if GH_TOKEN="$token_value" gh api 'repos/theangrygamershowproductions/DevOnboarder/issues?per_page=1' >/dev/null 2>&1; then
        echo "      Issues access: Working"
    else
        echo "      Issues access: Failed"
    fi

    # Actions workflows (correct endpoint per GitHub CLI docs)
    echo "    Actions Workflows API:"
    if GH_TOKEN="$token_value" gh api repos/theangrygamershowproductions/DevOnboarder/actions/workflows >/dev/null 2>&1; then
        echo "      Workflows: Working"
    else
        echo "      Workflows: Failed"
    fi

    # Actions runs (what AAR system actually needs - proper URL syntax)
    echo "    Actions Runs API:"
    if GH_TOKEN="$token_value" gh api 'repos/theangrygamershowproductions/DevOnboarder/actions/runs?per_page=1' >/dev/null 2>&1; then
        echo "      Workflow runs: Working"
    else
        echo "      Workflow runs: Failed"
    fi

    # Pull requests API
    echo "    Pull Requests API:"
    if GH_TOKEN="$token_value" gh api 'repos/theangrygamershowproductions/DevOnboarder/pulls?per_page=1' >/dev/null 2>&1; then
        echo "      Pull requests: Working"
    else
        echo "      Pull requests: Failed"
    fi

    echo ""

    # Rate limit check
    echo "  Rate Limit Status:"
    local rate_limit
    if rate_limit=$(GH_TOKEN="$token_value" gh api rate_limit 2>/dev/null); then
        local remaining limit
        remaining=$(echo "$rate_limit" | jq -r '.core.remaining' 2>/dev/null || echo "$rate_limit" | grep -A 10 '"core"' | grep '"remaining"' | head -1 | grep -o '[0-9]*')
        limit=$(echo "$rate_limit" | jq -r '.core.limit' 2>/dev/null || echo "$rate_limit" | grep -A 10 '"core"' | grep '"limit"' | head -1 | grep -o '[0-9]*')
        echo "    API calls: $remaining/$limit remaining"
    else
        echo "    Rate limit: Cannot check"
    fi

    echo ""
    echo "----------------------------------------"
    echo ""
}

# Main execution
echo "Primary Token: AAR_TOKEN"
inspect_token_permissions "AAR_TOKEN"

if [ -n "${CI_ISSUE_AUTOMATION_TOKEN:-}" ]; then
    echo "Comparison Token: CI_ISSUE_AUTOMATION_TOKEN"
    inspect_token_permissions "CI_ISSUE_AUTOMATION_TOKEN"
fi

echo "Summary:"
echo "========"
echo "This inspection validates:"
echo "• Token type and authentication"
echo "• Specific API endpoints the AAR system requires"
echo "• Fine-Grained token repository access (when applicable)"
echo "• Rate limit status"
echo ""
echo "GitHub CLI Documentation Compliance:"
echo "• Uses correct /actions/workflows endpoint"
echo "• Uses correct /actions/runs endpoint"
echo "• Uses proper URL parameter syntax (?per_page=1)"
echo "• Avoids broken /actions root endpoint"
echo ""
echo "For Fine-Grained tokens experiencing delays:"
echo "• Repository API working = permissions configured correctly"
echo "• Actions/Issues API failing = normal propagation delay (2-5 minutes)"
