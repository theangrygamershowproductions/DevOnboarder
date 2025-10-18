#!/usr/bin/env bash
# Enhanced Potato Policy Audit Report Generator
# Creates comprehensive audit trail and compliance report for DevOnboarder
# Integrates with Enhanced Potato Policy framework and virtual environment requirements
#
# Philosophy: Pain  Protocol  Protection
# Virtual Environment: REQUIRED for all operations

set -euo pipefail

# ANSI color codes for output formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date %Y%m%d_%H%M%S)
OUTPUT_FILE="${PROJECT_ROOT}/reports/enhanced-potato-policy-audit-${TIMESTAMP}.md"
CI_INTEGRATION=${1:-false}
SCHEDULED_RUN=${2:-false}

# Virtual environment validation
check_virtual_environment() {
    if [ -z "${VIRTUAL_ENV:-}" ]; then
        echo -e "${RED} CRITICAL: Virtual environment required for audit report generation${NC}" >&2
        echo -e "${YELLOW}   Solution: source .venv/bin/activate && pip install -e .[test]${NC}" >&2
        echo -e "${BLUE}   DevOnboarder requires ALL security tools to run in virtual environment context${NC}" >&2
        exit 1
    fi
}

# Setup directories
setup_directories() {
    mkdir -p "${PROJECT_ROOT}/reports"
    mkdir -p "${PROJECT_ROOT}/logs"
}

# Collect system information
collect_system_info() {
    local current_date
    current_date=$(date -Iseconds)
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local current_commit
    current_commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local user
    user=$(whoami 2>/dev/null || echo "unknown")

    cat << EOF
# Enhanced Potato Policy Audit Report

**Generated:** $current_date
**Project:** DevOnboarder
**Branch:** $current_branch
**Commit:** $current_commit
**User:** $user
**Virtual Environment:** ${VIRTUAL_ENV}
**Report Type:** $([ "$SCHEDULED_RUN" = true ] && echo "Scheduled Audit" || echo "Manual Audit")

## Executive Summary

This audit report provides a comprehensive assessment of DevOnboarder's Enhanced Potato Policy compliance, security posture, and automated protection mechanisms.

### Philosophy
**"Every rule has a scar behind it"** - The Enhanced Potato Policy implements the principle: **Pain  Protocol  Protection**.

EOF
}

# Run compliance checks and collect results
run_compliance_checks() {
    echo ""
    echo "## Compliance Check Results"
    echo ""

    # Run enhanced potato check
    local check_output
    local check_exit_code

    echo "### Enhanced Potato Policy Check"
    echo ""

    if check_output=$(bash "${SCRIPT_DIR}/enhanced_potato_check.sh" --dry-run 2>&1); then
        check_exit_code=0
        echo "**Status:**  COMPLIANT"
        echo ""
        echo "All Enhanced Potato Policy checks passed successfully."
    else
        check_exit_code=$?
        echo "**Status:**  VIOLATIONS DETECTED"
        echo ""
        echo "**Exit Code:** $check_exit_code"
        echo ""
        echo '```'
        echo "${check_output}"
        echo '```'
    fi

    echo ""
    echo "### Ignore File Coverage Analysis"
    echo ""

    # Check ignore file coverage
    local ignore_files=(".gitignore" ".dockerignore" ".codespell-ignore")
    local total_patterns=0
    local covered_patterns=0

    for ignore_file in "${ignore_files[@]}"; do
        local file_path="${PROJECT_ROOT}/${ignore_file}"
        if [ -f "$file_path" ]; then
            local pattern_count
            pattern_count=$(wc -l < "$file_path" 2>/dev/null || echo "0")
            total_patterns=$((total_patterns  pattern_count))

            echo "- **$ignore_file:** $pattern_count patterns"

            # Check for critical patterns
            local has_potato
            local has_env
            local has_secrets

            has_potato=$(grep -c "Potato" "$file_path" 2>/dev/null || echo "0")
            has_env=$(grep -c "\.env" "$file_path" 2>/dev/null || echo "0")
            has_secrets=$(grep -c "secret" "$file_path" 2>/dev/null || echo "0")

            if [ "$has_potato" -gt 0 ] && [ "$has_env" -gt 0 ] && [ "$has_secrets" -gt 0 ]; then
                echo "  -  Contains critical protection patterns"
                covered_patterns=$((covered_patterns  1))
            else
                echo "  -  Missing some critical patterns"
            fi
        else
            echo "- **$ignore_file:**  FILE MISSING"
        fi
    done

    echo ""
    echo "**Coverage Summary:** $covered_patterns of ${#ignore_files[@]} files properly configured"

    echo ""
    echo "### File System Security Scan"
    echo ""

    # Scan for potentially exposed files
    local exposed_files
    exposed_files=$(find "$PROJECT_ROOT" -type f \
        \( -name "*.env" -o -name "*.pem" -o -name "*.key" -o -name "secrets.*" -o -name "Potato.md" \) \
        -not -path "*/.git/*" \
        -not -path "*/.venv/*" \
        -not -path "*/node_modules/*" \
        -not -path "*/logs/*" \
        2>/dev/null || true)

    if [ -n "$exposed_files" ]; then
        echo "**Status:**  SENSITIVE FILES DETECTED"
        echo ""
        echo "The following potentially sensitive files were found:"
        echo ""
        echo '```'
        echo "${exposed_files}"
        echo '```'
        echo ""
        echo "**Action Required:** Verify these files are properly protected by ignore patterns."
    else
        echo "**Status:**  NO EXPOSED SENSITIVE FILES"
        echo ""
        echo "No potentially sensitive files detected in repository."
    fi
}

# Analyze historical violations
analyze_violations() {
    echo ""
    echo "## Violation History Analysis"
    echo ""

    local violation_log="${PROJECT_ROOT}/logs/potato-violations.log"

    if [ -f "$violation_log" ]; then
        local violation_count
        violation_count=$(grep -c "VIOLATION_DETECTED" "$violation_log" 2>/dev/null || echo "0")

        echo "**Total Violations Logged:** $violation_count"
        echo ""

        if [ "$violation_count" -gt 0 ]; then
            echo "### Recent Violations (Last 10)"
            echo ""
            echo '```'
            tail -n 30 "${violation_log}" | grep -A 5 "VIOLATION_DETECTED" | tail -n 20 || echo "No recent violations"
            echo '```'
        else
            echo " **No violations recorded** - excellent security posture!"
        fi
    else
        echo "**Violation Log:** Not found (clean installation or no violations)"
    fi

    echo ""
    echo "### GitHub Issues Integration"
    echo ""

    # Check for GitHub CLI and recent security issues
    if command -v gh &> /dev/null && [ -n "${GITHUB_TOKEN:-}" ]; then
        echo "**GitHub CLI:**  Available and authenticated"

        local security_issues
        if security_issues=$(gh issue list --label "security,potato-policy" --limit 5 --json number,title,createdAt,state 2>/dev/null); then
            echo ""
            echo "**Recent Security Issues:**"
            echo ""
            if [ "$security_issues" = "[]" ]; then
                echo " No recent security issues - system stable"
            else
                echo '```json'
                echo "${security_issues}" | head -20
                echo '```'
            fi
        else
            echo ""
            echo " Unable to fetch GitHub issues (check permissions)"
        fi
    else
        echo "**GitHub CLI:**  Not available or not authenticated"
        echo ""
        echo "GitHub issue integration requires:"
        echo "- GitHub CLI installed (\`gh\`)"
        echo "- \`GITHUB_TOKEN\` environment variable set"
    fi
}

# Virtual environment compliance analysis
analyze_virtual_env_compliance() {
    echo ""
    echo "## Virtual Environment Compliance"
    echo ""

    echo "**Current Virtual Environment:** \`${VIRTUAL_ENV}\`"
    echo ""

    # Check tool availability in virtual environment
    local tools=("python" "pip" "black" "ruff" "pytest")
    local compliant_tools=0

    echo "### Tool Availability Check"
    echo ""

    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            local tool_path
            tool_path=$(command -v "$tool")
            if [[ "$tool_path" == "${VIRTUAL_ENV}"* ]]; then
                echo "-  **$tool:** \`$tool_path\`"
                compliant_tools=$((compliant_tools  1))
            else
                echo "-  **$tool:** Not from virtual environment (\`$tool_path\`)"
            fi
        else
            echo "-  **$tool:** Not available"
        fi
    done

    echo ""
    echo "**Compliance Score:** $compliant_tools/${#tools[@]} tools properly isolated"

    # Check for virtual environment creation script
    if [ -f "${PROJECT_ROOT}/pyproject.toml" ]; then
        echo ""
        echo "### Virtual Environment Configuration"
        echo ""
        echo " **pyproject.toml** found - standard Python project structure"

        # Check if venv directory exists
        if [ -d "${PROJECT_ROOT}/.venv" ]; then
            echo " **Virtual environment directory** exists"
        else
            echo " **Virtual environment directory** not found"
        fi
    fi
}

# CI/CD integration analysis
analyze_ci_integration() {
    echo ""
    echo "## CI/CD Integration Analysis"
    echo ""

    # Check for CI configuration files
    local ci_files=(
        ".github/workflows/potato-policy-focused.yml"
        ".github/workflows/ci.yml"
        ".pre-commit-config.yaml"
    )

    echo "### CI Configuration Files"
    echo ""

    for ci_file in "${ci_files[@]}"; do
        local file_path="${PROJECT_ROOT}/${ci_file}"
        if [ -f "$file_path" ]; then
            echo "-  **$ci_file:** Present"

            # Check for potato policy references
            if grep -q "potato" "$file_path" 2>/dev/null; then
                echo "  - Contains Potato Policy integration"
            fi
        else
            echo "-  **$ci_file:** Missing"
        fi
    done

    echo ""
    echo "### Pre-commit Hook Integration"
    echo ""

    if [ -f "${PROJECT_ROOT}/.pre-commit-config.yaml" ]; then
        local potato_hooks
        potato_hooks=$(grep -c "potato" "${PROJECT_ROOT}/.pre-commit-config.yaml" 2>/dev/null || echo "0")

        if [ "$potato_hooks" -gt 0 ]; then
            echo " **Pre-commit hooks** include Potato Policy enforcement ($potato_hooks references)"
        else
            echo " **Pre-commit hooks** configured but no Potato Policy integration"
        fi
    else
        echo " **Pre-commit hooks** not configured"
    fi
}

# Generate recommendations
generate_recommendations() {
    echo ""
    echo "## Security Recommendations"
    echo ""

    echo "### Immediate Actions"
    echo ""
    echo "1. **Verify Virtual Environment Setup**"
    echo "   - Ensure \`source .venv/bin/activate\` is run before any DevOnboarder operations"
    echo "   - Install dependencies: \`pip install -e .[test]\`"
    echo ""
    echo "2. **Run Enhanced Security Check**"
    echo "   - Execute: \`bash scripts/enhanced_potato_check.sh --verbose\`"
    echo "   - Address any violations immediately"
    echo ""
    echo "3. **Enable Pre-commit Hooks**"
    echo "   - Install: \`pre-commit install\`"
    echo "   - Test: \`pre-commit run --all-files\`"
    echo ""

    echo "### Preventive Measures"
    echo ""
    echo "1. **Regular Audits**"
    echo "   - Run daily: \`bash scripts/generate_potato_report.sh --scheduled\`"
    echo "   - Review monthly: All security documentation and policies"
    echo ""
    echo "2. **Team Training**"
    echo "   - Review: \`docs/enhanced-potato-policy.md\`"
    echo "   - Practice: Virtual environment discipline"
    echo ""
    echo "3. **Monitoring Setup**"
    echo "   - Configure: GitHub CLI with proper tokens"
    echo "   - Enable: Automated issue creation for violations"
    echo ""

    echo "### Advanced Security"
    echo ""
    echo "1. **Comprehensive Protection**"
    echo "   - Deploy all Enhanced Potato Policy scripts"
    echo "   - Configure CI/CD pipeline integration"
    echo "   - Set up scheduled security scans"
    echo ""
    echo "2. **Incident Response**"
    echo "   - Document: Security incident response procedures"
    echo "   - Practice: Violation remediation workflows"
    echo "   - Review: Audit logs regularly"
}

# Generate footer with metadata
generate_footer() {
    echo ""
    echo "---"
    echo ""
    echo "## Report Metadata"
    echo ""
    echo "- **Framework Version:** Enhanced Potato Policy v2.0"
    echo "- **Script Location:** \`scripts/generate_potato_report.sh\`"
    echo "- **Virtual Environment:** \`${VIRTUAL_ENV}\`"
    echo "- **CI Integration:** $([ "$CI_INTEGRATION" = true ] && echo "Active" || echo "Manual")"
    echo "- **Next Scheduled Audit:** $(date -d '1 day' -Iseconds 2>/dev/null || echo 'Configure scheduled runs')"
    echo ""
    echo "### Related Documentation"
    echo ""
    echo "- [Enhanced Potato Policy](../docs/enhanced-potato-policy.md)"
    echo "- [DevOnboarder Integration Status](../docs/devonboarder-integration-status.md)"
    echo "- [Core Metadata Standards](../docs/core-metadata-standards.md)"
    echo ""
    echo "### Audit Trail"
    echo ""
    echo "- **Violation Log:** \`logs/potato-violations.log\`"
    echo "- **Audit Logs:** \`logs/enhanced_potato_check_*.log\`"
    echo "- **Reports Archive:** \`reports/\`"
    echo ""
    echo "---"
    echo ""
    echo "*This report was generated automatically by the Enhanced Potato Policy audit framework.*  "
    echo "*Philosophy: Pain  Protocol  Protection*  "
    echo "*DevOnboarder Security Framework v2.0*"
}

# Main execution function
main() {
    echo -e "${PURPLE} Enhanced Potato Policy Audit Report Generator${NC}"
    echo -e "${PURPLE}=================================================${NC}"
    echo -e "${BLUE}DevOnboarder Security Framework v2.0${NC}"
    echo -e "${BLUE}Philosophy: Pain  Protocol  Protection${NC}"
    echo ""

    # Critical setup
    check_virtual_environment
    setup_directories

    echo -e "${CYAN} Generating comprehensive audit report...${NC}"
    echo -e "${BLUE}Output: $OUTPUT_FILE${NC}"
    echo ""

    # Generate the complete report
    {
        collect_system_info
        run_compliance_checks
        analyze_violations
        analyze_virtual_env_compliance
        analyze_ci_integration
        generate_recommendations
        generate_footer
    } > "$OUTPUT_FILE"

    # Create symlink to latest report
    ln -sf "$(basename "$OUTPUT_FILE")" "${PROJECT_ROOT}/reports/potato-policy-latest.md"

    # Display summary
    echo -e "${GREEN} Audit report generated successfully${NC}"
    echo -e "${BLUE}FILE: Report: $OUTPUT_FILE${NC}"
    echo -e "${BLUE}LINK: Latest: reports/potato-policy-latest.md${NC}"
    echo -e "${BLUE}📏 Size: $(wc -l < "$OUTPUT_FILE") lines${NC}"

    # CI integration output
    if [ "${CI:-false}" = "true" ] || [ "$CI_INTEGRATION" = "true" ]; then
        echo "::notice title=Enhanced Potato Policy Audit::Generated comprehensive audit report: $OUTPUT_FILE"
    fi

    echo ""
    echo -e "${PURPLE} Enhanced Potato Policy: Audit Complete${NC}"
    echo -e "${GREEN} DevOnboarder security posture documented${NC}"
}

# Execute main function with arguments
main "$@"
