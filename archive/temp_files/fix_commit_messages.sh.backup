#!/bin/bash
# Fix commit messages to follow conventional commit format
# POTATO APPROVAL: emergency-commit-message-fix-20250807

set -euo pipefail

echo "🔧 DevOnboarder Commit Message Fixer"
echo "====================================="
echo "This script will fix non-conventional commit messages in the current branch."
echo

# Activate virtual environment if available
if [ -f .venv/bin/activate ]; then
    echo "📦 Activating virtual environment..."
    # shellcheck disable=SC1091 # Runtime source operation
    source .venv/bin/activate
fi

# Create backup branch
BACKUP_BRANCH="backup-before-commit-fix-$(date +%Y%m%d-%H%M%S)"
echo "💾 Creating backup branch: $BACKUP_BRANCH"
git branch "$BACKUP_BRANCH"

echo "🔍 Analyzing commits that need fixing..."

# Define the problematic commits and their fixes (used in filter-branch)
declare -A COMMIT_FIXES
COMMIT_FIXES["RESOLVE: merge conflicts in AAR portal and frontend packages"]="FIX(merge): resolve conflicts in AAR portal and frontend packages"
# shellcheck disable=SC2034 # Used in filter-branch msg-filter
COMMIT_FIXES["Revert \"FEAT(infrastructure): implement cloudflare tunnel architecture and fix discord bot ES modules\""]="REVERT(infrastructure): revert cloudflare tunnel architecture and discord bot ES modules"

# Get list of commits from main to HEAD
COMMITS=$(git log --oneline --reverse origin/main..HEAD)

echo "📋 Commits to be processed:"
echo "$COMMITS"
echo

# Ask for confirmation
read -p "🤔 Do you want to proceed with fixing these commit messages? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Operation cancelled."
    exit 1
fi

echo "🚀 Starting commit message fixes..."

# Use filter-branch to rewrite commit messages
git filter-branch -f --msg-filter '
    ORIGINAL_MSG=$(cat)

    # Fix specific problematic messages
    case "$ORIGINAL_MSG" in
        "RESOLVE: merge conflicts in AAR portal and frontend packages"*)
            echo "FIX(merge): resolve conflicts in AAR portal and frontend packages"
            ;;
        "Revert \"FEAT(infrastructure): implement cloudflare tunnel architecture and fix discord bot ES modules\""*)
            echo "REVERT(infrastructure): revert cloudflare tunnel architecture and discord bot ES modules"
            ;;
        *)
            echo "$ORIGINAL_MSG"
            ;;
    esac
' origin/main..HEAD

echo "✅ Commit message fixes completed!"
echo "💾 Backup branch created: $BACKUP_BRANCH"
echo

echo "🔍 Verifying fixes..."
git log --oneline origin/main..HEAD | head -10

echo
echo "🎉 Commit message fixing complete!"
echo "📋 Next steps:"
echo "  1. Review the changes: git log --oneline origin/main..HEAD"
echo "  2. Run validation: ./scripts/qc_pre_push.sh"
echo "  3. Force push if satisfied: git push --force-with-lease origin $(git branch --show-current)"
echo "  4. If issues occur, restore backup: git reset --hard $BACKUP_BRANCH"
