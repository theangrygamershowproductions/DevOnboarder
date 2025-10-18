#!/bin/bash

echo "=== Phase 1: Quality Assurance Framework Pre-Migration Validation ==="
echo "Starting validation of ACTUAL Quality Assurance scripts..."
echo ""

# Actual existing Quality Assurance scripts (based on directory scan)
VALIDATION_SCRIPTS=(
    "scripts/validate_terminal_output.sh"
    "scripts/validate_log_centralization.sh"
    "scripts/validate_cache_centralization.sh"
    "scripts/validate-bot-permissions.sh"
    "scripts/validate_agents.py"
    "scripts/validate_agents.sh"
    "scripts/validate_agents_new.py"
    "scripts/validate_pr_checklist.sh"
    "scripts/validate_quality_gates.sh"
    "scripts/validate_token_architecture.sh"
    "scripts/validate_markdown_compliance.sh"
    "scripts/validate_shell_safety.sh"
    "scripts/validate_no_verify_usage.sh"
    "scripts/validate_workflow_permissions.sh"
    "scripts/validate_bot_config.sh"
    "scripts/validate_cors_configuration.sh"
    "scripts/validate_documentation_accuracy.sh"
    "scripts/validate_documentation_structure.sh"
    "scripts/validate_issue_resolution.sh"
    "scripts/validate_tunnel_setup.sh"
    "scripts/validate_unicode_terminal_output.py"
    "scripts/validate_frontmatter_content.py"
    "scripts/validate_metadata_standards.py"
    "scripts/validate_milestone_cross_references.py"
    "scripts/validate_milestone_format.py"
    "scripts/validate_pr_summary.py"
    "scripts/validate_templates.py"
    "scripts/validate_template_variables.sh"
    "scripts/validate_final_4_percent.sh"
    "scripts/validate_split_readiness.sh"
    "scripts/validate_token_cleanup.sh"
    "scripts/validate_agent_certification.sh"
    "scripts/validate_ci_locally.sh"
    "scripts/validate.sh"
    "scripts/quick_validate.sh"
)

TESTING_SCRIPTS=(
    "scripts/run_tests.sh"
    "scripts/run_tests_with_logging.sh"
    "scripts/test_check_root_artifacts.sh"
    "scripts/test_coverage_implementation.sh"
    "scripts/test_option1_implementation.sh"
    "scripts/test_per_service_coverage_local.sh"
    "scripts/test_phase2_implementation.sh"
    "scripts/test_phase3_implementation.sh"
    "scripts/test_ssh_secret_formats.sh"
    "scripts/test_tunnel_integration.sh"
    "scripts/setup_tests.sh"
    "scripts/simple_test.sh"
    "scripts/simple_token_test.sh"
    "scripts/dashboard_service_test.py"
    "scripts/phase2_complete_test.sh"
    "scripts/phase2_start_and_test.sh"
    "scripts/quick_aar_test.sh"
    "scripts/quick_final_4_check.sh"
    "scripts/manage_test_artifacts.sh"
)

COMPLIANCE_SCRIPTS=(
    "scripts/check_potato_ignore.sh"
    "scripts/enhanced_potato_check.sh"
    "scripts/devonboarder_policy_check.sh"
    "scripts/security_audit.sh"
    "scripts/env_security_audit.sh"
    "scripts/check_commit_messages.sh"
    "scripts/check_environment_consistency.sh"
    "scripts/check_dependencies.sh"
    "scripts/check_versions.sh"
    "scripts/check_network_access.sh"
    "scripts/check_project_root.sh"
    "scripts/check_root_artifacts.sh"
    "scripts/check_docs.sh"
    "scripts/check_docstrings.py"
    "scripts/check_env_docs.py"
    "scripts/check_headers.py"
    "scripts/check_classic_token_scopes.sh"
    "scripts/check-bot-permissions.sh"
    "scripts/alembic_migration_check.sh"
    "scripts/mvp_readiness_check.sh"
    "scripts/comprehensive_token_health_check.sh"
    "scripts/token_health_check.sh"
    "scripts/clean_markdown_compliance_violations.sh"
    "scripts/fix_markdown_compliance_automation.sh"
    "scripts/fix_shellcheck_token_scripts.sh"
)

QUALITY_CONTROL_SCRIPTS=(
    "scripts/qc_pre_push.sh"
    "scripts/qc_docs.sh"
    "scripts/qc_with_autofix.sh"
    "scripts/clean_pytest_artifacts.sh"
    "scripts/check_pr_inline_comments.sh"
    "scripts/check_automerge_health.sh"
    "scripts/check_jest_config.sh"
    "scripts/audit_env_vars.sh"
    "scripts/audit_token_usage.py"
    "scripts/generate_token_audit_report.sh"
    "scripts/manage_token_audits.sh"
    "scripts/run_local_checks.sh"
)

# Validation functions
validate_syntax() {
    local script="$1"
    if [ -f "$script" ]; then
        if bash -n "$script" 2>/dev/null; then
            return 0
        else
            echo "SYNTAX  $script"
            return 1
        fi
    else
        echo "MISSING: $script"
        return 1
    fi
}

validate_shellcheck() {
    local script="$1"
    if [ -f "$script" ]; then
        # Skip Python files for shellcheck
        if [[ "$script" == *.py ]]; then
            echo "SKIPPING PYTHON: $script"
            return 0
        fi

        if command -v shellcheck >/dev/null 2>&1; then
            if shellcheck -x "$script" 2>/dev/null; then
                return 0
            else
                echo "SHELLCHECK ISSUE: $script"
                return 1
            fi
        else
            echo "SHELLCHECK NOT AVAILABLE - SKIPPING: $script"
            return 0
        fi
    else
        echo "MISSING: $script"
        return 1
    fi
}

# Count actual scripts
VALIDATION_COUNT=${#VALIDATION_SCRIPTS[@]}
TESTING_COUNT=${#TESTING_SCRIPTS[@]}
COMPLIANCE_COUNT=${#COMPLIANCE_SCRIPTS[@]}
QUALITY_CONTROL_COUNT=${#QUALITY_CONTROL_SCRIPTS[@]}
TOTAL_COUNT=$((VALIDATION_COUNT  TESTING_COUNT  COMPLIANCE_COUNT  QUALITY_CONTROL_COUNT))

echo "ACTUAL Quality Assurance Script Inventory:"
echo "  - Validation Scripts: $VALIDATION_COUNT"
echo "  - Testing Scripts: $TESTING_COUNT"
echo "  - Compliance Scripts: $COMPLIANCE_COUNT"
echo "  - Quality Control Scripts: $QUALITY_CONTROL_COUNT"
echo "  - Total: $TOTAL_COUNT scripts"
echo ""

# Run syntax validation
echo "1. Syntax Validation:"
SYNTAX_ERRORS=0

echo "Validating Validation Scripts ($VALIDATION_COUNT)..."
for script in "${VALIDATION_SCRIPTS[@]}"; do
    if ! validate_syntax "$script"; then
        ((SYNTAX_ERRORS))
    fi
done

echo "Validating Testing Scripts ($TESTING_COUNT)..."
for script in "${TESTING_SCRIPTS[@]}"; do
    if ! validate_syntax "$script"; then
        ((SYNTAX_ERRORS))
    fi
done

echo "Validating Compliance Scripts ($COMPLIANCE_COUNT)..."
for script in "${COMPLIANCE_SCRIPTS[@]}"; do
    if ! validate_syntax "$script"; then
        ((SYNTAX_ERRORS))
    fi
done

echo "Validating Quality Control Scripts ($QUALITY_CONTROL_COUNT)..."
for script in "${QUALITY_CONTROL_SCRIPTS[@]}"; do
    if ! validate_syntax "$script"; then
        ((SYNTAX_ERRORS))
    fi
done

echo ""
echo "Syntax Validation Summary:"
echo "Scripts with syntax errors: $SYNTAX_ERRORS"
if [ $SYNTAX_ERRORS -eq 0 ]; then
    echo " All Quality Assurance scripts pass syntax validation"
else
    echo "ATTENTION: $SYNTAX_ERRORS scripts need syntax fixes"
fi

# Run shellcheck validation
echo ""
echo "2. Shellcheck Compliance Validation:"
echo "Checking shellcheck compliance for Quality Assurance scripts..."

SHELLCHECK_ERRORS=0

echo "Validating Validation Scripts ($VALIDATION_COUNT)..."
for script in "${VALIDATION_SCRIPTS[@]}"; do
    if ! validate_shellcheck "$script"; then
        ((SHELLCHECK_ERRORS))
    fi
done

echo "Validating Testing Scripts ($TESTING_COUNT)..."
for script in "${TESTING_SCRIPTS[@]}"; do
    if ! validate_shellcheck "$script"; then
        ((SHELLCHECK_ERRORS))
    fi
done

echo "Validating Compliance Scripts ($COMPLIANCE_COUNT)..."
for script in "${COMPLIANCE_SCRIPTS[@]}"; do
    if ! validate_shellcheck "$script"; then
        ((SHELLCHECK_ERRORS))
    fi
done

echo "Validating Quality Control Scripts ($QUALITY_CONTROL_COUNT)..."
for script in "${QUALITY_CONTROL_SCRIPTS[@]}"; do
    if ! validate_shellcheck "$script"; then
        ((SHELLCHECK_ERRORS))
    fi
done

echo ""
echo "Shellcheck Validation Summary:"
echo "Scripts with shellcheck issues: $SHELLCHECK_ERRORS"
if [ $SHELLCHECK_ERRORS -eq 0 ]; then
    echo " All Quality Assurance scripts pass shellcheck validation"
else
    echo "ATTENTION: $SHELLCHECK_ERRORS scripts need shellcheck review"
fi

echo ""
echo "Pre-Migration Validation Results:"
echo "  - Total QA Scripts: $TOTAL_COUNT"
echo "  - Syntax Errors: $SYNTAX_ERRORS"
echo "  - Shellcheck Issues: $SHELLCHECK_ERRORS"
echo ""
echo "Next: Terminal output compliance validation (CRITICAL)"
echo "Run: bash phase1_pre_migration_validation.sh terminal_output"
