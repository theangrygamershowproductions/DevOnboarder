#!/usr/bin/env bash
# Token Policy Enforcement & Cleanup Validation for DevOnboarder
# Part of No Default Token Policy v1.0 implementation

set -euo pipefail

# Ensure we're in DevOnboarder root
if [ ! -f ".github/workflows/ci.yml" ]; then
    echo "❌ Please run this script from the DevOnboarder root directory"
    exit 1
fi

# Use centralized logging (DevOnboarder requirement)
mkdir -p logs
LOG_FILE="logs/token_policy_enforcement_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🔐 DevOnboarder Token Policy Enforcement & Cleanup Validation${NC}"
echo "==============================================================="
echo "Validating No Default Token Policy v1.0 compliance and cleanup"
echo ""

# Configuration
REGISTRY_FILE=".codex/tokens/token_scope_map.yaml"
AUDIT_SCRIPT="scripts/audit_token_usage.py"
GITHUB_WORKFLOWS=".github/workflows"
TOKEN_AUDIT_DIR="logs/token-audit"

# Initialize tracking variables
VIOLATIONS_FOUND=0
WARNINGS_FOUND=0
FILES_CHECKED=0
WORKFLOWS_CHECKED=0

# Function to log violations
log_violation() {
    local severity="$1"
    local message="$2"
    local file="$3"
    local line_number="${4:-}"

    case "$severity" in
        "CRITICAL")
            echo -e "${RED}❌ CRITICAL: $message${NC}"
            echo "   File: $file"
            [ -n "$line_number" ] && echo "   Line: $line_number"
            ((VIOLATIONS_FOUND++))
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  WARNING: $message${NC}"
            echo "   File: $file"
            [ -n "$line_number" ] && echo "   Line: $line_number"
            ((WARNINGS_FOUND++))
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO: $message${NC}"
            echo "   File: $file"
            ;;
    esac
}

# Function to activate virtual environment for Python tools
activate_virtual_env() {
    if [ ! -d ".venv" ]; then
        echo -e "${RED}❌ Virtual environment not found${NC}"
        echo "DevOnboarder requires virtual environment setup:"
        echo "  python -m venv .venv"
        echo "  source .venv/bin/activate"
        echo "  pip install -e .[test]"
        return 1
    fi

    # shellcheck source=/dev/null
    source .venv/bin/activate
    echo -e "${BLUE}🐍 Virtual environment activated for Python tools${NC}"
}

# Function to check registry availability and structure
check_token_registry() {
    echo -e "${BLUE}📋 Checking token scope registry...${NC}"

    if [ ! -f "$REGISTRY_FILE" ]; then
        log_violation "CRITICAL" "Token scope registry not found" "$REGISTRY_FILE"
        return 1
    fi

    echo "✅ Registry file exists: $REGISTRY_FILE"

    # Validate YAML structure if PyYAML is available
    if command -v python >/dev/null 2>&1 && python -c "import yaml" 2>/dev/null; then
        if python -c "
import yaml
try:
    with open('$REGISTRY_FILE') as f:
        data = yaml.safe_load(f)
    if data is None:
        print('ERROR: Empty registry')
        exit(1)
    if 'github_tokens' not in data:
        print('ERROR: Missing github_tokens section')
        exit(1)
    print('SUCCESS: Valid YAML structure')
except Exception as e:
    print(f'ERROR: {e}')
    exit(1)
"; then
            echo "✅ Registry has valid YAML structure"
        else
            log_violation "CRITICAL" "Registry has invalid YAML structure" "$REGISTRY_FILE"
        fi
    else
        log_violation "WARNING" "Cannot validate YAML structure (PyYAML not available)" "$REGISTRY_FILE"
    fi
}

# Function to scan workflows for token policy violations
scan_workflows_for_violations() {
    echo -e "${BLUE}🔍 Scanning GitHub workflows for token policy violations...${NC}"

    if [ ! -d "$GITHUB_WORKFLOWS" ]; then
        log_violation "WARNING" "GitHub workflows directory not found" "$GITHUB_WORKFLOWS"
        return 1
    fi

    # Find all workflow files
    local workflow_files
    workflow_files=$(find "$GITHUB_WORKFLOWS" -name "*.yml" -o -name "*.yaml")

    if [ -z "$workflow_files" ]; then
        log_violation "WARNING" "No workflow files found" "$GITHUB_WORKFLOWS"
        return 1
    fi

    while IFS= read -r workflow_file; do
        ((WORKFLOWS_CHECKED++))
        echo "Checking workflow: $(basename "$workflow_file")"

        # Check for direct GITHUB_TOKEN usage (violation)
        if grep -n "GITHUB_TOKEN" "$workflow_file" >/dev/null 2>&1; then
            # Check if it's being used for API calls (not just passed through)
            if grep -n -E "(gh |curl.*GITHUB_TOKEN|api\.github\.com.*GITHUB_TOKEN)" "$workflow_file" >/dev/null 2>&1; then
                while IFS= read -r violation_line; do
                    local line_number
                    line_number=$(echo "$violation_line" | cut -d: -f1)
                    log_violation "CRITICAL" "Direct GITHUB_TOKEN usage detected (violates No Default Token Policy)" "$workflow_file" "$line_number"
                done <<< "$(grep -n -E "(gh |curl.*GITHUB_TOKEN|api\.github\.com.*GITHUB_TOKEN)" "$workflow_file")"
            else
                log_violation "WARNING" "GITHUB_TOKEN referenced but usage pattern unclear" "$workflow_file"
            fi
        fi

        # Check for approved token usage patterns
        local approved_tokens=(
            "CI_ISSUE_AUTOMATION_TOKEN"
            "DIAGNOSTICS_BOT_KEY"
            "CI_HEALTH_KEY"
            "AAR_BOT_TOKEN"
            "CHECKLIST_BOT_TOKEN"
            "MONITORING_BOT_TOKEN"
            "ORCHESTRATOR_BOT_TOKEN"
            "SECURITY_AUDIT_TOKEN"
            "INFRASTRUCTURE_BOT_TOKEN"
            "AGENT_COORDINATOR_TOKEN"
            "ADVANCED_MONITOR_TOKEN"
            "CI_BOT_TOKEN"
        )

        for token in "${approved_tokens[@]}"; do
            if grep -q "$token" "$workflow_file"; then
                echo "  ✅ Found approved token: $token"
            fi
        done

        # Check for token fallback patterns (should be avoided)
        if grep -n -E "\${.*:-.*GITHUB_TOKEN}" "$workflow_file" >/dev/null 2>&1; then
            local fallback_lines
            fallback_lines=$(grep -n -E "\${.*:-.*GITHUB_TOKEN}" "$workflow_file")
            while IFS= read -r fallback_line; do
                local line_number
                line_number=$(echo "$fallback_line" | cut -d: -f1)
                log_violation "WARNING" "Token fallback pattern with GITHUB_TOKEN detected" "$workflow_file" "$line_number"
            done <<< "$fallback_lines"
        fi

        ((FILES_CHECKED++))

    done <<< "$workflow_files"
}

# Function to scan agent documentation for token usage
scan_agent_docs_for_token_usage() {
    echo -e "${BLUE}📚 Scanning agent documentation for token usage patterns...${NC}"

    if [ ! -d "agents" ]; then
        log_violation "WARNING" "Agents directory not found" "agents/"
        return 1
    fi

    # Find all agent markdown files
    local agent_files
    agent_files=$(find agents -name "*.md" 2>/dev/null || true)

    if [ -z "$agent_files" ]; then
        echo "No agent documentation files found"
        return 0
    fi

    while IFS= read -r agent_file; do
        echo "Checking agent doc: $(basename "$agent_file")"

        # Check for token references in documentation
        if grep -n -i "token" "$agent_file" >/dev/null 2>&1; then
            # Look for GITHUB_TOKEN specifically
            if grep -n "GITHUB_TOKEN" "$agent_file" >/dev/null 2>&1; then
                while IFS= read -r token_line; do
                    local line_number
                    line_number=$(echo "$token_line" | cut -d: -f1)
                    log_violation "WARNING" "GITHUB_TOKEN mentioned in agent documentation" "$agent_file" "$line_number"
                done <<< "$(grep -n "GITHUB_TOKEN" "$agent_file")"
            fi

            echo "  📝 Found token references in documentation"
        fi

        ((FILES_CHECKED++))

    done <<< "$agent_files"
}

# Function to run comprehensive token audit
run_comprehensive_token_audit() {
    echo -e "${BLUE}🔎 Running comprehensive token audit...${NC}"

    mkdir -p "$TOKEN_AUDIT_DIR"

    if [ ! -f "$AUDIT_SCRIPT" ]; then
        log_violation "CRITICAL" "Token audit script not found" "$AUDIT_SCRIPT"
        return 1
    fi

    # Activate virtual environment for Python audit script
    if ! activate_virtual_env; then
        log_violation "CRITICAL" "Cannot activate virtual environment for audit script" ".venv"
        return 1
    fi

    echo "Running token audit script..."
    local audit_output_file="$TOKEN_AUDIT_DIR/enforcement-validation-audit.json"

    if python "$AUDIT_SCRIPT" \
        --project-root . \
        --json-output "$audit_output_file" \
        --strict-mode 2>&1 | tee "$TOKEN_AUDIT_DIR/enforcement-validation-audit.log"; then
        echo "✅ Token audit completed successfully"

        # Parse audit results if jq is available
        if command -v jq >/dev/null 2>&1 && [ -f "$audit_output_file" ]; then
            local audit_violations
            audit_violations=$(jq -r '.violations // 0' "$audit_output_file" 2>/dev/null || echo "0")
            local audit_warnings
            audit_warnings=$(jq -r '.warnings // 0' "$audit_output_file" 2>/dev/null || echo "0")

            echo "  📊 Audit Results:"
            echo "     Violations: $audit_violations"
            echo "     Warnings: $audit_warnings"

            VIOLATIONS_FOUND=$((VIOLATIONS_FOUND + audit_violations))
            WARNINGS_FOUND=$((WARNINGS_FOUND + audit_warnings))
        fi
    else
        log_violation "CRITICAL" "Token audit script failed" "$AUDIT_SCRIPT"
    fi
}

# Function to check for cleanup artifacts and token-related debris
check_token_cleanup() {
    echo -e "${BLUE}🧹 Checking for token-related cleanup requirements...${NC}"

    # Check for any token-related temporary files
    local temp_token_files=()

    # Look for token files that might have been accidentally created
    while IFS= read -r -d '' file; do
        temp_token_files+=("$file")
    done < <(find . -name "*token*" -type f -not -path "./.git/*" -not -path "./logs/*" -not -path "./.venv/*" -not -path "./node_modules/*" -print0 2>/dev/null || true)

    if [ ${#temp_token_files[@]} -gt 0 ]; then
        echo "Found token-related files that may need review:"
        for file in "${temp_token_files[@]}"; do
            # Skip known good files
            case "$file" in
                ".codex/tokens/"*|"scripts/"*"token"*|"docs/"*)
                    echo "  ✅ $file (expected location)"
                    ;;
                *)
                    log_violation "WARNING" "Unexpected token-related file found" "$file"
                    ;;
            esac
        done
    else
        echo "✅ No unexpected token-related files found"
    fi

    # Check for environment files that might contain tokens
    local env_files=()
    while IFS= read -r -d '' file; do
        env_files+=("$file")
    done < <(find . -name ".env*" -type f -not -path "./.git/*" -not -path "./logs/*" -not -path "./.venv/*" -print0 2>/dev/null || true)

    if [ ${#env_files[@]} -gt 0 ]; then
        echo "Checking environment files for token exposure:"
        for env_file in "${env_files[@]}"; do
            if grep -q "TOKEN" "$env_file" 2>/dev/null; then
                echo "  📝 $env_file contains token references"

                # Check if it's properly gitignored
                if git check-ignore "$env_file" >/dev/null 2>&1; then
                    echo "    ✅ File is properly gitignored"
                else
                    log_violation "CRITICAL" "Environment file with tokens is not gitignored" "$env_file"
                fi
            fi
        done
    fi
}

# Function to validate Enhanced Potato Policy integration
check_potato_policy_integration() {
    echo -e "${BLUE}🥔 Checking Enhanced Potato Policy integration with token governance...${NC}"

    # Check for Potato Policy enforcement script
    if [ -f "scripts/check_potato_ignore.sh" ]; then
        echo "✅ Potato Policy enforcement script found"

        # Check if it's being run (should be in workflows)
        if grep -r "check_potato_ignore" .github/workflows/ >/dev/null 2>&1; then
            echo "✅ Potato Policy integrated into CI workflows"
        else
            log_violation "WARNING" "Potato Policy script not integrated into CI" "scripts/check_potato_ignore.sh"
        fi
    else
        log_violation "WARNING" "Potato Policy enforcement script not found" "scripts/check_potato_ignore.sh"
    fi

    # Check for Potato entries in ignore files (should protect token files)
    local ignore_files=(".gitignore" ".dockerignore" ".codespell-ignore")

    for ignore_file in "${ignore_files[@]}"; do
        if [ -f "$ignore_file" ]; then
            if grep -q "Potato" "$ignore_file"; then
                echo "✅ Potato entries found in $ignore_file"
            else
                log_violation "WARNING" "No Potato entries found in $ignore_file" "$ignore_file"
            fi
        else
            log_violation "WARNING" "Ignore file not found" "$ignore_file"
        fi
    done
}

# Function to generate comprehensive enforcement report
generate_enforcement_report() {
    echo -e "${BLUE}📊 Generating comprehensive token policy enforcement report...${NC}"

    local report_file="$TOKEN_AUDIT_DIR/enforcement-validation-report.md"

    cat > "$report_file" << EOF
# DevOnboarder Token Policy Enforcement Validation Report

**Generated**: $(date)
**Policy**: No Default Token Policy v1.0
**Validation Session**: $(basename "$LOG_FILE" .log)

## Executive Summary

- **Total Violations**: $VIOLATIONS_FOUND
- **Total Warnings**: $WARNINGS_FOUND
- **Files Checked**: $FILES_CHECKED
- **Workflows Checked**: $WORKFLOWS_CHECKED

## Policy Compliance Status

$(if [ "$VIOLATIONS_FOUND" -eq 0 ]; then
    echo "✅ **COMPLIANT** - No critical violations detected"
else
    echo "❌ **NON-COMPLIANT** - $VIOLATIONS_FOUND critical violations detected"
fi)

## Key Findings

### Token Registry Status
- Registry File: $([ -f "$REGISTRY_FILE" ] && echo "✅ Present" || echo "❌ Missing")
- YAML Structure: $(python -c "import yaml; yaml.safe_load(open('$REGISTRY_FILE'))" 2>/dev/null && echo "✅ Valid" || echo "❌ Invalid")

### Workflow Security
- Workflows Scanned: $WORKFLOWS_CHECKED
- GITHUB_TOKEN Violations: $(grep -l "GITHUB_TOKEN" .github/workflows/*.yml 2>/dev/null | wc -l || echo "0")
- Approved Token Usage: $(grep -l -E "(CI_ISSUE_AUTOMATION_TOKEN|DIAGNOSTICS_BOT_KEY|CI_HEALTH_KEY)" .github/workflows/*.yml 2>/dev/null | wc -l || echo "0")

### Enhanced Potato Policy Integration
- Enforcement Script: $([ -f "scripts/check_potato_ignore.sh" ] && echo "✅ Present" || echo "❌ Missing")
- CI Integration: $(grep -r "check_potato_ignore" .github/workflows/ >/dev/null 2>&1 && echo "✅ Active" || echo "❌ Missing")

### Virtual Environment Compliance
- Virtual Environment: $([ -d ".venv" ] && echo "✅ Available" || echo "❌ Missing")
- Audit Script: $([ -f "$AUDIT_SCRIPT" ] && echo "✅ Available" || echo "❌ Missing")

## Recommendations

$(if [ "$VIOLATIONS_FOUND" -gt 0 ]; then
    echo "### Critical Actions Required"
    echo ""
    echo "1. **Address Critical Violations**: Review and fix all critical violations listed above"
    echo "2. **Update Workflows**: Replace GITHUB_TOKEN usage with approved scoped tokens"
    echo "3. **Validate Registry**: Ensure token scope registry is complete and accurate"
    echo ""
fi)

$(if [ "$WARNINGS_FOUND" -gt 0 ]; then
    echo "### Recommended Improvements"
    echo ""
    echo "1. **Review Warnings**: Address $WARNINGS_FOUND warnings to improve compliance"
    echo "2. **Documentation Updates**: Update any documentation referencing deprecated patterns"
    echo "3. **Monitoring Enhancement**: Consider additional monitoring for edge cases"
    echo ""
fi)

### Ongoing Compliance

1. **Regular Audits**: Run this validation script regularly (recommend: weekly)
2. **CI Integration**: Consider adding this script to CI pipeline for continuous validation
3. **Team Training**: Ensure all team members understand the No Default Token Policy
4. **Documentation**: Keep token scope registry updated as new tokens are added

## Detailed Findings

Review the complete log file for detailed findings: \`$LOG_FILE\`

## Next Steps

1. Address any critical violations immediately
2. Plan remediation for warnings during next maintenance window
3. Schedule regular policy validation reviews
4. Update documentation based on findings

---

**Report Generated By**: DevOnboarder Token Policy Enforcement Validator
**Policy Version**: No Default Token Policy v1.0
**Contact**: See project documentation for governance questions
EOF

    echo "✅ Enforcement report generated: $report_file"
}

# Main execution
main() {
    echo "Starting comprehensive token policy enforcement validation..."
    echo ""

    # Step 1: Check token registry
    check_token_registry
    echo ""

    # Step 2: Scan workflows
    scan_workflows_for_violations
    echo ""

    # Step 3: Scan agent documentation
    scan_agent_docs_for_token_usage
    echo ""

    # Step 4: Run comprehensive audit
    run_comprehensive_token_audit
    echo ""

    # Step 5: Check cleanup requirements
    check_token_cleanup
    echo ""

    # Step 6: Check Potato Policy integration
    check_potato_policy_integration
    echo ""

    # Step 7: Generate comprehensive report
    generate_enforcement_report
    echo ""

    # Final summary
    echo -e "${BLUE}📋 Validation Summary${NC}"
    echo "=================="
    echo "Files Checked: $FILES_CHECKED"
    echo "Workflows Checked: $WORKFLOWS_CHECKED"
    echo "Violations Found: $VIOLATIONS_FOUND"
    echo "Warnings Found: $WARNINGS_FOUND"
    echo ""

    if [ "$VIOLATIONS_FOUND" -eq 0 ]; then
        echo -e "${GREEN}✅ SUCCESS: No critical policy violations detected${NC}"
        echo -e "Token governance appears to be properly implemented."
        echo ""
        echo "📊 Full report: $TOKEN_AUDIT_DIR/enforcement-validation-report.md"
        echo "📝 Detailed log: $LOG_FILE"
        return 0
    else
        echo -e "${RED}❌ FAILURE: $VIOLATIONS_FOUND critical policy violations detected${NC}"
        echo -e "Token governance requires immediate attention."
        echo ""
        echo "📊 Full report: $TOKEN_AUDIT_DIR/enforcement-validation-report.md"
        echo "📝 Detailed log: $LOG_FILE"
        echo ""
        echo "Next steps:"
        echo "1. Review detailed findings in the report"
        echo "2. Address critical violations immediately"
        echo "3. Plan remediation for warnings"
        echo "4. Re-run validation after fixes"
        return 1
    fi
}

# Help function
show_help() {
    echo "DevOnboarder Token Policy Enforcement & Cleanup Validation"
    echo "=========================================================="
    echo ""
    echo "This script validates compliance with the No Default Token Policy v1.0"
    echo "and checks for proper token governance implementation."
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h          Show this help message"
    echo "  --report-only       Generate report without running full validation"
    echo "  --strict            Enable strict mode (treat warnings as violations)"
    echo ""
    echo "Features:"
    echo "  • Token scope registry validation"
    echo "  • GitHub workflow scanning for policy violations"
    echo "  • Agent documentation review"
    echo "  • Comprehensive token audit execution"
    echo "  • Cleanup artifact detection"
    echo "  • Enhanced Potato Policy integration check"
    echo "  • Detailed compliance reporting"
    echo ""
    echo "Output:"
    echo "  • Centralized log: logs/token_policy_enforcement_*.log"
    echo "  • Compliance report: logs/token-audit/enforcement-validation-report.md"
    echo "  • Audit results: logs/token-audit/enforcement-validation-audit.json"
    echo ""
    echo "Exit codes:"
    echo "  0  - No critical violations (policy compliant)"
    echo "  1  - Critical violations found (policy non-compliant)"
    echo "  2  - Script execution error"
}

# Parse command line arguments
case "${1:-}" in
    "--help"|"-h")
        show_help
        exit 0
        ;;
    "--report-only")
        echo "Report-only mode not yet implemented"
        exit 1
        ;;
    "--strict")
        echo "Strict mode not yet implemented"
        exit 1
        ;;
    "")
        # Run full validation
        main
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 2
        ;;
esac
