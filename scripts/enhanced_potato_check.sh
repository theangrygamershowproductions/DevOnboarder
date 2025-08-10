#!/usr/bin/env bash
# Enhanced Potato Policy Enforcement Script
# "Every rule has a scar behind it" - Born from real-world security incidents
#
# This script implements comprehensive security checking for the DevOnboarder project
# following the Enhanced Potato Policy framework
#
# Philosophy: Pain → Protocol → Protection
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

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERBOSE=false
DRY_RUN=false
AUTO_FIX=true
EXIT_CODE=0

# Virtual environment validation
check_virtual_environment() {
    if [ -z "${VIRTUAL_ENV:-}" ]; then
        echo -e "${RED}FAILED CRITICAL: Virtual environment required for Enhanced Potato Policy operations${NC}" >&2
        echo -e "${YELLOW}   Solution: source .venv/bin/activate && pip install -e .[test]${NC}" >&2
        echo -e "${BLUE}   DevOnboarder requires ALL security tools to run in virtual environment context${NC}" >&2
        exit 1
    fi

    if [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}SUCCESS Virtual environment active: ${VIRTUAL_ENV}${NC}"
    fi
}

# Logging setup
setup_logging() {
    local log_dir="${PROJECT_ROOT}/logs"
    mkdir -p "$log_dir"

    # Create timestamped log file
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    LOG_FILE="${log_dir}/enhanced_potato_check_${timestamp}.log"

    # Initialize log file
    {
        echo "Enhanced Potato Policy Check - $(date -Iseconds)"
        echo "========================================"
        echo "Project Root: $PROJECT_ROOT"
        echo "Virtual Environment: ${VIRTUAL_ENV:-NONE}"
        echo "Script Version: 2.0"
        echo "========================================"
        echo ""
    } > "$LOG_FILE"

    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}EDIT Logging to: $LOG_FILE${NC}"
    fi
}

# Protected file patterns - Enhanced DevOnboarder specific
declare -a CRITICAL_PATTERNS=(
    "Potato.md"              # SSH keys, setup instructions
    "*.pem"                  # Private keys and certificates
    "*.key"                  # Cryptographic keys
    "id_rsa*"                # SSH private keys
    "*.p12"                  # PKCS#12 certificate stores
)

declare -a SENSITIVE_PATTERNS=(
    "*.env"                  # Environment variables
    ".env.*"                 # Environment-specific configs
    "secrets.yaml"           # Configuration secrets
    "secrets.yml"            # YAML configuration secrets
    "config/secrets.*"       # Application secrets
    "webhook-config.json"    # Webhook configurations
)

declare -a DEVONBOARDER_PATTERNS=(
    "discord-tokens.*"       # Discord bot authentication
    "github-tokens.*"        # GitHub API tokens
    "ci-secrets.*"          # CI/CD secrets
    "deployment-keys.*"     # Deployment authentication
    "backup-configs.*"      # Backup configurations
    "auth.db"               # Authentication databases
    ".codex/private/*"      # Private Codex data
    ".codex/cache/*"        # Cached sensitive data
)

# Ignore files that must contain protection patterns
declare -a IGNORE_FILES=(
    ".gitignore"
    ".dockerignore"
    ".codespell-ignore"
)

# Check if a pattern exists in ignore file
check_pattern_in_file() {
    local file="$1"
    local pattern="$2"

    if [ ! -f "$file" ]; then
        echo -e "${RED}FAILED Ignore file missing: $file${NC}" | tee -a "$LOG_FILE"
        return 1
    fi

    # Use exact match for simple patterns, regex for complex ones
    if grep -Fxq "$pattern" "$file" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Add pattern to ignore file
add_pattern_to_file() {
    local file="$1"
    local pattern="$2"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY-RUN] Would add '$pattern' to $file${NC}" | tee -a "$LOG_FILE"
        return 0
    fi

    echo -e "${BLUE}CONFIG Adding '$pattern' to $file${NC}" | tee -a "$LOG_FILE"
    echo "$pattern" >> "$file"

    # Sort and remove duplicates
    sort -u "$file" -o "$file"
}

# Validate ignore file coverage
validate_ignore_files() {
    local violations=0

    echo -e "${PURPLE}SEARCH Validating ignore file coverage...${NC}" | tee -a "$LOG_FILE"

    # Combine all patterns
    local all_patterns=("${CRITICAL_PATTERNS[@]}" "${SENSITIVE_PATTERNS[@]}" "${DEVONBOARDER_PATTERNS[@]}")

    for ignore_file in "${IGNORE_FILES[@]}"; do
        local file_path="${PROJECT_ROOT}/${ignore_file}"

        echo -e "${CYAN}   Checking: $ignore_file${NC}" | tee -a "$LOG_FILE"

        if [ ! -f "$file_path" ]; then
            echo -e "${RED}FAILED Missing ignore file: $ignore_file${NC}" | tee -a "$LOG_FILE"
            violations=$((violations + 1))

            if [ "$AUTO_FIX" = true ]; then
                echo -e "${BLUE}CONFIG Creating missing ignore file: $ignore_file${NC}" | tee -a "$LOG_FILE"
                touch "$file_path"
            fi
            continue
        fi

        for pattern in "${all_patterns[@]}"; do
            if ! check_pattern_in_file "$file_path" "$pattern"; then
                echo -e "${YELLOW}WARNING  Missing pattern '$pattern' in $ignore_file${NC}" | tee -a "$LOG_FILE"
                violations=$((violations + 1))

                if [ "$AUTO_FIX" = true ]; then
                    add_pattern_to_file "$file_path" "$pattern"
                fi
            fi
        done
    done

    if [ $violations -eq 0 ]; then
        echo -e "${GREEN}SUCCESS All ignore files properly configured${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}FAILED Found $violations ignore file violations${NC}" | tee -a "$LOG_FILE"
        EXIT_CODE=1
    fi

    return $violations
}

# Scan for exposed sensitive files
scan_exposed_files() {
    local violations=0

    echo -e "${PURPLE}SEARCH Scanning for exposed sensitive files...${NC}" | tee -a "$LOG_FILE"

    # Change to project root for relative path scanning
    cd "$PROJECT_ROOT"

    # Combine all patterns for scanning
    local all_patterns=("${CRITICAL_PATTERNS[@]}" "${SENSITIVE_PATTERNS[@]}" "${DEVONBOARDER_PATTERNS[@]}")

    for pattern in "${all_patterns[@]}"; do
        # Use find with pattern matching, exclude known safe directories
        local found_files
        found_files=$(find . -name "$pattern" \
            -not -path "./.git/*" \
            -not -path "./.venv/*" \
            -not -path "./node_modules/*" \
            -not -path "./logs/*" \
            -not -path "./.codex/logs/*" \
            -type f 2>/dev/null || true)

        if [ -n "$found_files" ]; then
            echo -e "${RED}FAILED CRITICAL: Found exposed sensitive files matching '$pattern':${NC}" | tee -a "$LOG_FILE"
            echo "$found_files" | while IFS= read -r file; do
                echo -e "${RED}   • $file${NC}" | tee -a "$LOG_FILE"
                violations=$((violations + 1))
            done

            # Log critical violation for audit trail
            {
                echo "CRITICAL_VIOLATION: $(date -Iseconds)"
                echo "Pattern: $pattern"
                echo "Files:"
                echo "$found_files"
                echo "---"
            } >> "${PROJECT_ROOT}/logs/potato_violations.log"
        fi
    done

    if [ $violations -eq 0 ]; then
        echo -e "${GREEN}SUCCESS No exposed sensitive files detected${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}FAILED CRITICAL: Found $violations exposed sensitive files${NC}" | tee -a "$LOG_FILE"
        EXIT_CODE=1
    fi

    return $violations
}

# Advanced content scanning for hardcoded secrets
scan_content_patterns() {
    local violations=0

    echo -e "${PURPLE}SEARCH Scanning for hardcoded secrets in content...${NC}" | tee -a "$LOG_FILE"

    # Advanced patterns for secret detection
    declare -a SECRET_PATTERNS=(
        "password\s*[:=]\s*['\"][^'\"]{8,}['\"]"          # Password assignments
        "api[_-]?key\s*[:=]\s*['\"][^'\"]{16,}['\"]"      # API key assignments
        "token\s*[:=]\s*['\"][^'\"]{20,}['\"]"            # Token assignments
        "secret\s*[:=]\s*['\"][^'\"]{12,}['\"]"           # Secret assignments
        "DISCORD_.*TOKEN.*['\"][^'\"]{50,}['\"]"          # Discord tokens
        "GITHUB_.*TOKEN.*['\"][^'\"]{30,}['\"]"           # GitHub tokens
        "jwt\s*[:=]\s*['\"]eyJ[^'\"]+['\"]"               # JWT tokens
        "-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----"         # Private keys
    )

    # Files to scan (exclude binary files, logs, and known safe files)
    local files_to_scan
    files_to_scan=$(find "$PROJECT_ROOT" -type f \
        \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" -o -name "*.md" -o -name "*.sh" \) \
        -not -path "*/.git/*" \
        -not -path "*/.venv/*" \
        -not -path "*/node_modules/*" \
        -not -path "*/logs/*" \
        -not -path "*/.codex/logs/*" \
        -not -path "*/coverage/*" \
        -not -path "*/test-results/*" \
        2>/dev/null || true)

    if [ -z "$files_to_scan" ]; then
        echo -e "${YELLOW}WARNING  No files found to scan for content patterns${NC}" | tee -a "$LOG_FILE"
        return 0
    fi

    for pattern in "${SECRET_PATTERNS[@]}"; do
        local matches
        matches=$(echo "$files_to_scan" | xargs grep -l -E "$pattern" 2>/dev/null || true)

        if [ -n "$matches" ]; then
            echo -e "${RED}FAILED POTENTIAL SECRET DETECTED - Pattern: $pattern${NC}" | tee -a "$LOG_FILE"
            echo "$matches" | while IFS= read -r file; do
                # Get specific line matches (without showing the actual secret)
                local line_numbers
                line_numbers=$(grep -n -E "$pattern" "$file" 2>/dev/null | cut -d: -f1 || true)
                echo -e "${RED}   • $file (lines: $line_numbers)${NC}" | tee -a "$LOG_FILE"
                violations=$((violations + 1))
            done

            # Log potential secret for manual review
            {
                echo "POTENTIAL_SECRET: $(date -Iseconds)"
                echo "Pattern: $pattern"
                echo "Files:"
                echo "$matches"
                echo "---"
            } >> "${PROJECT_ROOT}/logs/potato_violations.log"
        fi
    done

    if [ $violations -eq 0 ]; then
        echo -e "${GREEN}SUCCESS No hardcoded secrets detected in content${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${YELLOW}WARNING  Found $violations potential secrets - manual review required${NC}" | tee -a "$LOG_FILE"
        # Don't set EXIT_CODE for potential secrets, they need manual review
    fi

    return $violations
}

# Validate virtual environment isolation
validate_virtual_env_isolation() {
    echo -e "${PURPLE}SEARCH Validating virtual environment isolation...${NC}" | tee -a "$LOG_FILE"

    # Check that Python tools are available in virtual environment
    local required_tools=("python" "pip" "black" "ruff" "pytest")
    local violations=0

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo -e "${RED}FAILED Required tool '$tool' not available in virtual environment${NC}" | tee -a "$LOG_FILE"
            violations=$((violations + 1))
        elif [ "$VERBOSE" = true ]; then
            local tool_path
            tool_path=$(command -v "$tool")
            if [[ "$tool_path" == "${VIRTUAL_ENV}"* ]]; then
                echo -e "${GREEN}SUCCESS $tool: $tool_path${NC}" | tee -a "$LOG_FILE"
            else
                echo -e "${YELLOW}WARNING  $tool not from virtual environment: $tool_path${NC}" | tee -a "$LOG_FILE"
                violations=$((violations + 1))
            fi
        fi
    done

    if [ $violations -eq 0 ]; then
        echo -e "${GREEN}SUCCESS Virtual environment isolation validated${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}FAILED Virtual environment isolation violations: $violations${NC}" | tee -a "$LOG_FILE"
        EXIT_CODE=1
    fi

    return $violations
}

# Generate compliance report
generate_compliance_report() {
    local report_file
    report_file="${PROJECT_ROOT}/logs/potato_compliance_$(date +%Y%m%d_%H%M%S).md"

    {
        echo "# Enhanced Potato Policy Compliance Report"
        echo "Generated: $(date -Iseconds)"
        echo "Project: DevOnboarder"
        echo "Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
        echo "Commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
        echo ""
        echo "## Summary"
        echo "- Script Exit Code: $EXIT_CODE"
        echo "- Virtual Environment: ${VIRTUAL_ENV:-'NOT SET'}"
        echo "- Auto-fix Enabled: $AUTO_FIX"
        echo "- Dry Run Mode: $DRY_RUN"
        echo ""
        echo "## Log File"
        echo "Full details: $LOG_FILE"
        echo ""
        echo "## Next Steps"
        if [ $EXIT_CODE -eq 0 ]; then
            echo "SUCCESS All checks passed - system is compliant"
        else
            echo "FAILED Violations detected - review log file and fix issues"
            echo "SYMBOL See: docs/enhanced-potato-policy.md for guidance"
        fi
    } > "$report_file"

    echo -e "${BLUE}STATS Compliance report generated: $report_file${NC}" | tee -a "$LOG_FILE"
}

# Usage information
show_usage() {
    cat << EOF
Enhanced Potato Policy Enforcement Script

Usage: $0 [OPTIONS]

OPTIONS:
    -v, --verbose     Enable verbose output
    -d, --dry-run     Show what would be done without making changes
    -n, --no-autofix  Disable automatic fixing of violations
    -h, --help        Show this help message

DESCRIPTION:
    Comprehensive security enforcement for DevOnboarder project following
    the Enhanced Potato Policy framework. Validates ignore file coverage,
    scans for exposed sensitive files, and enforces virtual environment isolation.

REQUIREMENTS:
    - Must run in virtual environment (source .venv/bin/activate)
    - Requires DevOnboarder dependencies installed (pip install -e .[test])

EXAMPLES:
    $0                    # Run standard checks with auto-fix
    $0 --verbose          # Run with detailed output
    $0 --dry-run          # Preview changes without applying
    $0 --verbose --dry-run --no-autofix  # Maximum visibility, no changes

EXIT CODES:
    0    All checks passed
    1    Violations detected
    2    Configuration error

EOF
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                AUTO_FIX=false  # Disable auto-fix in dry-run mode
                shift
                ;;
            -n|--no-autofix)
                AUTO_FIX=false
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo -e "${RED}FAILED Unknown option: $1${NC}" >&2
                echo "Use --help for usage information" >&2
                exit 2
                ;;
        esac
    done
}

# Main execution function
main() {
    # Parse command line arguments
    parse_arguments "$@"

    # Display header
    echo -e "${PURPLE}POTATO Enhanced Potato Policy Enforcement${NC}"
    echo -e "${PURPLE}======================================${NC}"
    echo -e "${BLUE}DevOnboarder Security Framework v2.0${NC}"
    echo -e "${BLUE}Philosophy: Pain → Protocol → Protection${NC}"
    echo ""

    # Critical checks first
    check_virtual_environment
    setup_logging

    # Run all validation checks
    echo -e "${CYAN}DEPLOY Starting comprehensive security validation...${NC}" | tee -a "$LOG_FILE"
    echo ""

    validate_ignore_files
    echo ""

    scan_exposed_files
    echo ""

    scan_content_patterns
    echo ""

    validate_virtual_env_isolation
    echo ""

    # Generate compliance report
    generate_compliance_report

    # Final summary
    echo -e "${PURPLE}======================================${NC}"
    if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}SYMBOL Enhanced Potato Policy: ALL CHECKS PASSED${NC}"
        echo -e "${GREEN}SUCCESS DevOnboarder security framework is compliant${NC}"
    else
        echo -e "${RED}SYMBOL Enhanced Potato Policy: VIOLATIONS DETECTED${NC}"
        echo -e "${RED}FAILED Review violations and apply fixes${NC}"
        echo -e "${YELLOW}SYMBOL See docs/enhanced-potato-policy.md for guidance${NC}"
    fi
    echo -e "${BLUE}EDIT Full log: $LOG_FILE${NC}"
    echo -e "${PURPLE}======================================${NC}"

    exit $EXIT_CODE
}

# Execute main function with all arguments
main "$@"
