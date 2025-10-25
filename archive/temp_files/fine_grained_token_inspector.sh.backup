#!/bin/bash
# Fine-Grained Token Specific Inspector
# Designed specifically for GitHub Fine-Grained Personal Access Tokens

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit
# shellcheck disable=SC1091 # External dependency
source .venv/bin/activate
# shellcheck disable=SC1091 # External dependency
source scripts/load_token_environment.sh > /dev/null 2>&1

echo "Fine-Grained Token Inspector"
echo "==============================="
echo ""

inspect_fine_grained_token() {
    local token_name="$1"
    local token_value="${!token_name:-}"

    echo "Inspecting $token_name (Expected: Fine-Grained PAT)"
    echo "─────────────────────────────────────────────────"

    if [ -z "$token_value" ]; then
        echo "Token not found"
        return 1
    fi

    echo "Token prefix: ${token_value:0:25}..."
    echo "Token length: ${#token_value} characters"
    echo ""

    # Fine-Grained tokens start with github_pat_
    if [[ "$token_value" == github_pat_* ]]; then
        echo "Token format: Fine-Grained Personal Access Token"
    else
        echo "Token format: Not a Fine-Grained token (should start with 'github_pat_')"
        echo "   Your token starts with: ${token_value:0:15}..."
    fi

    echo ""
    echo "🔐 Authentication & Identity:"
    if user_response=$(GH_TOKEN="$token_value" gh api user 2>&1); then
        if echo "$user_response" | grep -q '"login"'; then
            username=$(echo "$user_response" | jq -r '.login' 2>/dev/null || echo "unknown")
            echo "   Authenticated as: $username"

            # Check if this is a user or organization context
            account_type=$(echo "$user_response" | jq -r '.type' 2>/dev/null || echo "User")
            echo "   Account type: $account_type"
        else
            echo "   Authentication failed"
            echo "   Error: $(echo "$user_response" | head -1)"
            return 1
        fi
    else
        echo "   Authentication failed - invalid token"
        return 1
    fi

    echo ""
    echo "Fine-Grained Token Installation Check:"

    # Fine-Grained tokens have installations
    if installation_response=$(GH_TOKEN="$token_value" gh api user/installations 2>&1); then
        if echo "$installation_response" | grep -q '"total_count"'; then
            total_count=$(echo "$installation_response" | jq -r '.total_count' 2>/dev/null || echo "0")
            echo "   Fine-Grained token installations: $total_count"

            if [ "$total_count" -gt 0 ]; then
                echo "   Installation details:"
                echo "$installation_response" | jq -r '.installations[] | "      - \(.account.login) (\(.account.type))"' 2>/dev/null || echo "      Unable to parse installation details"
            fi
        else
            echo "   No installations found"
            echo "   This might indicate a token configuration issue"
        fi
    else
        echo "   Cannot access installations endpoint"
        echo "   Error: $(echo "$installation_response" | head -1)"
        echo "   This suggests the token might not be Fine-Grained"
    fi

    echo ""
    echo "Repository Access Testing:"
    echo "   Testing specific repository: theangrygamershowproductions/DevOnboarder"

    # Test basic repository access
    echo ""
    echo "   🏠 Basic Repository Access:"
    if repo_response=$(GH_TOKEN="$token_value" gh api repos/theangrygamershowproductions/DevOnboarder 2>&1); then
        if echo "$repo_response" | grep -q '"full_name"'; then
            echo "      Repository metadata: Accessible"

            # Check permissions in the response
            if echo "$repo_response" | grep -q '"permissions"'; then
                echo "      Detected permissions in response:"
                echo "$repo_response" | jq -r '.permissions | to_entries[] | "         \(.key): \(.value)"' 2>/dev/null || echo "         Unable to parse permissions"
            fi
        else
            echo "      Repository metadata: Failed"
            echo "      Error: $(echo "$repo_response" | head -1)"
        fi
    else
        echo "      Repository access failed"
    fi

    # Test Actions API
    echo ""
    echo "   ⚡ Actions API Testing:"
    if actions_response=$(GH_TOKEN="$token_value" gh api repos/theangrygamershowproductions/DevOnboarder/actions 2>&1); then
        if echo "$actions_response" | grep -q '"total_count"'; then
            echo "      Actions API: Working"
        else
            echo "      Actions API: Failed"
            echo "      Response: $(echo "$actions_response" | head -1)"
        fi
    else
        echo "      Actions API: Failed to connect"
    fi

    # Test specific Actions endpoints
    echo "   • Workflows:"
    if GH_TOKEN="$token_value" gh api repos/theangrygamershowproductions/DevOnboarder/actions/workflows >/dev/null 2>&1; then
        echo "      Workflows: Accessible"
    else
        echo "      Workflows: Not accessible"
    fi

    echo "   • Workflow runs:"
    if GH_TOKEN="$token_value" gh api repos/theangrygamershowproductions/DevOnboarder/actions/runs >/dev/null 2>&1; then
        echo "      Workflow runs: Accessible"
    else
        echo "      Workflow runs: Not accessible"
    fi

    echo ""
}

# Inspect AAR_TOKEN
inspect_fine_grained_token "AAR_TOKEN"

echo ""
echo "Fine-Grained Token Troubleshooting:"
echo "==================================="
echo ""
echo "If your token is Fine-Grained but showing access issues:"
echo ""
echo "1. Check Repository Selection:"
echo "   • Go to: https://github.com/settings/personal-access-tokens/fine-grained"
echo "   • Find your token and click on it"
echo "   • Verify 'Repository access' includes 'theangrygamershowproductions/DevOnboarder'"
echo ""
echo "2. Check Repository Permissions:"
echo "   • Actions: Read and Write"
echo "   • Issues: Read and Write"
echo "   • Metadata: Read"
echo "   • Pull requests: Read and Write"
echo ""
echo "3. Consider Propagation Time:"
echo "   • Fine-Grained tokens can take 2-10 minutes for permissions to propagate"
echo "   • Organization repositories sometimes take longer"
echo ""
echo "4. 🔄 Try Regenerating:"
echo "   • If permissions look correct but still failing"
echo "   • Generate a new token with same permissions"
