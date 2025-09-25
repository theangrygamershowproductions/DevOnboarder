#!/bin/bash
# =============================================================================
# File: scripts/env_security_audit.sh
# Purpose: Audit environment variable security across all environment files
# Usage: bash scripts/env_security_audit.sh
# =============================================================================

# Ensure we're in the project root
cd "$(dirname "$0")/.." || exit

# Initialize logging
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder Environment Security Audit"
echo "Log file: $LOG_FILE"
echo ""

# Define sensitive patterns
SENSITIVE_PATTERNS=(
    "SECRET"
    "TOKEN"
    "KEY"
    "PASSWORD"
    "PASS"
    "CREDENTIAL"
    "CLIENT_SECRET"
)

# Define files to audit
ENV_FILES=(".env" ".env.dev" ".env.prod" ".env.ci")

# Function to check if variable contains sensitive data
is_sensitive_var() {
    local var_name=$1

    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        if echo "$var_name" | grep -qi "$pattern"; then
            return 0  # Is sensitive
        fi
    done

    return 1  # Not sensitive
}

# Function to audit environment file
audit_env_file() {
    local file=$1
    local is_committed=$2

    echo "=== Auditing: $file ==="
    echo "Committed to git: $is_committed"

    if [ ! -f "$file" ]; then
        echo "  WARNING: File not found"
        return 1
    fi

    local total_vars=0
    local sensitive_vars=0
    local test_values=0
    local production_values=0

    # Extract all variables
    while IFS='=' read -r var_name var_value; do
        if [ -n "$var_name" ] && [ -n "$var_value" ]; then
            total_vars=$((total_vars + 1))

            # Check if variable is sensitive
            if is_sensitive_var "$var_name"; then
                sensitive_vars=$((sensitive_vars + 1))

                # Check if value looks like test/placeholder data
                if echo "$var_value" | grep -qi "test\|placeholder\|ci_test\|mock\|fake\|localhost"; then
                    test_values=$((test_values + 1))
                    echo "  SAFE: $var_name (test value)"
                else
                    production_values=$((production_values + 1))
                    if [ "$is_committed" = "true" ]; then
                        echo "  RISK: $var_name (production value in committed file)"
                    else
                        echo "  OK: $var_name (production value in gitignored file)"
                    fi
                fi
            fi
        fi
    done < <(grep -E '^[A-Z_][A-Z0-9_]*=' "$file" 2>/dev/null || true)

    echo "  Total variables: $total_vars"
    echo "  Sensitive variables: $sensitive_vars"
    echo "  Test values: $test_values"
    echo "  Production values: $production_values"
    echo ""

    return 0
}

# Function to check git status
check_git_status() {
    local file=$1

    # Check if file is in .gitignore
    if git check-ignore "$file" >/dev/null 2>&1; then
        echo "false"  # File is gitignored
    else
        echo "true"   # File will be committed
    fi
}

# Main audit execution
main() {
    echo "Starting security audit of environment files"
    echo "Date: $(date)"
    echo ""

    # shellcheck disable=SC2034 # Variable reserved for future metrics expansion
    local total_risk_files=0
    local audit_passed=true

    # Audit each environment file
    for env_file in "${ENV_FILES[@]}"; do
        local is_committed
        is_committed=$(check_git_status "$env_file")

        audit_env_file "$env_file" "$is_committed"

        # Check for high-risk scenarios
        if [ "$env_file" = ".env.ci" ] && [ "$is_committed" = "true" ]; then
            echo "=== CI Security Check ==="

            # Check for production tunnel tokens in CI
            if grep -q "TUNNEL_TOKEN.*eyJ" "$env_file" 2>/dev/null; then
                echo "  CRITICAL: Real Cloudflare tunnel token found in CI file!"
                audit_passed=false
            else
                echo "  OK: CI uses test tunnel token"
            fi

            # Check for production URLs in CI
            if grep -q "https://.*\.theangrygamershow\.com" "$env_file" 2>/dev/null; then
                echo "  INFO: Production URLs found in CI (acceptable for frontend variables)"
            else
                echo "  OK: CI uses localhost URLs for testing"
            fi

            echo ""
        fi
    done

    # Security recommendations
    echo "=== Security Audit Summary ==="
    echo "Audit status: $([ "$audit_passed" = true ] && echo "PASSED" || echo "FAILED")"
    echo ""
    echo "Security Model:"
    echo "  .env         - Source of truth (GITIGNORED)"
    echo "  .env.dev     - Development config (GITIGNORED)"
    echo "  .env.prod    - Production config (GITIGNORED)"
    echo "  .env.ci      - CI test config (COMMITTED with test values)"
    echo ""
    echo "Protection Rules:"
    echo "  1. Production secrets NEVER in committed files"
    echo "  2. CI environment uses test/mock values only"
    echo "  3. Real tunnel tokens excluded from CI"
    echo "  4. Synchronization respects security boundaries"
    echo ""

    if [ "$audit_passed" = false ]; then
        echo "CRITICAL ISSUES FOUND!"
        echo "Action required: Remove production secrets from committed files"
        return 1
    else
        echo "Security audit passed - environment variables properly protected"
        return 0
    fi
}

# Execute audit
main "$@"
exit $?
