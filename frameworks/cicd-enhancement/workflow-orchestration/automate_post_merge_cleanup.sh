#!/bin/bash

# automate_post_merge_cleanup.sh - Automated post-merge cleanup workflow
# Follows DevOnboarder terminal output compliance and centralized logging

set -euo pipefail

# Centralized logging setup
mkdir -p logs
LOG_FILE="logs/post_merge_cleanup_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Load DevOnboarder environment
if [[ -f "scripts/load_token_environment.sh" ]]; then
    # shellcheck source=scripts/load_token_environment.sh
    source scripts/load_token_environment.sh
fi

echo "Starting automated post-merge cleanup workflow"
echo "Log file: $LOG_FILE"

# Function to validate PR number
validate_pr_number() {
    local pr_number="$1"
    if ! [[ "$pr_number" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Invalid PR number format: $pr_number"
        echo "Usage: $0 <pr-number>"
        exit 1
    fi
}

# Function to search for tracking issues
search_tracking_issues() {
    local pr_number="$1"
    echo "Searching for tracking issues related to PR #$pr_number"

    # Search patterns for tracking issues
    local search_patterns=(
        "is:open label:tracking PR #$pr_number"
        "is:open label:tracking #$pr_number"
        "is:open PR $pr_number"
        "is:open tracking $pr_number"
    )

    local found_issues=()

    for pattern in "${search_patterns[@]}"; do
        echo "Searching with pattern: $pattern"
        local issues
        if command -v gh >/dev/null 2>&1; then
            issues=$(gh issue list --search "$pattern" --json number,title,labels --jq '.[] | "\(.number):\(.title)"' 2>/dev/null || true)
            if [[ -n "$issues" ]]; then
                echo "Found issues with pattern '$pattern':"
                echo "$issues"
                # Store unique issue numbers
                while read -r issue_line; do
                    if [[ -n "$issue_line" ]]; then
                        local issue_number
                        issue_number=$(echo "$issue_line" | cut -d: -f1)
                        # Check if issue number already in array
                        local already_found=false
                        for existing_issue in "${found_issues[@]}"; do
                            if [[ "$existing_issue" == "$issue_number" ]]; then
                                already_found=true
                                break
                            fi
                        done

                        if [[ "$already_found" == false ]]; then
                            found_issues+=("$issue_number")
                        fi
                    fi
                done <<< "$issues"
            fi
        else
            echo "WARNING: GitHub CLI not available, skipping issue search"
        fi
    done

    # Return found issues
    printf '%s\n' "${found_issues[@]}"
}

# Function to close tracking issues
close_tracking_issues() {
    local pr_number="$1"
    local tracking_issues=("${@:2}")

    if [[ ${#tracking_issues[@]} -eq 0 ]]; then
        echo "No tracking issues found to close"
        return 0
    fi

    echo "Found ${#tracking_issues[@]} tracking issue(s) to close"

    for issue_number in "${tracking_issues[@]}"; do
        if [[ -n "$issue_number" ]]; then
            echo "Closing tracking issue #$issue_number"
            local close_message="Resolved via PR #$pr_number - automated post-merge cleanup"

            if command -v gh >/dev/null 2>&1; then
                if gh issue close "$issue_number" --comment "$close_message"; then
                    echo "Successfully closed tracking issue #$issue_number"
                else
                    echo "WARNING: Failed to close tracking issue #$issue_number"
                fi
            else
                echo "WARNING: GitHub CLI not available, cannot close issue #$issue_number"
                echo "Manual action required: Close issue #$issue_number with comment: $close_message"
            fi
        fi
    done
}

# Function to cleanup local branch
cleanup_local_branch() {
    local pr_number="$1"

    echo "Starting local branch cleanup"

    # Get current branch
    local current_branch
    current_branch=$(git branch --show-current)

    # Switch to main if not already there
    if [[ "$current_branch" != "main" ]]; then
        echo "Switching from $current_branch to main branch"
        if ! git checkout main; then
            echo "WARNING: Failed to switch to main branch"
            return 1
        fi
    fi

    # Update main branch
    echo "Updating main branch from origin"
    if ! git pull origin main; then
        echo "WARNING: Failed to update main branch"
        return 1
    fi

    # Find and delete merged branches related to PR
    echo "Looking for merged branches related to PR #$pr_number"
    local merged_branches
    merged_branches=$(git for-each-ref --format='%(refname:short)' --merged=main refs/heads/ | grep -v "^main$" || true)

    if [[ -n "$merged_branches" ]]; then
        echo "Found merged branches to clean up:"
        echo "$merged_branches"

        while read -r branch; do
            if [[ -n "$branch" ]]; then
                echo "Deleting merged branch: $branch"
                git branch -d "$branch" || echo "WARNING: Failed to delete branch $branch"
            fi
        done <<< "$merged_branches"
    else
        echo "No merged branches found to clean up"
    fi
}

# Function to verify cleanup completion
verify_cleanup() {
    echo "Verifying cleanup completion"

    # Check if still on main branch
    local current_branch
    current_branch=$(git branch --show-current)
    if [[ "$current_branch" == "main" ]]; then
        echo "VERIFICATION: Currently on main branch"
    else
        echo "WARNING: Not on main branch, currently on $current_branch"
    fi

    # Check for any remaining local branches
    local local_branches
    local_branches=$(git branch | grep -v "main" | grep -v "^\*" | grep -c . || true)
    echo "VERIFICATION: $local_branches non-main local branches remaining"

    # Check git status
    local git_status
    git_status=$(git status --porcelain)
    if [[ -z "$git_status" ]]; then
        echo "VERIFICATION: Working directory clean"
    else
        echo "WARNING: Working directory has uncommitted changes"
    fi
}

# Main workflow
main() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <pr-number>"
        echo "Example: $0 1555"
        exit 1
    fi

    local pr_number="$1"
    validate_pr_number "$pr_number"

    echo "Processing post-merge cleanup for PR #$pr_number"

    # Step 1: Search for tracking issues
    echo "=== Step 1: Searching for tracking issues ==="
    local tracking_issues
    readarray -t tracking_issues < <(search_tracking_issues "$pr_number")

    # Step 2: Close tracking issues
    echo "=== Step 2: Closing tracking issues ==="
    close_tracking_issues "$pr_number" "${tracking_issues[@]}"

    # Step 3: Cleanup local branches
    echo "=== Step 3: Local branch cleanup ==="
    cleanup_local_branch "$pr_number"

    # Step 4: Verify cleanup
    echo "=== Step 4: Verification ==="
    verify_cleanup

    echo "=== Post-merge cleanup completed ==="
    echo "Log file: $LOG_FILE"
    echo "Summary:"
    echo "- Processed PR #$pr_number"
    echo "- Found ${#tracking_issues[@]} tracking issue(s)"
    echo "- Cleaned up local branches"
    echo "- Verified main branch status"
}

# Execute main function with all arguments
main "$@"
