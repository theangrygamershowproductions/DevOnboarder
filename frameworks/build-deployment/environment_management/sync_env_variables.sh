#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# =============================================================================
# File: scripts/sync_env_variables.sh
# Purpose: Synchronize environment variables from .env to all environment files
# Usage: bash scripts/sync_env_variables.sh [--dry-run] [--verbose]
# =============================================================================

# Ensure we're in the project root
cd "$(dirname "$0")/.." || exit

# Initialize logging
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Configuration
SOURCE_ENV=".env"
TARGET_ENV_FILES=(
    ".env.dev"
    ".env.prod"
    ".env.ci"
)

# Command line options
DRY_RUN=false
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [--dry-run] [--verbose]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would be changed without making changes"
            echo "  --verbose    Show detailed output"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "DevOnboarder Environment Variable Synchronization"
echo "Source of truth: $SOURCE_ENV"
echo "Log file: $LOG_FILE"
echo "Dry run mode: $DRY_RUN"
echo ""

# Validate source file exists
if [ ! -f "$SOURCE_ENV" ]; then
    error "Source environment file $SOURCE_ENV not found"
    exit 1
fi

# Function to extract environment variables from source
extract_env_variables() {
    local file=$1
    # Extract non-comment, non-empty lines that contain = and start with valid variable names
    grep -E '^[A-Z_][A-Z0-9_]*=' "$file" | sort
}

# Function to update target environment file
update_target_env() {
    local target_file=$1
    local changes_made=0

    echo "Processing: $target_file"

    if [ ! -f "$target_file" ]; then
        echo "  WARNING: Target file $target_file not found, skipping"
        return 0
    fi

    # Create backup
    if [ "$DRY_RUN" = false ]; then
        cp "$target_file" "${target_file}.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    # Create temporary file for updated content
    local temp_file
    temp_file=$(mktemp)

    # Read source variables into associative array
    declare -A source_vars
    while IFS='=' read -r key value; do
        if [ -n "$key" ] && [ -n "$value" ]; then
            source_vars["$key"]="$value"
        fi
    done < <(extract_env_variables "$SOURCE_ENV")

    # Process target file line by line
    while IFS= read -r line; do
        # Check if line is a variable assignment
        if [[ $line =~ ^[A-Z_][A-Z0-9_]*= ]]; then
            # Extract variable name
            var_name=$(echo "$line" | cut -d'=' -f1)

            # Check if this variable exists in source
            if [ -n "${source_vars[$var_name]:-}" ]; then
                # Use source value
                new_line="${var_name}=${source_vars[$var_name]}"
                if [ "$line" != "$new_line" ]; then
                    if [ "$VERBOSE" = true ]; then
                        echo "  UPDATING: $var_name"
                        echo "    OLD: $line"
                        echo "    NEW: $new_line"
                    fi
                    changes_made=$((changes_made + 1))
                    echo "$new_line" >> "$temp_file"
                else
                    echo "$line" >> "$temp_file"
                fi
            else
                # Keep existing line (variable not in source)
                echo "$line" >> "$temp_file"
            fi
        else
            # Keep non-variable lines (comments, empty lines)
            echo "$line" >> "$temp_file"
        fi
    done < "$target_file"

    # Add any new variables from source that don't exist in target
    for var_name in "${!source_vars[@]}"; do
        if ! grep -q "^$var_name=" "$target_file"; then
            new_line="${var_name}=${source_vars[$var_name]}"
            echo "  ADDING: $var_name=${source_vars[$var_name]}"
            echo "$new_line" >> "$temp_file"
            changes_made=$((changes_made + 1))
        fi
    done

    # Apply changes if not dry run
    if [ "$DRY_RUN" = false ]; then
        mv "$temp_file" "$target_file"
        echo "  UPDATED: $changes_made changes applied to $target_file"
    else
        echo "  DRY RUN: $changes_made changes would be applied to $target_file"
        rm "$temp_file"
    fi

    return $changes_made
}

# Function to validate synchronized files
validate_synchronization() {
    local validation_errors=0

    echo ""
    echo "=== Validation: Checking Synchronization ==="

    # Critical variables that must be synchronized
    local critical_vars=(
        "VITE_AUTH_URL"
        "VITE_API_URL"
        "API_BASE_URL"
        "AUTH_URL"
        "DISCORD_REDIRECT_URI"
        "CORS_ALLOW_ORIGINS"
        "DEV_TUNNEL_AUTH_URL"
        "DEV_TUNNEL_API_URL"
        "DEV_TUNNEL_DISCORD_URL"
        "DEV_TUNNEL_DASHBOARD_URL"
    )

    for var_name in "${critical_vars[@]}"; do
        local source_value
        source_value=$(grep "^$var_name=" "$SOURCE_ENV" 2>/dev/null | cut -d'=' -f2- || echo "")

        if [ -z "$source_value" ]; then
            echo "  WARNING: Critical variable $var_name not found in source"
            continue
        fi

        for target_file in "${TARGET_ENV_FILES[@]}"; do
            if [ -f "$target_file" ]; then
                local target_value
                target_value=$(grep "^$var_name=" "$target_file" 2>/dev/null | cut -d'=' -f2- || echo "")

                if [ "$source_value" != "$target_value" ]; then
                    echo "  ERROR: Variable $var_name mismatch in $target_file"
                    echo "    Source: $source_value"
                    echo "    Target: $target_value"
                    validation_errors=$((validation_errors + 1))
                fi
            fi
        done
    done

    if [ $validation_errors -eq 0 ]; then
        echo "  SUCCESS: All critical variables synchronized"
    else
        echo "  FAILED: $validation_errors synchronization errors found"
    fi

    return $validation_errors
}

# Main execution
main() {
    local total_changes=0

    echo "Starting environment variable synchronization"
    echo "Source file: $SOURCE_ENV ($(wc -l < "$SOURCE_ENV") lines)"

    # Extract source variables for summary
    local source_var_count
    source_var_count=$(extract_env_variables "$SOURCE_ENV" | wc -l)
    echo "Source variables: $source_var_count environment variables"
    echo ""

    # Process each target file
    for target_file in "${TARGET_ENV_FILES[@]}"; do
        if update_target_env "$target_file"; then
            total_changes=$((total_changes + $?))
        fi
        echo ""
    done

    # Validation
    validate_synchronization
    local validation_result=$?

    # Summary
    echo ""
    echo "=== Synchronization Summary ==="
    echo "Total changes: $total_changes"
    echo "Validation result: $validation_result errors"
    echo "Mode: $([ "$DRY_RUN" = true ] && echo "DRY RUN" || echo "CHANGES APPLIED")"
    echo "Log file: $LOG_FILE"

    if [ $validation_result -gt 0 ]; then
        echo ""
        echo "RECOMMENDATION: Run with --dry-run first to review changes"
        echo "RECOMMENDATION: Backup important files before synchronization"
        return 1
    fi

    return 0
}

# Execute main function
main "$@"
exit_code=$?

echo ""
echo "Environment synchronization completed with exit code: $exit_code"
exit $exit_code
