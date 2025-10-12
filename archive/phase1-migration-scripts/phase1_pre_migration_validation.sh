#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"

# Phase 1 Pre-Migration QC Validation
# Quality Assurance Framework - Syntax Validation

set -euo pipefail

# Create logs directory for centralized logging
mkdir -p logs
LOG_FILE="logs/phase1_pre_migration_validation_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Phase 1: Quality Assurance Framework - Pre-Migration QC Validation"
echo "Started: $(date)"
echo "Log file: $LOG_FILE"

# Define Quality Assurance script categories
VALIDATION_SCRIPTS=(
    "scripts/validate_agents.py"
    "scripts/validate_agents.sh"
    "scripts/validate_agents_new.py"
    "scripts/validate_agent_certification.sh"
    "scripts/validate_terminal_output.sh"
    "scripts/validate_terminal_output_fixed.sh"
    "scripts/validate_terminal_output_simple.sh"
    "scripts/validate_unicode_terminal_output.py"
    "scripts/validate_token_architecture.sh"
    "scripts/validate_token_cleanup.sh"
    "scripts/validate_workflow_permissions.sh"
    "scripts/validate_pr_checklist.sh"
    "scripts/validate_pr_summary.py"
    "scripts/validate_quality_gates.sh"
    "scripts/validate_shell_safety.sh"
    "scripts/validate_bot_config.sh"
    "scripts/validate_cache_centralization.sh"
    "scripts/validate_log_centralization.sh"
    "scripts/validate_ci_locally.sh"
    "scripts/validate_cors_configuration.sh"
    "scripts/validate_documentation_accuracy.sh"
    "scripts/validate_documentation_structure.sh"
    "scripts/validate_frontmatter_content.py"
    "scripts/validate_issue_resolution.sh"
    "scripts/validate_markdown_compliance.sh"
    "scripts/validate_metadata_standards.py"
    "scripts/validate_milestone_cross_references.py"
    "scripts/validate_milestone_format.py"
    "scripts/validate_no_verify_usage.sh"
    "scripts/validate_split_readiness.sh"
    "scripts/validate_template_variables.sh"
    "scripts/validate_templates.py"
    "scripts/validate_tunnel_setup.sh"
    "scripts/validate_final_4_percent.sh"
    "scripts/validation_summary.sh"
    "scripts/validation_comparison.sh"
    "scripts/validate.sh"
    "scripts/quick_validate.sh"
    "scripts/monitor_validation.sh"
    "scripts/complete_system_validation.sh"
)

TESTING_SCRIPTS=(
    "scripts/run_tests.sh"
    "scripts/run_tests_with_logging.sh"
    "scripts/simple_test.sh"
    "scripts/setup_tests.sh"
    "scripts/manage_test_artifacts.sh"
    "scripts/clean_pytest_artifacts.sh"
    "scripts/test_check_root_artifacts.sh"
    "scripts/test_coverage_implementation.sh"
    "scripts/test_option1_implementation.sh"
    "scripts/test_per_service_coverage_local.sh"
    "scripts/test_phase2_implementation.sh"
    "scripts/test_phase3_implementation.sh"
    "scripts/test_ssh_secret_formats.sh"
    "scripts/test_tunnel_integration.sh"
    "scripts/phase1_diagnostic_assessment.sh"
    "scripts/phase2_complete_test.sh"
    "scripts/phase2_start_and_test.sh"
    "scripts/phase3_final_assessment.sh"
    "scripts/phase3_validation.sh"
    "scripts/quick_aar_test.sh"
    "scripts/quick_final_4_check.sh"
    "scripts/simple_token_test.sh"
    "scripts/dashboard_service_test.py"
    "scripts/check_jest_config.sh"
    "scripts/alembic_migration_check.sh"
)

COMPLIANCE_SCRIPTS=(
    "scripts/check_potato_ignore.sh"
    "scripts/enhanced_potato_check.sh"
    "scripts/devonboarder_policy_check.sh"
    "scripts/check_commit_messages.sh"
    "scripts/check_dependencies.sh"
    "scripts/check_docs.sh"
    "scripts/check_docstrings.py"
    "scripts/check_env_docs.py"
    "scripts/check_environment_consistency.sh"
    "scripts/check_headers.py"
    "scripts/check_network_access.sh"
    "scripts/check_project_root.sh"
    "scripts/check_root_artifacts.sh"
    "scripts/check_versions.sh"
    "scripts/clean_markdown_compliance_violations.sh"
    "scripts/fix_markdown_compliance_automation.sh"
    "scripts/fix_shellcheck_token_scripts.sh"
    "scripts/show_no_verify_enforcement.sh"
    "scripts/standards_enforcement_assessment.sh"
    "scripts/check-bot-permissions.sh"
    "scripts/validate-bot-permissions.sh"
    "scripts/check_classic_token_scopes.sh"
    "scripts/check_automerge_health.sh"
    "scripts/verify_gpg_keys.sh"
    "scripts/verify_and_commit.sh"
)

QUALITY_CONTROL_SCRIPTS=(
    "scripts/qc_pre_push.sh"
    "scripts/qc_docs.sh"
    "scripts/qc_with_autofix.sh"
    "scripts/security_audit.sh"
    "scripts/env_security_audit.sh"
    "scripts/audit_env_vars.sh"
    "scripts/audit_token_usage.py"
    "scripts/generate_token_audit_report.sh"
    "scripts/manage_token_audits.sh"
    "scripts/token_health_check.sh"
    "scripts/comprehensive_token_health_check.sh"
    "scripts/assess_pr_968.sh"
    "scripts/assess_pr_health.sh"
    "scripts/assess_pr_health_robust.sh"
    "scripts/assess_staged_task_readiness.sh"
    "scripts/mvp_readiness_check.sh"
    "scripts/cli_failure_tolerant_assessment.sh"
    "scripts/run_local_checks.sh"
    "scripts/check_pr_inline_comments.sh"
)

# Function to validate shell script syntax
validate_shell_syntax() {
    local script="$1"
    if [[ "$script" == *.sh ]]; then
        if bash -n "$script" 2>/dev/null; then
            echo "  PASS: $script"
            return 0
        else
            echo "  FAIL: $script - Syntax error"
            bash -n "$script" 2>&1 | sed 's/^/    /'
            return 1
        fi
    else
        echo "  SKIP: $script - Not a shell script"
        return 0
    fi
}

# Function to validate Python script syntax
validate_python_syntax() {
    local script="$1"
    if [[ "$script" == *.py ]]; then
        if python -m py_compile "$script" 2>/dev/null; then
            echo "  PASS: $script"
            return 0
        else
            echo "  FAIL: $script - Python syntax error"
            python -m py_compile "$script" 2>&1 | sed 's/^/    /'
            return 1
        fi
    else
        echo "  SKIP: $script - Not a Python script"
        return 0
    fi
}

# Function to validate script exists
validate_script_exists() {
    local script="$1"
    if [[ -f "$script" ]]; then
        return 0
    else
        echo "  MISSING: $script - File does not exist"
        return 1
    fi
}

# Validation counters
TOTAL_SCRIPTS=0
SYNTAX_ERRORS=0
MISSING_SCRIPTS=0

echo ""
echo "=== Phase 1: Pre-Migration Syntax Validation ==="
echo ""

# Validate Validation Scripts
echo "Validating Category 1: Validation Scripts (40 scripts)"
for script in "${VALIDATION_SCRIPTS[@]}"; do
    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
    if ! validate_script_exists "$script"; then
        MISSING_SCRIPTS=$((MISSING_SCRIPTS + 1))
        continue
    fi

    if [[ "$script" == *.sh ]]; then
        if ! validate_shell_syntax "$script"; then
            SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
        fi
    elif [[ "$script" == *.py ]]; then
        if ! validate_python_syntax "$script"; then
            SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
        fi
    fi
done

echo ""
echo "Validating Category 2: Testing Scripts (25 scripts)"
for script in "${TESTING_SCRIPTS[@]}"; do
    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
    if ! validate_script_exists "$script"; then
        MISSING_SCRIPTS=$((MISSING_SCRIPTS + 1))
        continue
    fi

    if [[ "$script" == *.sh ]]; then
        if ! validate_shell_syntax "$script"; then
            SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
        fi
    elif [[ "$script" == *.py ]]; then
        if ! validate_python_syntax "$script"; then
            SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
        fi
    fi
done

echo ""
echo "Validating Category 3: Compliance Scripts (25 scripts)"
for script in "${COMPLIANCE_SCRIPTS[@]}"; do
    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
    if ! validate_script_exists "$script"; then
        MISSING_SCRIPTS=$((MISSING_SCRIPTS + 1))
        continue
    fi

    if [[ "$script" == *.sh ]]; then
        if ! validate_shell_syntax "$script"; then
            SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
        fi
    elif [[ "$script" == *.py ]]; then
        if ! validate_python_syntax "$script"; then
            SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
        fi
    fi
done

echo ""
echo "Validating Category 4: Quality Control Scripts (19 scripts)"
for script in "${QUALITY_CONTROL_SCRIPTS[@]}"; do
    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
    if ! validate_script_exists "$script"; then
        MISSING_SCRIPTS=$((MISSING_SCRIPTS + 1))
        continue
    fi

    if [[ "$script" == *.sh ]]; then
        if ! validate_shell_syntax "$script"; then
            SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
        fi
    elif [[ "$script" == *.py ]]; then
        if ! validate_python_syntax "$script"; then
            SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
        fi
    fi
done

echo ""
echo "=== Pre-Migration Syntax Validation Summary ==="
echo "Total scripts checked: $TOTAL_SCRIPTS"
echo "Missing scripts: $MISSING_SCRIPTS"
echo "Syntax errors: $SYNTAX_ERRORS"
echo "Valid scripts: $((TOTAL_SCRIPTS - MISSING_SCRIPTS - SYNTAX_ERRORS))"

if [[ $SYNTAX_ERRORS -eq 0 && $MISSING_SCRIPTS -eq 0 ]]; then
    success "All Quality Assurance scripts passed syntax validation"
    exit 0
else
    echo "FAILURE: Pre-migration syntax validation failed"
    echo "  Missing scripts: $MISSING_SCRIPTS"
    echo "  Syntax errors: $SYNTAX_ERRORS"
    exit 1
fi
