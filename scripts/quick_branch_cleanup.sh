#!/usr/bin/env bash
# Quick branch cleanup script for DevOnboarder
# Performs safe cleanup of obviously stale branches

set -euo pipefail

echo "🧹 DevOnboarder Quick Branch Cleanup"
echo "===================================="
echo "This script will safely clean up obviously stale branches."
echo ""

# Check if we're in the right directory
if [ ! -f ".github/workflows/ci.yml" ]; then
    echo "❌ Please run this script from the DevOnboarder root directory"
    exit 1
fi

# Check current branch
current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "Current branch: $current_branch"

# Switch to main if not already there
if [ "$current_branch" != "main" ]; then
    echo "Switching to main branch..."
    git checkout main || {
        echo "❌ Failed to switch to main branch"
        exit 1
    }
fi

# Fetch and prune
echo "🔄 Fetching latest changes and pruning deleted branches..."
git fetch origin --prune

# Show current branch status
echo ""
echo "📊 Current local branches:"
git branch -v

echo ""
echo "📊 Current remote branches:"
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
        echo "✅ Deleted merged local branches"
    else
        echo "Skipped local branch deletion"
    fi
else
    echo "✅ No merged local branches found"
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
            git push origin --delete "$branch" 2>/dev/null || echo "⚠️  Failed to delete $branch (may already be deleted)"
        fi
    done
    echo "✅ Stale remote branch cleanup complete"
else
    echo "Skipped remote branch cleanup"
fi

# Final status
echo ""
echo "📊 Final status:"
git branch -v
echo ""
echo "✅ Quick cleanup complete!"
echo ""
echo "💡 For comprehensive cleanup, see: BRANCH_CLEANUP_ANALYSIS.md"
echo "💡 For automated cleanup, the nightly workflow will handle ongoing maintenance"
