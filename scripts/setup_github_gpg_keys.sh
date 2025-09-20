#!/bin/bash

# GitHub GPG Key Setup Script
# Purpose: Import all known GitHub signing keys to prevent signature verification issues
# Usage: bash scripts/setup_github_gpg_keys.sh

set -euo pipefail

# ====================================
# GitHub GPG Key Import Configuration
# ====================================

# Known GitHub signing keys (as of 2025)
declare -A GITHUB_KEYS=(
    ["B5690EEEBB952194"]="GitHub Web-flow (merge commits)"
    ["4AEE18F83AFDEB23"]="GitHub (general signing)"
    ["23AEE39F96BA1C7A"]="GitHub (additional signing key)"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ====================================
# Logging Setup
# ====================================

mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "GitHub GPG Key Setup - $(date)"
echo "Log file: $LOG_FILE"
echo "========================================"

# ====================================
# Functions
# ====================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_gpg_available() {
    if ! command -v gpg >/dev/null 2>&1; then
        log_error "GPG is not installed. Please install gpg first."
        exit 1
    fi
    log_info "GPG is available: $(gpg --version | head -n 1)"
}

check_internet_connection() {
    if ! curl -s --max-time 5 https://keys.openpgp.org >/dev/null; then
        log_warning "Cannot reach key servers. Check internet connection."
        return 1
    fi
    return 0
}

import_github_key() {
    local key_id="$1"
    local description="$2"

    log_info "Importing $description (Key ID: $key_id)"

    # Check if key is already imported
    if gpg --list-keys "$key_id" >/dev/null 2>&1; then
        log_warning "Key $key_id already exists in keyring"
        return 0
    fi

    # Try multiple key servers
    local key_servers=(
        "keys.openpgp.org"
        "keyserver.ubuntu.com"
        "pgp.mit.edu"
    )

    for server in "${key_servers[@]}"; do
        log_info "Trying keyserver: $server"
        if gpg --keyserver "$server" --recv-keys "$key_id" 2>/dev/null; then
            log_success "Successfully imported $description from $server"
            return 0
        fi
    done

    log_error "Failed to import $description from all key servers"
    return 1
}

verify_key_import() {
    local key_id="$1"
    local description="$2"

    if gpg --list-keys "$key_id" >/dev/null 2>&1; then
        log_success "Verified: $description is in keyring"

        # Show key details
        echo "Key details:"
        gpg --list-keys "$key_id" | sed 's/^/  /'
        echo
        return 0
    else
        log_error "Verification failed: $description not found in keyring"
        return 1
    fi
}

test_signature_verification() {
    log_info "Testing signature verification with imported keys"

    # Find a GitHub merge commit to test with
    local test_commit
    test_commit=$(git log --merges --grep="Merge pull request" --format="%H" -1 2>/dev/null || echo "")

    if [[ -n "$test_commit" ]]; then
        log_info "Testing with merge commit: $test_commit"
        if git verify-commit "$test_commit" 2>/dev/null; then
            log_success "Signature verification working correctly"
        else
            log_warning "Signature verification test failed, but keys are imported"
        fi
    else
        log_info "No merge commits found for testing"
    fi
}

show_imported_keys() {
    log_info "GitHub keys now in your GPG keyring:"
    echo

    for key_id in "${!GITHUB_KEYS[@]}"; do
        if gpg --list-keys "$key_id" >/dev/null 2>&1; then
            echo "✓ $key_id - ${GITHUB_KEYS[$key_id]}"
        else
            echo "✗ $key_id - ${GITHUB_KEYS[$key_id]} (import failed)"
        fi
    done
    echo
}

# ====================================
# Main Execution
# ====================================

main() {
    log_info "Starting GitHub GPG key setup"

    # Pre-flight checks
    check_gpg_available

    if ! check_internet_connection; then
        log_error "Cannot proceed without internet connection"
        exit 1
    fi

    # Import all GitHub keys
    local success_count=0
    local total_count=${#GITHUB_KEYS[@]}

    for key_id in "${!GITHUB_KEYS[@]}"; do
        description="${GITHUB_KEYS[$key_id]}"

        if import_github_key "$key_id" "$description"; then
            verify_key_import "$key_id" "$description"
            ((success_count++))
        fi
        echo
    done

    # Summary
    echo "========================================"
    log_info "Import Summary: $success_count/$total_count keys imported successfully"

    show_imported_keys

    # Test signature verification
    test_signature_verification

    if [[ $success_count -gt 0 ]]; then
        log_success "GitHub GPG key setup completed! ($success_count/$total_count keys available)"
        log_info "You should no longer see 'Can't check signature: No public key' errors"
        echo
        log_info "Setup complete. Check log file: $LOG_FILE"
        exit 0
    else
        log_warning "No keys could be imported. Check your internet connection and try again."
        echo
        log_info "Setup complete. Check log file: $LOG_FILE"
        exit 1
    fi
}

# ====================================
# Script Execution
# ====================================

# Only run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
