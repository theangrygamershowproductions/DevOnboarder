#!/bin/bash
# Fine-Grained Actions Permission Diagnostic
# Specifically tests Actions permission requirements for AAR system

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit
source .venv/bin/activate
source scripts/load_token_environment.sh > /dev/null 2>&1

echo "Fine-Grained Actions Permission Diagnostic"
echo "============================================="
echo ""
echo "Testing AAR_TOKEN Fine-Grained permissions..."
echo ""

if [ -z "$AAR_TOKEN" ]; then
    echo "ERROR: AAR_TOKEN not found"
    exit 1
fi

printf "Token format: %s...\n" "$(echo "$AAR_TOKEN" | cut -c1-25)"
echo ""

# Test all Actions endpoints needed by AAR system
test_actions_endpoint() {
    local endpoint="$1"
    local description="$2"
    local required_permission="$3"

    printf "Testing: %s\n" "$description"
    printf "   Endpoint: %s\n" "$endpoint"
    printf "   Required permission: %s\n" "$required_permission"

    if response=$(GH_TOKEN="$AAR_TOKEN" gh api "$endpoint" 2>&1); then
        if echo "$response" | grep -q -E '("total_count"|"workflow_runs"|"workflows"|"jobs")'; then
            echo "   SUCCESS: Endpoint accessible"
            return 0
        else
            echo "   FAILED: Unexpected response format"
            printf "   Response preview: %s\n" "$(echo "$response" | head -1 | cut -c1-100)"
            return 1
        fi
    else
        echo "   FAILED: Cannot access endpoint"
        # Parse the error message
        if echo "$response" | grep -q "Resource not accessible"; then
            echo "   Error: Resource not accessible by personal access token"
            printf "   NOTE: This suggests missing '%s' permission\n" "$required_permission"
        elif echo "$response" | grep -q "Bad credentials"; then
            echo "   Error: Authentication failed"
        elif echo "$response" | grep -q "Not Found"; then
            echo "   Error: Repository or resource not found"
        else
            printf "   Error: %s\n" "$(echo "$response" | head -1)"
        fi
        return 1
    fi
}

REPO="repos/theangrygamershowproductions/DevOnboarder"

echo "Testing AAR System Required Endpoints:"
echo "========================================="
echo ""

# Test each endpoint the AAR system needs
test_actions_endpoint "$REPO/actions" "Actions API Root" "Actions: Read"
test_actions_endpoint "$REPO/actions/workflows" "Workflows List" "Actions: Read"
test_actions_endpoint "$REPO/actions/runs" "Workflow Runs" "Actions: Read"

# Get the latest workflow run ID for more specific testing
echo "Getting latest workflow run for detailed testing..."
if latest_run=$(GH_TOKEN="$AAR_TOKEN" gh api "$REPO/actions/runs?per_page=1" 2>/dev/null | jq -r '.workflow_runs[0].id // empty' 2>/dev/null); then
    if [ -n "$latest_run" ]; then
        printf "   Latest run ID: %s\n" "$latest_run"
        echo ""
        test_actions_endpoint "$REPO/actions/runs/$latest_run" "Specific Workflow Run" "Actions: Read"
        test_actions_endpoint "$REPO/actions/runs/$latest_run/jobs" "Workflow Run Jobs" "Actions: Read"
        test_actions_endpoint "$REPO/actions/runs/$latest_run/logs" "Workflow Run Logs" "Actions: Read"
    else
        echo "   WARNING: No workflow runs found"
        echo ""
    fi
else
    echo "   ERROR: Cannot retrieve workflow runs for detailed testing"
    echo ""
fi

echo ""
echo "🔧 Fine-Grained Token Permission Analysis:"
echo "=========================================="
echo ""

# Check what permissions are actually needed
echo "Required Permissions for AAR System:"
echo "   • Actions: Read (minimum) - View workflow runs, jobs, logs"
echo "   • Actions: Write (preferred) - Create workflow dispatches if needed"
echo "   • Issues: Write - Create AAR issues"
echo "   • Repository: Read - Access repository metadata"
echo ""

echo "Troubleshooting Steps:"
echo "1. Go to: https://github.com/settings/personal-access-tokens/fine-grained"
echo "2. Find your AAR_TOKEN and click on it"
echo "3. Check 'Repository permissions' section:"
echo "   • Actions: Should be 'Read' or 'Read and write'"
echo "   • Issues: Should be 'Write'"
echo "   • Metadata: Should be 'Read'"
echo ""
echo "4. If permissions look correct:"
echo "   • Save the token settings (even without changes)"
echo "   • Wait 2-5 minutes for propagation"
echo "   • Re-run this test"
echo ""
echo "5. If still failing:"
echo "   • Try regenerating the token with the same permissions"
echo "   • Ensure the repository is selected in 'Repository access'"
