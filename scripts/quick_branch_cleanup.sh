#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Quick branch cleanup script for DevOnboarder
# Performs safe cleanup of obviously stale branches

set -euo pipefail

# Function to review pre-commit logs
review_precommit_logs() {
    echo ""
    check "REVIEWING PRE-COMMIT LOGS"
    echo "============================"

    # Check for pre-commit error logs
    if [ -f "logs/pre-commit-errors.log" ]; then
        echo "🔍 Found pre-commit error log. Analyzing..."
        echo ""

        # Show shellcheck errors
        if grep -q "shellcheck.*Failed" logs/pre-commit-errors.log; then
            echo "🚨 SHELLCHECK ERRORS DETECTED:"
            grep -A 20 "shellcheck.*Failed" logs/pre-commit-errors.log | head -20
            echo ""
            echo "💡 Fix Required: Review shellcheck errors above"
            echo "   Common fixes:"
            echo "   - Move function definitions before function calls"
            echo "   - Fix quoting issues"
            echo "   - Address variable usage warnings"
            echo ""
        fi

        # Show other critical errors
        if grep -q "Failed" logs/pre-commit-errors.log; then
            error "Other Pre-commit Failures Found:"
            grep "Failed" logs/pre-commit-errors.log
            echo ""
        fi

        # Show successful items for context
        success "Pre-commit Items That Passed:"
        grep "Passed" logs/pre-commit-errors.log | tail -5
        echo ""

        read -r -p "warning " Pre-commit errors found. Review complete? Press Enter to continue or Ctrl+C to exit and fix issues..."
        return 1
    else
        success "No pre-commit error log found - assuming clean run"
        return 0
    fi
}

# Function to handle commit with pre-commit log review
commit_with_log_review() {
    local commit_message="$1"

    echo "💾 Committing changes..."
    echo "Message: $commit_message"

    if git commit -m "$commit_message"; then
        success "Commit successful"
        return 0
    else
        echo ""
        warning " COMMIT FAILED - PRE-COMMIT HOOKS DETECTED ISSUES"
        echo "=================================================="

        # Call the log review function
        review_precommit_logs

        echo ""
        echo "🔍 LOG REVIEW REQUIRED:"
        echo "Pre-commit hooks have flagged issues that must be fixed before commit."
        echo ""
        check "Based on logs/pre-commit-errors.log analysis:"
        echo "  • Check shellcheck errors in scripts/verify_and_commit.sh"
        echo "  • Function definition order issues (SC2218)"
        echo "  • Review any other failures shown above"
        echo ""
        tool " To Fix Issues:"
        echo "  1. Review the logs/pre-commit-errors.log file"
        echo "  2. Fix all reported violations in the affected files"
        echo "  3. Stage your fixes: git add ."
        echo "  4. Re-attempt commit: git commit -m \"$commit_message\""
        echo "  5. Or use: git commit --amend --no-edit (if you want to amend)"
        echo ""
        sync "Alternative Recovery Options:"
        echo "  • Reset last commit: git reset --soft HEAD~1"
        echo "  • Check what's staged: git status"
        echo "  • Use enhanced commit tool: ./scripts/commit_changes.sh"
        echo ""

        read -r -p "⏸️  Press Enter after you've reviewed the errors and are ready to proceed..."
        echo ""
        echo "💡 Remember: All issues must be fixed for the commit to succeed."
        echo "   DevOnboarder enforces strict quality standards via pre-commit hooks."
        return 1
    fi
}

echo "🧹 DevOnboarder Quick Branch Cleanup"
echo "===================================="
echo "This script will safely clean up obviously stale branches."
echo ""

# Check if we're in the right directory
if [ ! -f ".github/workflows/ci.yml" ]; then
    error "Please run this script from the DevOnboarder root directory"
    exit 1
fi

# Check current branch
current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "Current branch: $current_branch"

# Create a feature branch for cleanup work
cleanup_branch="chore/automated-branch-cleanup-$(date +%Y%m%d-%H%M%S)"
echo "Creating feature branch: $cleanup_branch"

if ! git checkout -b "$cleanup_branch"; then
    error "Failed to create cleanup branch"
    exit 1
fi

success "Working on feature branch: $cleanup_branch"
echo ""

# Ensure we're working from latest main
echo "📥 Fetching latest main branch..."
git fetch origin main
git merge origin/main --no-edit

# Fetch and prune
sync "Fetching latest changes and pruning deleted branches..."
git fetch origin --prune

# Show current branch status
echo ""
report "Current local branches:"
git branch -v

echo ""
report "Current remote branches:"
git branch -r

# Check for merged branches
echo ""
echo "🔍 Checking for merged branches..."
merged_branches=$(git branch --merged main | grep -v "main" | grep -v "^\*" | grep -v "feat/potato-ignore-policy-focused" | xargs echo || echo "")

if [ -n "$merged_branches" ]; then
    echo "Found merged branches: $merged_branches"
    echo ""
    read -p "Delete these merged local branches? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$merged_branches" | xargs -r git branch -d
        success "Deleted merged local branches"
    else
        echo "Skipped local branch deletion"
    fi
else
    success "No merged local branches found"
fi

# Offer to clean up obvious remote stale branches
echo ""
echo "🔍 Checking for obviously stale remote branches..."

stale_remotes=(
    "codex/add-fastapi-endpoints-for-feedback"
    "codex/add-step-to-check-python-dependencies-in-ci"
    "codex/create-bot-permissions.yaml-configuration"
    "codex/create-qa-checklist-markdown-and-command-module"
    "codex/modify-security-audit-script-and-documentation"
    "codex/update-eslint-and-typescript-versions"
    "codex/verify-github-actions-workflow-success"
    "a30joe-codex/add-fastapi-endpoints-for-feedback"
    "hpehw1-codex/create-qa-checklist-markdown-and-command-module"
    "docs/update-discord-bot-documentation"
    "alert-autofix-1"
)

echo "The following remote branches appear to be stale Codex/automated branches:"
for branch in "${stale_remotes[@]}"; do
    if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        echo "  - $branch"
    fi
done

echo ""
read -p "Delete these stale remote branches? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    for branch in "${stale_remotes[@]}"; do
        if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
            echo "Deleting remote branch: $branch"
            git push origin --delete "$branch" 2>/dev/null || warning " Failed to delete $branch (may already be deleted)"
        fi
    done
    success "Stale remote branch cleanup complete"
else
    echo "Skipped remote branch cleanup"
fi

# Check if there are any changes to commit from cleanup
echo ""
echo "🔍 Checking for changes to commit from cleanup..."
if ! git diff --quiet || ! git diff --staged --quiet; then
    note "Found changes that need to be committed"
    echo ""

    # Show what changes were made
    echo "Changes from branch cleanup:"
    git status --short
    echo ""

    # Stage changes
    check "Staging cleanup changes..."
    git add .

    # Commit with appropriate message
    commit_msg="CHORE(scripts): automated branch cleanup - removed stale local and remote branches"

    # Use the enhanced commit function with log review
    if commit_with_log_review "$commit_msg"; then
        echo ""
        success "Commit successful! Now creating pull request..."
        echo ""
        deploy "Next Steps:"
        echo "1. Push feature branch: git push origin $cleanup_branch"
        echo "2. Create PR to merge cleanup changes into main"
        echo "3. Review and merge PR after approval"
        echo ""
        echo "Current branch: $cleanup_branch"
        echo "Changes committed and ready for PR creation"
    else
        echo ""
        error "Commit failed. Please fix the issues identified in the log review."
        echo "   Then retry: git commit -m \"$commit_msg\""
        exit 1
    fi
else
    success "No changes to commit from cleanup"
fi

# Final status
echo ""
report "Final status:"
git branch -v
echo ""
success "Quick cleanup complete!"
echo ""
echo "💡 For comprehensive cleanup, see: BRANCH_CLEANUP_ANALYSIS.md"
echo "💡 For automated cleanup, the nightly workflow will handle ongoing maintenance"
