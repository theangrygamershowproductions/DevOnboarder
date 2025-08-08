#!/bin/bash
# =============================================================================
# File: scripts/validate_no_verify_usage.sh
# Version: 1.0.0
# Author: DevOnboarder Project
# Created: 2025-08-05
# Purpose: Validate --no-verify usage requires explicit Potato Approval
# DevOnboarder Project Standards: Compliant with copilot-instructions.md
# =============================================================================

set -euo pipefail

# Centralized logging
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/no_verify_validation_$(date +%Y%m%d_%H%M%S).log"

log_info() {
    echo "INFO: $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "ERROR: $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo "WARNING: $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo "SUCCESS: $1" | tee -a "$LOG_FILE"
}

# Files that legitimately contain --no-verify references (ignore list)
is_ignored_file() {
    local file="$1"

    # Ignore patterns for legitimate --no-verify usage
    case "$file" in
        # Validation scripts themselves need to search for patterns
        "./scripts/validate_no_verify_usage.sh") return 0 ;;
        "./scripts/git_safety_wrapper.sh") return 0 ;;

        # Documentation that explains the policy (with examples of what NOT to do)
        "./docs/NO_VERIFY_POLICY.md") return 0 ;;
        "./docs/NO_VERIFY_QUICK_REFERENCE.md") return 0 ;;
        "./docs/standards/vscode-ci-integration-standard.md") return 0 ;;
        "./docs/ci-dashboard.md") return 0 ;;
        "./.github/copilot-instructions.md") return 0 ;;

        # CI workflows that enforce the policy
        "./.github/workflows/no-verify-policy.yml") return 0 ;;

        # Any file with explicit ignore comment
        *)
            if grep -q "# NO-VERIFY-IGNORE:" "$file" 2>/dev/null; then
                return 0
            fi
            return 1
            ;;
    esac
}

# Check for --no-verify usage in scripts and documentation
check_no_verify_usage() {
    log_info "Scanning for --no-verify usage across DevOnboarder"

    local violations=0
    local emergency_approved=0

    # Search all shell scripts for --no-verify
    while IFS= read -r -d '' file; do
        # Skip ignored files
        if is_ignored_file "$file"; then
            continue
        fi

        if grep -n "git.*--no-verify" "$file" 2>/dev/null; then
            log_warning "Found --no-verify usage in: $file"

            # Check for Potato Approval comment
            if grep -B5 -A5 "git.*--no-verify" "$file" | grep -i "potato approval\|emergency approved\|# POTATO:" >/dev/null 2>&1; then
                log_info "Emergency approval found for: $file"
                ((emergency_approved++))
            else
                log_error "VIOLATION: Unauthorized --no-verify usage in: $file"
                ((violations++))
            fi
        fi
    done < <(find . -name "*.sh" -type f -print0)

    # Search documentation for --no-verify references
    while IFS= read -r -d '' file; do
        # Skip ignored files
        if is_ignored_file "$file"; then
            continue
        fi

        if grep -n "\-\-no-verify" "$file" 2>/dev/null; then
            local line_with_context
            line_with_context=$(grep -B2 -A2 "\-\-no-verify" "$file")

            if echo "$line_with_context" | grep -i "potato approval\|emergency\|forbidden\|violation" >/dev/null 2>&1; then
                log_info "Authorized documentation reference in: $file"
            else
                log_warning "Documentation reference needs Potato context in: $file"
            fi
        fi
    done < <(find . -name "*.md" -type f -print0)

    # Summary
    echo ""
    log_info "No-verify validation summary:"
    echo "Emergency approved usages: $emergency_approved"
    echo "Unauthorized violations: $violations"

    if [ "$violations" -gt 0 ]; then
        log_error "CRITICAL: Found $violations unauthorized --no-verify usage(s)"
        echo ""
        echo "Required actions:"
        echo "1. Remove all unauthorized --no-verify usage"
        echo "2. Fix underlying issues instead of bypassing quality gates"
        echo "3. For true emergencies, add explicit Potato Approval comment"
        return 1
    else
        log_success "All --no-verify usage properly authorized"
        return 0
    fi
}

# Check for git aliases that might bypass hooks
check_git_aliases() {
    log_info "Checking for git aliases that bypass pre-commit hooks"

    local alias_violations=0

    # Check global git config
    if git config --global --get-regexp alias 2>/dev/null | grep -E "(--no-verify|bypass|skip)" >/dev/null 2>&1; then
        log_error "VIOLATION: Global git aliases found that bypass hooks"
        git config --global --get-regexp alias | grep -E "(--no-verify|bypass|skip)"
        ((alias_violations++))
    fi

    # Check local git config
    if git config --local --get-regexp alias 2>/dev/null | grep -E "(--no-verify|bypass|skip)" >/dev/null 2>&1; then
        log_error "VIOLATION: Local git aliases found that bypass hooks"
        git config --local --get-regexp alias | grep -E "(--no-verify|bypass|skip)"
        ((alias_violations++))
    fi

    if [ "$alias_violations" -gt 0 ]; then
        log_error "Found $alias_violations git aliases that bypass quality gates"
        return 1
    else
        log_success "No problematic git aliases found"
        return 0
    fi
}

# Validate emergency approval format
validate_emergency_approval() {
    local file="$1"
    local line_number="$2"

    # Check for proper emergency approval format within 5 lines
    if sed -n "$((line_number-5)),$((line_number+5))p" "$file" | grep -E "# POTATO: EMERGENCY APPROVED|# Emergency Potato Approval|# CRITICAL: Potato approved" >/dev/null; then
        return 0
    else
        return 1
    fi
}

# Generate emergency approval template
generate_emergency_template() {
    log_info "Generating emergency approval template"

    cat << 'EOF'
# =============================================================================
# EMERGENCY --no-verify APPROVAL TEMPLATE
# =============================================================================
#
# ONLY use this template for true emergencies that require bypassing quality gates
# All usage must have explicit Potato Approval documented
#
# Template format:
#
# # POTATO: EMERGENCY APPROVED - [DATE] - [INITIALS]
# # REASON: [Specific emergency reason]
# # IMPACT: [What happens if not bypassed immediately]
# # ROLLBACK: [How to properly fix after emergency]
# git commit --no-verify -m "EMERGENCY: [description]"
#
# Example:
# # POTATO: EMERGENCY APPROVED - 2025-08-05 - PL
# # REASON: Production outage, hotfix needed immediately
# # IMPACT: Service down affecting users
# # ROLLBACK: Will fix linting violations in follow-up commit
# git commit --no-verify -m "EMERGENCY: Fix critical auth service crash"
#
# =============================================================================
EOF
}

# Main validation function
main() {
    log_info "Starting --no-verify usage validation"

    local exit_code=0

    # Run all checks
    if ! check_no_verify_usage; then
        exit_code=1
    fi

    if ! check_git_aliases; then
        exit_code=1
    fi

    # Show emergency template if violations found
    if [ "$exit_code" -ne 0 ]; then
        echo ""
        log_info "Emergency approval template for authorized usage:"
        echo ""
        generate_emergency_template
    fi

    if [ "$exit_code" -eq 0 ]; then
        log_success "All --no-verify usage validation passed"
    else
        log_error "Validation failed - unauthorized --no-verify usage detected"
    fi

    return $exit_code
}

# Show usage
show_usage() {
    echo "No-Verify Usage Validator for DevOnboarder"
    echo ""
    echo "Purpose: Ensure --no-verify only used with explicit Potato Approval"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  validate   - Run full validation (default)"
    echo "  template   - Show emergency approval template"
    echo "  help       - Show this help"
    echo ""
    echo "Emergency Usage Requirements:"
    echo "1. Must have explicit Potato Approval comment"
    echo "2. Must document emergency reason and impact"
    echo "3. Must include rollback plan"
    echo "4. Only for true emergencies, not convenience"
}

# Handle command line arguments
case "${1:-validate}" in
    "validate")
        main
        ;;
    "template")
        generate_emergency_template
        ;;
    "help")
        show_usage
        ;;
    *)
        log_error "Unknown command: ${1:-}"
        show_usage
        exit 1
        ;;
esac
