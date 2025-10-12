#!/bin/bash
# maintainer_token_manager.sh - Secure token management for external PR operations
# Version: 1.0.0
# Security Level: Tier 3 - Maintainer Override Zone
# Description: Manages personal access tokens for maintainer external PR operations

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TOKEN_STORE="$HOME/.config/devonboarder/maintainer_tokens"
TOKEN_LOG="$PROJECT_ROOT/logs/token_operations.log"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_token_action() {
    local action="$1"
    local details="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "$timestamp: TOKEN_$action: $details" >> "$TOKEN_LOG"
}

log_error() {
    local message="$1"
    echo -e "${RED}ERROR: $message${NC}" >&2
    log_token_action "ERROR" "$message"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}SUCCESS: $message${NC}"
}

log_info() {
    local message="$1"
    echo -e "${BLUE}INFO: $message${NC}"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}WARNING: $message${NC}"
}

# Secure token storage functions
init_token_store() {
    # Create secure token directory
    mkdir -p "$TOKEN_STORE"
    chmod 700 "$TOKEN_STORE"

    # Create .gitkeep to ensure directory is tracked (but empty)
    touch "$TOKEN_STORE/.gitkeep"
    chmod 600 "$TOKEN_STORE/.gitkeep"
}

store_token_securely() {
    local token_name="$1"
    local token_value="$2"
    local description="$3"

    local token_file="$TOKEN_STORE/${token_name}.token"
    local meta_file="$TOKEN_STORE/${token_name}.meta"

    # Store token encrypted (using gpg if available, otherwise base64)
    if command -v gpg &> /dev/null; then
        echo "$token_value" | gpg --encrypt --recipient "$(whoami)" --output "$token_file"
    else
        echo "$token_value" | base64 > "$token_file"
    fi

    chmod 600 "$token_file"

    # Store metadata
    cat > "$meta_file" << EOF
created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
description: $description
encrypted: $(command -v gpg &> /dev/null && echo "true" || echo "false")
last_used: never
expires: $(date -u -d "+90 days" +"%Y-%m-%dT%H:%M:%SZ")
EOF

    chmod 600 "$meta_file"

    log_token_action "STORED" "Token '$token_name' stored securely"
    log_success "Token '$token_name' stored securely"
}

retrieve_token() {
    local token_name="$1"

    local token_file="$TOKEN_STORE/${token_name}.token"
    local meta_file="$TOKEN_STORE/${token_name}.meta"

    if [[ ! -f "$token_file" ]]; then
        log_error "Token '$token_name' not found"
        return 1
    fi

    # Update last_used timestamp
    if [[ -f "$meta_file" ]]; then
        sed -i "s/last_used:.*/last_used: $(date -u +"%Y-%m-%dT%H:%M:%SZ")/" "$meta_file"
    fi

    # Retrieve token
    if command -v gpg &> /dev/null && grep -q "encrypted: true" "$meta_file" 2>/dev/null; then
        gpg --decrypt "$token_file" 2>/dev/null
    else
        base64 -d "$token_file" 2>/dev/null
    fi

    log_token_action "RETRIEVED" "Token '$token_name' retrieved"
}

delete_token() {
    local token_name="$1"

    local token_file="$TOKEN_STORE/${token_name}.token"
    local meta_file="$TOKEN_STORE/${token_name}.meta"

    if [[ ! -f "$token_file" ]]; then
        log_error "Token '$token_name' not found"
        return 1
    fi

    # Secure delete
    shred -u "$token_file" 2>/dev/null || rm -f "$token_file"
    shred -u "$meta_file" 2>/dev/null || rm -f "$meta_file"

    log_token_action "DELETED" "Token '$token_name' securely deleted"
    log_success "Token '$token_name' securely deleted"
}

list_tokens() {
    echo "Stored maintainer tokens:"
    echo "========================"

    local found_tokens=false

    for meta_file in "$TOKEN_STORE"/*.meta; do
        if [[ -f "$meta_file" ]]; then
            found_tokens=true
            local token_name
            token_name=$(basename "$meta_file" .meta)

            echo "Token: $token_name"
            echo "  $(grep "description:" "$meta_file" | cut -d: -f2- | sed 's/^ *//')"
            echo "  Created: $(grep "created:" "$meta_file" | cut -d: -f2- | sed 's/^ *//')"
            echo "  Expires: $(grep "expires:" "$meta_file" | cut -d: -f2- | sed 's/^ *//')"
            echo "  Last Used: $(grep "last_used:" "$meta_file" | cut -d: -f2- | sed 's/^ *//')"
            echo
        fi
    done

    if [[ "$found_tokens" != "true" ]]; then
        echo "No tokens stored."
    fi
}

validate_token_scopes() {
    local token="$1"

    log_info "Validating token scopes..."

    # Test repository access
    if GH_TOKEN="$token" gh repo view --json name &> /dev/null; then
        log_success "✓ Repository access confirmed"
    else
        log_error "✗ Repository access failed"
        return 1
    fi

    # Test workflow permissions
    if GH_TOKEN="$token" gh workflow list &> /dev/null; then
        log_success "✓ Workflow management access confirmed"
    else
        log_error "✗ Workflow management access failed"
        return 1
    fi

    # Test issue permissions
    if GH_TOKEN="$token" gh issue list --limit 1 &> /dev/null; then
        log_success "✓ Issue management access confirmed"
    else
        log_error "✗ Issue management access failed"
        return 1
    fi

    # Test PR permissions
    if GH_TOKEN="$token" gh pr list --limit 1 &> /dev/null; then
        log_success "✓ Pull request access confirmed"
    else
        log_error "✗ Pull request access failed"
        return 1
    fi

    log_success "All required token scopes validated"
}

check_token_expiry() {
    local token_name="$1"

    local meta_file="$TOKEN_STORE/${token_name}.meta"

    if [[ ! -f "$meta_file" ]]; then
        log_error "Token '$token_name' not found"
        return 1
    fi

    local expiry_date
    expiry_date=$(grep "expires:" "$meta_file" | cut -d: -f2- | sed 's/^ *//')

    if [[ -z "$expiry_date" ]]; then
        log_warning "No expiry date found for token '$token_name'"
        return 0
    fi

    local current_date
    current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Calculate days until expiry
    local expiry_epoch
    local current_epoch
    expiry_epoch=$(date -d "$expiry_date" +%s)
    current_epoch=$(date -d "$current_date" +%s)

    local days_until_expiry=$(( (expiry_epoch - current_epoch) / 86400 ))

    if [[ $days_until_expiry -lt 0 ]]; then
        log_error "Token '$token_name' has expired!"
        return 1
    elif [[ $days_until_expiry -le 7 ]]; then
        log_warning "Token '$token_name' expires in $days_until_expiry days"
        return 0
    elif [[ $days_until_expiry -le 30 ]]; then
        log_info "Token '$token_name' expires in $days_until_expiry days"
        return 0
    else
        log_success "Token '$token_name' is valid (expires in $days_until_expiry days)"
        return 0
    fi
}

rotate_token() {
    local token_name="$1"
    local new_token="$2"
    local description="${3:-}"

    log_info "Rotating token '$token_name'..."

    # Delete old token
    delete_token "$token_name"

    # Store new token
    if [[ -z "$description" ]]; then
        description="Rotated token (updated $(date -u +"%Y-%m-%d"))"
    fi

    store_token_securely "$token_name" "$new_token" "$description"

    log_token_action "ROTATED" "Token '$token_name' rotated successfully"
    log_success "Token '$token_name' rotated successfully"
}

generate_token_report() {
    local report_file="$PROJECT_ROOT/reports/token_status_$(date +%Y%m%d_%H%M%S).md"

    mkdir -p "$PROJECT_ROOT/reports"

    cat > "$report_file" << EOF
# Token Status Report
Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Summary

This report shows the status of all stored maintainer tokens for external PR operations.

## Token Details

EOF

    local expired_count=0
    local expiring_count=0
    local valid_count=0

    for meta_file in "$TOKEN_STORE"/*.meta; do
        if [[ -f "$meta_file" ]]; then
            local token_name
            token_name=$(basename "$meta_file" .meta)

            echo "### Token: $token_name" >> "$report_file"
            echo "- **Description**: $(grep "description:" "$meta_file" | cut -d: -f2- | sed 's/^ *//')" >> "$report_file"
            echo "- **Created**: $(grep "created:" "$meta_file" | cut -d: -f2- | sed 's/^ *//')" >> "$report_file"
            echo "- **Last Used**: $(grep "last_used:" "$meta_file" | cut -d: -f2- | sed 's/^ *//')" >> "$report_file"
            echo "- **Expires**: $(grep "expires:" "$meta_file" | cut -d: -f2- | sed 's/^ *//')" >> "$report_file"

            # Check expiry status
            if check_token_expiry "$token_name" 2>/dev/null; then
                local expiry_days
                expiry_days=$(check_token_expiry "$token_name" 2>&1 | grep -o "[0-9]\+ days" | head -1 | cut -d' ' -f1 || echo "unknown")

                if [[ "$expiry_days" == "unknown" ]]; then
                    echo "- **Status**: Valid (expiry unknown)" >> "$report_file"
                    ((valid_count++))
                elif [[ $expiry_days -le 7 ]]; then
                    echo "- **Status**: ⚠️  EXPIRES SOON ($expiry_days days)" >> "$report_file"
                    ((expiring_count++))
                elif [[ $expiry_days -le 30 ]]; then
                    echo "- **Status**: ⚠️  Expires soon ($expiry_days days)" >> "$report_file"
                    ((expiring_count++))
                else
                    echo "- **Status**: ✅ Valid ($expiry_days days remaining)" >> "$report_file"
                    ((valid_count++))
                fi
            else
                echo "- **Status**: ❌ EXPIRED" >> "$report_file"
                ((expired_count++))
            fi

            echo "" >> "$report_file"
        fi
    done

    # Summary
    cat >> "$report_file" << EOF
## Summary Statistics

- **Valid Tokens**: $valid_count
- **Expiring Soon**: $expiring_count
- **Expired Tokens**: $expired_count
- **Total Tokens**: $((valid_count + expiring_count + expired_count))

## Recommendations

EOF

    if [[ $expired_count -gt 0 ]]; then
        echo "- **URGENT**: $expired_count token(s) have expired and must be rotated immediately" >> "$report_file"
    fi

    if [[ $expiring_count -gt 0 ]]; then
        echo "- **ACTION NEEDED**: $expiring_count token(s) expire within 30 days" >> "$report_file"
    fi

    if [[ $valid_count -eq 0 ]]; then
        echo "- **WARNING**: No valid tokens available for external PR operations" >> "$report_file"
    fi

    echo "- Regular token rotation recommended (every 60-90 days)" >> "$report_file"
    echo "- Review token usage logs regularly for security monitoring" >> "$report_file"

    log_success "Token status report generated: $report_file"
    echo "Report saved to: $report_file"
}

# Interactive menu
show_menu() {
    echo
    echo "=== Maintainer Token Manager ==="
    echo "Security Level: Tier 3 - Token Management"
    echo
    echo "Available operations:"
    echo "1. Store New Token"
    echo "2. Retrieve Token"
    echo "3. List Stored Tokens"
    echo "4. Validate Token Scopes"
    echo "5. Check Token Expiry"
    echo "6. Rotate Token"
    echo "7. Delete Token"
    echo "8. Generate Status Report"
    echo "9. Exit"
    echo
}

# Main menu handler
handle_menu_choice() {
    local choice="$1"

    case "$choice" in
        1) # Store New Token
            read -p "Enter token name: " token_name
            read -s -p "Enter token value: " token_value
            echo
            read -p "Enter description: " description
            store_token_securely "$token_name" "$token_value" "$description"
            ;;
        2) # Retrieve Token
            read -p "Enter token name: " token_name
            echo "Token value:"
            retrieve_token "$token_name"
            ;;
        3) # List Stored Tokens
            list_tokens
            ;;
        4) # Validate Token Scopes
            read -s -p "Enter token to validate: " token_value
            echo
            validate_token_scopes "$token_value"
            ;;
        5) # Check Token Expiry
            read -p "Enter token name: " token_name
            check_token_expiry "$token_name"
            ;;
        6) # Rotate Token
            read -p "Enter token name to rotate: " token_name
            read -s -p "Enter new token value: " new_token
            echo
            read -p "Enter description (optional): " description
            rotate_token "$token_name" "$new_token" "$description"
            ;;
        7) # Delete Token
            read -p "Enter token name to delete: " token_name
            read -p "Are you sure? (y/N): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                delete_token "$token_name"
            else
                log_info "Delete cancelled"
            fi
            ;;
        8) # Generate Status Report
            generate_token_report
            ;;
        9) # Exit
            echo "Exiting token manager"
            exit 0
            ;;
        *)
            log_error "Invalid choice"
            ;;
    esac
}

# Main function
main() {
    # Initialize token store
    init_token_store

    # Create log directory
    mkdir -p "$PROJECT_ROOT/logs"

    log_info "Token manager started"
    log_info "All token operations will be audited"

    # Interactive mode
    while true; do
        show_menu
        read -p "Enter your choice (1-9): " choice
        handle_menu_choice "$choice"
        echo
        read -p "Press Enter to continue..."
    done
}

# Command-line mode
if [[ $# -gt 0 ]]; then
    case "$1" in
        "store")
            if [[ $# -lt 4 ]]; then
                echo "Usage: $0 store <name> <token> <description>"
                exit 1
            fi
            store_token_securely "$2" "$3" "$4"
            ;;
        "get")
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 get <name>"
                exit 1
            fi
            retrieve_token "$2"
            ;;
        "list")
            list_tokens
            ;;
        "validate")
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 validate <token>"
                exit 1
            fi
            validate_token_scopes "$2"
            ;;
        "check-expiry")
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 check-expiry <name>"
                exit 1
            fi
            check_token_expiry "$2"
            ;;
        "rotate")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 rotate <name> <new_token> [description]"
                exit 1
            fi
            rotate_token "$2" "$3" "${4:-}"
            ;;
        "delete")
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 delete <name>"
                exit 1
            fi
            delete_token "$2"
            ;;
        "report")
            generate_token_report
            ;;
        *)
            echo "Usage: $0 [command] [args...]"
            echo "Commands:"
            echo "  store <name> <token> <desc>     - Store new token"
            echo "  get <name>                     - Retrieve token"
            echo "  list                           - List all tokens"
            echo "  validate <token>               - Validate token scopes"
            echo "  check-expiry <name>            - Check token expiry"
            echo "  rotate <name> <new> [desc]     - Rotate existing token"
            echo "  delete <name>                  - Delete token"
            echo "  report                         - Generate status report"
            echo "  (no args for interactive mode)"
            exit 1
            ;;
    esac
else
    main
fi