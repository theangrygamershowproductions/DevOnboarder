#!/usr/bin/env bash
# =============================================================================
# Enhanced Environment Sync with Allowlist Integration
# =============================================================================

set -euo pipefail

# Configuration from smart_env_sync.sh (avoiding problematic exec redirect)
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
    "VITE_HOST"
    "HOST"
)

# Configuration
SOURCE_ENV=".env"
DRY_RUN=false

# Helper functions from smart_env_sync.sh
get_var_value() {
    local file=$1
    local var_name=$2

    if [ -f "$file" ]; then
        grep "^${var_name}=" "$file" 2>/dev/null | cut -d'=' -f2- | head -1
    fi
}

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

# Helper functions for environment-specific and CI exclusions
is_environment_specific() {
    local var_name=$1
    for env_var in "${ENVIRONMENT_SPECIFIC_VARS[@]}"; do
        if [ "$var_name" = "$env_var" ]; then
            return 0
        fi
    done
    return 1
}

is_ci_excluded() {
    local var_name=$1
    for ci_var in "${CI_EXCLUSIONS[@]}"; do
        if [ "$var_name" = "$ci_var" ]; then
            return 0
        fi
    done
    return 1
}

# Function to load environment allowlist for a service
load_service_allowlist() {
    local service_name=$1
    local allowlist_file="envmaps/${service_name}.allowlist"
    local allowlist_vars=()

    if [ -f "$allowlist_file" ]; then
        echo "Loading allowlist for service: $service_name"

        # Read allowlist file, ignoring comments and empty lines
        while IFS= read -r line; do
            # Skip comments and empty lines
            if [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ -n "$line" ]]; then
                # Remove any trailing comments and whitespace
                var_name=$(echo "$line" | sed 's/#.*//' | xargs)
                if [[ -n "$var_name" ]]; then
                    allowlist_vars+=("$var_name")
                fi
            fi
        done < "$allowlist_file"

        echo "  Loaded ${#allowlist_vars[@]} variables from $allowlist_file"
    else
        echo "  WARNING: Allowlist file not found: $allowlist_file"
        echo "  Using legacy variable synchronization"
    fi

    # Export array as global variable
    eval "${service_name}_ALLOWLIST=(\"\${allowlist_vars[@]}\")"
}

# Function to check if variable is allowed for a service
is_variable_allowed_for_service() {
    local var_name=$1
    local service_name=$2
    local allowlist_var="${service_name}_ALLOWLIST[@]"
    local allowed_vars=("${!allowlist_var}")

    # If no allowlist is loaded, use legacy behavior
    if [ ${#allowed_vars[@]} -eq 0 ]; then
        return 0  # Allow by default if no allowlist
    fi

    # Check if variable is in allowlist
    for allowed_var in "${allowed_vars[@]}"; do
        if [ "$var_name" = "$allowed_var" ]; then
            return 0  # Variable is allowed
        fi
    done

    return 1  # Variable not in allowlist
}

# Function to sync variables for a specific service using allowlist
sync_service_variables() {
    local service_name=$1
    local target_env_file=$2
    local changes_made=0
    local sync_errors=0

    echo "=== Syncing variables for service: $service_name ==="

    # Load allowlist for this service
    load_service_allowlist "$service_name"

    # Get allowlist array
    local allowlist_var="${service_name}_ALLOWLIST[@]"
    local allowed_vars=("${!allowlist_var}")

    if [ ${#allowed_vars[@]} -eq 0 ]; then
        echo "  WARNING: No allowlist found for $service_name, skipping"
        return 1
    fi

    # Process each variable in the allowlist
    for var_name in "${allowed_vars[@]}"; do
        echo "  Processing: $var_name"

        # Get source value from main .env
        local source_value
        source_value=$(get_var_value "$SOURCE_ENV" "$var_name")

        if [ -z "$source_value" ]; then
            echo "    WARNING: Variable $var_name not found in source file"
            continue
        fi

        # Validate URL format if applicable
        if [[ $var_name =~ URL$ ]] || [[ $var_name =~ URI$ ]]; then
            if ! validate_single_domain_format "$var_name" "$source_value"; then
                sync_errors=$((sync_errors + 1))
                continue
            fi
        fi

        # Check if this is an environment-specific variable that shouldn't be synced
        if is_environment_specific "$var_name"; then
            echo "    SKIPPED: Environment-specific variable"
            continue
        fi

        # Check if variable should be excluded for CI
        if [[ "$target_env_file" = ".env.ci" ]] && is_ci_excluded "$var_name"; then
            echo "    SKIPPED: CI-excluded variable"
            continue
        fi

        # Get current value in target file
        local target_value
        target_value=$(get_var_value "$target_env_file" "$var_name")

        if [ "$source_value" != "$target_value" ]; then
            echo "    OLD ($target_env_file): $target_value"
            echo "    NEW ($target_env_file): $source_value"

            if update_var_in_file "$target_env_file" "$var_name" "$source_value"; then
                changes_made=$((changes_made + 1))
            fi
        else
            echo "    OK: Already synchronized"
        fi
    done

    echo "  Service sync complete: $changes_made changes, $sync_errors errors"
    return $((sync_errors))
}

# Function to validate service allowlists
validate_service_allowlists() {
    local validation_errors=0

    echo "=== Validating Service Allowlists ==="

    # Check if envmaps directory exists
    if [ ! -d "envmaps" ]; then
        echo "ERROR: envmaps directory not found"
        echo "  Create allowlist files in envmaps/ directory"
        return 1
    fi

    # Validate each allowlist file
    for allowlist_file in envmaps/*.allowlist; do
        if [ -f "$allowlist_file" ]; then
            local service_name
            service_name=$(basename "$allowlist_file" .allowlist)
            echo "Validating: $service_name"

            # Count variables in allowlist
            local var_count
            var_count=$(grep -cv '^#\|^[[:space:]]*$' "$allowlist_file")
            echo "  Variables: $var_count"

            # Check for duplicate variables
            local duplicates
            duplicates=$(grep -v '^#' "$allowlist_file" | grep -v '^[[:space:]]*$' | sort | uniq -d)
            if [ -n "$duplicates" ]; then
                echo "  WARNING: Duplicate variables found:"
                printf '%s\n' "$duplicates" | sed 's/^/    /'
                validation_errors=$((validation_errors + 1))
            fi

            # Check for variables that exist in source .env
            local missing_count=0
            while IFS= read -r line; do
                if [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ -n "$line" ]]; then
                    var_name=$(echo "$line" | sed 's/#.*//' | xargs)
                    if [[ -n "$var_name" ]]; then
                        if ! get_var_value "$SOURCE_ENV" "$var_name" >/dev/null 2>&1; then
                            if [ "$missing_count" -eq 0 ]; then
                                echo "  INFO: Variables not in source .env:"
                            fi
                            echo "    $var_name"
                            missing_count=$((missing_count + 1))
                        fi
                    fi
                fi
            done < "$allowlist_file"

            if [ "$missing_count" -gt 0 ]; then
                echo "  Total missing from source: $missing_count"
            fi
        fi
    done

    return $((validation_errors))
}

# Enhanced sync function with allowlist support
sync_with_allowlists() {
    local total_changes=0
    local total_errors=0

    echo "=== Enhanced Environment Sync with Allowlists ==="

    # Validate allowlists first
    if ! validate_service_allowlists; then
        echo "ERROR: Allowlist validation failed"
        return 1
    fi

    # Define service to environment file mappings
    declare -A service_env_map=(
        ["frontend"]=".env.dev"
        ["bot"]=".env.dev"
        ["auth"]=".env.dev"
        ["backend"]=".env.dev"
        ["integration"]=".env.dev"
        ["orchestrator"]=".env.dev"
    )

    # Sync variables for each service
    for service in "${!service_env_map[@]}"; do
        local env_file="${service_env_map[$service]}"

        if [ -f "$env_file" ]; then
            sync_service_variables "$service" "$env_file"
            local sync_result=$?
            total_changes=$((total_changes + sync_result))
        else
            echo "WARNING: Environment file not found: $env_file"
        fi
    done

    # Also sync to .env.prod and .env.ci for applicable services
    for service in frontend auth backend integration; do
        for env_file in .env.prod .env.ci; do
            if [ -f "$env_file" ]; then
                sync_service_variables "$service" "$env_file" >/dev/null 2>&1
            fi
        done
    done

    echo ""
    echo "Enhanced sync complete: $total_changes total changes"
    return $((total_errors))
}

usage() {
    echo "Enhanced Environment Sync with Allowlist Integration"
    echo "Usage: $0 [validate|sync|help]"
    echo ""
    echo "Available commands:"
    echo "  validate     - Validate service allowlists"
    echo "  sync         - Sync environment variables with allowlists"
    echo "  help         - Show this help message"
    echo ""
    echo "This script can also be sourced to use functions in other scripts:"
    echo "  source $0"
}

main() {
    if [[ $# -eq 0 || ${1:-} == "-h" || ${1:-} == "--help" ]]; then
        usage
        return 0
    fi
    case "$1" in
        validate) validate_service_allowlists ;;
        sync)     sync_with_allowlists ;;
        help)     usage ;;
        *)        echo "Unknown command: $1"; usage; return 1 ;;
    esac
}

# Only run main when executed directly, not when sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
