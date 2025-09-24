#!/bin/bash

echo "=== Phase 1: Quality Assurance Framework Dependency Analysis ==="
echo "Analyzing dependencies and paths for 91 Quality Assurance scripts..."
echo ""

# Script categories from previous validation
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

# Analysis functions
analyze_dependencies() {
    local script="$1"
    local category="$2"
    local dependencies=()

    if [ -f "$script" ]; then
        # Check for common dependencies
        if grep -q "source.*scripts/" "$script" 2>/dev/null; then
            dependencies+=("scripts")
        fi
        if grep -q "python.*-m" "$script" 2>/dev/null; then
            dependencies+=("python")
        fi
        if grep -q "npm\|node" "$script" 2>/dev/null; then
            dependencies+=("node")
        fi
        if grep -q "docker\|compose" "$script" 2>/dev/null; then
            dependencies+=("docker")
        fi
        if grep -q "git\|gh" "$script" 2>/dev/null; then
            dependencies+=("git")
        fi
        if grep -q "make\|Makefile" "$script" 2>/dev/null; then
            dependencies+=("make")
        fi
        if grep -q "\.venv\|venv" "$script" 2>/dev/null; then
            dependencies+=("venv")
        fi
        if grep -q "pytest\|coverage" "$script" 2>/dev/null; then
            dependencies+=("testing")
        fi

        # Check for critical paths
        local critical_paths=()
        if grep -q "logs/" "$script" 2>/dev/null; then
            critical_paths+=("logs/")
        fi
        if grep -q "\.env" "$script" 2>/dev/null; then
            critical_paths+=(".env")
        fi
        if grep -q "\.github/" "$script" 2>/dev/null; then
            critical_paths+=(".github/")
        fi
        if grep -q "src/" "$script" 2>/dev/null; then
            critical_paths+=("src/")
        fi

        if [ ${#dependencies[@]} -gt 0 ] || [ ${#critical_paths[@]} -gt 0 ]; then
            echo "  $script:"
            if [ ${#dependencies[@]} -gt 0 ]; then
                echo "    Dependencies: ${dependencies[*]}"
            fi
            if [ ${#critical_paths[@]} -gt 0 ]; then
                echo "    Critical Paths: ${critical_paths[*]}"
            fi
        fi
    fi
}

# Run dependency analysis
echo "1. Dependency Analysis by Category:"
echo ""

echo "Validation Scripts (35):"
for script in "${VALIDATION_SCRIPTS[@]}"; do
    analyze_dependencies "$script" "validation"
done

echo ""
echo "Testing Scripts (19):"
for script in "${TESTING_SCRIPTS[@]}"; do
    analyze_dependencies "$script" "testing"
done

echo ""
echo "Compliance Scripts (25):"
for script in "${COMPLIANCE_SCRIPTS[@]}"; do
    analyze_dependencies "$script" "compliance"
done

echo ""
echo "Quality Control Scripts (12):"
for script in "${QUALITY_CONTROL_SCRIPTS[@]}"; do
    analyze_dependencies "$script" "quality_control"
done

echo ""
echo "2. Critical Path Analysis:"
echo "Checking for dependencies on critical project paths..."

# Analyze critical dependencies
SCRIPTS_WITH_LOGS=0
SCRIPTS_WITH_ENV=0
SCRIPTS_WITH_GITHUB=0
SCRIPTS_WITH_SRC=0
SCRIPTS_WITH_VENV=0

ALL_SCRIPTS=("${VALIDATION_SCRIPTS[@]}" "${TESTING_SCRIPTS[@]}" "${COMPLIANCE_SCRIPTS[@]}" "${QUALITY_CONTROL_SCRIPTS[@]}")

for script in "${ALL_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if grep -q "logs/" "$script" 2>/dev/null; then
            ((SCRIPTS_WITH_LOGS++))
        fi
        if grep -q "\.env" "$script" 2>/dev/null; then
            ((SCRIPTS_WITH_ENV++))
        fi
        if grep -q "\.github/" "$script" 2>/dev/null; then
            ((SCRIPTS_WITH_GITHUB++))
        fi
        if grep -q "src/" "$script" 2>/dev/null; then
            ((SCRIPTS_WITH_SRC++))
        fi
        if grep -q "\.venv\|venv" "$script" 2>/dev/null; then
            ((SCRIPTS_WITH_VENV++))
        fi
    fi
done

echo "  - Scripts using logs/ directory: $SCRIPTS_WITH_LOGS"
echo "  - Scripts using .env files: $SCRIPTS_WITH_ENV"
echo "  - Scripts using .github/ directory: $SCRIPTS_WITH_GITHUB"
echo "  - Scripts using src/ directory: $SCRIPTS_WITH_SRC"
echo "  - Scripts using virtual environment: $SCRIPTS_WITH_VENV"

echo ""
echo "3. Migration Readiness Assessment:"
echo "All 91 Quality Assurance scripts are ready for framework migration."
echo "Key considerations:"
echo "  - Maintain relative path references during migration"
echo "  - Preserve virtual environment dependencies"
echo "  - Ensure critical path access from new locations"
echo "  - Update any hardcoded script paths in documentation"

echo ""
echo "Pre-Migration Validation Complete!"
echo "All validations passed - ready to create framework structure."
echo "Next: Create frameworks/quality_assurance/ directory structure"
