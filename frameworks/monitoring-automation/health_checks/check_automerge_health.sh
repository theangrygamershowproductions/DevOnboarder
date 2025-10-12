#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Check for automerge hanging issues
# Usage: bash scripts/check_automerge_health.sh

# Centralized logging for troubleshooting and repository health
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

set -euo pipefail

# Color output functions
red() { printf "\033[31m%s\033[0m\n" "$1"; }
green() { printf "\033[32m%s\033[0m\n" "$1"; }
yellow() { printf "\033[33m%s\033[0m\n" "$1"; }
blue() { printf "\033[34m%s\033[0m\n" "$1"; }

blue "DevOnboarder Automerge Health Check"
echo "========================================"

# Get repository info
if ! REPO_FULL=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name'); then
    red "error "Could not get repository information"
    echo "Make sure you're in a git repository and have GitHub CLI access"
    exit 1
fi

printf "Repository: "
blue "$REPO_FULL"
echo ""

# Check 1: Repository default branch
blue "1. Checking repository default branch..."
DEFAULT_BRANCH=$(gh api "repos/$REPO_FULL" --jq '.default_branch')
if [ "$DEFAULT_BRANCH" = "main" ]; then
    green "PASS: Default branch: $DEFAULT_BRANCH"
else
    yellow "Default branch is '$DEFAULT_BRANCH', expected 'main'"
    echo "   Fix: gh api repos/$REPO_FULL -X PATCH --field default_branch=main"
fi
echo ""

# Check 2: Auto-merge enabled for repository
blue "2. Checking repository auto-merge settings..."
AUTO_MERGE_ALLOWED=$(gh api "repos/$REPO_FULL" --jq '.allow_auto_merge')
if [ "$AUTO_MERGE_ALLOWED" = "true" ]; then
    green "PASS: Auto-merge allowed: $AUTO_MERGE_ALLOWED"
else
    yellow "Auto-merge not allowed at repository level"
    echo "   Repository settings may prevent automerge functionality"
fi
echo ""

# Check 3: Branch protection rules
blue "3. Checking branch protection rules..."
if PROTECTION_RULES=$(gh api "repos/$REPO_FULL/branches/main/protection" 2>/dev/null); then
    REQUIRED_CHECKS=$(echo "$PROTECTION_RULES" | jq -r '.required_status_checks.contexts[]?' | wc -l)
    if [ "$REQUIRED_CHECKS" -gt 0 ]; then
        green "PASS: Branch protection active with $REQUIRED_CHECKS required checks"

        # Show required check names
        echo "   Required status checks:"
        echo "$PROTECTION_RULES" | jq -r '.required_status_checks.contexts[]?' | sed 's/^/     - /'
    else
        yellow "No required status checks configured"
    fi
else
    yellow "No branch protection rules found for main branch"
fi
echo ""

# Check 4: Open PRs with potential hanging issues
blue "4. Scanning open PRs for automerge issues..."
HANGING_PRS=0

if OPEN_PRS=$(gh pr list --state open --json number,headRefOid,autoMergeRequest 2>/dev/null); then
    PR_COUNT=$(echo "$OPEN_PRS" | jq '. | length')

    if [ "$PR_COUNT" -eq 0 ]; then
        echo "   No open PRs found"
    else
        echo "   Checking $PR_COUNT open PR(s)..."

        while read -r pr; do
            PR_NUMBER=$(echo "$pr" | jq -r '.number')
            HEAD_SHA=$(echo "$pr" | jq -r '.headRefOid')
            AUTO_MERGE_ENABLED=$(echo "$pr" | jq -r '.autoMergeRequest != null')

            # Check commit status for this PR
            if COMMIT_STATUS=$(gh api "repos/$REPO_FULL/commits/$HEAD_SHA/status" 2>/dev/null); then
                OVERALL_STATE=$(echo "$COMMIT_STATUS" | jq -r '.state')

                # Check if PR has completed check runs
                if PR_CHECKS=$(gh pr view "$PR_NUMBER" --json statusCheckRollup 2>/dev/null); then
                    COMPLETED_SUCCESSFUL_CHECKS=$(echo "$PR_CHECKS" | jq '[.statusCheckRollup[] | select(.status == "COMPLETED" and .conclusion == "SUCCESS")] | length')

                    # Potential hanging condition: automerge enabled, pending status, but completed checks
                    if [ "$AUTO_MERGE_ENABLED" = "true" ] && [ "$OVERALL_STATE" = "pending" ] && [ "$COMPLETED_SUCCESSFUL_CHECKS" -gt 0 ]; then
                        red "URGENT: POTENTIAL HANGING: PR #$PR_NUMBER"
                        echo "     - Automerge: enabled"
                        echo "     - Overall status: $OVERALL_STATE (concerning)"
                        echo "     - Completed successful checks: $COMPLETED_SUCCESSFUL_CHECKS"
                        echo "     - Recommendation: Check status check name alignment"
                        HANGING_PRS=$((HANGING_PRS + 1))
                    elif [ "$AUTO_MERGE_ENABLED" = "true" ]; then
                        green "   PASS: PR #$PR_NUMBER: Automerge enabled, status: $OVERALL_STATE"
                    fi
                fi
            fi
        done < <(echo "$OPEN_PRS" | jq -c '.[]')
    fi
else
    yellow "Could not fetch open PRs"
fi
echo ""

# Check 5: Recent workflow failures that might indicate status check issues
blue "5. Checking recent workflow health..."
if RECENT_RUNS=$(gh run list --limit 5 --json status,conclusion,workflowName 2>/dev/null); then
    FAILED_RUNS=$(echo "$RECENT_RUNS" | jq '[.[] | select(.conclusion == "failure")] | length')

    if [ "$FAILED_RUNS" -eq 0 ]; then
        green "PASS: Recent workflow runs look healthy (no failures in last 5)"
    else
        yellow "$FAILED_RUNS workflow failures in recent runs"
        echo "   Failed workflows might affect status check reporting"
    fi
else
    yellow "Could not check recent workflow runs"
fi
echo ""

# Summary
blue "SUMMARY: Health Check Summary"
echo "======================="

if [ "$HANGING_PRS" -eq 0 ]; then
    green "PASS: No automerge hanging issues detected"
    echo ""
    blue "FIXES:  Quick fixes for common issues:"
    echo "   - Default branch issue: gh api repos/$REPO_FULL -X PATCH --field default_branch=main"
    echo "   - Status check alignment: See docs/troubleshooting/AUTOMERGE_HANGING_INDEFINITELY.md"
else
    red "URGENT: ALERT: $HANGING_PRS PR(s) potentially affected by automerge hanging"
    echo ""
    blue "URGENT: Immediate actions:"
    echo "   1. Check default branch: gh api repos/$REPO_FULL --jq '.default_branch'"
    echo "   2. Verify status check names: see troubleshooting guide"
    echo "   3. Review: docs/troubleshooting/AUTOMERGE_HANGING_INDEFINITELY.md"
fi

echo ""
blue "docs "Documentation:"
echo "   - Full troubleshooting guide: docs/troubleshooting/AUTOMERGE_HANGING_INDEFINITELY.md"
echo "   - Repository setup: docs/standards/REPOSITORY_SETUP.md"
echo ""
printf "Last checked: %s\n" "$(date)"
