#!/usr/bin/env bash
# Robust PR Health Assessment - Fixes terminal communication and JSON issues

# Centralized logging for troubleshooting and repository health
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

set -euo pipefail

PR_NUMBER="$1"
if [ $# -ne 1 ]; then
    echo "Usage: $0 <pr-number>" >&2
    exit 1
fi

echo "HEALTH: Robust PR Health Assessment #$PR_NUMBER"
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
echo "INFO: Retrieving PR information..."
if ! PR_INFO=$(execute_gh_command "pr view $PR_NUMBER --json number,title,state,mergeable"); then
    echo "ERROR: Failed to retrieve PR information"
    echo "STATS: Health Score: Cannot calculate (PR data unavailable)"
    exit 1
fi

echo "SUCCESS: PR Information Retrieved:"
echo "  Number: $(echo "$PR_INFO" | jq -r '.number // "unknown"')"
echo "  Title: $(echo "$PR_INFO" | jq -r '.title // "unknown"')"
echo "  State: $(echo "$PR_INFO" | jq -r '.state // "unknown"')"
echo ""

# Get check status with robust error handling
echo "INFO: Retrieving check status..."
if CHECK_INFO=$(execute_gh_command "pr checks $PR_NUMBER --json name,conclusion,status"); then
    echo "SUCCESS: Check information retrieved"
else
    echo "WARNING:  Using alternative check retrieval method..."
    # Alternative: Get from status checks if regular checks fail
    if CHECK_INFO=$(execute_gh_command "pr view $PR_NUMBER --json statusCheckRollup"); then
        # Transform statusCheckRollup to match expected format
        CHECK_INFO=$(echo "$CHECK_INFO" | jq '.statusCheckRollup | map({name: .name, conclusion: .conclusion, status: .status})')
        echo "SUCCESS: Check information retrieved via alternative method"
    else
        echo "ERROR: Cannot retrieve check information"
        echo "STATS: Health Score: Cannot calculate (check data unavailable)"
        exit 1
    fi
fi

# Calculate health score with proper error handling
if [ "$(echo "$CHECK_INFO" | jq length)" -eq 0 ]; then
    echo "WARNING:  No checks found"
    echo "STATS: Health Score: 0% (no checks available)"
    exit 0
fi

TOTAL_CHECKS=$(echo "$CHECK_INFO" | jq length)
SUCCESS_CHECKS=$(echo "$CHECK_INFO" | jq '[.[] | select(.conclusion == "success")] | length')
FAILURE_CHECKS=$(echo "$CHECK_INFO" | jq '[.[] | select(.conclusion == "failure")] | length')
PENDING_CHECKS=$(echo "$CHECK_INFO" | jq '[.[] | select(.conclusion == null or .conclusion == "" or .status == "in_progress")] | length')

echo "STATS: Check Summary:"
echo "  Total: $TOTAL_CHECKS"
echo "  SUCCESS: Success: $SUCCESS_CHECKS"
echo "  ERROR: Failed: $FAILURE_CHECKS"
echo "  ⏳ Pending: $PENDING_CHECKS"
echo ""

# Calculate health percentage
HEALTH_SCORE=$((SUCCESS_CHECKS * 100 / TOTAL_CHECKS))
echo "STATS: PR Health Score: ${HEALTH_SCORE}%"

# Health recommendations based on recalibrated standards
if [ "$HEALTH_SCORE" -ge 95 ]; then
    echo "COMPLETE: EXCELLENT: Meets 95% quality standard"
    echo "TARGET: Recommendation: Ready for merge"
elif [ "$HEALTH_SCORE" -ge 85 ]; then
    echo "SUCCESS: GOOD: Strong health score"
    echo "TARGET: Recommendation: Manual review recommended"
elif [ "$HEALTH_SCORE" -ge 70 ]; then
    echo "WARNING:  ACCEPTABLE: Functional but needs improvement"
    echo "TARGET: Recommendation: Targeted fixes required"
elif [ "$HEALTH_SCORE" -ge 50 ]; then
    echo "ERROR: POOR: Significant issues present"
    echo "TARGET: Recommendation: Major fixes required"
else
    echo "ALERT: FAILING: Critical failures present"
    echo "TARGET: Recommendation: Fresh start recommended"
fi

# Show failing checks if any
if [ "$FAILURE_CHECKS" -gt 0 ]; then
    echo ""
    echo "ERROR: Failing Checks:"
    echo "$CHECK_INFO" | jq -r '.[] | select(.conclusion == "failure") | "  - \(.name)"'
fi

echo ""
echo "SUCCESS: Robust health assessment complete"
