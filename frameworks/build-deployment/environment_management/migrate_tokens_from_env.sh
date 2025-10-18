#!/bin/bash

# =============================================================================
# DevOnboarder Token Migration Script
# =============================================================================
# Purpose: Migrate authentication tokens from .env files to .tokens files
# Usage: bash scripts/migrate_tokens_from_env.sh [--dry-run] [--environment ENV]
# =============================================================================

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="logs/$(basename "$0" .sh)_$(date %Y%m%d_%H%M%S).log"

# Ensure logs directory exists
mkdir -p "$PROJECT_ROOT/logs"

# Logging function
log() {
    local timestamp
    timestamp=$(date '%Y-%m-%d %H:%M:%S')
    printf "[%s] %s\n" "$timestamp" "$*" | tee -a "$LOG_FILE"
}

# Token keys that should be migrated (authentication only)
declare -a TOKEN_KEYS=(
    "AAR_TOKEN"
    "BOT_JWT"
    "CF_DNS_API_TOKEN"
    "CI_BOT_TOKEN"
    "CI_ISSUE_AUTOMATION_TOKEN"
    "DEV_ORCHESTRATION_BOT_KEY"
    "DISCORD_BOT_TOKEN"
    "DISCORD_CLIENT_SECRET"
    "PROD_ORCHESTRATION_BOT_KEY"
    "STAGING_ORCHESTRATION_BOT_KEY"
    "TUNNEL_TOKEN"
)

# Configuration keys that should REMAIN in .env files
declare -a CONFIG_KEYS=(
    "DATABASE_URL"
    "REDIS_URL"
    "APP_ENV"
    "NODE_ENV"
    "PYTHON_ENV"
    "DISCORD_GUILD_ID"
    "DISCORD_CLIENT_ID"
    "API_BASE_URL"
    "AUTH_URL"
    "CORS_ALLOW_ORIGINS"
    "VITE_AUTH_URL"
    "ENVIRONMENT"
    "DEBUG"
    "CI"
)
export CONFIG_KEYS

# Default options
DRY_RUN=false
TARGET_ENV=""
FORCE_OVERWRITE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --environment)
            TARGET_ENV="$2"
            shift 2
            ;;
        --force)
            FORCE_OVERWRITE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run           Show what would be done without making changes"
            echo "  --environment ENV   Target specific environment (dev, prod, ci)"
            echo "  --force            Overwrite existing token files"
            echo "  --help             Show this help message"
            echo ""
            echo "Token Keys to Migrate:"
            printf "  %s\n" "${TOKEN_KEYS[@]}"
            exit 0
            ;;
        *)
            log " Unknown option $1"
            exit 1
            ;;
    esac
done

# Function to extract token from env file
extract_token() {
    local env_file="$1"
    local token_key="$2"

    if [[ -f "$env_file" ]]; then
        grep "^${token_key}=" "$env_file" 2>/dev/null | head -1 | cut -d'=' -f2- || true
    fi
}

# Function to migrate tokens from specific environment
migrate_environment() {
    local env_suffix="$1"
    local env_file="$PROJECT_ROOT/.env${env_suffix}"
    local tokens_file="$PROJECT_ROOT/.tokens${env_suffix}"

    log "Processing environment: ${env_suffix:-"(default)"}"

    if [[ ! -f "$env_file" ]]; then
        log " Environment file not found: $env_file"
        return 0
    fi

    # Check if tokens file already exists
    if [[ -f "$tokens_file" && "$FORCE_OVERWRITE" != "true" ]]; then
        log " Tokens file already exists: $tokens_file"
        log "Use --force to overwrite or manually merge"
        return 0
    fi

    # Extract tokens from env file
    local extracted_tokens=()
    local tokens_found=false

    for token_key in "${TOKEN_KEYS[@]}"; do
        local token_value
        token_value=$(extract_token "$env_file" "$token_key")

        if [[ -n "$token_value" ]]; then
            extracted_tokens=("${token_key}=${token_value}")
            tokens_found=true
            log "Found token: $token_key"
        fi
    done

    if [[ "$tokens_found" == "false" ]]; then
        log "No tokens found in $env_file"
        return 0
    fi

    # Create tokens file
    if [[ "$DRY_RUN" == "true" ]]; then
        log "DRY RUN: Would create $tokens_file with ${#extracted_tokens[@]} tokens"
        for token_line in "${extracted_tokens[@]}"; do
            # Extract token name and mask the value for security
            token_name=$(echo "$token_line" | cut -d'=' -f1)
            token_value=$(echo "$token_line" | cut -d'=' -f2-)
            masked_value="${token_value:0:8}***MASKED***"
            log "  ${token_name}=${masked_value}"
        done
    else
        log "Creating tokens file: $tokens_file"

        # Create tokens file with header
        cat > "$tokens_file" << 'EOF'
# =============================================================================
# DevOnboarder Token Management v2.0
# =============================================================================
# CRITICAL: This file contains authentication tokens and secrets
# Security: MUST be added to .gitignore (except .tokens.ci)
# Management: Use scripts/token_loader.py for validation and loading
# =============================================================================

EOF

        # Add extracted tokens
        for token_line in "${extracted_tokens[@]}"; do
            echo "$token_line" >> "$tokens_file"
        done

        log "Created $tokens_file with ${#extracted_tokens[@]} tokens"

        # Set appropriate permissions
        chmod 600 "$tokens_file"
        log "Set secure permissions (600) on $tokens_file"

        # Add to .gitignore if not .tokens.ci
        if [[ "$env_suffix" != ".ci" ]]; then
            if ! grep -q "^\.tokens${env_suffix}$" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
                echo ".tokens${env_suffix}" >> "$PROJECT_ROOT/.gitignore"
                log "Added .tokens${env_suffix} to .gitignore"
            fi
        fi
    fi

    # Clean up env file (remove token keys)
    if [[ "$DRY_RUN" == "false" ]]; then
        log "Cleaning token keys from $env_file"
        local temp_file="${env_file}.tmp"

        # Create backup
        cp "$env_file" "${env_file}.backup.$(date %Y%m%d_%H%M%S)"
        log "Created backup: ${env_file}.backup.$(date %Y%m%d_%H%M%S)"

        # Remove token keys from env file
        while IFS= read -r line; do
            local should_keep=true

            for token_key in "${TOKEN_KEYS[@]}"; do
                if [[ "$line" =~ ^${token_key}= ]]; then
                    should_keep=false
                    break
                fi
            done

            if [[ "$should_keep" == "true" ]]; then
                echo "$line" >> "$temp_file"
            fi
        done < "$env_file"

        # Replace original file
        mv "$temp_file" "$env_file"
        log "Removed token keys from $env_file"
    fi
}

# Main execution
log "Starting DevOnboarder token migration"
log "Dry run: $DRY_RUN"
log "Target environment: ${TARGET_ENV:-"all"}"
log "Force overwrite: $FORCE_OVERWRITE"

# Migrate specific environment or all
if [[ -n "$TARGET_ENV" ]]; then
    case "$TARGET_ENV" in
        dev)
            migrate_environment ".dev"
            ;;
        prod)
            migrate_environment ".prod"
            ;;
        ci)
            migrate_environment ".ci"
            ;;
        default)
            migrate_environment ""
            ;;
        *)
            log " Unknown environment: $TARGET_ENV"
            log "Valid environments: dev, prod, ci, default"
            exit 1
            ;;
    esac
else
    # Migrate all environments
    migrate_environment ""        # .env  .tokens
    migrate_environment ".dev"    # .env.dev  .tokens.dev
    migrate_environment ".prod"   # .env.prod  .tokens.prod
    migrate_environment ".ci"     # .env.ci  .tokens.ci
fi

# Validation step
log "Validating migration results..."

if [[ "$DRY_RUN" == "false" ]]; then
    # Test token loading
    if command -v python3 > /dev/null; then
        log "Testing token loading system..."
        if python3 "$PROJECT_ROOT/scripts/token_loader.py" info > /dev/null 2>&1; then
            log " Token loading system validated"
        else
            log " Token loading system validation failed"
        fi
    fi
fi

log "Token migration completed successfully"
log "Log file: $LOG_FILE"

if [[ "$DRY_RUN" == "false" ]]; then
    echo ""
    echo "Next steps:"
    echo "1. Review the created .tokens* files"
    echo "2. Test your services with: python scripts/token_loader.py load"
    echo "3. Update processes to use token_loader instead of environment variables"
    echo "4. Commit the cleaned .env files (tokens removed)"
fi
