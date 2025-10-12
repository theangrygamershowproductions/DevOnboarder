#!/usr/bin/env bash
# DevOnboarder External PR Detection Utility
# Implements fork detection and external PR identification
# Used by CI workflows and automation scripts

set -euo pipefail

# Source color utilities if available
if [ -f "/home/potato/TAGS/shared/scripts/color_utils.sh" ]; then
    source "/home/potato/TAGS/shared/scripts/color_utils.sh"
fi

# Calculate repository root
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"

# Logging setup
LOG_FILE="$REPO_ROOT/logs/external_pr_detection_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Output format for GitHub Actions
GITHUB_OUTPUT="${GITHUB_OUTPUT:-/dev/stdout}"

usage() {
    cat << EOF
DevOnboarder External PR Detection Utility

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --detect-fork          Detect if current PR is from a fork
    --detect-external      Detect if current PR is from external repository
    --get-pr-info          Get comprehensive PR information
    --validate-security    Validate security context for current PR
    --help                 Show this help message

ENVIRONMENT VARIABLES:
    GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FORK    Fork status from GitHub
    GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FULL_NAME  External repo name
    GITHUB_REPOSITORY                           Current repository

EXAMPLES:
    $0 --detect-fork
    $0 --get-pr-info
    $0 --validate-security

OUTPUT:
    Results are written to stdout and GitHub Actions output format
EOF
}

# Detect if PR is from a forked repository
detect_fork() {
    local is_fork="false"

    # Check GitHub Actions context
    if [ -n "${GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FORK:-}" ]; then
        if [ "$GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FORK" = "true" ]; then
            is_fork="true"
            echo "Fork detected via GitHub Actions context"
        else
            echo "Not a fork according to GitHub Actions context"
        fi
    else
        echo "GitHub Actions fork context not available"
        # Fallback detection would go here if needed
    fi

    # Output for GitHub Actions
    echo "is_fork=$is_fork" >> "$GITHUB_OUTPUT"
    echo "$is_fork"
}

# Detect if PR is from external repository (different owner)
detect_external() {
    local is_external="false"

    # Check GitHub Actions context
    if [ -n "${GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FULL_NAME:-}" ] && [ -n "${GITHUB_REPOSITORY:-}" ]; then
        if [ "$GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FULL_NAME" != "$GITHUB_REPOSITORY" ]; then
            is_external="true"
            echo "External repository detected: $GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FULL_NAME"
        else
            echo "Internal repository PR: $GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FULL_NAME"
        fi
    else
        echo "GitHub Actions repository context not available"
    fi

    # Output for GitHub Actions
    echo "is_external=$is_external" >> "$GITHUB_OUTPUT"
    echo "$is_external"
}

# Get comprehensive PR information
get_pr_info() {
    echo "=== External PR Information ==="

    # Basic PR information
    if [ -n "${GITHUB_EVENT_PULL_REQUEST_NUMBER:-}" ]; then
        echo "PR Number: $GITHUB_EVENT_PULL_REQUEST_NUMBER"
        echo "pr_number=$GITHUB_EVENT_PULL_REQUEST_NUMBER" >> "$GITHUB_OUTPUT"
    fi

    if [ -n "${GITHUB_EVENT_PULL_REQUEST_HEAD_SHA:-}" ]; then
        echo "PR HEAD SHA: $GITHUB_EVENT_PULL_REQUEST_HEAD_SHA"
        echo "head_sha=$GITHUB_EVENT_PULL_REQUEST_HEAD_SHA" >> "$GITHUB_OUTPUT"
    fi

    # Fork detection
    echo "Fork Status: $(detect_fork)"

    # External repository detection
    echo "External Repository: $(detect_external)"

    # Repository information
    if [ -n "${GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_OWNER_LOGIN:-}" ]; then
        echo "PR Owner: $GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_OWNER_LOGIN"
        echo "pr_owner=$GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_OWNER_LOGIN" >> "$GITHUB_OUTPUT"
    fi

    if [ -n "${GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_NAME:-}" ]; then
        echo "PR Repository: $GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_NAME"
        echo "pr_repo=$GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_NAME" >> "$GITHUB_OUTPUT"
    fi

    if [ -n "${GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FULL_NAME:-}" ]; then
        echo "PR Full Repository: $GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FULL_NAME"
        echo "pr_full_repo=$GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FULL_NAME" >> "$GITHUB_OUTPUT"
    fi

    # Base repository information
    if [ -n "${GITHUB_REPOSITORY:-}" ]; then
        echo "Base Repository: $GITHUB_REPOSITORY"
        echo "base_repo=$GITHUB_REPOSITORY" >> "$GITHUB_OUTPUT"
    fi
}

# Validate security context for current PR
validate_security() {
    echo "=== Security Context Validation ==="

    local is_fork="false"
    local is_external="false"
    local security_level="unknown"
    local recommendations=""

    # Perform detections
    is_fork=$(detect_fork)
    is_external=$(detect_external)

    # Determine security level
    if [ "$is_fork" = "true" ] || [ "$is_external" = "true" ]; then
        security_level="external_pr"
        recommendations="Use Tier 1 Safe Execution Zone workflow. Limit permissions. No auto-merge."

        echo "🔒 SECURITY LEVEL: EXTERNAL PR (High Risk)"
        echo "Recommendations:"
        echo "  - Execute in Safe Execution Zone (Tier 1)"
        echo "  - Use read-only permissions only"
        echo "  - No access to repository secrets"
        echo "  - Trigger privileged operations via workflow_run"
        echo "  - Require explicit maintainer approval"
        echo "  - No auto-merge allowed"

    elif [ "$is_fork" = "false" ] && [ "$is_external" = "false" ]; then
        security_level="internal_pr"
        recommendations="Standard CI workflow acceptable."

        echo "✅ SECURITY LEVEL: INTERNAL PR (Standard Risk)"
        echo "Recommendations:"
        echo "  - Standard CI workflow acceptable"
        echo "  - Full permissions available"
        echo "  - Auto-merge may be allowed per policy"

    else
        security_level="unknown"
        recommendations="Unable to determine security context. Manual review required."

        echo "⚠️  SECURITY LEVEL: UNKNOWN"
        echo "Recommendations:"
        echo "  - Manual security review required"
        echo "  - Verify PR origin manually"
        echo "  - Apply most restrictive permissions"
    fi

    # Output for GitHub Actions
    echo "security_level=$security_level" >> "$GITHUB_OUTPUT"
    echo "recommendations=$recommendations" >> "$GITHUB_OUTPUT"

    echo
    echo "Security validation complete."
}

# Main execution logic
main() {
    local command=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --detect-fork)
                command="detect_fork"
                shift
                ;;
            --detect-external)
                command="detect_external"
                shift
                ;;
            --get-pr-info)
                command="get_pr_info"
                shift
                ;;
            --validate-security)
                command="validate_security"
                shift
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                usage >&2
                exit 1
                ;;
        esac
    done

    # Execute command
    case $command in
        detect_fork)
            detect_fork
            ;;
        detect_external)
            detect_external
            ;;
        get_pr_info)
            get_pr_info
            ;;
        validate_security)
            validate_security
            ;;
        "")
            echo "No command specified. Use --help for usage information." >&2
            exit 1
            ;;
    esac
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi