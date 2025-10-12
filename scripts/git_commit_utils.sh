#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Git commit utilities for DevOnboarder
# Provides reusable functions for robust commit handling with pre-commit log review

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to handle commit with comprehensive pre-commit log review
commit_with_log_review() {
    local commit_message="$1"
    local show_success_details="${2:-true}"

    echo -e "${GREEN}NOTE: Committing changes..."
    echo "Message: $commit_message"
    echo ""

    if git commit -m "$commit_message"; then
        success_msg " Commit successful!"

        if [ "$show_success_details" = "true" ]; then
            # Show the latest commit
            echo ""
            echo -e "${YELLOW}Latest commit:"
            git log --oneline -1
            echo ""
            echo -e "${GREEN}🎉 All changes committed successfully!"
        fi
        return 0
    else
        echo ""
        echo -e "${RED}WARNING:  COMMIT FAILED - PRE-COMMIT HOOKS DETECTED ISSUES"
        echo "====================================================="
        echo ""
        echo -e "${YELLOW}🔍 LOG REVIEW REQUIRED:"
        echo "Pre-commit hooks have flagged issues that must be fixed before commit."
        echo ""
        echo -e "${YELLOW}CHECK: Common Issues to Check:"
        echo "  • ${BLUE}Markdown violations:"
        echo "    - MD022: Headings must have blank lines before and after"
        echo "    - MD032: Lists must have blank lines before and after"
        echo "    - MD031: Fenced code blocks need blank lines around them"
        echo "    - MD007: Proper list indentation (4 spaces for nested)"
        echo "    - MD009: No trailing spaces (except 2 for line breaks)"
        echo ""
        echo "  • ${BLUE}Bash script issues:"
        echo "    - Shellcheck warnings (quoting, variable usage, etc.)"
        echo "    - Script formatting and best practices"
        echo "    - Executable permissions missing"
        echo ""
        echo "  • ${BLUE}Code formatting:"
        echo "    - Python: black formatting, ruff linting"
        echo "    - TypeScript/JavaScript: ESLint violations"
        echo "    - File formatting (trailing spaces, line endings)"
        echo ""
        echo -e "${YELLOW}TOOL:  Step-by-Step Fix Process:"
        echo "  1. ${BLUE}Read the error output above carefully${NC} - it tells you exactly what to fix"
        echo "  2. ${BLUE}Fix all reported violations${NC} in the affected files"
        echo "  3. ${BLUE}Stage your fixes:${NC} git add ."
        echo "  4. ${BLUE}Re-attempt commit:${NC} git commit -m \"$commit_message\""
        echo "  5. ${BLUE}Or amend this commit:${NC} git commit --amend --no-edit"
        echo ""
        echo -e "${YELLOW}SYNC: Recovery Options if Needed:"
        echo "  • ${BLUE}Reset this commit attempt:${NC} git reset --soft HEAD~1"
        echo "  • ${BLUE}Check current status:${NC} git status"
        echo "  • ${BLUE}Use smart commit tool:${NC} ./scripts/commit_changes.sh"
        echo "  • ${BLUE}Learn commit patterns:${NC} ./scripts/commit_message_guide.sh"
        echo ""
        echo -e "${YELLOW}TARGET: Pro Tips:"
        echo "  • Run ${BLUE}markdownlint-cli2${NC} on .md files to check markdown before commit"
        echo "  • Run ${BLUE}shellcheck${NC} on .sh files to check bash scripts"
        echo "  • Use ${BLUE}git add -p${NC} to stage changes interactively"
        echo ""

        read -r -p "⏸️  Press Enter after you've reviewed the errors and understand what needs fixing..."
        echo ""
        echo -e "${YELLOW}💡 IMPORTANT: All issues must be fixed for the commit to succeed."
        echo "   DevOnboarder enforces strict quality standards via pre-commit hooks."
        echo "   This ensures code quality and prevents issues from entering the repository."
        echo ""
        echo -e "${GREEN}DEPLOY: Once you've fixed the issues, retry with:"
        echo "   git commit -m \"$commit_message\""
        echo ""
        return 1
    fi
}

# Function to stage changes with confirmation
stage_changes_with_confirmation() {
    local description="$1"

    echo -e "${YELLOW}CHECK: Staging $description..."
    echo ""
    echo "Files to be staged:"
    git status --short
    echo ""

    read -p "Stage these changes? [Y/n] " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        git add .
        success_msg " Changes staged"
        echo ""
        echo "Staged files:"
        git diff --staged --name-status
        return 0
    else
        echo "Staging cancelled"
        return 1
    fi
}

# Function to check if there are changes to commit
check_for_changes() {
    if git diff --quiet && git diff --staged --quiet; then
        success_msg " No changes to commit - working directory is clean"
        return 1
    fi

    if git diff --staged --quiet; then
        debug_msg "  No staged changes found"
        if ! git diff --quiet; then
            echo "Unstaged changes are available:"
            git status --short
            return 2  # Unstaged changes available
        fi
        return 1  # No changes at all
    fi

    return 0  # Staged changes ready to commit
}

# Function to show commit preparation summary
show_commit_preparation() {
    echo -e "${BLUE}NOTE: Commit Preparation Summary"
    echo "=========================="
    echo ""

    echo -e "${YELLOW}Staged files:"
    git diff --staged --name-status
    echo ""

    echo -e "${YELLOW}Commit will include:"
    local staged_files
    staged_files=$(git diff --staged --name-only)
    local file_count
    file_count=$(echo "$staged_files" | wc -l)

    echo "  📁 Total files: $file_count"

    # Analyze file types
    local doc_files script_files python_files config_files js_files
    doc_files=$(echo "$staged_files" | grep -cE "\.(md|rst|txt)$")
    script_files=$(echo "$staged_files" | grep -cE "\.sh$")
    python_files=$(echo "$staged_files" | grep -cE "\.py$")
    config_files=$(echo "$staged_files" | grep -cE "\.(yml|yaml|json|toml)$")
    js_files=$(echo "$staged_files" | grep -cE "\.(js|ts|jsx|tsx)$")

    [ "$doc_files" -gt 0 ] && echo "  NOTE: Documentation files: $doc_files"
    [ "$script_files" -gt 0 ] && echo "  TOOL: Script files: $script_files"
    [ "$python_files" -gt 0 ] && echo "  PYTHON: Python files: $python_files"
    [ "$config_files" -gt 0 ] && echo "  ⚙️ Configuration files: $config_files"
    [ "$js_files" -gt 0 ] && echo "  ⚡ JavaScript/TypeScript files: $js_files"

    echo ""
}
