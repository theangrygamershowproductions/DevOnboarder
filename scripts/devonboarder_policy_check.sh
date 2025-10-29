#!/bin/bash

# DevOnboarder Policy Quick Reference Tool
# Makes critical policies easily accessible to developers and agents

set -euo pipefail

show_usage() {
    cat << 'EOF'
DevOnboarder Policy Quick Reference

Usage: devonboarder-policy [OPTION]

OPTIONS:
    terminal        Show Terminal Output Policy (ZERO TOLERANCE)
    triage          Show Issue Discovery & Triage SOP
    priority        Show Priority Stack Framework
    escalation      Show Emergency Escalation Procedures
    tokens          Show Token Architecture v2.1 info
    violations      Check for current policy violations
    all             Show all policies (default)

EXAMPLES:
    devonboarder-policy terminal     # Terminal output rules
    devonboarder-policy violations   # Run policy checks
    devonboarder-policy triage       # Issue management process

QUICK CHECKS:
    ./scripts/validate_terminal_output.sh     # Check terminal violations
    ./scripts/qc_pre_push.sh                  # Full quality validation
    ./scripts/smart_env_sync.sh --validate    # Environment consistency
EOF
}

show_terminal_policy() {
    echo "🚨 TERMINAL OUTPUT POLICY - ZERO TOLERANCE"
    echo "=========================================="
    echo ""
    echo " FORBIDDEN (causes immediate hanging):"
    echo "  - echo \" Task completed\"              # Emojis cause hanging"
    echo "  - echo \" Deployment successful\"       # Unicode causes hanging"
    echo "  - echo \"Status: \$STATUS_VAR\"           # Variable expansion causes hanging"
    printf "  - echo -e \"Line1\\nLine2\"                # Multi-line escape sequences\n"
    echo ""
    echo " REQUIRED PATTERNS:"
    echo "  - echo \"Task completed successfully\"    # Plain ASCII only"
    printf "  - printf \"Status: %%s\\n\" \"\$STATUS_VAR\" # Variables with printf\n"
    echo "  - Individual echo commands only          # No multi-line or here-doc"
    echo ""
    echo "🛡️ ENFORCEMENT:"
    echo "  - Pre-commit hooks block violations"
    echo "  - CI enforcement across all workflows"
    echo "  - Current violations: Run ./scripts/validate_terminal_output.sh"
    echo ""
    echo "  REMEMBER: Terminal hanging is CRITICAL FAILURE in DevOnboarder"
}

show_triage_sop() {
    echo " ISSUE DISCOVERY & TRIAGE SOP"
    echo "==============================="
    echo ""
    echo " DECISION FRAMEWORK (4 Steps):"
    echo "  1. Immediate Impact Assessment"
    echo "     - Does this block current work?  Address immediately"
    echo "     - No?  Proceed to Priority Stack evaluation"
    echo ""
    echo "  2. Priority Stack Classification"
    echo "     - Tier 1: Strategic Foundation (meta-frameworks)"
    echo "     - Tier 2: Capability Expansion (high-value features)"
    echo "     - Tier 3: Infrastructure Enhancement (architecture)"
    echo "     - Tier 4: Process Optimization (workflow improvements)"
    echo ""
    echo "  3. Scope Impact Evaluation"
    echo "     - Low (<5 files): Consider integrating with current work"
    echo "     - Medium (5-20 files): Usually create separate issue"
    echo "     - High (20 files): Always create separate issue"
    echo ""
    echo "  4. Integration Decision Matrix"
    echo "     - Tier 1: Always separate issue (strategic importance)"
    echo "     - Tier 2: Based on scope impact and current work"
    echo ""
    echo "TARGET: TARGET: <15 minute triage decisions"
    echo "LOCATION: REFERENCE: docs/ISSUE_DISCOVERY_TRIAGE_SOP.md"
}

show_priority_framework() {
    echo "TARGET: PRIORITY STACK FRAMEWORK"
    echo "==========================="
    echo ""
    echo "🔴 TIER 1: STRATEGIC FOUNDATION"
    echo "  - Priority frameworks, meta-decision systems"
    echo "  - GitHub project organization"
    echo "  - Documentation standardization"
    echo ""
    echo "🟡 TIER 2: CAPABILITY EXPANSION"
    echo "  - High-value features and training systems"
    echo "  - Integration platforms (bridge systems)"
    echo "  - Security infrastructure"
    echo ""
    echo "🟢 TIER 3: INFRASTRUCTURE ENHANCEMENT"
    echo "  - MVP progression phases"
    echo "  - Docker service mesh & dashboard"
    echo "  - Architecture improvements"
    echo ""
    echo "🔵 TIER 4: PROCESS OPTIMIZATION"
    echo "  - Workflow automation"
    echo "  - Archive & protection systems"
    echo "  - Nice-to-have improvements"
    echo ""
    echo " CURRENT DISTRIBUTION: ~22 issues across 4 tiers"
    echo "LOCATION: REFERENCE: docs/PRIORITY_STACK_FRAMEWORK_UPDATE.md"
}

show_escalation_procedures() {
    echo "🆘 EMERGENCY ESCALATION PROCEDURES"
    echo "=================================="
    echo ""
    echo "🚨 POLICY VIOLATION ESCALATION:"
    echo "  1. Detection  Classification  Notification"
    echo "  2. Containment  Remediation  Follow-up"
    echo ""
    echo "FAST: RAPID RESPONSE FOR CI FAILURES:"
    echo "  - Issue detection via AAR system"
    echo "  - Clear escalation paths for critical issues"
    echo "  - Tested rollback and recovery procedures"
    echo ""
    echo " EMERGENCY COMMANDS:"
    echo "  - bash scripts/enhanced_ci_failure_analyzer.py"
    echo "  - python scripts/generate_aar.py --workflow-run-id <id>"
    echo "  - bash scripts/manage_ci_failure_issues.sh"
    echo ""
    echo " ESCALATION CONTACTS:"
    echo "  - Security Team: DevOnboarder Security Team"
    echo "  - Project Lead: DevOnboarder Project Lead"
    echo ""
    echo "LOCATION: REFERENCE: docs/policies/no-default-token-policy.md (Appendix C)"
}

show_token_architecture() {
    echo "🔑 TOKEN ARCHITECTURE v2.1"
    echo "=========================="
    echo ""
    echo " HIERARCHY (Fallback Chain):"
    echo "  1. CI_ISSUE_AUTOMATION_TOKEN (highest privilege)"
    echo "  2. CI_BOT_TOKEN (medium privilege)"
    echo "  3. GITHUB_TOKEN (default/basic)"
    echo ""
    echo " KEY SCRIPTS (15 Enhanced Scripts):"
    echo "  - scripts/enhanced_token_loader.sh     # Primary loader"
    echo "  - scripts/load_token_environment.sh    # Legacy fallback"
    echo "  - scripts/complete_system_validation.sh # Full validation"
    echo ""
    echo " IMPLEMENTATION PHASES:"
    echo "  - Phase 1 (Critical): 5 scripts including setup_discord_bot.sh"
    echo "  - Phase 2 (Automation): 7 scripts including monitor_ci_health.sh"
    echo "  - Phase 3 (Developer): 3 scripts including validate_token_architecture.sh"
    echo ""
    echo " SELF-CONTAINED: All scripts load tokens automatically"
    echo "LOCATION: REFERENCE: Token Architecture v2.1 documentation"
}

check_violations() {
    echo " POLICY VIOLATION CHECK"
    echo "========================="
    echo ""
    echo "Running comprehensive policy validation..."
    echo ""

    # Terminal output violations
    echo "1. Terminal Output Policy:"
    if ./scripts/validate_terminal_output.sh >/dev/null 2>&1; then
        echo "    No terminal output violations found"
    else
        echo "     Terminal output violations detected"
        echo "      Run: ./scripts/validate_terminal_output.sh"
    fi
    echo ""

    # Quality Control
    echo "2. Quality Control (95% threshold):"
    if ./scripts/qc_pre_push.sh >/dev/null 2>&1; then
        echo "    All QC metrics passing"
    else
        echo "     Quality control issues detected"
        echo "      Run: ./scripts/qc_pre_push.sh"
    fi
    echo ""

    # Environment synchronization
    echo "3. Environment Variable Consistency:"
    if ./scripts/smart_env_sync.sh --validate-only >/dev/null 2>&1; then
        echo "    Environment variables synchronized"
    else
        echo "     Environment inconsistencies detected"
        echo "      Run: ./scripts/smart_env_sync.sh --validate-only"
    fi
    echo ""

    # Potato Policy
    echo "4. Enhanced Potato Policy:"
    if ./scripts/check_potato_ignore.sh >/dev/null 2>&1; then
        echo "    Potato Policy compliance verified"
    else
        echo "     Potato Policy violations detected"
        echo "      Run: ./scripts/check_potato_ignore.sh"
    fi
    echo ""

    echo "For detailed analysis, run individual validation commands shown above."
}

show_all_policies() {
    show_terminal_policy
    echo ""
    printf '=%.0s' {1..60}; echo
    echo ""
    show_triage_sop
    echo ""
    printf '=%.0s' {1..60}; echo
    echo ""
    show_priority_framework
    echo ""
    printf '=%.0s' {1..60}; echo
    echo ""
    show_escalation_procedures
    echo ""
    printf '=%.0s' {1..60}; echo
    echo ""
    show_token_architecture
    echo ""
    printf '=%.0s' {1..60}; echo
    echo ""
    echo " For current policy violations, run: devonboarder-policy violations"
}

# Main logic
case "${1:-all}" in
    "terminal")
        show_terminal_policy
        ;;
    "triage")
        show_triage_sop
        ;;
    "priority")
        show_priority_framework
        ;;
    "escalation")
        show_escalation_procedures
        ;;
    "tokens")
        show_token_architecture
        ;;
    "violations")
        check_violations
        ;;
    "all")
        show_all_policies
        ;;
    "-h"|"--help"|"help")
        show_usage
        ;;
    *)
        echo "Unknown option: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
