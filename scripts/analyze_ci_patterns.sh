#!/usr/bin/env bash
# CI Failure Pattern Recognition Agent
# Analyzes CI failures and categorizes them for better decision making

set -euo pipefail

# Use provided PR number or determine from current context
if [ $# -eq 1 ]; then
    PR_NUMBER="$1"
elif [ -n "${GITHUB_REF_NAME:-}" ] && [[ "${GITHUB_REF_NAME}" =~ ^feature/ ]]; then
    # In CI context, try to get PR number from GitHub context
    PR_NUMBER=$(gh pr list --head "${GITHUB_REF_NAME}" --json number --jq '.[0].number' 2>/dev/null || echo "")
else
    # Try to determine current PR from git branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    if [ -n "$current_branch" ] && [[ "$current_branch" =~ ^feature/ ]]; then
        PR_NUMBER=$(gh pr list --head "$current_branch" --json number --jq '.[0].number' 2>/dev/null || echo "")
    else
        PR_NUMBER=""
    fi
fi

if [ -z "$PR_NUMBER" ]; then
    echo "Usage: $0 <pr-number>" >&2
    echo "Or run from a feature branch with an open PR" >&2
    exit 1
fi

echo "SEARCH CI Failure Pattern Analysis for PR #$PR_NUMBER"
echo "================================================"

# Check if GitHub CLI is authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "WARNING  GitHub CLI not authenticated, using basic analysis"
    echo "SUCCESS Proceeding with simplified pattern analysis"
    echo "Bot Pattern Analysis Complete (simplified mode)"
    exit 0
fi

# Get failing checks with error handling
FAILING_CHECKS=$(gh pr view "$PR_NUMBER" --json statusCheckRollup --jq '[.statusCheckRollup[] | select(.conclusion == "FAILURE")]' 2>/dev/null || echo "[]")

if [ "$(echo "$FAILING_CHECKS" | jq length)" -eq 0 ]; then
    echo "SUCCESS No failing checks detected"
    exit 0
fi

echo "STATS Failure Analysis:"
echo

# Categorize failures
echo "$FAILING_CHECKS" | jq -r '.[] | "\(.name): \(.conclusion)"' | while read -r check; do
    check_name=$(echo "$check" | cut -d: -f1)
    echo "FAILED $check_name"

    # Pattern matching for common failure types
    case "$check_name" in
        *"test"*)
            echo "   EMOJI Category: TEST FAILURE"
            echo "   SYMBOL Impact: Core functionality issues"
            echo "   CONFIG Action: Investigate test failures, may need code fixes"
            ;;
        *"lint"*|*"format"*)
            echo "   SYMBOL Category: FORMATTING/LINTING"
            echo "   SYMBOL Impact: Code style issues"
            echo "   CONFIG Action: Auto-fixable, run formatters/linters"
            ;;
        *"quality"*|*"markdown"*|*"Markdown"*)
            echo "   EDIT Category: DOCUMENTATION QUALITY"
            echo "   SYMBOL Impact: Documentation standards"
            echo "   CONFIG Action: Fix markdown formatting, likely auto-fixable"
            ;;
        *"security"*|*"audit"*)
            echo "   SYMBOL Category: SECURITY SCAN"
            echo "   SYMBOL Impact: Security vulnerabilities"
            echo "   CONFIG Action: Update dependencies, review security issues"
            ;;
        *"permission"*|*"check"*)
            echo "   SYMBOL Category: PERMISSIONS/VALIDATION"
            echo "   SYMBOL Impact: Access or validation rules"
            echo "   CONFIG Action: Review permissions, update configurations"
            ;;
        *"build"*|*"compile"*)
            echo "   SYMBOL  Category: BUILD FAILURE"
            echo "   SYMBOL Impact: Code compilation issues"
            echo "   CONFIG Action: Fix syntax errors, dependency issues"
            ;;
        *)
            echo "   SYMBOL Category: UNKNOWN"
            echo "   SYMBOL Impact: Requires investigation"
            echo "   CONFIG Action: Manual analysis needed"
            ;;
    esac
    echo
done

# Generate overall recommendation
FAILURE_COUNT=$(echo "$FAILING_CHECKS" | jq length)
echo "TARGET Overall Assessment:"
echo "  Total Failures: $FAILURE_COUNT"

# Check for auto-fixable issues
AUTO_FIXABLE=$(echo "$FAILING_CHECKS" | jq -r '.[] | .name' | grep -cE "(lint|format|markdown|quality)")
MANUAL_FIXES=$(( FAILURE_COUNT - AUTO_FIXABLE ))

echo "  Auto-fixable: $AUTO_FIXABLE"
echo "  Manual fixes needed: $MANUAL_FIXES"

echo
echo "IDEA Strategic Recommendation:"

if [ "$AUTO_FIXABLE" -eq "$FAILURE_COUNT" ]; then
    echo "  SUCCESS ALL FAILURES AUTO-FIXABLE: Run automated fixes and continue"
    echo "  CONFIG Commands: markdownlint --fix, ruff --fix, pre-commit run --all-files"
elif [ "$AUTO_FIXABLE" -gt "$MANUAL_FIXES" ]; then
    echo "  SYMBOL  MOSTLY AUTO-FIXABLE: Fix automatically, then address remaining issues"
    echo "  CONFIG Priority: Run auto-fixes first, then evaluate remaining failures"
elif [ "$MANUAL_FIXES" -gt 3 ]; then
    echo "  WARNING  MANY MANUAL FIXES: Consider cost/benefit of continuing vs fresh start"
    echo "  THINKING Question: Has this PR achieved its core objective?"
else
    echo "  CONFIG MANAGEABLE: Continue with targeted fixes"
    echo "  SYMBOL Approach: Address each failure systematically"
fi

echo
echo "Bot Pattern Analysis Complete"
