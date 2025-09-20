#!/bin/bash
# =============================================================================
# File: scripts/sync_tokens.sh
# Purpose: DevOnboarder Token Synchronization System
# Description: Synchronizes tokens across environment-specific files
# Author: DevOnboarder Team
# Created: 2025-09-04
# DevOnboarder Standards: Token management v2.0, security boundaries
# Virtual Environment: Not required
# =============================================================================

set -euo pipefail

# Configuration
SOURCE_TOKENS=".tokens"
TOKENS_FILES=(".tokens.dev" ".tokens.ci" ".tokens.prod")

# Security configuration - tokens that should NEVER be synchronized to CI
CI_EXCLUDED_TOKENS=(
    "AAR_TOKEN"
    "CI_ISSUE_AUTOMATION_TOKEN"
    "CI_BOT_TOKEN"
    "DISCORD_BOT_TOKEN"
    "DISCORD_CLIENT_SECRET"
    "BOT_JWT"
    "TUNNEL_TOKEN"
    "CF_DNS_API_TOKEN"
    "DEV_ORCHESTRATION_BOT_KEY"
    "PROD_ORCHESTRATION_BOT_KEY"
    "STAGING_ORCHESTRATION_BOT_KEY"
)

# Function to check if token should be excluded for CI
is_token_excluded_for_ci() {
    local token_name=$1

    for excluded_token in "${CI_EXCLUDED_TOKENS[@]}"; do
        if [ "$token_name" = "$excluded_token" ]; then
            return 0  # Excluded
        fi
    done

    return 1  # Not excluded
}

# Function to get token value from source file
get_token_value() {
    local token_name=$1
    local source_file=$2

    if [ ! -f "$source_file" ]; then
        return 1
    fi

    grep "^${token_name}=" "$source_file" 2>/dev/null | cut -d'=' -f2- || return 1
}

# Function to update token in target file
update_token_in_file() {
    local token_name=$1
    local token_value=$2
    local target_file=$3

    # Create file if it doesn't exist
    if [ ! -f "$target_file" ]; then
        touch "$target_file"
    fi

    # Check if token already exists
    if grep -q "^${token_name}=" "$target_file" 2>/dev/null; then
        # Update existing token
        if command -v sed >/dev/null 2>&1; then
            sed -i.bak "s|^${token_name}=.*|${token_name}=${token_value}|" "$target_file"
            rm -f "${target_file}.bak" 2>/dev/null || true
        else
            # Fallback for systems without sed
            grep -v "^${token_name}=" "$target_file" > "${target_file}.tmp" || true
            echo "${token_name}=${token_value}" >> "${target_file}.tmp"
            mv "${target_file}.tmp" "$target_file"
        fi
    else
        # Add new token
        echo "${token_name}=${token_value}" >> "$target_file"
    fi
}

# Function to synchronize tokens to a target file
sync_to_file() {
    local target_file=$1
    local is_ci_file=$2

    printf "Synchronizing tokens to %s...\n" "$target_file"

    if [ ! -f "$SOURCE_TOKENS" ]; then
        printf "Warning: Source tokens file not found: %s\n" "$SOURCE_TOKENS"
        return 1
    fi

    local synced_count=0
    local excluded_count=0

    # Read tokens from source file
    while IFS= read -r line; do
        # Skip empty lines and comments
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        # Parse token lines
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            local token_name="${BASH_REMATCH[1]}"
            local token_value="${BASH_REMATCH[2]}"

            # Check if token should be excluded for CI
            if [ "$is_ci_file" = "true" ] && is_token_excluded_for_ci "$token_name"; then
                # Use test placeholder for CI
                local ci_placeholder="ci_test_${token_name,,}_placeholder"
                update_token_in_file "$token_name" "$ci_placeholder" "$target_file"
                ((excluded_count++))
                printf "  Protected: %s (using CI placeholder)\n" "$token_name"
            else
                # Use actual value
                update_token_in_file "$token_name" "$token_value" "$target_file"
                ((synced_count++))
                printf "  Synced: %s\n" "$token_name"
            fi
        fi
    done < "$SOURCE_TOKENS"

    printf "Synchronized %d tokens, %d CI placeholders to %s\n" "$synced_count" "$excluded_count" "$target_file"
}

# Function to validate synchronization
validate_sync() {
    printf "Validating token synchronization...\n"

    if [ ! -f "$SOURCE_TOKENS" ]; then
        printf "Error: Source tokens file not found: %s\n" "$SOURCE_TOKENS"
        return 1
    fi

    local validation_errors=0

    for target_file in "${TOKENS_FILES[@]}"; do
        if [ ! -f "$target_file" ]; then
            printf "Warning: Target file not found: %s\n" "$target_file"
            continue
        fi

        printf "Validating %s...\n" "$target_file"

        local is_ci_file="false"
        if [[ "$target_file" == *.ci ]]; then
            is_ci_file="true"
        fi

        # Check each token from source
        while IFS= read -r line; do
            if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
                continue
            fi

            if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
                local token_name="${BASH_REMATCH[1]}"
                local expected_value="${BASH_REMATCH[2]}"

                # Get actual value from target file
                local actual_value
                actual_value=$(get_token_value "$token_name" "$target_file" || echo "")

                if [ "$is_ci_file" = "true" ] && is_token_excluded_for_ci "$token_name"; then
                    # Should be CI placeholder
                    local ci_placeholder="ci_test_${token_name,,}_placeholder"
                    if [ "$actual_value" != "$ci_placeholder" ]; then
                        printf "  Error: %s: Expected CI placeholder, got: %s\n" "$token_name" "$actual_value"
                        ((validation_errors++))
                    else
                        printf "  Protected: %s: CI placeholder correct\n" "$token_name"
                    fi
                else
                    # Should match source value
                    if [ "$actual_value" != "$expected_value" ]; then
                        printf "  Error: %s: Mismatch detected\n" "$token_name"
                        ((validation_errors++))
                    else
                        printf "  Success: %s: Synchronized correctly\n" "$token_name"
                    fi
                fi
            fi
        done < "$SOURCE_TOKENS"
    done

    if [ "$validation_errors" -eq 0 ]; then
        printf "All token synchronization validated successfully\n"
        return 0
    else
        printf "Found %d synchronization errors\n" "$validation_errors"
        return 1
    fi
}

# Function to create token files with headers
create_token_file_with_header() {
    local target_file=$1
    local environment=$2

    cat > "$target_file" << EOF
# =============================================================================
# DevOnboarder Token Management v2.0
# File: $target_file ($environment Environment)
# Security: $([ "$environment" = "CI Test" ] && echo "COMMITTED - Test values only, no production secrets" || echo "GITIGNORED - Contains production tokens")
# Synchronization: Managed by scripts/sync_tokens.sh
# =============================================================================

EOF
}

# Function to show usage
show_usage() {
    cat << EOF
DevOnboarder Token Synchronization System v2.0

Usage: $0 [COMMAND] [OPTIONS]

Commands:
  --sync-all          Synchronize all token files from source
  --sync <file>       Synchronize specific token file
  --validate-only     Validate synchronization without changes
  --create-templates  Create token file templates
  --help              Show this help message

Examples:
  $0 --sync-all                    # Sync all token files
  $0 --sync .tokens.dev            # Sync only development tokens
  $0 --validate-only               # Check synchronization status
  $0 --create-templates            # Create initial token file structure

Security:
  - Production tokens NEVER synchronized to CI files
  - CI files use test placeholders for security
  - All synchronization respects Enhanced Potato Policy

EOF
}

# Main execution
main() {
    case "${1:-}" in
        "--sync-all")
            printf "Starting complete token synchronization...\n"
            for target_file in "${TOKENS_FILES[@]}"; do
                local is_ci_file="false"
                if [[ "$target_file" == *.ci ]]; then
                    is_ci_file="true"
                fi
                sync_to_file "$target_file" "$is_ci_file"
            done
            printf "Token synchronization completed\n"
            ;;

        "--sync")
            if [ -z "${2:-}" ]; then
                printf "Error: Target file required for --sync\n"
                printf "Usage: %s --sync <target_file>\n" "$0"
                exit 1
            fi
            local target_file="$2"
            local is_ci_file="false"
            if [[ "$target_file" == *.ci ]]; then
                is_ci_file="true"
            fi
            sync_to_file "$target_file" "$is_ci_file"
            ;;

        "--validate-only")
            validate_sync
            ;;

        "--create-templates")
            printf "Creating token file templates...\n"

            # Create .tokens.dev template
            if [ ! -f ".tokens.dev" ]; then
                create_token_file_with_header ".tokens.dev" "Development"
                printf "Created .tokens.dev template\n"
            fi

            # Create .tokens.ci template with placeholders
            if [ ! -f ".tokens.ci" ]; then
                create_token_file_with_header ".tokens.ci" "CI Test"
                printf "Created .tokens.ci template\n"
            fi

            # Create .tokens.prod template
            if [ ! -f ".tokens.prod" ]; then
                create_token_file_with_header ".tokens.prod" "Production"
                printf "Created .tokens.prod template\n"
            fi

            printf "Edit .tokens file and run --sync-all to populate templates\n"
            ;;

        "--help"|"-h"|"")
            show_usage
            ;;

        *)
            printf "Unknown command: %s\n" "$1"
            printf "Run '%s --help' for usage information\n" "$0"
            exit 1
            ;;
    esac
}

# Ensure we're in the project root
if [ ! -f "pyproject.toml" ] || [ ! -f "Makefile" ]; then
    printf "Error: Must run from DevOnboarder project root\n"
    printf "Current directory: %s\n" "$(pwd)"
    exit 1
fi

# Execute main function
main "$@"
