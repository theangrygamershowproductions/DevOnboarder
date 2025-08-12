#!/bin/bash
# =============================================================================
# File: scripts/show_no_verify_enforcement.sh
# Version: 1.0.0
# Author: DevOnboarder Project
# Created: 2025-08-05
# Purpose: Display comprehensive --no-verify enforcement system status
# DevOnboarder Project Standards: Compliant with copilot-instructions.md
# =============================================================================

set -euo pipefail

# Centralized logging
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/no_verify_enforcement_$(date +%Y%m%d_%H%M%S).log"

log_info() {
    echo "INFO: $1" | tee -a "$LOG_FILE"
}

show_enforcement_status() {
    echo "SYMBOL"
    echo "POTATO DevOnboarder --no-verify Enforcement System Status"
    echo "SYMBOL"
    echo ""

    # Policy Documentation
    echo "SYMBOL POLICY DOCUMENTATION:"
    if [ -f "docs/NO_VERIFY_POLICY.md" ]; then
        echo "SUCCESS Policy document: docs/NO_VERIFY_POLICY.md"
        echo "   - Zero Tolerance Policy defined"
        echo "   - Emergency procedures documented"
        echo "   - Potato Approval requirements specified"
    else
        echo "FAILED Policy document missing"
    fi
    echo ""

    # Validation Scripts
    echo "CONFIG ENFORCEMENT SCRIPTS:"
    if [ -f "scripts/validate_no_verify_usage.sh" ] && [ -x "scripts/validate_no_verify_usage.sh" ]; then
        echo "SUCCESS Validation script: scripts/validate_no_verify_usage.sh (executable)"
    else
        echo "FAILED Validation script missing or not executable"
    fi

    if [ -f "scripts/git_safety_wrapper.sh" ] && [ -x "scripts/git_safety_wrapper.sh" ]; then
        echo "SUCCESS Safety wrapper: scripts/git_safety_wrapper.sh (executable)"
    else
        echo "FAILED Safety wrapper missing or not executable"
    fi
    echo ""

    # Pre-commit Hooks
    echo "HOOK PRE-COMMIT INTEGRATION:"
    if [ -f ".pre-commit-config.yaml" ]; then
        if grep -q "validate-no-verify" ".pre-commit-config.yaml"; then
            echo "SUCCESS Pre-commit hook: validate-no-verify configured"
        else
            echo "FAILED Pre-commit hook not configured"
        fi
    else
        echo "FAILED Pre-commit config missing"
    fi
    echo ""

    # CI/CD Integration
    echo "DEPLOY CI/CD INTEGRATION:"
    if [ -f ".github/workflows/no-verify-policy.yml" ]; then
        echo "SUCCESS GitHub Actions: no-verify-policy.yml configured"
    else
        echo "FAILED GitHub Actions workflow missing"
    fi
    echo ""

    # Current Status
    echo "STATS CURRENT COMPLIANCE STATUS:"
    log_info "Running validation check"

    if ./scripts/validate_no_verify_usage.sh >/dev/null 2>&1; then
        echo "SUCCESS COMPLIANT: All --no-verify usage properly authorized"
        local emergency_approvals
        emergency_approvals=$(grep -r "POTATO.*APPROVED\|Emergency.*Potato" . --include="*.sh" --include="*.md" 2>/dev/null | wc -l || echo 0)
        echo "   Emergency approvals found: $emergency_approvals"
    else
        echo "FAILED VIOLATION: Unauthorized --no-verify usage detected"
        echo "   Run: ./scripts/validate_no_verify_usage.sh for details"
    fi
    echo ""

    # Emergency Procedures
    echo "SYMBOL EMERGENCY PROCEDURES:"
    echo "For true emergencies requiring --no-verify bypass:"
    echo "1. Use: ./scripts/git_safety_wrapper.sh commit --no-verify -m 'Emergency'"
    echo "2. Answer justification questions (production outage, security fix, etc.)"
    echo "3. Provide impact assessment and rollback plan"
    echo "4. Receive 1-hour time-limited Potato Approval"
    echo "5. Fix quality issues in immediate follow-up commit"
    echo ""

    # Quality Gate Alternative
    echo "SUCCESS PREFERRED: QUALITY GATE RESOLUTION:"
    echo "Instead of bypassing, fix the actual issues:"
    echo "1. Run: ./scripts/qc_pre_push.sh (identify specific issues)"
    echo "2. Fix: python -m ruff check --fix . (Python issues)"
    echo "3. Fix: markdownlint --fix docs/ (documentation issues)"
    echo "4. Commit: git commit -m 'Fix quality gate violations'"
    echo ""

    # Monitoring
    echo "SYMBOL MONITORING CAPABILITIES:"
    echo "- Comprehensive audit logging: logs/git_safety_*.log"
    echo "- Emergency approval tracking with timestamps"
    echo "- CI pipeline validation reports"
    echo "- Pre-commit hook enforcement"
    echo "- Git alias detection and prevention"
    echo ""

    echo "SYMBOL"
    echo "DevOnboarder maintains 'quiet reliability' through quality gates."
    echo "This enforcement system ensures --no-verify is only used for true"
    echo "emergencies with proper approval and documentation."
    echo "SYMBOL"
}

# Show usage
show_usage() {
    echo "No-Verify Enforcement System Status Display"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  status     - Show enforcement system status (default)"
    echo "  test       - Test emergency approval process"
    echo "  help       - Show this help"
}

# Test emergency approval process
test_emergency_process() {
    echo "Testing emergency approval process..."
    echo ""
    echo "This would normally prompt for:"
    echo "1. Emergency justification (production outage, security fix, etc.)"
    echo "2. Impact assessment (what happens if not fixed immediately)"
    echo "3. Rollback plan (how to fix quality issues afterward)"
    echo "4. Approval confirmation (type 'EMERGENCY' to confirm)"
    echo ""
    echo "For actual emergency usage:"
    echo "./scripts/git_safety_wrapper.sh commit --no-verify -m 'Emergency fix'"
}

# Main execution
case "${1:-status}" in
    "status")
        show_enforcement_status
        ;;
    "test")
        test_emergency_process
        ;;
    "help")
        show_usage
        ;;
    *)
        echo "Unknown command: ${1:-}"
        show_usage
        exit 1
        ;;
esac
