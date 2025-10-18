#!/bin/bash
# =============================================================================
# File: scripts/git_safety_wrapper.sh
# Version: 1.0.0
# Author: DevOnboarder Project
# Created: 2025-08-05
# Purpose: Git wrapper that enforces --no-verify approval requirements
# DevOnboarder Project Standards: Compliant with copilot-instructions.md
# =============================================================================

set -euo pipefail

# Centralized logging
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/git_safety_$(date %Y%m%d_%H%M%S).log"

log_info() {
    echo " $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo " $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo " $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo " $1" | tee -a "$LOG_FILE"
}

# Check for Potato Approval file
check_potato_approval() {
    local approval_file=".potato_emergency_approval"

    if [ ! -f "$approval_file" ]; then
        return 1
    fi

    # Check if approval is still valid (within 1 hour)
    local approval_time
    approval_time=$(stat -c %Y "$approval_file" 2>/dev/null || echo 0)
    local current_time
    current_time=$(date %s)
    local time_diff=$((current_time - approval_time))

    # 1 hour = 3600 seconds
    if [ "$time_diff" -gt 3600 ]; then
        log_warning "Potato approval expired (older than 1 hour)"
        rm -f "$approval_file"
        return 1
    fi

    return 0
}

# Create emergency approval prompt
request_potato_approval() {
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "🥔 POTATO EMERGENCY APPROVAL REQUIRED"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "You are attempting to use --no-verify which bypasses DevOnboarder's"
    echo "quality gates. This should only be used in true emergencies."
    echo ""
    echo "DevOnboarder's quality gates exist to maintain the 'quiet reliability'"
    echo "philosophy and prevent technical debt accumulation."
    echo ""

    # Show current quality gate status
    echo "Current quality gate issues:"
    echo "────────────────────────────────────────────────────────────────"

    # Try to run pre-commit to show what would fail
    if command -v pre-commit >/dev/null 2>&1; then
        echo "Running pre-commit check to show issues..."
        pre-commit run --all-files 2>&1 | head -20 || true
    else
        echo "Pre-commit not available - cannot show specific issues"
    fi

    echo "────────────────────────────────────────────────────────────────"
    echo ""

    # Emergency justification questions
    echo "Emergency Justification Required:"
    echo ""

    read -r -p "1. Is this a production outage or critical security fix? (y/N): " is_emergency
    if [[ ! "$is_emergency" =~ ^[Yy]$ ]]; then
        log_error "Not a valid emergency - please fix quality gate issues instead"
        return 1
    fi

    read -r -p "2. Describe the emergency (minimum 10 characters): " emergency_reason
    if [ ${#emergency_reason} -lt 10 ]; then
        log_error "Emergency description too short - please provide detailed justification"
        return 1
    fi

    read -r -p "3. What is the immediate impact if not committed now?: " impact
    if [ ${#impact} -lt 5 ]; then
        log_error "Impact description required"
        return 1
    fi

    read -r -p "4. How will you fix the quality issues afterward?: " rollback_plan
    if [ ${#rollback_plan} -lt 5 ]; then
        log_error "Rollback plan required"
        return 1
    fi

    read -r -p "5. Enter your initials for approval tracking: " initials
    if [ ${#initials} -lt 1 ]; then
        log_error "Initials required for tracking"
        return 1
    fi

    # Final confirmation
    echo ""
    echo "Emergency Approval Summary:"
    echo "──────────────────────────"
    echo "Reason: $emergency_reason"
    echo "Impact: $impact"
    echo "Rollback: $rollback_plan"
    echo "Approved by: $initials"
    echo "Time: $(date)"
    echo ""

    read -r -p "Confirm this is a true emergency requiring --no-verify? (type 'EMERGENCY'): " confirmation
    if [ "$confirmation" != "EMERGENCY" ]; then
        log_error "Emergency not confirmed - please fix quality issues properly"
        return 1
    fi

    # Create approval file with details
    {
        echo "# POTATO EMERGENCY APPROVAL"
        echo "# Date: $(date)"
        echo "# Approved by: $initials"
        echo "# Reason: $emergency_reason"
        echo "# Impact: $impact"
        echo "# Rollback: $rollback_plan"
        echo "# Valid until: $(date -d '1 hour')"
    } > .potato_emergency_approval

    log_success "Emergency approval granted for 1 hour"

    # Schedule automatic cleanup
    (sleep 3600 && rm -f .potato_emergency_approval) &

    return 0
}

# Main git wrapper function
git_wrapper() {
    local args=("$@")
    local has_no_verify=false

    # Check if --no-verify is in arguments
    for arg in "${args[@]}"; do
        if [ "$arg" = "--no-verify" ]; then
            has_no_verify=true
            break
        fi
    done

    # If --no-verify is used, check for approval
    if [ "$has_no_verify" = true ]; then
        log_warning "Detected --no-verify usage in git command"

        if ! check_potato_approval; then
            echo ""
            log_error "No valid Potato approval found for --no-verify usage"

            if ! request_potato_approval; then
                log_error "Emergency approval denied - command blocked"
                echo ""
                echo "DevOnboarder requires fixing quality issues rather than bypassing them."
                echo "This maintains our 'quiet reliability' philosophy."
                echo ""
                echo "Suggested actions:"
                echo "1. Run: ./scripts/qc_pre_push.sh to see specific issues"
                echo "2. Fix the identified problems"
                echo "3. Commit normally without --no-verify"
                echo ""
                return 1
            fi
        else
            log_info "Valid Potato approval found - allowing --no-verify"
        fi

        # Log the emergency usage
        {
            echo "EMERGENCY COMMIT LOG"
            echo "Date: $(date)"
            echo "Command: git ${args[*]}"
            echo "Working directory: $(pwd)"
            echo "Git status:"
            git status --porcelain
            echo "────────────────────────────────────────"
        } >> "$LOG_FILE"
    fi

    # Execute the git command
    log_info "Executing: git ${args[*]}"
    exec git "${args[@]}"
}

# Show usage
show_usage() {
    echo "Git Safety Wrapper for DevOnboarder"
    echo ""
    echo "Purpose: Enforce Potato Approval for --no-verify usage"
    echo ""
    echo "Usage: $0 <git-command> [arguments]"
    echo ""
    echo "Examples:"
    echo "  $0 commit -m 'Normal commit'           # No approval needed"
    echo "  $0 commit --no-verify -m 'Emergency'   # Requires Potato approval"
    echo "  $0 push origin main                    # No approval needed"
    echo ""
    echo "Emergency Approval Process:"
    echo "1. Justification questions"
    echo "2. Impact assessment"
    echo "3. Rollback plan required"
    echo "4. 1-hour time limit"
    echo "5. Automatic cleanup"
}

# Main execution
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

# Handle help requests
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "help" ]; then
    show_usage
    exit 0
fi

# Execute git wrapper
git_wrapper "$@"
