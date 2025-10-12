#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Robust PR Health Assessment - Fixes terminal communication and JSON issues

set -euo pipefail

PR_NUMBER="$1"
if [ $# -ne 1 ]; then
    echo "Usage: $0 <pr-number>" >&2
    exit 1
fi

echo "🏥 Robust PR Health Assessment #$PR_NUMBER"
echo "========================================"

# Robust GitHub CLI execution with explicit output handling
execute_gh_command() {
    local cmd="$1"
    local max_retries=3
    local retry=0

    while [ $retry -lt $max_retries ]; do
        if result=$(gh "$cmd" 2>&1); then
            echo "$result"
            return 0
        fi

        ((retry++))
        echo "GitHub CLI retry $retry/$max_retries..." >&2
        sleep 2
    done

    echo "GitHub CLI command failed: gh $cmd" >&2
    return 1
}

# Get PR basic information with error handling
check "Retrieving PR information..."
if ! PR_INFO=$(execute_gh_command "pr view $PR_NUMBER --json number,title,state,mergeable"); then
    error "Failed to retrieve PR information"
    report "Health Score: Cannot calculate (PR data unavailable)"
    exit 1
fi

success "PR Information Retrieved:"
echo "  Number: $(echo "$PR_INFO" | jq -r '.number // "unknown"')"
echo "  Title: $(echo "$PR_INFO" | jq -r '.title // "unknown"')"
echo "  State: $(echo "$PR_INFO" | jq -r '.state // "unknown"')"
echo ""

# Get check status with robust error handling
echo "🔍 Retrieving check status..."
if CHECK_INFO=$(execute_gh_command "pr checks $PR_NUMBER --json name,conclusion,status"); then
    success "Check information retrieved"
else
    warning " Using alternative check retrieval method..."
    # Alternative: Get from status checks if regular checks fail
    if CHECK_INFO=$(execute_gh_command "pr view $PR_NUMBER --json statusCheckRollup"); then
        # Transform statusCheckRollup to match expected format
        CHECK_INFO=$(echo "$CHECK_INFO" | jq '.statusCheckRollup | map({name: .name, conclusion: .conclusion, status: .status})')
        success "Check information retrieved via alternative method"
    else
        error "Cannot retrieve check information"
        report "Health Score: Cannot calculate (check data unavailable)"
        exit 1
    fi
fi

# Calculate health score with proper error handling
if [ "$(echo "$CHECK_INFO" | jq length)" -eq 0 ]; then
    warning " No checks found"
    report "Health Score: 0% (no checks available)"
    exit 0
fi

TOTAL_CHECKS=$(echo "$CHECK_INFO" | jq length)
SUCCESS_CHECKS=$(echo "$CHECK_INFO" | jq '[.[] | select(.conclusion == "success")] | length')
FAILURE_CHECKS=$(echo "$CHECK_INFO" | jq '[.[] | select(.conclusion == "failure")] | length')
PENDING_CHECKS=$(echo "$CHECK_INFO" | jq '[.[] | select(.conclusion == null or .conclusion == "" or .status == "in_progress")] | length')

report "Check Summary:"
echo "  Total: $TOTAL_CHECKS"
echo "  SUCCESS: Success: $SUCCESS_CHECKS"
echo "  ERROR: Failed: $FAILURE_CHECKS"
echo "  ⏳ Pending: $PENDING_CHECKS"
echo ""

# Calculate health percentage
HEALTH_SCORE=$((SUCCESS_CHECKS * 100 / TOTAL_CHECKS))
report "PR Health Score: ${HEALTH_SCORE}%"

# Health recommendations based on recalibrated standards
if [ "$HEALTH_SCORE" -ge 95 ]; then
    echo "🎉 EXCELLENT: Meets 95% quality standard"
    target "Recommendation: Ready for merge"
elif [ "$HEALTH_SCORE" -ge 85 ]; then
    success "GOOD: Strong health score"
    target "Recommendation: Manual review recommended"
elif [ "$HEALTH_SCORE" -ge 70 ]; then
    warning " ACCEPTABLE: Functional but needs improvement"
    target "Recommendation: Targeted fixes required"
elif [ "$HEALTH_SCORE" -ge 50 ]; then
    error "POOR: Significant issues present"
    target "Recommendation: Major fixes required"
else
    echo "🚨 FAILING: Critical failures present"
    target "Recommendation: Fresh start recommended"
fi

# Show failing checks if any
if [ "$FAILURE_CHECKS" -gt 0 ]; then
    echo ""
    error "Failing Checks:"
    echo "$CHECK_INFO" | jq -r '.[] | select(.conclusion == "failure") | "  - \(.name)"'
fi

echo ""
success "Robust health assessment complete"
