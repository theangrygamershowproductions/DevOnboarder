#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Quick commit script to handle staged and unstaged changes

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔍 Checking Git Status"
echo "======================="

# Check if we're in a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    error_msg " Not in a git repository"
    exit 1
fi

echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
echo ""

# Show current status
echo -e "${YELLOW}Git Status:"
git status --short

echo ""
echo -e "${YELLOW}Staged Changes:"
git diff --staged --name-status

echo ""
echo -e "${YELLOW}Unstaged Changes:"
git diff --name-status

echo ""

# Check if there are any changes to commit
if git diff --staged --quiet; then
    debug_msg "  No staged changes to commit"

    # Check if there are unstaged changes that could be staged
    if ! git diff --quiet; then
        echo -e "${YELLOW}Found unstaged changes. Stage them?"
        read -p "Stage all changes? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git add .
            success_msg " Staged all changes"
        fi
    else
        success_msg " Working directory is clean"
        exit 0
    fi
fi

# Show what will be committed
echo -e "${YELLOW}Changes to be committed:"
git diff --staged --name-status

echo ""

# Generate intelligent commit message suggestions
changed_files=$(git diff --staged --name-only)
changed_count=$(echo "$changed_files" | wc -l)

echo -e "${YELLOW}NOTE: Analyzing changes for commit message suggestions..."
echo ""

# Analyze file types and changes
doc_files=$(echo "$changed_files" | grep -cE "\.(md|rst|txt)$")
script_files=$(echo "$changed_files" | grep -cE "scripts/.*\.sh$")
python_files=$(echo "$changed_files" | grep -cE "\.(py)$")
config_files=$(echo "$changed_files" | grep -cE "\.(yml|yaml|json|toml|ini)$")
js_ts_files=$(echo "$changed_files" | grep -cE "\.(js|ts|jsx|tsx)$")

# Show what's being committed
echo -e "${YELLOW}Files to be committed ($changed_count total):"
echo "$changed_files" | head -10
if [ "$changed_count" -gt 10 ]; then
    echo "... and $((changed_count - 10)) more files"
fi
echo ""

# Generate smart suggestions based on content
suggestions=()

if [ "$script_files" -gt 0 ]; then
    if echo "$changed_files" | grep -q "git\|sync\|commit"; then
        suggestions+=("FEAT(scripts): add git workflow utilities for safer sync operations")
        suggestions+=("CHORE(scripts): enhance git utilities with conflict detection")
    elif echo "$changed_files" | grep -q "branch\|cleanup"; then
        suggestions+=("FEAT(scripts): add comprehensive branch cleanup utilities")
        suggestions+=("CHORE(scripts): enhance branch management automation")
    else
        suggestions+=("CHORE(scripts): update automation scripts")
    fi
fi

if [ "$doc_files" -gt 0 ]; then
    if echo "$changed_files" | grep -q "README"; then
        suggestions+=("docs "update README with new utilities and workflow guidance")
    elif echo "$changed_files" | grep -q "git-utilities"; then
        suggestions+=("docs "add comprehensive git utilities documentation")
    elif echo "$changed_files" | grep -q "scripts"; then
        suggestions+=("docs "document new script utilities and usage examples")
    else
        suggestions+=("docs "update documentation files")
    fi
fi

if [ "$config_files" -gt 0 ]; then
    suggestions+=("CONFIG: update configuration files")
fi

if [ "$python_files" -gt 0 ]; then
    suggestions+=("FEAT: update Python components")
fi

if [ "$js_ts_files" -gt 0 ]; then
    suggestions+=("FEAT: update TypeScript/JavaScript components")
fi

# Default fallback
if [ ${#suggestions[@]} -eq 0 ]; then
    suggestions+=("CHORE: update project files")
fi

# Show suggestions
echo -e "${YELLOW}💡 Suggested commit messages:"
for i in "${!suggestions[@]}"; do
    echo "  $((i+1)). ${suggestions[$i]}"
done
echo "  0. Enter custom message"
echo ""

# Ask for selection
read -r -p "Select option (1-${#suggestions[@]}) or press Enter for option 1: " selection

if [ -z "$selection" ]; then
    selection=1
fi

if [ "$selection" = "0" ]; then
    read -r -p "Enter custom commit message: " commit_msg
elif [ "$selection" -ge 1 ] && [ "$selection" -le "${#suggestions[@]}" ]; then
    commit_msg="${suggestions[$((selection-1))]}"
    echo "Selected: $commit_msg"
else
    echo "Invalid selection, using first suggestion"
    commit_msg="${suggestions[0]}"
fi

# Commit the changes
echo ""
echo -e "${GREEN}NOTE: Committing changes..."

if git commit -m "$commit_msg"; then
    success_msg " Commit successful!"

    # Show the latest commit
    echo ""
    echo -e "${YELLOW}Latest commit:"
    git log --oneline -1

    echo ""
    echo -e "${GREEN}🎉 All changes committed successfully!"
else
    echo ""
    echo -e "${RED}WARNING:  COMMIT FAILED - PRE-COMMIT HOOKS DETECTED ISSUES"
    echo "====================================================="
    echo ""
    echo -e "${YELLOW}🔍 LOG REVIEW REQUIRED:"
    echo "Pre-commit hooks have flagged issues that must be fixed before commit."
    echo ""
    echo -e "${YELLOW}CHECK: Common Issues to Check:"
    echo "  • Markdown violations (MD022: headings need blank lines, MD032: lists need blank lines)"
    echo "  • Bash shellcheck warnings (formatting, quoting, etc.)"
    echo "  • File formatting issues (trailing spaces, line endings)"
    echo "  • Python linting errors (ruff, black formatting)"
    echo "  • TypeScript/JavaScript ESLint violations"
    echo ""
    echo -e "${YELLOW}TOOL:  To Fix Issues:"
    echo "  1. Review the error output above carefully"
    echo "  2. Fix all reported violations in the affected files"
    echo "  3. Stage your fixes: git add ."
    echo "  4. Re-attempt commit: git commit -m \"$commit_msg\""
    echo "  5. Or use: git commit --amend --no-edit (to amend this commit)"
    echo ""
    echo -e "${YELLOW}SYNC: Alternative Recovery Options:"
    echo "  • Reset this commit: git reset --soft HEAD~1"
    echo "  • Check what's staged: git status"
    echo "  • Run this script again: ./scripts/commit_changes.sh"
    echo "  • Use educational guide: ./scripts/commit_message_guide.sh"
    echo ""

    read -r -p "⏸️  Press Enter after you've reviewed the errors and are ready to proceed..."
    echo ""
    echo -e "${YELLOW}💡 Remember: All issues must be fixed for the commit to succeed."
    echo "   DevOnboarder enforces strict quality standards via pre-commit hooks."
    echo ""
    echo -e "${GREEN}DEPLOY: Once fixed, you can retry with: git commit -m \"$commit_msg\""
fi
