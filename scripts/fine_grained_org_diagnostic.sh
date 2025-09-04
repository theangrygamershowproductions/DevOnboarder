#!/bin/bash
# Fine-Grained Token Organization Permission Diagnostic
# Identifies and resolves organization-specific Fine-Grained token issues

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit
source .venv/bin/activate
source scripts/load_token_environment.sh > /dev/null 2>&1

echo "Fine-Grained Token Organization Diagnostic"
echo "============================================="
echo ""

if [ -z "$AAR_TOKEN" ]; then
    echo "ERROR: AAR_TOKEN not found"
    exit 1
fi

echo "Analyzing Fine-Grained token organization access..."
echo ""

# Basic token info
echo "Token Information:"
printf "   Format: %s...\n" "$(echo "$AAR_TOKEN" | cut -c1-25)"
printf "   Length: %d characters\n" "${#AAR_TOKEN}"
echo "   Type: Fine-Grained Personal Access Token"
echo ""

# User context
echo "Token Owner:"
if user_info=$(GH_TOKEN="$AAR_TOKEN" gh api user 2>/dev/null); then
    username=$(echo "$user_info" | jq -r '.login')
    printf "   Username: %s\n" "$username"
    printf "   Account type: %s\n" "$(echo "$user_info" | jq -r '.type')"
else
    echo "   Cannot determine token owner"
    exit 1
fi
echo ""

# Repository context
echo "Target Repository:"
echo "   Owner: theangrygamershowproductions"
echo "   Repository: DevOnboarder"
echo "   Context: Organization repository"
echo ""

# Organization info
echo "Organization Analysis:"
if org_info=$(GH_TOKEN="$AAR_TOKEN" gh api orgs/theangrygamershowproductions 2>/dev/null); then
    echo "   Organization accessible: theangrygamershowproductions"
    printf "   Name: %s\n" "$(echo "$org_info" | jq -r '.name')"
    printf "   Type: %s\n" "$(echo "$org_info" | jq -r '.type')"
    printf "   Public repos: %s\n" "$(echo "$org_info" | jq -r '.public_repos')"
else
    echo "   Organization not accessible"
    echo "   This might indicate a Fine-Grained token organization approval issue"
fi
echo ""

# Repository direct access
echo "📚 Repository Direct Access:"
if repo_info=$(GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder 2>/dev/null); then
    echo "   Repository metadata: Accessible"

    # Check if we can see permissions
    if echo "$repo_info" | jq -e '.permissions' >/dev/null 2>&1; then
        echo "   Repository permissions found:"
        echo "$repo_info" | jq -r '.permissions | to_entries[] | "      \(.key): \(.value)"'
    else
        echo "   Repository permissions: Not visible (may indicate limited access)"
    fi

    # Check repository owner
    owner_type=$(echo "$repo_info" | jq -r '.owner.type')
    echo "   Repository owner type: $owner_type"

    if [ "$owner_type" = "Organization" ]; then
        echo "   This is an organization repository - Fine-Grained tokens need special setup"
    fi
else
    echo "   Repository not accessible"
    echo "   This indicates a Fine-Grained token configuration issue"
fi
echo ""

# Test Actions API specifically
echo "⚡ Actions API Testing:"
echo "   Testing organization repository Actions access..."

# Try different Actions endpoints
test_endpoint() {
    local endpoint="$1"
    local description="$2"

    echo "   • $description:"
    if result=$(GH_TOKEN="$AAR_TOKEN" gh api "$endpoint" 2>&1); then
        if echo "$result" | grep -q -E '("total_count"|"workflow_runs"|"workflows")'; then
            echo "     Success"
            return 0
        else
            echo "     Unexpected response"
            return 1
        fi
    else
        # Analyze the error
        if echo "$result" | grep -q "Resource not accessible"; then
            echo "     Resource not accessible (permission issue)"
        elif echo "$result" | grep -q "Not Found"; then
            echo "     Not Found (may indicate organization approval needed)"
        elif echo "$result" | grep -q "Bad credentials"; then
            echo "     Authentication failed"
        else
            echo "     Error: $(echo "$result" | head -1 | cut -c1-50)..."
        fi
        return 1
    fi
}

test_endpoint "repos/theangrygamershowproductions/DevOnboarder/actions/workflows" "Workflows"
test_endpoint "repos/theangrygamershowproductions/DevOnboarder/actions/runs" "Workflow Runs"

echo ""
echo "🔧 Fine-Grained Token Organization Resolution:"
echo "=============================================="
echo ""
echo "IDENTIFIED ISSUE: Organization Repository + Fine-Grained Token"
echo ""
echo "Fine-Grained tokens have stricter access controls for organization repositories."
echo "Here's how to fix this:"
echo ""
echo "Step 1: Check Organization Approval"
echo "   1. Go to: https://github.com/settings/personal-access-tokens/fine-grained"
echo "   2. Find your AAR_TOKEN and click on it"
echo "   3. Look for 'Organization approval' section"
echo "   4. Check if 'theangrygamershowproductions' shows as 'Approved'"
echo ""
echo "Step 2: Request Organization Approval (if needed)"
echo "   1. In the token settings, under 'Repository access'"
echo "   2. Select 'Selected repositories'"
echo "   3. Choose 'theangrygamershowproductions/DevOnboarder'"
echo "   4. If prompted, request approval from organization owner"
echo ""
echo "Step 3: Verify Repository Permissions"
echo "   Required permissions for AAR system:"
echo "   • Actions: Read and write"
echo "   • Issues: Write"
echo "   • Metadata: Read"
echo "   • Pull requests: Write"
echo ""
echo "Step 4: Alternative Solution (if approval is challenging)"
echo "   Consider creating a Classic Personal Access Token instead:"
echo "   1. Go to: https://github.com/settings/tokens"
echo "   2. Generate new token (classic)"
echo "   3. Select scopes: repo, workflow"
echo "   4. Classic tokens don't require organization approval"
echo ""
echo "⏰ Step 5: Wait for Propagation"
echo "   After approval/changes: Wait 2-10 minutes for permissions to take effect"
echo ""
echo "Step 6: Re-test"
echo "   Run this diagnostic again to verify the fix"
