#!/usr/bin/env bash
# Comprehensive branch cleanup for DevOnboarder
# This script safely identifies and cleans up merged and stale branches

set -euo pipefail

# Logging setup
mkdir -p logs
LOG_FILE="logs/comprehensive_branch_cleanup_$(date %Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🧹 DevOnboarder Comprehensive Branch Cleanup"
echo "============================================="
echo "Log: $LOG_FILE"
echo "Timestamp: $(date)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
DRY_RUN="${DRY_RUN:-true}"
BASE_BRANCH="${BASE_BRANCH:-main}"
DAYS_STALE="${DAYS_STALE:-30}"

echo "Configuration:"
echo "- DRY_RUN: $DRY_RUN"
echo "- BASE_BRANCH: $BASE_BRANCH"
echo "- DAYS_STALE: $DAYS_STALE"
echo ""

# Protected branches (never delete)
PROTECTED_BRANCHES=("main" "dev" "staging" "HEAD" "feat/potato-ignore-policy-focused")

# Function to check if branch is protected
is_protected_branch() {
    local branch="$1"
    for protected in "${PROTECTED_BRANCHES[@]}"; do
        if [[ "$branch" == "$protected" || "$branch" == *"$protected"* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to safely run git commands
safe_git() {
    git "$@" 2>/dev/null || {
        echo "  Git command failed: git $*"
        return 1
    }
}

# Current state analysis
echo -e "${BLUE} Current Branch Analysis${NC}"
echo "============================"

echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"

# Count branches
local_count=$(find .git/refs/heads -type f 2>/dev/null | wc -l || echo 0)
remote_count=$(find .git/refs/remotes/origin -type f 2>/dev/null | wc -l || echo 0)

echo "Local branches: $local_count"
echo "Remote branches: $remote_count"
echo ""

# List all local branches
echo -e "${YELLOW}Local Branches:${NC}"
echo "---------------"
if [ -d ".git/refs/heads" ]; then
    find .git/refs/heads -type f -exec basename {} \; 2>/dev/null | sort || echo "None found"
    # List nested branches safely
    if [ -d ".git/refs/heads" ]; then
        find .git/refs/heads -type f 2>/dev/null | sed 's|.git/refs/heads/||' | sort || true
    fi
fi
echo ""

# List all remote branches
echo -e "${YELLOW}Remote Branches:${NC}"
echo "----------------"
if [ -d ".git/refs/remotes/origin" ]; then
    find .git/refs/remotes/origin -type f -exec basename {} \; 2>/dev/null | sort || echo "None found"
    # List nested remote branches safely
    find .git/refs/remotes/origin -type f 2>/dev/null | sed 's|.git/refs/remotes/origin/||' | sort || true
fi
echo ""

# Fetch latest remote information
echo "SYNC: Fetching latest remote information..."
if safe_git fetch origin --prune; then
    echo " Remote fetch successful"
else
    echo "  Remote fetch failed - continuing with local analysis only"
fi
echo ""

# Identify merged local branches
echo -e "${BLUE} Merged Branch Analysis${NC}"
echo "=========================="

merged_locals=()
echo -e "${YELLOW}Local branches merged into $BASE_BRANCH:${NC}"

if [ -d ".git/refs/heads" ]; then
    # Get all local branch names (including nested branches)
    all_locals=()
    declare -A seen_branches

    # Find all branch files recursively and deduplicate
    while IFS= read -r -d '' file; do
        branch="${file#.git/refs/heads/}"
        # Only add if not already seen
        if [[ -z "${seen_branches[$branch]:-}" ]]; then
            seen_branches["$branch"]=1
            all_locals=("$branch")
        fi
    done < <(find .git/refs/heads -type f -print0 2>/dev/null)

    # Check each branch for merge status
    for branch in "${all_locals[@]}"; do
        if ! is_protected_branch "$branch"; then
            # Check if branch is merged into base branch
            if safe_git merge-base --is-ancestor "$branch" "$BASE_BRANCH"; then
                echo "   $branch (merged)"
                merged_locals=("$branch")
            else
                echo "   $branch (not merged)"
            fi
        else
            echo "  🔒 $branch (protected)"
        fi
    done
else
    echo "No local branches found"
fi
echo ""

# Identify stale branches
echo -e "${BLUE}📅 Stale Branch Analysis${NC}"
echo "======================="

cutoff_date=$(date -d "$DAYS_STALE days ago" %s 2>/dev/null || date -v-"${DAYS_STALE}"d %s 2>/dev/null || echo "0")
stale_locals=()

echo -e "${YELLOW}Branches older than $DAYS_STALE days:${NC}"

for branch in "${all_locals[@]:-}"; do
    if ! is_protected_branch "$branch"; then
        # Get last commit timestamp for branch
        if commit_hash=$(cat ".git/refs/heads/$branch" 2>/dev/null); then
            if commit_date=$(safe_git show -s --format=%ct "$commit_hash"); then
                if [ "$commit_date" -lt "$cutoff_date" ]; then
                    relative_date=$(safe_git show -s --format=%cr "$commit_hash" || echo "unknown")
                    echo "  📅 $branch ($relative_date)"
                    stale_locals=("$branch")
                fi
            fi
        fi
    fi
done
echo ""

# Cleanup recommendations
echo -e "${BLUE} Cleanup Recommendations${NC}"
echo "========================="

if [ ${#merged_locals[@]} -gt 0 ]; then
    echo -e "${GREEN}Safe to delete (merged):${NC}"
    for branch in "${merged_locals[@]}"; do
        echo "  - $branch"
    done
    echo ""
fi

if [ ${#stale_locals[@]} -gt 0 ]; then
    echo -e "${YELLOW}Consider deleting (stale):${NC}"
    for branch in "${stale_locals[@]}"; do
        echo "  - $branch"
    done
    echo ""
fi

# Cleanup execution
if [ "$DRY_RUN" = "false" ]; then
    echo -e "${RED}  LIVE MODE - WILL DELETE BRANCHES${NC}"
    echo "=================================="

    # Switch to base branch if needed
    current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    if [ "$current_branch" != "$BASE_BRANCH" ]; then
        echo "Switching to $BASE_BRANCH..."
        if safe_git checkout "$BASE_BRANCH"; then
            echo " Switched to $BASE_BRANCH"
        else
            echo " Failed to switch to $BASE_BRANCH - aborting cleanup"
            exit 1
        fi
    fi

    # Delete merged local branches
    for branch in "${merged_locals[@]}"; do
        echo "Deleting merged branch: $branch"
        if safe_git branch -d "$branch"; then
            echo " Deleted $branch"
        else
            echo "  Failed to delete $branch (trying force delete)"
            if safe_git branch -D "$branch"; then
                echo " Force deleted $branch"
            else
                echo " Failed to delete $branch"
            fi
        fi
    done

    echo ""
    echo " Local branch cleanup complete"
else
    echo -e "${BLUE} DRY RUN MODE - No branches will be deleted${NC}"
    echo "=============================================="
    echo "To actually delete branches, run with: DRY_RUN=false"
fi

echo ""
echo " Summary:"
echo "- Merged branches found: ${#merged_locals[@]}"
echo "- Stale branches found: ${#stale_locals[@]}"
echo "- Protected branches: ${#PROTECTED_BRANCHES[@]}"
echo ""
echo " Cleanup log saved to: $LOG_FILE"

# Create summary file
SUMMARY_FILE="logs/branch_cleanup_summary_$(date %Y%m%d_%H%M%S).md"
cat > "$SUMMARY_FILE" << EOF
# Branch Cleanup Summary

**Date:** $(date)
**Mode:** $([ "$DRY_RUN" = "true" ] && echo "Dry Run" || echo "Live Cleanup")

## Statistics

- **Local Branches:** $local_count
- **Remote Branches:** $remote_count
- **Merged Branches:** ${#merged_locals[@]}
- **Stale Branches:** ${#stale_locals[@]}

## Merged Branches (Safe to Delete)

$(for branch in "${merged_locals[@]:-}"; do echo "- \`$branch\`"; done)

## Stale Branches (Consider Deleting)

$(for branch in "${stale_locals[@]:-}"; do echo "- \`$branch\`"; done)

## Actions Taken

$([ "$DRY_RUN" = "true" ] && echo "No actions taken (dry run mode)" || echo "Deleted merged branches")

## Next Steps

1. Review the branch list above
2. Manually verify any branches you want to keep
3. Run with \`DRY_RUN=false\` to perform actual cleanup
4. Consider setting up automated branch cleanup in CI

---

Generated by DevOnboarder Branch Cleanup Utility
EOF

echo "FILE: Summary report: $SUMMARY_FILE"
