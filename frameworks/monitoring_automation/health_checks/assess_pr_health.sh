#!/usr/bin/env bash
# PR Health Assessment Agent
# Analyzes PR status and provides recommendations for next actions

set -euo pipefail

PR_NUMBER="$1"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <pr-number>" >&2
    exit 1
fi

echo "INFO: PR Health Assessment for #$PR_NUMBER"
echo "=================================="

# Get PR details
PR_DATA=$(gh pr view "$PR_NUMBER" --json state,mergeable,statusCheckRollup,commits,changedFiles,additions,deletions,title,body)

# Extract key metrics
STATE=$(echo "$PR_DATA" | jq -r '.state')
MERGEABLE=$(echo "$PR_DATA" | jq -r '.mergeable')
COMMIT_COUNT=$(echo "$PR_DATA" | jq '.commits | length')
CHANGED_FILES=$(echo "$PR_DATA" | jq '.changedFiles')
ADDITIONS=$(echo "$PR_DATA" | jq '.additions')
DELETIONS=$(echo "$PR_DATA" | jq '.deletions')
TITLE=$(echo "$PR_DATA" | jq -r '.title')

# Analyze status checks
FAILING_CHECKS=$(echo "$PR_DATA" | jq -r '[.statusCheckRollup[] | select(.conclusion == "FAILURE") | .name] | join(", ")')
PASSING_CHECKS=$(echo "$PR_DATA" | jq -r '[.statusCheckRollup[] | select(.conclusion == "SUCCESS") | .name] | join(", ")')
TOTAL_CHECKS=$(echo "$PR_DATA" | jq '.statusCheckRollup | length')
FAILED_COUNT=$(echo "$PR_DATA" | jq '[.statusCheckRollup[] | select(.conclusion == "FAILURE")] | length')
PASSED_COUNT=$(echo "$PR_DATA" | jq '[.statusCheckRollup[] | select(.conclusion == "SUCCESS")] | length')

echo "STATS: PR Metrics:"
echo "  Title: $TITLE"
echo "  State: $STATE"
echo "  Mergeable: $MERGEABLE"
echo "  Commits: $COMMIT_COUNT"
echo "  Changed Files: $CHANGED_FILES"
echo "  Lines Added: +$ADDITIONS"
echo "  Lines Deleted: -$DELETIONS"
echo

echo "TEST: CI Health:"
echo "  Total Checks: $TOTAL_CHECKS"
echo "  Passing: $PASSED_COUNT"
echo "  Failing: $FAILED_COUNT"
echo

if [ "$FAILED_COUNT" -gt 0 ]; then
    echo "ERROR: Failing Checks: $FAILING_CHECKS"
fi

if [ "$PASSED_COUNT" -gt 0 ]; then
    echo "SUCCESS: Passing Checks: $PASSING_CHECKS"
fi

echo

# Calculate health score
if [ "$TOTAL_CHECKS" -gt 0 ]; then
    HEALTH_PERCENTAGE=$((PASSED_COUNT * 100 / TOTAL_CHECKS))
else
    HEALTH_PERCENTAGE=0
fi

echo "HEALTH: PR Health Score: $HEALTH_PERCENTAGE%"

# Provide recommendations
echo
echo "TARGET: Recommendations:"

if [ "$HEALTH_PERCENTAGE" -ge 80 ]; then
    echo "  SUCCESS: HIGH HEALTH: PR is in good shape, consider proceeding with merge"
    if [ "$FAILED_COUNT" -gt 0 ]; then
        echo "  TOOL: Minor fixes needed for remaining $FAILED_COUNT failing checks"
    fi
elif [ "$HEALTH_PERCENTAGE" -ge 50 ]; then
    echo "  WARNING:  MEDIUM HEALTH: PR has significant value but needs attention"
    echo "  🤔 Consider: Is core objective achieved? If yes, prepare for merge"
    echo "  TOOL: Address critical failures, consider new PR for complex issues"
elif [ "$HEALTH_PERCENTAGE" -ge 20 ]; then
    echo "  WARNING:  LOW HEALTH: Major issues present"
    echo "  RELOAD: Recommendation: Fresh start with new PR might be more efficient"
    echo "  SAVE: Preserve valuable work from this PR for reuse"
else
    echo "  ERROR: CRITICAL: Extensive failures detected"
    echo "  🆕 STRONG RECOMMENDATION: Start fresh with new PR"
    echo "  INFO: Extract lessons learned and valuable code changes"
fi

# Check for scope indicators
if [ "$COMMIT_COUNT" -gt 10 ]; then
    echo "  TREND: HIGH COMMIT COUNT: Consider breaking into smaller PRs"
fi

if [ "$CHANGED_FILES" -gt 20 ]; then
    echo "  FOLDER: LARGE SCOPE: Many files changed, complex review required"
fi

if [ "$ADDITIONS" -gt 1000 ]; then
    echo "  STATS: LARGE CHANGESET: Significant code additions, careful review needed"
fi

echo
echo "🤖 Automated Assessment Complete"
