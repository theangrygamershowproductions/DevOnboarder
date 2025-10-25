#!/bin/bash

# =============================================================================
# DevOnboarder CI/CD Token Migration Script v2.1
# =============================================================================
# Purpose: Move ONLY CI/CD automation tokens from .env files to .tokens files
# Application runtime tokens stay in .env files
# Usage: bash scripts/migrate_cicd_tokens.sh [--dry-run] [--environment ENV]
# =============================================================================

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="logs/cicd_token_migration_$(date %Y%m%d_%H%M%S).log"

# Ensure logs directory exists
mkdir -p "$PROJECT_ROOT/logs"

# Logging function
log() {
    local timestamp
    timestamp=$(date '%Y-%m-%d %H:%M:%S')
    printf "[%s] %s\n" "$timestamp" "$*" | tee -a "$LOG_FILE"
}

# CI/CD tokens that should be moved to .tokens files
declare -a CICD_TOKEN_KEYS=(
    "AAR_TOKEN"
    "CI_BOT_TOKEN"
    "CI_ISSUE_AUTOMATION_TOKEN"
    "DEV_ORCHESTRATION_BOT_KEY"
    "PROD_ORCHESTRATION_BOT_KEY"
    "STAGING_ORCHESTRATION_BOT_KEY"
)

# Application runtime tokens that should REMAIN in .env files
declare -a RUNTIME_TOKEN_KEYS=(
    "DISCORD_BOT_TOKEN"
    "DISCORD_CLIENT_SECRET"
    "BOT_JWT"
    "CF_DNS_API_TOKEN"
    "TUNNEL_TOKEN"
)

# Configuration keys that should REMAIN in .env files (reference list)
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
            echo "DevOnboarder CI/CD Token Migration v2.1"
            echo "Moves ONLY CI/CD automation tokens to .tokens files"
            echo "Application runtime tokens stay in .env files"
            echo ""
            echo "Options:"
            echo "  --dry-run           Show what would be done without making changes"
            echo "  --environment ENV   Target specific environment (dev, prod, ci)"
            echo "  --force            Overwrite existing token files"
            echo "  --help             Show this help message"
            echo ""
            echo "CI/CD Tokens to Migrate (to .tokens files):"
            printf "  %s\n" "${CICD_TOKEN_KEYS[@]}"
            echo ""
            echo "Runtime Tokens to Keep (in .env files):"
            printf "  %s\n" "${RUNTIME_TOKEN_KEYS[@]}"
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

# Function to migrate CI/CD tokens from specific environment
migrate_cicd_tokens() {
    local env_suffix="$1"
    local env_file="$PROJECT_ROOT/.env${env_suffix}"
    local tokens_file="$PROJECT_ROOT/.tokens${env_suffix}"

    log "Processing CI/CD tokens for environment: ${env_suffix:-"(default)"}"

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

    # Extract CI/CD tokens from env file
    local extracted_cicd_tokens=()
    local cicd_tokens_found=false

    for token_key in "${CICD_TOKEN_KEYS[@]}"; do
        local token_value
        token_value=$(extract_token "$env_file" "$token_key")

        if [[ -n "$token_value" ]]; then
            extracted_cicd_tokens=("${token_key}=${token_value}")
            cicd_tokens_found=true
            log "Found CI/CD token: $token_key"
        fi
    done

    if [[ "$cicd_tokens_found" == "false" ]]; then
        log "No CI/CD tokens found in $env_file"
        return 0
    fi

    # Create CI/CD tokens file
    if [[ "$DRY_RUN" == "true" ]]; then
        log "DRY RUN: Would create $tokens_file with ${#extracted_cicd_tokens[@]} CI/CD tokens"
        for token_line in "${extracted_cicd_tokens[@]}"; do
            # Extract token name and mask the value for security
            token_name=$(echo "$token_line" | cut -d'=' -f1)
            token_value=$(echo "$token_line" | cut -d'=' -f2-)
            masked_value="${token_value:0:8}***MASKED***"
            log "  ${token_name}=${masked_value}"
        done
    else
        log "Creating CI/CD tokens file: $tokens_file"

        # Create tokens file with header
        cat > "$tokens_file" << 'EOF'
# =============================================================================
# DevOnboarder Token Management v2.1 - CI/CD Automation Tokens
# =============================================================================
# Purpose: CI/CD automation, GitHub Actions, deployment processes
# Security: MUST be added to .gitignore (except .tokens.ci)
# Management: Use scripts/token_loader.py --type=cicd for loading
#
#  Application runtime tokens (Discord, etc.) stay in .env files
# =============================================================================

EOF

        # Add extracted CI/CD tokens
        for token_line in "${extracted_cicd_tokens[@]}"; do
            echo "$token_line" >> "$tokens_file"
        done

        log "Created $tokens_file with ${#extracted_cicd_tokens[@]} CI/CD tokens"

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

    # Clean up env file (remove ONLY CI/CD token keys)
    if [[ "$DRY_RUN" == "false" ]]; then
        log "Cleaning CI/CD token keys from $env_file (keeping runtime tokens)"
        local temp_file="${env_file}.tmp"

        # Create backup
        cp "$env_file" "${env_file}.backup.$(date %Y%m%d_%H%M%S)"
        log "Created backup: ${env_file}.backup.$(date %Y%m%d_%H%M%S)"

        # Remove only CI/CD token keys from env file
        while IFS= read -r line; do
            local should_keep=true

            # Only remove CI/CD tokens (keep runtime tokens and config)
            for cicd_token_key in "${CICD_TOKEN_KEYS[@]}"; do
                if [[ "$line" =~ ^${cicd_token_key}= ]]; then
                    should_keep=false
                    log "Removing CI/CD token: $cicd_token_key"
                    break
                fi
            done

            if [[ "$should_keep" == "true" ]]; then
                echo "$line" >> "$temp_file"
            fi
        done < "$env_file"

        # Replace original file
        mv "$temp_file" "$env_file"
        log "Removed CI/CD token keys from $env_file (runtime tokens preserved)"
    fi
}

# Function to verify runtime tokens remain in env file
verify_runtime_tokens() {
    local env_suffix="$1"
    local env_file="$PROJECT_ROOT/.env${env_suffix}"

    if [[ ! -f "$env_file" ]]; then
        return 0
    fi

    log "Verifying runtime tokens remain in $env_file"

    local runtime_tokens_remaining=0
    for runtime_token in "${RUNTIME_TOKEN_KEYS[@]}"; do
        if grep -q "^${runtime_token}=" "$env_file" 2>/dev/null; then
            ((runtime_tokens_remaining))
            log " Runtime token preserved: $runtime_token"
        fi
    done

    log "Runtime tokens preserved: $runtime_tokens_remaining"
}

# Main execution
log "Starting DevOnboarder CI/CD token migration v2.1"
log "Scope: CI/CD automation tokens ONLY"
log "Dry run: $DRY_RUN"
log "Target environment: ${TARGET_ENV:-"all"}"
log "Force overwrite: $FORCE_OVERWRITE"

echo ""
log "CI/CD tokens to migrate:"
for token in "${CICD_TOKEN_KEYS[@]}"; do
    log "  - $token"
done

echo ""
log "Runtime tokens to keep in .env:"
for token in "${RUNTIME_TOKEN_KEYS[@]}"; do
    log "  - $token"
done
echo ""

# Migrate specific environment or all
if [[ -n "$TARGET_ENV" ]]; then
    case "$TARGET_ENV" in
        dev)
            migrate_cicd_tokens ".dev"
            verify_runtime_tokens ".dev"
            ;;
        prod)
            migrate_cicd_tokens ".prod"
            verify_runtime_tokens ".prod"
            ;;
        ci)
            migrate_cicd_tokens ".ci"
            verify_runtime_tokens ".ci"
            ;;
        default)
            migrate_cicd_tokens ""
            verify_runtime_tokens ""
            ;;
        *)
            log " Unknown environment: $TARGET_ENV"
            log "Valid environments: dev, prod, ci, default"
            exit 1
            ;;
    esac
else
    # Migrate all environments
    migrate_cicd_tokens ""        # .env  .tokens
    verify_runtime_tokens ""

    migrate_cicd_tokens ".dev"    # .env.dev  .tokens.dev
    verify_runtime_tokens ".dev"

    migrate_cicd_tokens ".prod"   # .env.prod  .tokens.prod
    verify_runtime_tokens ".prod"

    migrate_cicd_tokens ".ci"     # .env.ci  .tokens.ci
    verify_runtime_tokens ".ci"
fi

# Enhanced validation step
log "Validating CI/CD token migration results..."

if [[ "$DRY_RUN" == "false" ]]; then
    # Test CI/CD token loading
    if command -v python3 > /dev/null; then
        log "Testing CI/CD token loading system..."
        if python3 "$PROJECT_ROOT/scripts/token_loader.py" info > /dev/null 2>&1; then
            log " Token loading system validated"
        else
            log " Token loading system validation failed"
        fi
    fi

    # Verify separation
    log "Verifying separation of concerns..."
    for env_file in .env .env.dev .env.prod .env.ci; do
        if [[ -f "$PROJECT_ROOT/$env_file" ]]; then
            cicd_tokens_in_env=0
            for cicd_token in "${CICD_TOKEN_KEYS[@]}"; do
                if grep -q "^${cicd_token}=" "$PROJECT_ROOT/$env_file" 2>/dev/null; then
                    ((cicd_tokens_in_env))
                fi
            done

            if [[ $cicd_tokens_in_env -eq 0 ]]; then
                log "No CI/CD tokens found in $env_file (correct)"
            else
                log " $cicd_tokens_in_env CI/CD tokens still in $env_file"
            fi
        fi
    done
fi

log "CI/CD token migration completed successfully"
log "Log file: $LOG_FILE"

if [[ "$DRY_RUN" == "false" ]]; then
    echo ""
    echo "CI/CD Token Migration v2.1 Complete!"
    echo "===================================="
    echo ""
    echo "CI/CD automation tokens moved to .tokens files"
    echo "Runtime tokens preserved in .env files"
    echo "Clear separation of concerns achieved"
    echo ""
    echo "Next steps:"
    echo "1. Review the created .tokens* files for CI/CD tokens"
    echo "2. Test CI/CD workflows: python3 scripts/token_loader.py load --type=cicd"
    echo "3. Verify services still work: python3 scripts/token_loader.py load --type=runtime"
    echo "4. Update CI/CD processes to use token_loader for automation tokens"
    echo "5. Commit the cleaned .env files (CI/CD tokens removed, runtime preserved)"
fi
