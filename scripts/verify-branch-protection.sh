#!/usr/bin/env bash
# Verify Branch Protection - Compares current server config vs protection.json
set -euo pipefail

OWNER=${OWNER:-theangrygamershowproductions}
REPO=${REPO:-DevOnboarder}

echo "===== Verify Branch Protection Against Server State ====="
echo "Repository: $OWNER/$REPO"
echo "Branch: main"

# Check for jq availability
if ! command -v jq >/dev/null 2>&1; then
    echo "::error::jq is required for this script"
    echo "Install with: sudo apt-get install jq"
    exit 2
fi

# Check if protection.json exists
if [[ ! -f "protection.json" ]]; then
    echo "::error::protection.json not found in current directory"
    exit 1
fi

echo "Fetching live branch protection from GitHub..."
live=$(gh api -H "Accept: application/vnd.github+json" "repos/$OWNER/$REPO/branches/main/protection")

if [[ -z "$live" ]]; then
    echo "::error::Failed to fetch branch protection from GitHub"
    exit 1
fi

echo "Comparing required status check contexts..."

# Compare contexts (most critical check)
live_ctx=$(echo "$live" | jq -r '.required_status_checks.contexts[]' | sort -u)
file_ctx=$(jq -r '.required_status_checks.contexts[]' protection.json | sort -u)

# Create temporary files for diff
temp_live=$(mktemp)
temp_file=$(mktemp)
echo "$live_ctx" > "$temp_live"
echo "$file_ctx" > "$temp_file"

diff_out=$(diff -u "$temp_file" "$temp_live" || true)
rm -f "$temp_live" "$temp_file"

if [[ -n "$diff_out" ]]; then
    echo "::error::Branch protection contexts drifted:"
    echo "--- protection.json (expected)"
    echo "+++ GitHub server (actual)"
    echo "$diff_out"
    echo ""
    echo "To fix this drift:"
    echo "1. Update protection.json with current server state, OR"
    echo "2. Re-apply protection.json to server with: ./apply-branch-protection.sh"
    exit 1
fi

echo "✅ Required status check contexts match"

# Compare core boolean toggles
echo "Comparing core protection settings..."

declare -A PATHS=(
    [".required_status_checks.strict"]="Require branches to be up to date"
    [".enforce_admins"]="Enforce admin restrictions"
    [".required_pull_request_reviews.required_approving_review_count"]="Required approving reviews"
    [".required_pull_request_reviews.dismiss_stale_reviews"]="Dismiss stale reviews"
    [".required_conversation_resolution"]="Require conversation resolution"
    [".required_linear_history"]="Require linear history"
)

drift_found=false

for path in "${!PATHS[@]}"; do
    description="${PATHS[$path]}"
    live_v=$(echo "$live" | jq -r "$path // empty")
    file_v=$(jq -r "$path // empty" protection.json)

    # Handle nested .enabled structure in live data for certain fields
    if [[ "$path" == ".enforce_admins" || "$path" == ".required_conversation_resolution" || "$path" == ".required_signatures" ]]; then
        # These fields return {enabled: boolean} from server, but are stored as boolean in file
        live_enabled=$(echo "$live" | jq -r "${path}.enabled // empty")

        if [[ "$live_enabled" != "$file_v" && "$live_enabled" != "" && "$file_v" != "" ]]; then
            echo "::error::Drift in $description"
            echo "  Path: $path"
            echo "  Server enabled: $live_enabled"
            echo "  File: $file_v"
            drift_found=true
        elif [[ "$file_v" != "" ]]; then
            echo "✅ $description: $file_v"
        fi
    else
        # Regular comparison for other fields
        if [[ "$live_v" != "$file_v" && "$live_v" != "" && "$file_v" != "" ]]; then
            echo "::error::Drift in $description"
            echo "  Path: $path"
            echo "  Server: $live_v"
            echo "  File: $file_v"
            drift_found=true
        elif [[ "$file_v" != "" ]]; then
            echo "✅ $description: $file_v"
        fi
    fi
done

if [[ "$drift_found" == "true" ]]; then
    echo ""
    echo "::error::Branch protection configuration has drifted"
    echo "Server state differs from protection.json"
    echo ""
    echo "To resolve:"
    echo "1. Review the differences above"
    echo "2. Update protection.json to match desired state"
    echo "3. Re-apply with: ./apply-branch-protection.sh"
    exit 1
fi

echo ""
echo "✅ Branch protection matches protection.json"
echo "Server configuration is consistent with local file"

# Additional validation: check that all required checks are reasonable
echo ""
echo "Additional validation checks..."

ctx_count=$(echo "$file_ctx" | wc -l | tr -d ' ')
echo "✅ Total required checks: $ctx_count"

if [[ $ctx_count -gt 20 ]]; then
    echo "⚠ Warning: Very high number of required checks ($ctx_count)"
    echo "Consider if all checks are truly necessary for merge blocking"
fi

if [[ $ctx_count -lt 5 ]]; then
    echo "⚠ Warning: Very few required checks ($ctx_count)"
    echo "Consider if additional quality gates are needed"
fi

echo "✅ Branch protection verification completed successfully"
