#!/usr/bin/env bash
# Monitor external PR welcome system in production
# POTATO APPROVAL: monitor-external-pr-20251002

set -euo pipefail

echo " External PR Welcome System - Production Monitoring"
echo "===================================================="

# Check recent external PRs to see if any have been processed
echo "Checking recent external PRs..."

# Get list of recent PRs from forks
EXTERNAL_PRS=$(gh pr list --state all --limit 10 --json number,headRepository,createdAt,author --jq '.[] | select(.headRepository.owner.login != "theangrygamershowproductions") | {number: .number, author: .author.login, created: .createdAt, repo: .headRepository.owner.login}')

if [ -n "$EXTERNAL_PRS" ]; then
    echo "Recent external PRs found:"
    echo "$EXTERNAL_PRS"

    echo ""
    echo " Checking for welcome comments..."

    # Check each external PR for welcome comments
    gh pr list --state all --limit 5 --json number | jq -r '.[].number' | while read -r pr_number; do
        if gh pr view "$pr_number" --json comments --jq '.comments[].body' | grep -q "External PR Security Notice"; then
            echo " PR #$pr_number has welcome comment"
        else
            echo "ℹ️  PR #$pr_number - no welcome comment (may be from same contributor or internal)"
        fi
    done
else
    echo "ℹ️  No recent external PRs found to test against"
fi

echo ""
echo "TARGET: Monitoring Setup:"
echo "===================================="
echo "Option 1: Active monitoring - check workflow runs for 'Welcome external contributors' job"
echo "Option 2: Create test PR from fork account to validate"
echo "Option 3: Set up GitHub webhook to monitor welcome comment creation"

echo ""
echo " Workflow Run Monitoring:"
gh run list --workflow=pr-automation.yml --limit 5 --json displayTitle,conclusion,createdAt

echo ""
echo " Recommendation:"
echo "1. Monitor next 2-3 external PRs closely"
echo "2. Check workflow runs for any failures"
echo "3. Validate welcome messages appear correctly"
echo "4. Have rollback plan ready if issues detected"
