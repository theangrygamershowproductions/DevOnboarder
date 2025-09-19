#!/bin/bash
# scripts/ci_gh_issue_wrapper.sh
# Centralized GitHub issue operations wrapper for CI workflows
# Provides error handling, logging, and permission management

set -e

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
    if ! require_tokens "CI_ISSUE_AUTOMATION_TOKEN" "CI_BOT_TOKEN"; then
        echo "❌ Cannot proceed without required tokens for GitHub issue operations"
        echo "💡 CI issue wrapper requires GitHub API access with issue permissions"
        exit 1
    fi
fi

# Centralized logging
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder CI GitHub Issue Wrapper"
echo "====================================="
echo "Timestamp: $(date)"
echo

# Function to recommend the best token for specific operations
recommend_token_for_operation() {
    local operation="$1"
    case "$operation" in
        "comment"|"close")
            echo "Recommended tokens for issue $operation:"
            echo "  - CI_ISSUE_AUTOMATION_TOKEN (primary)"
            echo "  - CI_ISSUE_TOKEN (specialized for CI failures)"
            echo "  - CLEANUP_CI_FAILURE_KEY (specialized for closing failures)"
            ;;
        "list")
            echo "Recommended tokens for issue listing:"
            echo "  - CI_ISSUE_AUTOMATION_TOKEN (primary)"
            echo "  - DIAGNOSTICS_BOT_KEY (specialized for monitoring)"
            echo "  - CI_HEALTH_KEY (specialized for health checks)"
            ;;
        "pr-comment")
            echo "Recommended tokens for PR operations:"
            echo "  - CHECKLIST_BOT_TOKEN (specialized for PR quality)"
            echo "  - AAR_BOT_TOKEN (specialized for post-merge)"
            echo "  - CI_ISSUE_AUTOMATION_TOKEN (primary fallback)"
            ;;
        "general"|*)
            echo "Token Selection Guide:"
            echo "  Choose the most specific token for your use case"
            echo "  Avoid GITHUB_TOKEN unless absolutely necessary"
            ;;
    esac
}

# Function to get GitHub token following DevOnboarder hierarchy
get_github_token() {
    # DevOnboarder token hierarchy for GitHub issue operations
    # Based on .codex/tokens/token_scope_map.yaml
    local issue_operation_tokens=(
        "CI_ISSUE_AUTOMATION_TOKEN"    # PRIMARY: Main CI automation & issue management
        "CI_ISSUE_TOKEN"              # SPECIALIZED: Creates CI issues on failure
        "DIAGNOSTICS_BOT_KEY"         # SPECIALIZED: Root Artifact Monitor issue creation
        "CI_HEALTH_KEY"               # SPECIALIZED: CI stability monitoring issues
        "CLEANUP_CI_FAILURE_KEY"      # SPECIALIZED: CI failure auto-closer
        "AAR_BOT_TOKEN"               # SPECIALIZED: Post-merge reporting issues
        "REVIEW_KNOWN_ERRORS_KEY"     # SPECIALIZED: Error pattern recognition
        "SECURITY_AUDIT_TOKEN"        # SPECIALIZED: Security policy enforcement
        "VALIDATE_PERMISSIONS_TOKEN"   # SPECIALIZED: Bot permissions validation
        "CI_BOT_TOKEN"                # DEPRECATED: Legacy bot operations (scoped)
        "GITHUB_TOKEN"                # PROHIBITED: Broad permissions (fallback only)
    )

    echo "Checking DevOnboarder token hierarchy for issue operations..."

    for token_name in "${issue_operation_tokens[@]}"; do
        local token_value="${!token_name}"
        if [[ -n "$token_value" ]]; then
            case "$token_name" in
                "CI_ISSUE_AUTOMATION_TOKEN")
                    echo "Using PRIMARY token: $token_name (Main CI automation)"
                    ;;
                "CI_ISSUE_TOKEN"|"DIAGNOSTICS_BOT_KEY"|"CI_HEALTH_KEY"|"CLEANUP_CI_FAILURE_KEY"|"AAR_BOT_TOKEN"|"REVIEW_KNOWN_ERRORS_KEY"|"SECURITY_AUDIT_TOKEN"|"VALIDATE_PERMISSIONS_TOKEN")
                    echo "Using SPECIALIZED token: $token_name (Task-scoped)"
                    ;;
                "CI_BOT_TOKEN")
                    echo "Using DEPRECATED token: $token_name (Legacy - consider upgrading)"
                    ;;
                "GITHUB_TOKEN")
                    echo "Using PROHIBITED token: $token_name (Fallback only - violates No Default Token Policy)"
                    ;;
            esac
            export GITHUB_TOKEN="$token_value"
            return 0
        fi
    done

    echo "ERROR: No GitHub token found in DevOnboarder hierarchy"
    echo "Expected tokens (in priority order):"
    echo "  1. CI_ISSUE_AUTOMATION_TOKEN (primary)"
    echo "  2. Task-specific tokens (CI_ISSUE_TOKEN, DIAGNOSTICS_BOT_KEY, etc.)"
    echo "  3. CI_BOT_TOKEN (deprecated)"
    echo "  4. GITHUB_TOKEN (prohibited - fallback only)"
    echo
    echo "See .codex/tokens/token_scope_map.yaml for complete token registry"
    return 1
}

# Function to validate required environment
validate_environment() {
    if ! get_github_token; then
        exit 1
    fi

    if ! command -v gh >/dev/null 2>&1; then
        echo "ERROR: GitHub CLI (gh) not found"
        exit 1
    fi

    # Test GitHub CLI authentication
    if ! gh auth status >/dev/null 2>&1; then
        echo "ERROR: GitHub CLI not authenticated"
        exit 1
    fi
}

# Function to handle issue comment operations
handle_issue_comment() {
    local issue_number="$1"
    local comment_body="$2"

    if [[ -z "$issue_number" || -z "$comment_body" ]]; then
        echo "ERROR: Issue comment requires issue number and comment body"
        exit 1
    fi

    echo "Adding comment to issue #$issue_number"

    if gh issue comment "$issue_number" --body "$comment_body"; then
        echo "Successfully commented on issue #$issue_number"
        return 0
    else
        echo "ERROR: Failed to comment on issue #$issue_number"
        return 1
    fi
}

# Function to handle issue closing operations with template support
handle_issue_close() {
    local issue_number="$1"
    local close_comment="$2"
    local template_file="$3"

    if [[ -z "$issue_number" ]]; then
        echo "ERROR: Issue close requires issue number"
        exit 1
    fi

    echo "Closing issue #$issue_number"

    # Enhanced two-step process for DevOnboarder terminal output policy compliance
    if [[ -n "$template_file" && -f "$template_file" ]]; then
        echo "Using template file for detailed comment: $template_file"
        # Step 1: Add detailed comment from template file
        if gh issue comment "$issue_number" --body-file "$template_file"; then
            echo "Successfully added detailed comment from template"
            # Step 2: Simple closure
            if gh issue close "$issue_number" --reason completed; then
                echo "Successfully closed issue #$issue_number with template comment"
                return 0
            else
                echo "ERROR: Failed to close issue #$issue_number after adding comment"
                return 1
            fi
        else
            echo "ERROR: Failed to add comment from template file"
            return 1
        fi
    elif [[ -n "$close_comment" ]]; then
        # Legacy single-step process (for simple comments only)
        echo "Using simple comment closure (legacy mode)"
        if gh issue close "$issue_number" --comment "$close_comment"; then
            echo "Successfully closed issue #$issue_number with comment"
            return 0
        else
            echo "ERROR: Failed to close issue #$issue_number"
            return 1
        fi
    else
        # Simple closure without comment
        if gh issue close "$issue_number" --reason completed; then
            echo "Successfully closed issue #$issue_number"
            return 0
        else
            echo "ERROR: Failed to close issue #$issue_number"
            return 1
        fi
    fi
}

# Function to handle issue listing operations
handle_issue_list() {
    local search_query="$1"
    local state="${2:-open}"
    local json_fields="${3:-number,title,labels}"

    echo "Searching for issues with query: $search_query"

    if gh issue list --search "$search_query" --state "$state" --json "$json_fields"; then
        echo "Successfully retrieved issue list"
        return 0
    else
        echo "ERROR: Failed to list issues"
        return 1
    fi
}

# Function to handle PR comment operations
handle_pr_comment() {
    local pr_number="$1"
    local comment_body="$2"

    if [[ -z "$pr_number" || -z "$comment_body" ]]; then
        echo "ERROR: PR comment requires PR number and comment body"
        exit 1
    fi

    echo "Adding comment to PR #$pr_number"

    if gh pr comment "$pr_number" --body "$comment_body"; then
        echo "Successfully commented on PR #$pr_number"
        return 0
    else
        echo "ERROR: Failed to comment on PR #$pr_number"
        return 1
    fi
}

# Main command dispatcher
main() {
    validate_environment

    local operation="$1"
    shift

    case "$operation" in
        "comment")
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                handle_issue_comment "$1" "$2"
            else
                echo "ERROR: Invalid issue number format"
                exit 1
            fi
            ;;
        "close")
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                handle_issue_close "$1" "$2"
            else
                echo "ERROR: Invalid issue number format"
                exit 1
            fi
            ;;
        "list")
            handle_issue_list "$1" "$2" "$3"
            ;;
        "pr-comment")
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                handle_pr_comment "$1" "$2"
            else
                echo "ERROR: Invalid PR number format"
                exit 1
            fi
            ;;
        *)
            echo "Usage: $0 <operation> [args...]"
            echo
            echo "Operations:"
            echo "  comment <issue_number> <comment_body>    - Add comment to issue"
            echo "  close <issue_number> [close_comment]     - Close issue with optional comment"
            echo "  list <search_query> [state] [json_fields] - List issues matching query"
            echo "  pr-comment <pr_number> <comment_body>    - Add comment to pull request"
            echo
            echo "DevOnboarder Token Hierarchy:"
            echo "  PRIMARY: CI_ISSUE_AUTOMATION_TOKEN (main CI automation)"
            echo "  SPECIALIZED: CI_ISSUE_TOKEN, DIAGNOSTICS_BOT_KEY, CI_HEALTH_KEY, etc."
            echo "  DEPRECATED: CI_BOT_TOKEN (legacy)"
            echo "  PROHIBITED: GITHUB_TOKEN (fallback only)"
            echo
            echo "See .codex/tokens/token_scope_map.yaml for complete token registry"
            echo
            recommend_token_for_operation "general"
            exit 1
            ;;
    esac
}

# Handle script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
