#!/usr/bin/env bash
# Enhanced Potato Policy Violation Reporter
# Comprehensive violation detection, reporting, and issue creation for DevOnboarder
# Integrates with Enhanced Potato Policy framework and CI monitoring system
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
export REPO_OWNER="theangrygamershowproductions"
export REPO_NAME="DevOnboarder"

# Log files
VIOLATION_LOG="${PROJECT_ROOT}/logs/potato-violations.log"
AUDIT_LOG="${PROJECT_ROOT}/logs/potato-audit-$(date %Y%m%d_%H%M%S).log"

# Virtual environment validation
check_virtual_environment() {
    if [ -z "${VIRTUAL_ENV:-}" ]; then
        echo -e "${RED} CRITICAL: Virtual environment required for violation reporting${NC}" >&2
        echo -e "${YELLOW}   Solution: source .venv/bin/activate && pip install -e .[test]${NC}" >&2
        echo -e "${BLUE}   DevOnboarder requires ALL security tools to run in virtual environment context${NC}" >&2
        exit 1
    fi
}

# Setup logging infrastructure
setup_logging() {
    local log_dir="${PROJECT_ROOT}/logs"
    mkdir -p "$log_dir"

    # Initialize audit log
    {
        echo "Enhanced Potato Policy Violation Reporter - $(date -Iseconds)"
        echo "============================================================"
        echo "Project Root: $PROJECT_ROOT"
        echo "Virtual Environment: ${VIRTUAL_ENV}"
        echo "Repository: ${REPO_OWNER}/${REPO_NAME}"
        echo "============================================================"
        echo ""
    } > "$AUDIT_LOG"

    # Ensure violation log exists
    touch "$VIOLATION_LOG"
}

# Enhanced violation detection
detect_violations() {
    local violations_detected=false
    local violation_details=""

    echo -e "${PURPLE} Running enhanced violation detection...${NC}" | tee -a "$AUDIT_LOG"

    # Run enhanced potato check script
    local check_output
    local check_exit_code

    if check_output=$(bash "${SCRIPT_DIR}/enhanced_potato_check.sh" --no-autofix 2>&1); then
        check_exit_code=0
    else
        check_exit_code=$?
    fi

    # Log the check output
    {
        echo "ENHANCED_POTATO_CHECK_OUTPUT: $(date -Iseconds)"
        echo "Exit Code: $check_exit_code"
        echo "Output:"
        echo "$check_output"
        echo "---"
    } >> "$AUDIT_LOG"

    if [ $check_exit_code -ne 0 ]; then
        violations_detected=true
        violation_details="$check_output"
        echo -e "${RED} Enhanced Potato Policy violations detected${NC}" | tee -a "$AUDIT_LOG"
    else
        echo -e "${GREEN} No violations detected by enhanced check${NC}" | tee -a "$AUDIT_LOG"
    fi

    # Additional git-based violation detection
    if ! git diff --quiet; then
        local changed_files
        changed_files=$(git diff --name-only)

        echo -e "${YELLOW} Git working directory changes detected:${NC}" | tee -a "$AUDIT_LOG"
        echo "$changed_files" | tee -a "$AUDIT_LOG"

        # Check if changes are only auto-fixed ignore files
        if echo "$changed_files" | grep -qvE "^(\.gitignore|\.dockerignore|\.codespell-ignore)$"; then
            violations_detected=true
            violation_details="${violation_details}\n\nAdditional files modified:\n${changed_files}"
            echo -e "${RED} Real violations detected beyond ignore file auto-fixes${NC}" | tee -a "$AUDIT_LOG"
        else
            echo -e "${GREEN} Only ignore files auto-updated (automatic remediation)${NC}" | tee -a "$AUDIT_LOG"
        fi
    fi

    # Scan for recently added sensitive files
    local recent_files
    recent_files=$(find "$PROJECT_ROOT" -type f -mtime -1 \
        \( -name "*.env" -o -name "*.pem" -o -name "*.key" -o -name "secrets.*" \) \
        -not -path "*/.git/*" \
        -not -path "*/.venv/*" \
        -not -path "*/node_modules/*" \
        2>/dev/null || true)

    if [ -n "$recent_files" ]; then
        violations_detected=true
        violation_details="${violation_details}\n\nRecently created sensitive files:\n${recent_files}"
        echo -e "${RED} Recently created sensitive files detected${NC}" | tee -a "$AUDIT_LOG"
        echo "$recent_files" | tee -a "$AUDIT_LOG"
    fi

    if [ "$violations_detected" = true ]; then
        return 1
    else
        return 0
    fi
}

# Enhanced GitHub issue creation
create_github_issue() {
    local violation_type="$1"
    local violation_details="$2"

    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}  GitHub CLI not available - violation logged but no issue created${NC}" | tee -a "$AUDIT_LOG"
        return 1
    fi

    if [ -z "${GITHUB_TOKEN:-}" ]; then
        echo -e "${YELLOW}  GITHUB_TOKEN not set - violation logged but no issue created${NC}" | tee -a "$AUDIT_LOG"
        return 1
    fi

    local timestamp
    timestamp=$(date -Iseconds)
    local branch
    branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local commit
    commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local user
    user=$(whoami 2>/dev/null || echo "unknown")

    local issue_title="🥔 Enhanced Potato Policy Violation - ${violation_type} (${branch})"

    local issue_body
    read -r -d '' issue_body << EOF || true
# 🚨 Enhanced Potato Policy Violation Detected

## Incident Details

- **Violation Type:** ${violation_type}
- **Detection Time:** ${timestamp}
- **Branch:** \`${branch}\`
- **Commit:** \`${commit}\`
- **User:** \`${user}\`
- **Repository:** ${REPO_OWNER}/${REPO_NAME}

## Violation Summary

${violation_details}

## Immediate Actions Required

1. **Review** the detected violations listed above
2. **Remove** any exposed sensitive files from the repository
3. **Update** ignore files to prevent future violations
4. **Verify** that no sensitive data was committed to git history
5. **Rotate** any potentially exposed secrets or keys

## Enhanced Potato Policy Framework

This violation was detected by the DevOnboarder Enhanced Potato Policy framework, which protects:

### Critical Security Files
- \`Potato.md\` - SSH keys, setup instructions
- \`*.pem\`, \`*.key\` - Private keys and certificates
- \`id_rsa*\` - SSH private keys
- \`*.p12\` - PKCS#12 certificate stores

### Sensitive Configuration
- \`*.env\` - Environment variables
- \`secrets.yaml/yml\` - Configuration secrets
- \`config/secrets.*\` - Application secrets
- \`webhook-config.json\` - Webhook configurations

### DevOnboarder-Specific
- \`discord-tokens.*\` - Discord bot authentication
- \`github-tokens.*\` - GitHub API tokens
- \`ci-secrets.*\` - CI/CD secrets
- \`auth.db\` - Authentication databases

## Remediation Commands

Run these commands in virtual environment context:

\`\`\`bash
# Activate virtual environment
source .venv/bin/activate

# Run enhanced policy check with auto-fix
bash scripts/enhanced_potato_check.sh --verbose

# Validate compliance
bash scripts/enhanced_potato_check.sh --dry-run

# Generate audit report
bash scripts/generate_potato_report.sh
\`\`\`

## Prevention

To prevent future violations:

1. **Always run pre-commit hooks** - they include Potato Policy enforcement
2. **Use virtual environment** for all DevOnboarder operations
3. **Review** \`docs/enhanced-potato-policy.md\` for complete guidelines
4. **Enable auto-fix** in your development environment

## Automation Details

- **Detection Script:** \`scripts/enhanced_potato_check.sh\`
- **Reporter Script:** \`scripts/potato_violation_reporter.sh\`
- **Policy Documentation:** \`docs/enhanced-potato-policy.md\`
- **CI Integration:** \`.github/workflows/potato-policy-focused.yml\`

---

**Priority:** Critical
**Category:** Security Violation
**Framework:** Enhanced Potato Policy v2.0
**Philosophy:** Pain  Protocol  Protection

This issue was automatically created by the Enhanced Potato Policy violation reporter.
EOF

    echo -e "${BLUE} Creating GitHub issue for ${violation_type}...${NC}" | tee -a "$AUDIT_LOG"

    # Create GitHub issue with enhanced error handling
    local issue_url
    if issue_url=$(gh issue create \
        --title "$issue_title" \
        --body "$issue_body" \
        --label "security,potato-policy,automated,critical" \
        --assignee "@me" 2>&1); then

        echo -e "${GREEN} GitHub issue created successfully${NC}" | tee -a "$AUDIT_LOG"
        echo -e "${CYAN}LINK: Issue URL: $issue_url${NC}" | tee -a "$AUDIT_LOG"

        # Log issue creation
        {
            echo "GITHUB_ISSUE_CREATED: $(date -Iseconds)"
            echo "URL: $issue_url"
            echo "Title: $issue_title"
            echo "---"
        } >> "$VIOLATION_LOG"

        return 0
    else
        echo -e "${RED} Failed to create GitHub issue: $issue_url${NC}" | tee -a "$AUDIT_LOG"

        # Log failure
        {
            echo "GITHUB_ISSUE_FAILED: $(date -Iseconds)"
            echo "Error: $issue_url"
            echo "---"
        } >> "$VIOLATION_LOG"

        return 1
    fi
}

# Log violation to audit trail
log_violation() {
    local violation_type="$1"
    local violation_details="$2"

    local timestamp
    timestamp=$(date -Iseconds)
    local branch
    branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local commit
    commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local user
    user=$(whoami 2>/dev/null || echo "unknown")

    # Log to violation log
    {
        echo "VIOLATION_DETECTED: $timestamp"
        echo "Type: $violation_type"
        echo "Branch: $branch"
        echo "Commit: $commit"
        echo "User: $user"
        echo "Details:"
        echo "$violation_details"
        echo "---"
    } >> "$VIOLATION_LOG"

    echo -e "${BLUE} Violation logged to: $VIOLATION_LOG${NC}" | tee -a "$AUDIT_LOG"
}

# Generate comprehensive violation report
generate_violation_report() {
    local violation_type="$1"
    local violation_details="$2"

    local report_file
    report_file="${PROJECT_ROOT}/logs/violation_report_$(date %Y%m%d_%H%M%S).md"

    {
        echo "# Enhanced Potato Policy Violation Report"
        echo ""
        echo "**Generated:** $(date -Iseconds)  "
        echo "**Project:** DevOnboarder  "
        echo "**Branch:** $(git branch --show-current 2>/dev/null || echo 'unknown')  "
        echo "**Commit:** $(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')  "
        echo "**User:** $(whoami 2>/dev/null || echo 'unknown')  "
        echo ""
        echo "## Violation Summary"
        echo ""
        echo "**Type:** $violation_type"
        echo ""
        echo "## Details"
        echo ""
        echo "$violation_details"
        echo ""
        echo "## Required Actions"
        echo ""
        echo "1. Review and address all detected violations"
        echo "2. Run \`bash scripts/enhanced_potato_check.sh\` to validate fixes"
        echo "3. Ensure virtual environment is active for all operations"
        echo "4. Review \`docs/enhanced-potato-policy.md\` for prevention guidelines"
        echo ""
        echo "## Audit Trail"
        echo ""
        echo "- Violation Log: \`$VIOLATION_LOG\`"
        echo "- Audit Log: \`$AUDIT_LOG\`"
        echo "- Virtual Environment: \`${VIRTUAL_ENV}\`"
        echo ""
        echo "---"
        echo "*This report was generated automatically by the Enhanced Potato Policy framework*"
    } > "$report_file"

    echo -e "${BLUE} Violation report generated: $report_file${NC}" | tee -a "$AUDIT_LOG"
}

# Main execution function
main() {
    echo -e "${PURPLE}🚨 Enhanced Potato Policy Violation Reporter${NC}"
    echo -e "${PURPLE}=============================================${NC}"
    echo -e "${BLUE}DevOnboarder Security Framework v2.0${NC}"
    echo -e "${BLUE}Philosophy: Pain  Protocol  Protection${NC}"
    echo ""

    # Critical setup
    check_virtual_environment
    setup_logging

    echo -e "${CYAN} Starting comprehensive violation detection...${NC}" | tee -a "$AUDIT_LOG"
    echo ""

    # Detect violations
    local violation_details=""
    local violation_type="Unknown"

    if detect_violations; then
        echo -e "${GREEN}🎉 No violations detected - system is compliant${NC}" | tee -a "$AUDIT_LOG"
        echo -e "${GREEN} Enhanced Potato Policy: ALL CHECKS PASSED${NC}"
        echo -e "${BLUE} Audit log: $AUDIT_LOG${NC}"
        exit 0
    else
        violation_type="Security Policy Violation"
        violation_details=$(tail -n 50 "$AUDIT_LOG" | grep -A 20 -B 5 "" || echo "See audit log for details")

        echo -e "${RED}💥 VIOLATIONS DETECTED${NC}" | tee -a "$AUDIT_LOG"
        echo ""

        # Log the violation
        log_violation "$violation_type" "$violation_details"

        # Generate comprehensive report
        generate_violation_report "$violation_type" "$violation_details"

        # Create GitHub issue if possible
        if create_github_issue "$violation_type" "$violation_details"; then
            echo -e "${GREEN} GitHub issue created for tracking${NC}"
        else
            echo -e "${YELLOW}  GitHub issue creation failed but violation logged${NC}"
        fi

        echo ""
        echo -e "${RED} Enhanced Potato Policy: VIOLATIONS REQUIRE ATTENTION${NC}"
        echo -e "${YELLOW}📖 Review: docs/enhanced-potato-policy.md${NC}"
        echo -e "${BLUE} Full audit: $AUDIT_LOG${NC}"
        echo -e "${BLUE} Violation log: $VIOLATION_LOG${NC}"

        exit 1
    fi
}

# Execute main function
main "$@"
