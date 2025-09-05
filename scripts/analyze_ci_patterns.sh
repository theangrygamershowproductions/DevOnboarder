#!/usr/bin/env bash
# CI Failure Pattern Recognition Agent
# Analyzes CI failures and categorizes them for better decision making

set -euo pipefail

# Load tokens using Token Architecture v2.1 with developer guidance
if [ -f "scripts/enhanced_token_loader.sh" ]; then
    # shellcheck source=scripts/enhanced_token_loader.sh disable=SC1091
    source scripts/enhanced_token_loader.sh
elif [ -f "scripts/load_token_environment.sh" ]; then
    # shellcheck source=scripts/load_token_environment.sh disable=SC1091
    source scripts/load_token_environment.sh
fi

# Legacy fallback for development
if [ -f .env ]; then
    # shellcheck source=.env disable=SC1091
    source .env
fi

# Check for required tokens with enhanced guidance
if command -v require_tokens >/dev/null 2>&1; then
    if ! require_tokens "AAR_TOKEN"; then
        echo "❌ Cannot proceed without required tokens for CI pattern analysis"
        echo "💡 CI pattern analysis requires GitHub API access for PR and workflow data"
        exit 1
    fi
fi

# Use provided PR number or determine from current context
if [ $# -eq 1 ]; then
    PR_NUMBER="$1"
elif [ -n "${GITHUB_REF_NAME:-}" ] && [[ "${GITHUB_REF_NAME}" =~ ^feature/ ]]; then
    # In CI context, try to get PR number from GitHub context
    PR_NUMBER=$(GH_TOKEN="${AAR_TOKEN:-}" gh pr list --head "${GITHUB_REF_NAME}" --json number --jq '.[0].number' 2>/dev/null || echo "")
else
    # Try to determine current PR from git branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    if [ -n "$current_branch" ] && [[ "$current_branch" =~ ^feature/ ]]; then
        PR_NUMBER=$(GH_TOKEN="${AAR_TOKEN:-}" gh pr list --head "$current_branch" --json number --jq '.[0].number' 2>/dev/null || echo "")
    else
        PR_NUMBER=""
    fi
fi

if [ -z "$PR_NUMBER" ]; then
    echo "Usage: $0 <pr-number>" >&2
    echo "Or run from a feature branch with an open PR" >&2
    exit 1
fi

echo "🔍 CI Failure Pattern Analysis for PR #$PR_NUMBER"
echo "================================================"

# Check if GitHub CLI is authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "⚠️  GitHub CLI not authenticated, using basic analysis"
    echo "✅ Proceeding with simplified pattern analysis"
    echo "🤖 Pattern Analysis Complete (simplified mode)"
    exit 0
fi

# Get failing checks with error handling
FAILING_CHECKS=$(gh pr view "$PR_NUMBER" --json statusCheckRollup --jq '[.statusCheckRollup[] | select(.conclusion == "FAILURE")]' 2>/dev/null || echo "[]")

if [ "$(echo "$FAILING_CHECKS" | jq length)" -eq 0 ]; then
    echo "✅ No failing checks detected"
    exit 0
fi

echo "📊 Failure Analysis:"
echo

# Categorize failures
echo "$FAILING_CHECKS" | jq -r '.[] | "\(.name): \(.conclusion)"' | while read -r check; do
    check_name=$(echo "$check" | cut -d: -f1)
    echo "❌ $check_name"

    # Pattern matching for common failure types
    case "$check_name" in
        *"test"*)
            echo "   🧪 Category: TEST FAILURE"
            echo "   📋 Impact: Core functionality issues"
            echo "   🔧 Action: Investigate test failures, may need code fixes"
            ;;
        *"lint"*|*"format"*)
            echo "   🎨 Category: FORMATTING/LINTING"
            echo "   📋 Impact: Code style issues"
            echo "   🔧 Action: Auto-fixable, run formatters/linters"
            ;;
        *"quality"*|*"markdown"*|*"Markdown"*)
            echo "   📝 Category: DOCUMENTATION QUALITY"
            echo "   📋 Impact: Documentation standards"
            echo "   🔧 Action: Fix markdown formatting, likely auto-fixable"
            ;;
        *"security"*|*"audit"*)
            echo "   🔒 Category: SECURITY SCAN"
            echo "   📋 Impact: Security vulnerabilities"
            echo "   🔧 Action: Update dependencies, review security issues"
            ;;
        *"permission"*|*"check"*)
            echo "   🔑 Category: PERMISSIONS/VALIDATION"
            echo "   📋 Impact: Access or validation rules"
            echo "   🔧 Action: Review permissions, update configurations"
            ;;
        *"build"*|*"compile"*)
            echo "   🏗️  Category: BUILD FAILURE"
            echo "   📋 Impact: Code compilation issues"
            echo "   🔧 Action: Fix syntax errors, dependency issues"
            ;;
        *)
            echo "   ❓ Category: UNKNOWN"
            echo "   📋 Impact: Requires investigation"
            echo "   🔧 Action: Manual analysis needed"
            ;;
    esac
    echo
done

# Generate overall recommendation
FAILURE_COUNT=$(echo "$FAILING_CHECKS" | jq length)
echo "🎯 Overall Assessment:"
echo "  Total Failures: $FAILURE_COUNT"

# Check for auto-fixable issues
AUTO_FIXABLE=$(echo "$FAILING_CHECKS" | jq -r '.[] | .name' | grep -cE "(lint|format|markdown|quality)")
MANUAL_FIXES=$(( FAILURE_COUNT - AUTO_FIXABLE ))

echo "  Auto-fixable: $AUTO_FIXABLE"
echo "  Manual fixes needed: $MANUAL_FIXES"

echo
echo "💡 Strategic Recommendation:"

if [ "$AUTO_FIXABLE" -eq "$FAILURE_COUNT" ]; then
    echo "  ✅ ALL FAILURES AUTO-FIXABLE: Run automated fixes and continue"
    echo "  🔧 Commands: markdownlint --fix, ruff --fix, pre-commit run --all-files"
elif [ "$AUTO_FIXABLE" -gt "$MANUAL_FIXES" ]; then
    echo "  ⚖️  MOSTLY AUTO-FIXABLE: Fix automatically, then address remaining issues"
    echo "  🔧 Priority: Run auto-fixes first, then evaluate remaining failures"
elif [ "$MANUAL_FIXES" -gt 3 ]; then
    echo "  ⚠️  MANY MANUAL FIXES: Consider cost/benefit of continuing vs fresh start"
    echo "  🤔 Question: Has this PR achieved its core objective?"
else
    echo "  🔧 MANAGEABLE: Continue with targeted fixes"
    echo "  📋 Approach: Address each failure systematically"
fi

echo
echo "🤖 Pattern Analysis Complete"
