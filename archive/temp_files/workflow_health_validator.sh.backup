#!/bin/bash
# scripts/workflow_health_validator.sh
# Pre-flight validation for GitHub Actions workflows
# Tests configurations, API connectivity, and permissions before deployment

set -e

# Centralized logging
mkdir -p logs/workflow-validation
LOG_FILE="logs/workflow-validation/health_check_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder Workflow Health Validator"
echo "====================================="
echo "Timestamp: $(date)"
echo "Log File: $LOG_FILE"
echo ""

# Validation results tracking
declare -A VALIDATION_RESULTS
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Main validation function
main() {
    local workflow_filter="${1:-all}"

    echo "Starting workflow health validation"
    echo "Filter: $workflow_filter"
    echo ""

    # Core validation checks
    validate_environment_setup
    validate_github_connectivity
    validate_workflow_configurations "$workflow_filter"
    validate_critical_scripts
    validate_permissions_and_tokens

    # Generate summary report
    generate_health_report
}

# Validate environment setup
validate_environment_setup() {
    echo "=== ENVIRONMENT VALIDATION ==="
    echo ""

    # Check required tools
    check_required_tool "gh" "GitHub CLI"
    check_required_tool "jq" "JSON processor"
    check_required_tool "yamllint" "YAML linter" "optional"
    check_required_tool "git" "Git version control"

    # Check DevOnboarder structure
    check_directory_structure

    echo ""
}

# Check if required tool is available
check_required_tool() {
    local tool="$1"
    local description="$2"
    local optional="${3:-required}"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if command -v "$tool" >/dev/null 2>&1; then
        echo "✅ $description ($tool): Available"
        VALIDATION_RESULTS["tool_$tool"]="PASS"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        if [[ "$optional" == "optional" ]]; then
            echo "⚠️  $description ($tool): Not available (optional)"
            VALIDATION_RESULTS["tool_$tool"]="SKIP"
        else
            echo "❌ $description ($tool): Missing (required)"
            VALIDATION_RESULTS["tool_$tool"]="FAIL"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
    fi
}

# Check DevOnboarder directory structure
check_directory_structure() {
    local required_dirs=(".github/workflows" "scripts" "logs")

    for dir in "${required_dirs[@]}"; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

        if [[ -d "$dir" ]]; then
            echo "✅ Directory structure ($dir): Present"
            VALIDATION_RESULTS["dir_$dir"]="PASS"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo "❌ Directory structure ($dir): Missing"
            VALIDATION_RESULTS["dir_$dir"]="FAIL"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
    done
}

# Validate GitHub connectivity
validate_github_connectivity() {
    echo "=== GITHUB CONNECTIVITY VALIDATION ==="
    echo ""

    # Test GitHub CLI authentication
    test_github_auth

    # Test API endpoints
    test_github_api_endpoints

    # Test repository access
    test_repository_access

    echo ""
}

# Test GitHub CLI authentication
test_github_auth() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if gh auth status >/dev/null 2>&1; then
        echo "✅ GitHub CLI Authentication: Active"
        VALIDATION_RESULTS["github_auth"]="PASS"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))

        # Get auth details
        local auth_info
        auth_info=$(gh auth status 2>&1)
        echo "   $(echo "$auth_info" | head -1)"
    else
        echo "❌ GitHub CLI Authentication: Failed"
        VALIDATION_RESULTS["github_auth"]="FAIL"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        echo "   Run: gh auth login"
    fi
}

# Test GitHub API endpoints
test_github_api_endpoints() {
    local endpoints=(
        "user:Get authenticated user"
        "repos/:owner/:repo:Repository access"
        "repos/:owner/:repo/issues:Issue operations"
        "repos/:owner/:repo/pulls:Pull request operations"
        "repos/:owner/:repo/actions/runs:Workflow runs access"
    )

    for endpoint_info in "${endpoints[@]}"; do
        local endpoint="${endpoint_info%%:*}"
        local description="${endpoint_info#*:}"

        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

        if test_api_endpoint "$endpoint"; then
            echo "✅ GitHub API ($description): Accessible"
            VALIDATION_RESULTS["api_$endpoint"]="PASS"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo "❌ GitHub API ($description): Failed"
            VALIDATION_RESULTS["api_$endpoint"]="FAIL"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
    done
}

# Test specific API endpoint
test_api_endpoint() {
    local endpoint="$1"

    case "$endpoint" in
        "user")
            gh api user >/dev/null 2>&1
            ;;
        "repos/:owner/:repo")
            gh api repos/:owner/:repo >/dev/null 2>&1
            ;;
        "repos/:owner/:repo/issues")
            gh api repos/:owner/:repo/issues --paginate=false >/dev/null 2>&1
            ;;
        "repos/:owner/:repo/pulls")
            gh api repos/:owner/:repo/pulls --paginate=false >/dev/null 2>&1
            ;;
        "repos/:owner/:repo/actions/runs")
            gh api repos/:owner/:repo/actions/runs --paginate=false >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# Test repository access
test_repository_access() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if gh repo view >/dev/null 2>&1; then
        echo "✅ Repository Access: Available"
        VALIDATION_RESULTS["repo_access"]="PASS"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))

        # Show repo info
        local repo_info
        repo_info=$(gh repo view --json name,owner,defaultBranch | jq -r '"\(.owner.login)/\(.name) (default: \(.defaultBranch))"')
        echo "   Repository: $repo_info"
    else
        echo "❌ Repository Access: Failed"
        VALIDATION_RESULTS["repo_access"]="FAIL"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

# Validate workflow configurations
validate_workflow_configurations() {
    local filter="$1"

    echo "=== WORKFLOW CONFIGURATION VALIDATION ==="
    echo "Filter: $filter"
    echo ""

    # Find workflow files
    local workflow_files
    if [[ "$filter" == "all" ]]; then
        workflow_files=(.github/workflows/*.yml .github/workflows/*.yaml)
    else
        workflow_files=(.github/workflows/*"$filter"*.yml .github/workflows/*"$filter"*.yaml)
    fi

    # Validate each workflow
    for workflow_file in "${workflow_files[@]}"; do
        if [[ -f "$workflow_file" ]]; then
            validate_single_workflow "$workflow_file"
        fi
    done

    # Specific validation for problematic workflows
    validate_aar_automation_workflow
    validate_pr_merge_cleanup_workflow

    echo ""
}

# Validate single workflow file
validate_single_workflow() {
    local workflow_file="$1"
    local workflow_name
    workflow_name=$(basename "$workflow_file" .yml)

    echo "Validating workflow: $workflow_name"

    # YAML syntax validation
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if command -v yamllint >/dev/null 2>&1; then
        if yamllint "$workflow_file" >/dev/null 2>&1; then
            echo "  ✅ YAML Syntax: Valid"
            VALIDATION_RESULTS["yaml_$workflow_name"]="PASS"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo "  ❌ YAML Syntax: Invalid"
            VALIDATION_RESULTS["yaml_$workflow_name"]="FAIL"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
    else
        echo "  ⚠️  YAML Syntax: Skipped (yamllint not available)"
        VALIDATION_RESULTS["yaml_$workflow_name"]="SKIP"
    fi

    # Check for common issues
    check_workflow_common_issues "$workflow_file" "$workflow_name"
}

# Check for common workflow issues
check_workflow_common_issues() {
    local workflow_file="$1"
    local workflow_name="$2"

    # Check for gitignored directory commits
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if grep -q "git add logs/" "$workflow_file"; then
        echo "  ❌ GitIgnore Issue: Attempts to commit logs/ (gitignored)"
        VALIDATION_RESULTS["gitignore_$workflow_name"]="FAIL"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    else
        echo "  ✅ GitIgnore Compliance: No gitignored commits"
        VALIDATION_RESULTS["gitignore_$workflow_name"]="PASS"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    fi

    # Check for unhandled jq operations
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if grep -q "jq -r" "$workflow_file" && ! grep -q "jq.*||" "$workflow_file"; then
        echo "  ❌ Error Handling: jq operations without error handling"
        VALIDATION_RESULTS["error_handling_$workflow_name"]="FAIL"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    else
        echo "  ✅ Error Handling: Adequate error handling found"
        VALIDATION_RESULTS["error_handling_$workflow_name"]="PASS"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    fi
}

# Specific validation for AAR Automation
validate_aar_automation_workflow() {
    local workflow_file=".github/workflows/aar-automation.yml"

    if [[ -f "$workflow_file" ]]; then
        echo "Special validation: AAR Automation"

        # Check for specific AAR issues
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if grep -q "git add logs/" "$workflow_file"; then
            echo "  ❌ AAR Logs Issue: DETECTED - Workflow attempts to commit gitignored logs/"
            VALIDATION_RESULTS["aar_logs_specific"]="FAIL"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            echo "    Fix: Remove 'git add logs/' line from workflow"
        else
            echo "  ✅ AAR Logs Issue: RESOLVED - No gitignored commits"
            VALIDATION_RESULTS["aar_logs_specific"]="PASS"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        fi
    fi
}

# Specific validation for PR Merge Cleanup
validate_pr_merge_cleanup_workflow() {
    local workflow_file=".github/workflows/pr-merge-cleanup.yml"

    if [[ -f "$workflow_file" ]]; then
        echo "Special validation: PR Merge Cleanup"

        # Check for JSON parsing error handling
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if grep -q "jq -r" "$workflow_file" && ! grep -q "jq.*||.*error\|set +e.*jq" "$workflow_file"; then
            echo "  ❌ JSON Parsing Issue: DETECTED - jq operations without error handling"
            VALIDATION_RESULTS["json_parsing_specific"]="FAIL"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            echo "    Fix: Add error handling for jq JSON parsing operations"
        else
            echo "  ✅ JSON Parsing Issue: RESOLVED - Error handling present"
            VALIDATION_RESULTS["json_parsing_specific"]="PASS"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        fi
    fi
}

# Validate critical scripts
validate_critical_scripts() {
    echo "=== CRITICAL SCRIPTS VALIDATION ==="
    echo ""

    local critical_scripts=(
        "scripts/ci_gh_issue_wrapper.sh:GitHub issue operations"
        "scripts/generate_aar.sh:AAR generation"
        "scripts/ci_troubleshooting_framework.sh:Troubleshooting framework"
    )

    for script_info in "${critical_scripts[@]}"; do
        local script_path="${script_info%%:*}"
        local description="${script_info#*:}"

        validate_script "$script_path" "$description"
    done

    echo ""
}

# Validate individual script
validate_script() {
    local script_path="$1"
    local description="$2"

    echo "Validating: $description"

    # Check if script exists
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if [[ -f "$script_path" ]]; then
        echo "  ✅ Script Exists: $script_path"
        VALIDATION_RESULTS["exists_$(basename "$script_path")"]="PASS"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo "  ❌ Script Missing: $script_path"
        VALIDATION_RESULTS["exists_$(basename "$script_path")"]="FAIL"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return
    fi

    # Check if script is executable
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if [[ -x "$script_path" ]]; then
        echo "  ✅ Executable: Yes"
        VALIDATION_RESULTS["executable_$(basename "$script_path")"]="PASS"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo "  ❌ Executable: No"
        VALIDATION_RESULTS["executable_$(basename "$script_path")"]="FAIL"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi

    # Check for basic shell syntax
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if bash -n "$script_path" 2>/dev/null; then
        echo "  ✅ Shell Syntax: Valid"
        VALIDATION_RESULTS["syntax_$(basename "$script_path")"]="PASS"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo "  ❌ Shell Syntax: Invalid"
        VALIDATION_RESULTS["syntax_$(basename "$script_path")"]="FAIL"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

# Validate permissions and tokens
validate_permissions_and_tokens() {
    echo "=== PERMISSIONS AND TOKENS VALIDATION ==="
    echo ""

    # Test token availability
    test_token_availability

    # Test repository permissions
    test_repository_permissions

    echo ""
}

# Test token availability
test_token_availability() {
    local tokens=("GITHUB_TOKEN" "CI_ISSUE_AUTOMATION_TOKEN" "CI_BOT_TOKEN")

    for token in "${tokens[@]}"; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

        if [[ -n "${!token}" ]]; then
            echo "✅ Token Available: $token"
            VALIDATION_RESULTS["token_$token"]="PASS"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo "⚠️  Token Missing: $token (may be loaded in CI)"
            VALIDATION_RESULTS["token_$token"]="SKIP"
        fi
    done
}

# Test repository permissions
test_repository_permissions() {
    local permissions=("read" "write" "issues" "pull_requests")

    for permission in "${permissions[@]}"; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

        case "$permission" in
            "read")
                if gh repo view >/dev/null 2>&1; then
                    echo "✅ Permission ($permission): Available"
                    VALIDATION_RESULTS["perm_$permission"]="PASS"
                    PASSED_CHECKS=$((PASSED_CHECKS + 1))
                else
                    echo "❌ Permission ($permission): Failed"
                    VALIDATION_RESULTS["perm_$permission"]="FAIL"
                    FAILED_CHECKS=$((FAILED_CHECKS + 1))
                fi
                ;;
            "issues")
                if gh issue list --limit 1 >/dev/null 2>&1; then
                    echo "✅ Permission ($permission): Available"
                    VALIDATION_RESULTS["perm_$permission"]="PASS"
                    PASSED_CHECKS=$((PASSED_CHECKS + 1))
                else
                    echo "❌ Permission ($permission): Failed"
                    VALIDATION_RESULTS["perm_$permission"]="FAIL"
                    FAILED_CHECKS=$((FAILED_CHECKS + 1))
                fi
                ;;
            *)
                echo "⚠️  Permission ($permission): Untested"
                VALIDATION_RESULTS["perm_$permission"]="SKIP"
                ;;
        esac
    done
}

# Generate health report
generate_health_report() {
    echo "=== WORKFLOW HEALTH REPORT ==="
    echo ""

    local pass_rate=0
    if [[ $TOTAL_CHECKS -gt 0 ]]; then
        pass_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    fi

    echo "Overall Health Score: $pass_rate% ($PASSED_CHECKS/$TOTAL_CHECKS checks passed)"
    echo ""

    # Health status determination
    if [[ $pass_rate -ge 90 ]]; then
        echo "🟢 System Status: HEALTHY"
        echo "   All critical systems operational"
    elif [[ $pass_rate -ge 75 ]]; then
        echo "🟡 System Status: WARNING"
        echo "   Some issues detected, monitoring required"
    elif [[ $pass_rate -ge 50 ]]; then
        echo "🟠 System Status: DEGRADED"
        echo "   Multiple issues detected, intervention needed"
    else
        echo "🔴 System Status: CRITICAL"
        echo "   System integrity compromised, immediate action required"
    fi

    echo ""

    # Failed checks summary
    if [[ $FAILED_CHECKS -gt 0 ]]; then
        echo "❌ Failed Checks ($FAILED_CHECKS):"
        for check_id in "${!VALIDATION_RESULTS[@]}"; do
            if [[ "${VALIDATION_RESULTS[$check_id]}" == "FAIL" ]]; then
                echo "   - $check_id"
            fi
        done
        echo ""
    fi

    # Recommendations
    generate_recommendations

    echo "Log File: $LOG_FILE"
    echo "Timestamp: $(date)"
}

# Generate specific recommendations
generate_recommendations() {
    echo "🔧 Recommendations:"

    if [[ "${VALIDATION_RESULTS[aar_logs_specific]}" == "FAIL" ]]; then
        echo "   1. Fix AAR Automation: Remove 'git add logs/' from .github/workflows/aar-automation.yml"
    fi

    if [[ "${VALIDATION_RESULTS[json_parsing_specific]}" == "FAIL" ]]; then
        echo "   2. Fix JSON Parsing: Add error handling to jq operations in PR merge cleanup"
    fi

    if [[ "${VALIDATION_RESULTS[github_auth]}" == "FAIL" ]]; then
        echo "   3. GitHub Authentication: Run 'gh auth login' to authenticate"
    fi

    if [[ $FAILED_CHECKS -eq 0 ]]; then
        echo "   ✅ No critical issues detected"
        echo "   💡 System is ready for workflow execution"
    fi

    echo ""
}

# Main execution
main "$@"
