#!/bin/bash
# =============================================================================
# File: frameworks/build_deployment/environment_management/smart_env_sync.sh - Variables that should remain environment-specific (never synchronized)
ENVIRONMENT_SPECIFIC_VARS=(
    "JWT_SECRET_KEY"
    "AUTH_SECRET_KEY"
    "DISCORD_BOT_TOKEN"
    "DISCORD_CLIENT_SECRET"
    "BOT_JWT"
    "APP_ENV"
    "NODE_ENV"
    "PYTHON_ENV"
    "CI"
    "DEBUG"
    "DATABASE_URL"
    "REDIS_URL"
    "GH_TOKEN"
    "NPM_TOKEN"
    # SECURITY: Never sync real tunnel credentials to CI
    "TUNNEL_TOKEN"
    "TUNNEL_ID"
    "CF_DNS_API_TOKEN"
)

# CI-specific exclusions (localhost URLs for testing)
CI_EXCLUSIONS=(
    "DEV_TUNNEL_AUTH_URL"
    "DEV_TUNNEL_API_URL"
    "DEV_TUNNEL_APP_URL"
    "DEV_TUNNEL_DISCORD_URL"
    "DEV_TUNNEL_DASHBOARD_URL"
    "DEV_TUNNEL_FRONTEND_URL"
    "VITE_ALLOWED_HOST_DEV"
    "VITE_ALLOWED_HOST_PROD"
)

# Configuration
SOURCE_ENV=".env"
CONFIG_FILE="config/env-sync-config.yaml"
TARGET_ENV_FILES=(".env.dev" ".env.prod" ".env.ci")

# Initialize logging
mkdir -p logs
LOG_FILE="logs/smart_env_sync_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Command line options
SYNC_ALL=false
VALIDATE_ONLY=false
DRY_RUN=false
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --sync-all)
            # shellcheck disable=SC2034 # Variable used in conditional logic flow
            SYNC_ALL=true
            shift
            ;;
        --validate-only)
            VALIDATE_ONLY=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --sync-all         Synchronize all configured variables"
            echo "  --validate-only    Only validate synchronization, don't change files"
            echo "  --dry-run          Show what would be changed without making changes"
            echo "  --verbose          Show detailed output"
            echo "  --help             Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  ENV_SYNC_AUTO=true    Enable automatic synchronization"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "DevOnboarder Smart Environment Variable Synchronization"
echo "Source of truth: $SOURCE_ENV"
echo "Configuration: $CONFIG_FILE"
echo "Log file: $LOG_FILE"
echo ""

# Variables that should be synchronized (from our current analysis)
SYNCHRONIZED_VARS=(
    # Frontend configuration (safe to sync)
    "VITE_AUTH_URL"
    "VITE_API_URL"
    "VITE_FEEDBACK_URL"
    "VITE_DISCORD_INTEGRATION_URL"
    "VITE_DASHBOARD_URL"

    # Backend service URLs (safe to sync)
    "API_BASE_URL"
    "AUTH_URL"
    "DISCORD_REDIRECT_URI"

    # CORS configuration (safe to sync)
    "CORS_ALLOW_ORIGINS"

    # Discord configuration (safe to sync)
    "DISCORD_CLIENT_ID"
    "DISCORD_GUILD_IDS"

    # Tunnel URLs (excluded from CI via CI_EXCLUSIONS)
    "DEV_TUNNEL_AUTH_URL"
    "DEV_TUNNEL_API_URL"
    "DEV_TUNNEL_APP_URL"
    "DEV_TUNNEL_DISCORD_URL"
    "DEV_TUNNEL_DASHBOARD_URL"
    "DEV_TUNNEL_FRONTEND_URL"

    # Vite host configuration (excluded from CI via CI_EXCLUSIONS)
    "VITE_ALLOWED_HOST_DEV"
    "VITE_ALLOWED_HOST_PROD"
)

# Function to check if variable should be excluded for specific file
is_variable_excluded() {
    local var_name=$1
    local target_file=$2

    # Check if variable is environment-specific (never sync)
    for excluded_var in "${ENVIRONMENT_SPECIFIC_VARS[@]}"; do
        if [ "$var_name" = "$excluded_var" ]; then
            return 0  # Excluded
        fi
    done

    # Special handling for .env.ci (use localhost for testing)
    if [ "$target_file" = ".env.ci" ]; then
        for ci_excluded_var in "${CI_EXCLUSIONS[@]}"; do
            if [ "$var_name" = "$ci_excluded_var" ]; then
                return 0  # Excluded for CI
            fi
        done
    fi

    return 1  # Not excluded
}

# Function to get variable value from file
get_var_value() {
    local file=$1
    local var_name=$2

    if [ -f "$file" ]; then
        grep "^${var_name}=" "$file" 2>/dev/null | cut -d'=' -f2- | head -1
    fi
}

# Function to update variable in target file
update_var_in_file() {
    local target_file=$1
    local var_name=$2
    local var_value=$3

    if [ ! -f "$target_file" ]; then
        echo "  WARNING: Target file $target_file not found"
        return 1
    fi

    # Check if variable exists in target
    if grep -q "^${var_name}=" "$target_file"; then
        # Update existing variable
        if [ "$DRY_RUN" = false ]; then
            # Use sed to replace the line
            sed -i.bak "s|^${var_name}=.*|${var_name}=${var_value}|" "$target_file"
        fi
        echo "    UPDATED: ${var_name} in $target_file"
    else
        # Add new variable
        if [ "$DRY_RUN" = false ]; then
            echo "${var_name}=${var_value}" >> "$target_file"
        fi
        echo "    ADDED: ${var_name} to $target_file"
    fi

    return 0
}

# Function to validate single domain format
validate_single_domain_format() {
    local var_name=$1
    local var_value=$2

    # Check if URL contains the old multi-subdomain format
    if echo "$var_value" | grep -q "\.dev\.theangrygamershow\.com"; then
        echo "  ERROR: $var_name uses old multi-subdomain format: $var_value"
        local suggested_value="${var_value//.dev.theangrygamershow.com/.theangrygamershow.com}"
        echo "    SHOULD BE: $suggested_value"
        return 1
    fi

    return 0
}

# Function to synchronize variables
sync_variables() {
    local changes_made=0
    local sync_errors=0

    echo "=== Synchronizing Variables ==="

    for var_name in "${SYNCHRONIZED_VARS[@]}"; do
        echo "Processing: $var_name"

        # Get source value
        local source_value
        source_value=$(get_var_value "$SOURCE_ENV" "$var_name")

        if [ -z "$source_value" ]; then
            echo "  WARNING: Variable $var_name not found in source file"
            continue
        fi

        # Validate single domain format for URL variables
        if [[ $var_name =~ URL$ ]] || [[ $var_name =~ URI$ ]]; then
            if ! validate_single_domain_format "$var_name" "$source_value"; then
                sync_errors=$((sync_errors + 1))
                continue
            fi
        fi

        # Synchronize to each target file
        for target_file in "${TARGET_ENV_FILES[@]}"; do
            if [ -f "$target_file" ]; then
                # Check if variable should be excluded for this file
                if is_variable_excluded "$var_name" "$target_file"; then
                    if [ "$VERBOSE" = true ]; then
                        echo "    SKIPPED ($target_file): Variable excluded for this environment"
                    fi
                    continue
                fi

                local target_value
                target_value=$(get_var_value "$target_file" "$var_name")

                if [ "$source_value" != "$target_value" ]; then
                    if [ "$VERBOSE" = true ]; then
                        echo "    OLD ($target_file): $target_value"
                        echo "    NEW ($target_file): $source_value"
                    fi

                    if update_var_in_file "$target_file" "$var_name" "$source_value"; then
                        changes_made=$((changes_made + 1))
                    fi
                fi
            fi
        done
    done

    echo ""
    echo "Synchronization complete: $changes_made changes, $sync_errors errors"
    return $sync_errors
}

# Function to validate all environments
validate_environments() {
    local validation_errors=0

    echo "=== Validation: Environment Consistency ==="

    # Check critical variables
    local critical_vars=(
        "VITE_AUTH_URL"
        "VITE_API_URL"
        "CORS_ALLOW_ORIGINS"
        "DEV_TUNNEL_AUTH_URL"
        "API_BASE_URL"
    )

    for var_name in "${critical_vars[@]}"; do
        local source_value
        source_value=$(get_var_value "$SOURCE_ENV" "$var_name")

        if [ -z "$source_value" ]; then
            echo "  ERROR: Critical variable $var_name missing from source"
            validation_errors=$((validation_errors + 1))
            continue
        fi

        # Validate single domain format
        if ! validate_single_domain_format "$var_name" "$source_value"; then
            validation_errors=$((validation_errors + 1))
            continue
        fi

        echo "  VALIDATING: $var_name"

        # Check each target file
        for target_file in "${TARGET_ENV_FILES[@]}"; do
            if [ -f "$target_file" ]; then
                local target_value
                target_value=$(get_var_value "$target_file" "$var_name")

                if [ "$source_value" != "$target_value" ]; then
                    echo "    MISMATCH in $target_file:"
                    echo "      Source: $source_value"
                    echo "      Target: $target_value"
                    validation_errors=$((validation_errors + 1))
                fi
            fi
        done
    done

    # Special validation for CORS origins
    local cors_origins
    cors_origins=$(get_var_value "$SOURCE_ENV" "CORS_ALLOW_ORIGINS")
    if [ -n "$cors_origins" ]; then
        echo "  VALIDATING: CORS domain consistency"

        # Check that CORS includes all required domains
        local required_domains=(
            "dev.theangrygamershow.com"
            "auth.theangrygamershow.com"
            "api.theangrygamershow.com"
            "discord.theangrygamershow.com"
            "dashboard.theangrygamershow.com"
        )

        for domain in "${required_domains[@]}"; do
            if ! echo "$cors_origins" | grep -q "$domain"; then
                echo "    ERROR: CORS origins missing required domain: $domain"
                validation_errors=$((validation_errors + 1))
            fi
        done
    fi

    echo ""
    if [ $validation_errors -eq 0 ]; then
        echo "SUCCESS: All environments are synchronized and valid"
    else
        echo "FAILED: $validation_errors validation errors found"
    fi

    return $validation_errors
}

# Function to show environment status
show_env_status() {
    echo "=== Environment Status Summary ==="

    for file in "$SOURCE_ENV" "${TARGET_ENV_FILES[@]}"; do
        if [ -f "$file" ]; then
            local var_count
            var_count=$(grep -c "^[A-Z_][A-Z0-9_]*=" "$file" 2>/dev/null || echo "0")
            echo "  $file: $var_count variables"

            # Show key tunnel variables
            local auth_url
            auth_url=$(get_var_value "$file" "VITE_AUTH_URL")
            if [ -n "$auth_url" ]; then
                echo "    VITE_AUTH_URL: $auth_url"
            fi
        else
            echo "  $file: NOT FOUND"
        fi
    done
    echo ""
}

# Main execution
main() {
    local exit_code=0

    echo "Starting smart environment synchronization"
    echo "Mode: $([ "$DRY_RUN" = true ] && echo "DRY RUN" || echo "LIVE")"
    echo "Operation: $([ "$VALIDATE_ONLY" = true ] && echo "VALIDATE ONLY" || echo "SYNC AND VALIDATE")"
    echo ""

    # Check if source file exists
    if [ ! -f "$SOURCE_ENV" ]; then
        echo "ERROR: Source file $SOURCE_ENV not found"
        exit 1
    fi

    # Show current status
    show_env_status

    # Perform operations
    if [ "$VALIDATE_ONLY" = false ]; then
        echo "Synchronizing variables from $SOURCE_ENV..."
        if ! sync_variables; then
            exit_code=1
        fi
        echo ""
    fi

    # Always validate
    echo "Validating environment consistency..."
    if ! validate_environments; then
        exit_code=1
    fi

    # Final summary
    echo ""
    echo "=== Summary ==="
    echo "Operation: $([ "$DRY_RUN" = true ] && echo "DRY RUN COMPLETED" || echo "CHANGES APPLIED")"
    echo "Result: $([ $exit_code -eq 0 ] && echo "SUCCESS" || echo "ERRORS FOUND")"
    echo "Log file: $LOG_FILE"

    if [ $exit_code -gt 0 ]; then
        echo ""
        echo "RECOMMENDATIONS:"
        echo "1. Fix validation errors before proceeding"
        echo "2. Run with --dry-run to preview changes"
        echo "3. Ensure .env is the authoritative source"
    fi

    return $exit_code
}

# Execute main function
main "$@"
exit $?
