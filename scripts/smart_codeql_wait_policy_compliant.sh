#!/bin/bash

# Smart CodeQL Wait Script - Policy Compliant Version
# Uses DevOnboarder No Default Token Policy v1.0 compliant tokens
# No third-party actions needed - uses specialized CI_ISSUE_AUTOMATION_TOKEN

set -e

CHECK_TYPE="$1"  # "javascript-typescript" or "python"
COMMIT_SHA="$2"

if [ -z "$CHECK_TYPE" ] || [ -z "$COMMIT_SHA" ]; then
    echo "Usage: $0 <check-type> <commit-sha>"
    echo "Example: $0 javascript-typescript abc123"
    exit 1
fi

echo "Smart CodeQL Wait Script (Policy Compliant)"
echo "==========================================="
echo "Using CI_ISSUE_AUTOMATION_TOKEN (No Default Token Policy v1.0 compliant)"
echo "Waiting for CodeQL $CHECK_TYPE analysis on commit $COMMIT_SHA"

# Function to get available CodeQL checks using policy-compliant token
get_available_checks() {
    if ! json=$(curl -s -H "Authorization: token $CI_ISSUE_AUTOMATION_TOKEN" \
         -H "Accept: application/vnd.github+json" \
         "https://api.github.com/repos/theangrygamershowproductions/DevOnboarder/commits/$COMMIT_SHA/check-runs" 2>/dev/null); then
        echo "ERROR: Failed to fetch check runs using CI_ISSUE_AUTOMATION_TOKEN"
        return 1
    fi

    echo "$json" | jq -r '.check_runs[] | select(.name | contains("CodeQL")) | .name' || echo ""
}

# Function to check if a specific check exists and get its status
check_specific_check() {
    local check_name="$1"
    local json="$2"

    status=$(echo "$json" | jq -r --arg n "$check_name" '.check_runs[] | select(.name==$n) | .status // empty' | head -n1)
    conclusion=$(echo "$json" | jq -r --arg n "$check_name" '.check_runs[] | select(.name==$n) | .conclusion // empty' | head -n1)

    echo "$status|$conclusion"
}

# Get initial list of available checks
echo "Discovering available CodeQL checks..."
AVAILABLE_CHECKS=$(get_available_checks)

if [ -z "$AVAILABLE_CHECKS" ]; then
    echo "No CodeQL checks found yet. This might be normal if CodeQL analysis hasn't started."
    echo "Will retry..."
else
    echo "Available CodeQL checks:"
    echo "$AVAILABLE_CHECKS" | while read -r check; do
        echo "  - $check"
    done
fi

# Try different check name patterns
POSSIBLE_NAMES=(
    "CodeQL/Analyze ($CHECK_TYPE) (dynamic)"
    "CodeQL/Analyze ($CHECK_TYPE)"
    "CodeQL/Analyze ($CHECK_TYPE) (actions)"
    "CodeQL"
)

TARGET_CHECK=""
TARGET_STATUS=""

# Try to find a matching check
for check_name in "${POSSIBLE_NAMES[@]}"; do
    echo "Trying check name: $check_name"

    if ! json=$(curl -s -H "Authorization: token $CI_ISSUE_AUTOMATION_TOKEN" \
         -H "Accept: application/vnd.github+json" \
         "https://api.github.com/repos/theangrygamershowproductions/DevOnboarder/commits/$COMMIT_SHA/check-runs" 2>/dev/null); then
        echo "API call failed, will retry..."
        sleep 5
        continue
    fi

    result=$(check_specific_check "$check_name" "$json")
    status=$(echo "$result" | cut -d'|' -f1)
    conclusion=$(echo "$result" | cut -d'|' -f2)

    if [ -n "$status" ]; then
        echo "Found matching check: $check_name (status: $status)"
        TARGET_CHECK="$check_name"
        TARGET_STATUS="$status"
        TARGET_CONCLUSION="$conclusion"
        break
    fi
done

if [ -z "$TARGET_CHECK" ]; then
    echo "ERROR: No matching CodeQL check found for type: $CHECK_TYPE"
    echo "Tried names:"
    for name in "${POSSIBLE_NAMES[@]}"; do
        echo "  - $name"
    done
    echo ""
    echo "Available checks:"
    AVAILABLE_CHECKS=$(get_available_checks)
    if [ -n "$AVAILABLE_CHECKS" ]; then
        echo "$AVAILABLE_CHECKS" | while read -r check; do
            echo "  - $check"
        done
    else
        echo "  No checks available"
    fi
    exit 1
fi

echo "Monitoring check: $TARGET_CHECK"

# Wait for completion with progress updates
ITERATION=0
MAX_ITERATIONS=90  # 15 minutes with 10-second intervals

while [ "$TARGET_STATUS" != "completed" ] && [ $ITERATION -lt $MAX_ITERATIONS ]; do
    ITERATION=$((ITERATION + 1))

    if ! json=$(curl -s -H "Authorization: token $CI_ISSUE_AUTOMATION_TOKEN" \
         -H "Accept: application/vnd.github+json" \
         "https://api.github.com/repos/theangrygamershowproductions/DevOnboarder/commits/$COMMIT_SHA/check-runs" 2>/dev/null); then
        echo "API call failed, will retry..."
        sleep 10
        continue
    fi

    result=$(check_specific_check "$TARGET_CHECK" "$json")
    TARGET_STATUS=$(echo "$result" | cut -d'|' -f1)
    TARGET_CONCLUSION=$(echo "$result" | cut -d'|' -f2)

    if [ $((ITERATION % 6)) -eq 0 ]; then
        ELAPSED_MINUTES=$((ITERATION / 6))
        echo "Still waiting... ($ELAPSED_MINUTES minutes elapsed, check status: $TARGET_STATUS)"
    fi

    if [ "$TARGET_STATUS" != "completed" ]; then
        sleep 10
    fi
done

# Final result
if [ "$TARGET_STATUS" = "completed" ]; then
    echo "SUCCESS: CodeQL $CHECK_TYPE analysis completed with conclusion: $TARGET_CONCLUSION"

    if [ "$TARGET_CONCLUSION" = "success" ] || [ "$TARGET_CONCLUSION" = "neutral" ]; then
        echo "Check passed - proceeding with CI pipeline"
        exit 0
    else
        echo "Check failed with conclusion: $TARGET_CONCLUSION"
        exit 1
    fi
else
    echo "TIMEOUT: CodeQL $CHECK_TYPE analysis did not complete within 15 minutes"
    echo "This might indicate an issue with the CodeQL analysis job"
    exit 1
fi
