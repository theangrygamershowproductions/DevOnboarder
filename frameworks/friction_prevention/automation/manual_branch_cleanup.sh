#!/usr/bin/env bash
# Manual branch cleanup script - safe interactive cleanup of local and remote branches
# This script provides a comprehensive view and safe cleanup options

set -euo pipefail

# Colors for output
# shellcheck disable=SC2034  # Colors may be used selectively
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging setup
mkdir -p logs
LOG_FILE="logs/branch_cleanup_$(date %Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🧹 DevOnboarder Branch Cleanup Utility"
echo "======================================="
echo "Log: $LOG_FILE"
echo ""

# Function to safely run git commands
safe_git() {
    if command -v git >/dev/null 2>&1; then
        git "$@"
    else
        echo " Git not found. Please install git."
        exit 1
    fi
}

# Function to check if we're in a git repository
check_git_repo() {
    if ! safe_git rev-parse --git-dir >/dev/null 2>&1; then
        echo " Not in a git repository."
        exit 1
    fi
}

# Function to get current branch
get_current_branch() {
    safe_git branch --show-current 2>/dev/null || echo "unknown"
}

# Function to list all branches with details
list_branches() {
    echo -e "${BLUE} Branch Analysis${NC}"
    echo "==================="

    current_branch=$(get_current_branch)
    echo -e "Current branch: ${GREEN}$current_branch${NC}"
    echo ""

    echo -e "${YELLOW}Local Branches:${NC}"
    echo "---------------"
    safe_git branch -v 2>/dev/null || echo "No local branches found"
    echo ""

    echo -e "${YELLOW}Remote Branches:${NC}"
    echo "----------------"
    safe_git branch -r -v 2>/dev/null || echo "No remote branches found"
    echo ""

    echo -e "${YELLOW}Recently Merged Branches:${NC}"
    echo "-------------------------"
    # Show branches merged into main in the last 60 days
    safe_git for-each-ref --format='%(refname:short) %(committerdate:relative) %(authorname)' \
        --sort=-committerdate refs/heads/ refs/remotes/origin/ 2>/dev/null | \
        head -20 || echo "Unable to fetch branch details"
    echo ""
}

# Function to find merged branches
find_merged_branches() {
    echo -e "${BLUE} Finding Merged Branches${NC}"
    echo "============================"

    base_branch="${1:-main}"
    echo "Base branch: $base_branch"
    echo ""

    # Update remote references
    echo "Fetching latest remote changes..."
    safe_git fetch origin --prune >/dev/null 2>&1 || echo "Warning: Failed to fetch from origin"

    echo -e "${YELLOW}Local branches merged into $base_branch:${NC}"
    local_merged=$(safe_git branch --merged "$base_branch" 2>/dev/null | grep -v "^\*" | grep -v "$base_branch" | xargs -r echo || echo "")
    if [ -n "$local_merged" ]; then
        echo "$local_merged"
    else
        echo "None found"
    fi
    echo ""

    echo -e "${YELLOW}Remote branches merged into origin/$base_branch:${NC}"
    remote_merged=$(safe_git branch -r --merged "origin/$base_branch" 2>/dev/null | \
                   grep -v "origin/$base_branch" | \
                   grep -v "origin/HEAD" | \
                   grep -v "origin/dev" | \
                   grep -v "origin/staging" | \
                   grep -v "origin/release/" | \
                   sed 's/origin\///' | xargs -r echo || echo "")
    if [ -n "$remote_merged" ]; then
        echo "$remote_merged"
    else
        echo "None found"
    fi
    echo ""
}

# Function to safely delete local branches
cleanup_local_branches() {
    echo -e "${BLUE}🗑️  Local Branch Cleanup${NC}"
    echo "========================="

    current_branch=$(get_current_branch)
    base_branch="${1:-main}"

    # Switch to base branch if not already there
    if [ "$current_branch" != "$base_branch" ]; then
        echo "Switching to $base_branch..."
        safe_git checkout "$base_branch" 2>/dev/null || {
            echo " Failed to switch to $base_branch. Please switch manually."
            return 1
        }
    fi

    # Find merged local branches
    merged_locals=$(safe_git branch --merged "$base_branch" 2>/dev/null | \
                   grep -v "^\*" | \
                   grep -v "$base_branch" | \
                   grep -v "dev" | \
                   grep -v "staging" | \
                   grep -v "feat/potato-ignore-policy-focused" | \
                   sed 's/^[ *]*//' || echo "")

    if [ -z "$merged_locals" ]; then
        echo " No local merged branches to delete"
        return 0
    fi

    echo "Found merged local branches:"
    echo "$merged_locals"
    echo ""

    read -p "Delete these local branches? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$merged_locals" | while read -r branch; do
            if [ -n "$branch" ]; then
                echo "Deleting local branch: $branch"
                safe_git branch -d "$branch" 2>/dev/null || {
                    echo "  Failed to delete $branch (may have unmerged changes)"
                    read -p "Force delete $branch? [y/N] " -n 1 -r
                    echo ""
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        safe_git branch -D "$branch" && echo " Force deleted $branch"
                    fi
                }
            fi
        done
    else
        echo "Skipped local branch cleanup"
    fi
}

# Function to list stale branches
list_stale_branches() {
    echo -e "${BLUE}📅 Stale Branch Analysis${NC}"
    echo "========================"

    days_threshold="${1:-30}"
    echo "Checking for branches older than $days_threshold days..."
    echo ""

    cutoff_date=$(date -d "$days_threshold days ago" %s 2>/dev/null || date -v-"${days_threshold}"d %s 2>/dev/null || echo "0")

    echo -e "${YELLOW}Stale Local Branches:${NC}"
    safe_git for-each-ref --format='%(refname:short) %(committerdate:unix) %(committerdate:relative)' refs/heads/ 2>/dev/null | \
        while read -r branch timestamp relative; do
            if [ "$timestamp" -lt "$cutoff_date" ] && [ "$branch" != "main" ] && [ "$branch" != "dev" ] && [ "$branch" != "feat/potato-ignore-policy-focused" ]; then
                echo "  $branch ($relative)"
            fi
        done || echo "Unable to analyze local branches"
    echo ""

    echo -e "${YELLOW}Stale Remote Branches:${NC}"
    safe_git for-each-ref --format='%(refname:short) %(committerdate:unix) %(committerdate:relative)' refs/remotes/origin/ 2>/dev/null | \
        while read -r branch timestamp relative; do
            branch_name=${branch#origin/}
            if [ "$timestamp" -lt "$cutoff_date" ] && [ "$branch_name" != "main" ] && [ "$branch_name" != "dev" ] && [ "$branch_name" != "HEAD" ] && [ "$branch_name" != "feat/potato-ignore-policy-focused" ]; then
                echo "  $branch_name ($relative)"
            fi
        done || echo "Unable to analyze remote branches"
    echo ""
}

# Function to run automated cleanup (safe mode)
run_automated_cleanup() {
    echo -e "${BLUE}🤖 Automated Safe Cleanup${NC}"
    echo "=========================="

    # Run existing cleanup script in dry-run mode
    if [ -f "scripts/cleanup_branches.sh" ]; then
        echo "Running existing cleanup script (dry-run mode)..."
        DRY_RUN=true BASE_BRANCH=main DAYS_STALE=30 bash scripts/cleanup_branches.sh
    else
        echo "  Cleanup script not found. Manual cleanup only."
    fi
}

# Main menu
main_menu() {
    echo -e "${GREEN}🧹 Branch Cleanup Options${NC}"
    echo "=========================="
    echo "1. List all branches"
    echo "2. Find merged branches"
    echo "3. List stale branches (30 days)"
    echo "4. Clean up local merged branches"
    echo "5. Run automated cleanup (dry-run)"
    echo "6. Exit"
    echo ""

    read -r -p "Select option [1-6]: " choice

    case $choice in
        1)
            list_branches
            echo ""
            main_menu
            ;;
        2)
            find_merged_branches main
            echo ""
            main_menu
            ;;
        3)
            list_stale_branches 30
            echo ""
            main_menu
            ;;
        4)
            cleanup_local_branches main
            echo ""
            main_menu
            ;;
        5)
            run_automated_cleanup
            echo ""
            main_menu
            ;;
        6)
            echo "👋 Branch cleanup complete. Log saved to: $LOG_FILE"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            main_menu
            ;;
    esac
}

# Main execution
main() {
    check_git_repo

    echo " Quick branch overview:"
    echo "Current branch: $(get_current_branch)"
    echo "Local branches: $(safe_git branch 2>/dev/null | wc -l || echo 'unknown')"
    echo "Remote branches: $(safe_git branch -r 2>/dev/null | wc -l || echo 'unknown')"
    echo ""

    main_menu
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
