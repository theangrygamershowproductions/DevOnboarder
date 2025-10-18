#!/bin/bash
# scripts/log_workflow_failure.sh
# Enhanced workflow failure logging and diagnosis for DevOnboarder CI

set -euo pipefail

# Initialize logging
LOG_DIR="logs/workflow-failures"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date %Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/failure_${TIMESTAMP}.log"

# Redirect all output to log file and console
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder Workflow Failure Logger"
echo "==================================="
echo "Timestamp: $(date)"
echo "Workflow: ${GITHUB_WORKFLOW:-unknown}"
echo "Job: ${GITHUB_JOB:-unknown}"
echo "Run ID: ${GITHUB_RUN_ID:-unknown}"
echo "Repository: ${GITHUB_REPOSITORY:-unknown}"
echo "Actor: ${GITHUB_ACTOR:-unknown}"
echo "Event: ${GITHUB_EVENT_NAME:-unknown}"
echo "Ref: ${GITHUB_REF:-unknown}"
echo ""

# Function to log failure context
log_failure_context() {
    local failure_type="$1"
    local error_message="$2"

    echo "FAILURE TYPE: $failure_type"
    echo "ERROR MESSAGE: $error_message"
    echo ""

    # Log environment variables (sanitized)
    echo "ENVIRONMENT CONTEXT:"
    echo "GITHUB_WORKSPACE: ${GITHUB_WORKSPACE:-not set}"
    echo "RUNNER_OS: ${RUNNER_OS:-not set}"
    echo "CI: ${CI:-not set}"
    echo "GITHUB_ACTIONS: ${GITHUB_ACTIONS:-not set}"
    echo ""

    # Log file system context
    echo "FILE SYSTEM CONTEXT:"
    echo "Current directory: $(pwd)"
    echo "Directory contents:"
    ls -la || echo "Could not list directory"
    echo ""

    # Log git context if available
    if command -v git >/dev/null 2>&1; then
        echo "GIT CONTEXT:"
        echo "Git status:"
        git status --porcelain || echo "Could not get git status"
        echo "Current branch:"
        git branch --show-current || echo "Could not get current branch"
        echo "Recent commits:"
        git log --oneline -5 || echo "Could not get git log"
        echo ""
    fi
}

# Function to log GitHub CLI diagnostics
log_gh_diagnostics() {
    echo "GITHUB CLI DIAGNOSTICS:"

    if command -v gh >/dev/null 2>&1; then
        echo "GitHub CLI version:"
        gh --version || echo "Could not get gh version"

        echo "GitHub CLI auth status:"
        gh auth status || echo "Could not get gh auth status"

        echo "Available tokens (sanitized):"
        if [ -n "${GITHUB_TOKEN:-}" ]; then
            echo "GITHUB_TOKEN: available"
        else
            echo "GITHUB_TOKEN: not available"
        fi

        if [ -n "${AAR_TOKEN:-}" ]; then
            echo "AAR_TOKEN: available"
        else
            echo "AAR_TOKEN: not available"
        fi
    else
        echo "GitHub CLI not available"
    fi
    echo ""
}

# Function to capture workflow-specific diagnostics
log_workflow_specific() {
    case "${GITHUB_WORKFLOW:-}" in
        "Auto Fix")
            echo "AUTO FIX WORKFLOW DIAGNOSTICS:"
            echo "Checking for patch files..."
            find . -name "*.patch" -o -name "*.diff" | head -10 || echo "No patch files found"
            ;;
        "CI Monitor")
            echo "CI MONITOR WORKFLOW DIAGNOSTICS:"
            echo "Checking for artifact directories..."
            find . -name "*artifact*" -type d | head -10 || echo "No artifact directories found"
            ;;
        "CI Failure Analyzer")
            echo "CI FAILURE ANALYZER DIAGNOSTICS:"
            echo "Checking virtual environment..."
            if [ -n "${VIRTUAL_ENV:-}" ]; then
                echo "Virtual environment active: $VIRTUAL_ENV"
            else
                echo "No virtual environment active"
            fi
            ;;
        *)
            echo "GENERAL WORKFLOW DIAGNOSTICS:"
            echo "No specific diagnostics for workflow: ${GITHUB_WORKFLOW:-unknown}"
            ;;
    esac
    echo ""
}

# Main execution
if [ $# -ge 2 ]; then
    FAILURE_TYPE="$1"
    ERROR_MESSAGE="$2"
else
    FAILURE_TYPE="UNKNOWN"
    ERROR_MESSAGE="No error message provided"
fi

log_failure_context "$FAILURE_TYPE" "$ERROR_MESSAGE"
log_gh_diagnostics
log_workflow_specific

echo "FAILURE LOG COMPLETE"
echo "Log file: $LOG_FILE"
echo "Use this information for debugging workflow issues"

# If running in GitHub Actions, set output
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "failure_log_file=$LOG_FILE" >> "$GITHUB_OUTPUT"
    echo "failure_timestamp=$TIMESTAMP" >> "$GITHUB_OUTPUT"
fi
