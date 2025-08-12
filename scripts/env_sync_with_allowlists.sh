#!/bin/bash

# Environment Variable Synchronization with Security Allowlists
# DevOnboarder CI Stabilization Bundle - Objective 5

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color output (shellcheck disable for template variables)
# shellcheck disable=SC2034
RED='\033[0;31m'
# shellcheck disable=SC2034
GREEN='\033[0;32m'
# shellcheck disable=SC2034
YELLOW='\033[1;33m'
# shellcheck disable=SC2034
NC='\033[0m' # No Color

# Logging
LOG_FILE="logs/env_sync_allowlist_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Environment Variable Synchronization with Allowlists"
echo "Timestamp: $(date)"
echo "Log file: $LOG_FILE"

# Security allowlists for environment variables
# shellcheck disable=SC2034  # Arrays defined for future allowlist validation
declare -a FRONTEND_ALLOWLIST=(
    "VITE_API_URL"
    "VITE_AUTH_URL"
    "VITE_DISCORD_INTEGRATION_URL"
    "VITE_DASHBOARD_URL"
    "VITE_FRONTEND_URL"
    "VITE_ENVIRONMENT"
)

# shellcheck disable=SC2034  # Arrays defined for future allowlist validation
declare -a BACKEND_ALLOWLIST=(
    "DATABASE_URL"
    "DISCORD_BOT_TOKEN"
    "DISCORD_CLIENT_ID"
    "DISCORD_CLIENT_SECRET"
    "DISCORD_GUILD_ID"
    "JWT_SECRET_KEY"
    "JWT_ALGORITHM"
    "TOKEN_EXPIRE_SECONDS"
    "API_BASE_URL"
    "AUTH_URL"
    "FRONTEND_URL"
    "CORS_ORIGINS"
    "INIT_DB_ON_STARTUP"
    "APP_ENV"
    "ENVIRONMENT"
    "CI"
    "NODE_ENV"
    "PYTHON_ENV"
)

# shellcheck disable=SC2034  # Arrays defined for future allowlist validation
declare -a CI_SAFE_ALLOWLIST=(
    "CI"
    "NODE_ENV"
    "PYTHON_ENV"
    "DATABASE_URL"
    "VITE_API_URL"
    "VITE_AUTH_URL"
    "VITE_DISCORD_INTEGRATION_URL"
    "VITE_DASHBOARD_URL"
    "ENVIRONMENT"
)

# Function to validate environment variable against allowlist
validate_env_var() {
    local var_name="$1"
    local allowlist_name="$2"
    local -n allowlist_ref=$allowlist_name

    for allowed_var in "${allowlist_ref[@]}"; do
        if [[ "$var_name" == "$allowed_var" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to sync environment variables with allowlist validation
sync_env_with_allowlist() {
    local source_file="$1"
    local target_file="$2"
    local allowlist_name="$3"

    echo "Syncing $source_file -> $target_file (allowlist: $allowlist_name)"

    if [[ ! -f "$source_file" ]]; then
        echo "Source file $source_file not found, skipping sync"
        return 1
    fi

    # Create backup of target file
    if [[ -f "$target_file" ]]; then
        cp "$target_file" "${target_file}.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    # Process source file and apply allowlist
    while IFS='=' read -r key value || [[ -n "$key" ]]; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue

        # Remove leading/trailing whitespace
        key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # Validate against allowlist
        if validate_env_var "$key" "$allowlist_name"; then
            echo "$key=$value" >> "$target_file.tmp"
        else
            echo "SECURITY: Variable $key not in $allowlist_name allowlist, skipping"
        fi
    done < "$source_file"

    # Replace target file atomically
    if [[ -f "$target_file.tmp" ]]; then
        mv "$target_file.tmp" "$target_file"
        echo "Successfully synced $(wc -l < "$target_file") variables to $target_file"
    else
        echo "No valid variables found for $target_file"
    fi
}

# Function to generate CI-safe environment file
generate_ci_safe_env() {
    local ci_env_file="$PROJECT_ROOT/.env.ci"

    echo "Generating CI-safe environment file: $ci_env_file"

    cat > "$ci_env_file" << 'EOF'
# CI-safe environment variables - Auto-generated with security allowlist
# DO NOT add production secrets to this file

# CI Environment
CI=true
NODE_ENV=test
PYTHON_ENV=test
ENVIRONMENT=ci

# Test Database
DATABASE_URL=sqlite:///./test_devonboarder.db

# Test Service URLs (localhost for CI)
VITE_API_URL=http://localhost:8001
VITE_AUTH_URL=http://localhost:8002
VITE_DISCORD_INTEGRATION_URL=http://localhost:8081
VITE_DASHBOARD_URL=http://localhost:8003

# Test Discord Tokens (placeholder values)
DISCORD_BOT_TOKEN=ci_test_discord_bot_token_placeholder
DISCORD_CLIENT_ID=ci_test_client_id_placeholder
DISCORD_CLIENT_SECRET=ci_test_client_secret_placeholder
DISCORD_GUILD_ID=1386935663139749998

# Test JWT Configuration
JWT_SECRET_KEY=ci_test_jwt_secret_key_placeholder
JWT_ALGORITHM=HS256
TOKEN_EXPIRE_SECONDS=1800

# Test CORS Origins
CORS_ORIGINS=http://localhost:3000,http://localhost:8081
EOF

    echo "Generated CI-safe environment file with $(wc -l < "$ci_env_file") variables"
}

# Function to validate no production secrets in CI file
validate_ci_security() {
    local ci_env_file="$PROJECT_ROOT/.env.ci"
    local violations=0

    echo "Validating CI environment file security..."

    # Check for production-like patterns
    if grep -q "prod\|production\|live" "$ci_env_file" 2>/dev/null; then
        echo "SECURITY VIOLATION: Production patterns found in CI environment"
        violations=$((violations + 1))
    fi

    # Check for real tokens (not placeholder)
    if grep -v "placeholder\|test\|ci_" "$ci_env_file" | grep -q "TOKEN\|SECRET\|KEY" 2>/dev/null; then
        echo "SECURITY VIOLATION: Real tokens may be present in CI environment"
        violations=$((violations + 1))
    fi

    if [[ $violations -eq 0 ]]; then
        echo "CI environment file security validation passed"
        return 0
    else
        echo "CI environment file security validation FAILED with $violations violations"
        return 1
    fi
}

# Main synchronization process
main() {
    echo "Starting environment variable synchronization with allowlists..."

    cd "$PROJECT_ROOT"

    # Generate CI-safe environment
    generate_ci_safe_env

    # Validate CI security
    if ! validate_ci_security; then
        echo "CI security validation failed, aborting"
        exit 1
    fi

    # If .env exists, sync to development files with allowlists
    if [[ -f ".env" ]]; then
        echo "Source .env file found, syncing with allowlist validation..."

        # Sync to .env.dev with backend allowlist
        sync_env_with_allowlist ".env" ".env.dev" "BACKEND_ALLOWLIST"

        # Create frontend-specific .env file
        echo "Creating frontend-specific environment file..."
        sync_env_with_allowlist ".env" "frontend/.env.local" "FRONTEND_ALLOWLIST"

        echo "Environment synchronization completed successfully"
    else
        echo "No source .env file found, using CI-safe defaults only"
    fi

    # Summary
    echo ""
    echo "Environment Synchronization Summary:"
    echo "- CI environment: .env.ci ($(wc -l < ".env.ci" 2>/dev/null || echo 0) variables)"
    echo "- Development: .env.dev ($(wc -l < ".env.dev" 2>/dev/null || echo 0) variables)"
    echo "- Frontend: frontend/.env.local ($(wc -l < "frontend/.env.local" 2>/dev/null || echo 0) variables)"
    echo "- Security validation: PASSED"
    echo "- Log file: $LOG_FILE"
}

# Execute main function
main "$@"
