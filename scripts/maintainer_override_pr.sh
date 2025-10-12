#!/bin/bash
# maintainer_override_pr.sh - Manual maintainer intervention for external PRs
# Version: 1.0.0
# Security Level: Tier 3 - Maintainer Override Zone
# Description: Provides manual intervention capabilities for external PRs requiring privileged operations

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_FILE="$PROJECT_ROOT/logs/maintainer_override.log"
AUDIT_FILE="$PROJECT_ROOT/logs/maintainer_audit.log"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_action() {
    local pr_number="$1"
    local action="$2"
    local details="$3"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "$timestamp: EXTERNAL-PR-$pr_number: $action: $details" >> "$LOG_FILE"
    echo "$timestamp: EXTERNAL-PR-$pr_number: $action: $details" >> "$AUDIT_FILE"
}

log_error() {
    local message="$1"
    echo -e "${RED}ERROR: $message${NC}" >&2
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ"): ERROR: $message" >> "$LOG_FILE"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}SUCCESS: $message${NC}"
}

log_info() {
    local message="$1"
    echo -e "${BLUE}INFO: $message${NC}"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}WARNING: $message${NC}"
}

# Security validation
validate_environment() {
    # Check if running in correct directory
    if [[ ! -f "$PROJECT_ROOT/package.json" ]] || [[ ! -d "$PROJECT_ROOT/.github" ]]; then
        log_error "Must be run from DevOnboarder project root"
        exit 1
    fi

    # Check for required tools
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is required but not installed"
        exit 1
    fi

    # Check authentication
    if ! gh auth status &> /dev/null; then
        log_error "Not authenticated with GitHub CLI. Run 'gh auth login' first"
        exit 1
    fi

    # Verify token has required scopes
    if ! gh repo view --json viewerPermission | jq -e '.viewerPermission == "ADMIN" or .viewerPermission == "MAINTAIN"' &> /dev/null; then
        log_error "Insufficient permissions. Must be repository maintainer or admin"
        exit 1
    fi
}

# PR validation
validate_pr() {
    local pr_number="$1"

    # Check if PR exists
    if ! gh pr view "$pr_number" &> /dev/null; then
        log_error "PR #$pr_number does not exist"
        return 1
    fi

    # Check if PR is from external contributor (fork)
    local pr_info
    pr_info=$(gh pr view "$pr_number" --json headRepository,author --jq '{headRepo: .headRepository.nameWithOwner, author: .author.login, isFork: (.headRepository.isFork // false)}')

    local is_fork
    is_fork=$(echo "$pr_info" | jq -r '.isFork')

    if [[ "$is_fork" != "true" ]]; then
        log_warning "PR #$pr_number is not from a fork. Consider using standard procedures"
        return 0
    fi

    log_info "PR #$pr_number validated as external PR from fork"
    return 0
}

# Manual comment function
manual_comment() {
    local pr_number="$1"
    local message="$2"

    log_info "Adding manual comment to PR #$pr_number"

    if gh pr comment "$pr_number" --body "$message"; then
        log_success "Comment added to PR #$pr_number"
        log_action "$pr_number" "COMMENT" "Manual comment added: $message"
    else
        log_error "Failed to add comment to PR #$pr_number"
        return 1
    fi
}

# Manual workflow dispatch
dispatch_workflow() {
    local pr_number="$1"
    local workflow_name="${2:-External PR Privileged Operations}"

    log_info "Dispatching workflow '$workflow_name' for PR #$pr_number"

    if gh workflow run "$workflow_name" -f pr_number="$pr_number"; then
        log_success "Workflow '$workflow_name' dispatched for PR #$pr_number"
        log_action "$pr_number" "WORKFLOW_DISPATCH" "Dispatched workflow: $workflow_name"
    else
        log_error "Failed to dispatch workflow for PR #$pr_number"
        return 1
    fi
}

# Manual merge function
manual_merge() {
    local pr_number="$1"
    local merge_method="${2:-squash}"
    local delete_branch="${3:-true}"

    log_info "Manually merging PR #$pr_number with method: $merge_method"

    local merge_cmd="gh pr merge $pr_number --$merge_method"
    if [[ "$delete_branch" == "true" ]]; then
        merge_cmd="$merge_cmd --delete-branch"
    fi

    if eval "$merge_cmd"; then
        log_success "PR #$pr_number merged successfully"
        log_action "$pr_number" "MERGE" "Manual merge with method: $merge_method, delete_branch: $delete_branch"
    else
        log_error "Failed to merge PR #$pr_number"
        return 1
    fi
}

# Security block function
security_block() {
    local pr_number="$1"
    local reason="$2"

    log_warning "Security blocking PR #$pr_number: $reason"

    # Add security-blocked label
    if gh pr edit "$pr_number" --add-label "security-blocked"; then
        log_success "Added security-blocked label to PR #$pr_number"
    else
        log_error "Failed to add security-blocked label"
    fi

    # Create security incident issue
    local issue_body="## 🚨 Security Incident: External PR #$pr_number

**Reason**: $reason
**Blocked By**: $(gh auth status --show-token | grep -o 'Logged in to [^ ]*' || echo 'Maintainer')
**Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

### Actions Taken
- PR blocked with 'security-blocked' label
- Security incident issue created
- @security-team notified

### Next Steps
1. Security team review required
2. Determine appropriate response
3. Update incident status"

    if gh issue create \
        --title "🚨 SECURITY: External PR #$pr_number Blocked - $reason" \
        --body "$issue_body" \
        --label "security-incident,external-pr"; then

        log_success "Security incident issue created for PR #$pr_number"
        log_action "$pr_number" "SECURITY_BLOCK" "Security incident created: $reason"
    else
        log_error "Failed to create security incident issue"
    fi
}

# Emergency fix application
apply_emergency_fix() {
    local pr_number="$1"
    local fix_description="$2"

    log_info "Applying emergency fix to PR #$pr_number: $fix_description"

    # Checkout PR
    if ! gh pr checkout "$pr_number"; then
        log_error "Failed to checkout PR #$pr_number"
        return 1
    fi

    # Create fix branch
    local fix_branch="fix-external-pr-$pr_number"
    git checkout -b "$fix_branch"

    log_info "Created fix branch: $fix_branch"
    log_info "Apply your fixes now, then run: git add . && git commit -m \"FIX: $fix_description\""
    log_info "After committing, run: git push origin $fix_branch"

    # Wait for user to apply fixes
    read -p "Press Enter after applying and committing fixes..."

    # Push fixes
    if git push origin "$fix_branch"; then
        log_success "Fix branch pushed: $fix_branch"
        log_action "$pr_number" "EMERGENCY_FIX" "Applied fix: $fix_description, branch: $fix_branch"
    else
        log_error "Failed to push fix branch"
        return 1
    fi

    # Comment on PR
    local comment_body="## 🔧 Emergency Fix Applied

I've applied fixes for validation issues in your external PR. Here's what was addressed:

**Fix Description**: $fix_description

**Fix Branch**: \`$fix_branch\`

Please review the changes in the fix branch. If everything looks good, you can:
1. Merge the fix branch into your PR branch
2. Push the updated changes
3. Request re-validation

The fix addresses the issues that were preventing automated validation."

    manual_comment "$pr_number" "$comment_body"
}

# Batch processing function
batch_process() {
    local pr_list="$1"
    local action="$2"
    local action_params="${3:-}"

    log_info "Starting batch processing: $action for PRs: $pr_list"

    local success_count=0
    local fail_count=0

    for pr in $pr_list; do
        log_info "Processing PR #$pr..."

        case "$action" in
            "comment")
                if manual_comment "$pr" "$action_params"; then
                    ((success_count++))
                else
                    ((fail_count++))
                fi
                ;;
            "dispatch")
                if dispatch_workflow "$pr" "$action_params"; then
                    ((success_count++))
                else
                    ((fail_count++))
                fi
                ;;
            *)
                log_error "Unknown batch action: $action"
                ((fail_count++))
                ;;
        esac
    done

    log_info "Batch processing complete: $success_count successful, $fail_count failed"
    log_action "BATCH" "BATCH_PROCESS" "Action: $action, Success: $success_count, Failed: $fail_count"
}

# Interactive menu
show_menu() {
    echo
    echo "=== External PR Maintainer Override Tool ==="
    echo "Security Level: Tier 3 - Maintainer Override Zone"
    echo
    echo "Available operations:"
    echo "1. Manual Comment"
    echo "2. Dispatch Workflow"
    echo "3. Manual Merge"
    echo "4. Security Block"
    echo "5. Apply Emergency Fix"
    echo "6. Batch Process"
    echo "7. View PR Details"
    echo "8. Exit"
    echo
}

# Main menu handler
handle_menu_choice() {
    local choice="$1"

    case "$choice" in
        1) # Manual Comment
            read -p "Enter PR number: " pr_number
            read -p "Enter comment message: " message
            validate_pr "$pr_number" && manual_comment "$pr_number" "$message"
            ;;
        2) # Dispatch Workflow
            read -p "Enter PR number: " pr_number
            read -p "Enter workflow name (default: External PR Privileged Operations): " workflow_name
            workflow_name="${workflow_name:-External PR Privileged Operations}"
            validate_pr "$pr_number" && dispatch_workflow "$pr_number" "$workflow_name"
            ;;
        3) # Manual Merge
            read -p "Enter PR number: " pr_number
            echo "Merge methods: merge, squash, rebase"
            read -p "Enter merge method (default: squash): " merge_method
            merge_method="${merge_method:-squash}"
            read -p "Delete branch after merge? (y/n, default: y): " delete_branch
            delete_branch="${delete_branch:-y}"
            [[ "$delete_branch" == "y" ]] && delete_branch="true" || delete_branch="false"
            validate_pr "$pr_number" && manual_merge "$pr_number" "$merge_method" "$delete_branch"
            ;;
        4) # Security Block
            read -p "Enter PR number: " pr_number
            read -p "Enter reason for blocking: " reason
            validate_pr "$pr_number" && security_block "$pr_number" "$reason"
            ;;
        5) # Apply Emergency Fix
            read -p "Enter PR number: " pr_number
            read -p "Enter fix description: " fix_description
            validate_pr "$pr_number" && apply_emergency_fix "$pr_number" "$fix_description"
            ;;
        6) # Batch Process
            read -p "Enter PR numbers (space-separated): " pr_list
            echo "Batch actions: comment, dispatch"
            read -p "Enter action: " action
            case "$action" in
                "comment")
                    read -p "Enter comment message: " message
                    batch_process "$pr_list" "comment" "$message"
                    ;;
                "dispatch")
                    read -p "Enter workflow name (default: External PR Privileged Operations): " workflow_name
                    workflow_name="${workflow_name:-External PR Privileged Operations}"
                    batch_process "$pr_list" "dispatch" "$workflow_name"
                    ;;
                *)
                    log_error "Invalid batch action"
                    ;;
            esac
            ;;
        7) # View PR Details
            read -p "Enter PR number: " pr_number
            echo
            gh pr view "$pr_number" --json number,title,author,headRepository,reviews,labels
            ;;
        8) # Exit
            echo "Exiting maintainer override tool"
            exit 0
            ;;
        *)
            log_error "Invalid choice"
            ;;
    esac
}

# Main function
main() {
    # Validate environment
    validate_environment

    # Create log directory if it doesn't exist
    mkdir -p "$PROJECT_ROOT/logs"

    log_info "Maintainer override tool started"
    log_info "Security Level: Tier 3 - All actions will be audited"

    # Interactive mode
    while true; do
        show_menu
        read -p "Enter your choice (1-8): " choice
        handle_menu_choice "$choice"
        echo
        read -p "Press Enter to continue..."
    done
}

# Command-line mode
if [[ $# -gt 0 ]]; then
    case "$1" in
        "comment")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 comment <pr_number> <message>"
                exit 1
            fi
            validate_environment
            validate_pr "$2" && manual_comment "$2" "$3"
            ;;
        "dispatch")
            workflow_name="External PR Privileged Operations"
            if [[ $# -ge 3 ]]; then
                workflow_name="$3"
            fi
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 dispatch <pr_number> [workflow_name]"
                exit 1
            fi
            validate_environment
            validate_pr "$2" && dispatch_workflow "$2" "$workflow_name"
            ;;
        "merge")
            merge_method="squash"
            delete_branch="true"
            if [[ $# -ge 3 ]]; then
                merge_method="$3"
            fi
            if [[ $# -ge 4 ]]; then
                [[ "$4" == "true" ]] && delete_branch="true" || delete_branch="false"
            fi
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 merge <pr_number> [merge_method] [delete_branch]"
                exit 1
            fi
            validate_environment
            validate_pr "$2" && manual_merge "$2" "$merge_method" "$delete_branch"
            ;;
        "block")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 block <pr_number> <reason>"
                exit 1
            fi
            validate_environment
            validate_pr "$2" && security_block "$2" "$3"
            ;;
        "batch-comment")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 batch-comment <pr_numbers> <message>"
                exit 1
            fi
            validate_environment
            batch_process "$2" "comment" "$3"
            ;;
        "batch-dispatch")
            workflow_name="External PR Privileged Operations"
            if [[ $# -ge 3 ]]; then
                workflow_name="$3"
            fi
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 batch-dispatch <pr_numbers> [workflow_name]"
                exit 1
            fi
            validate_environment
            batch_process "$2" "dispatch" "$workflow_name"
            ;;
        *)
            echo "Usage: $0 [command] [args...]"
            echo "Commands:"
            echo "  comment <pr_number> <message>          - Add manual comment"
            echo "  dispatch <pr_number> [workflow]         - Dispatch workflow"
            echo "  merge <pr_number> [method] [del_branch] - Manual merge"
            echo "  block <pr_number> <reason>             - Security block PR"
            echo "  batch-comment <prs> <message>          - Batch comments"
            echo "  batch-dispatch <prs> [workflow]        - Batch workflow dispatch"
            echo "  (no args for interactive mode)"
            exit 1
            ;;
    esac
else
    main
fi