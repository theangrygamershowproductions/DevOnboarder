#!/bin/bash

# generate_aar_bot_gpg_key.sh
# DevOnboarder AAR Bot GPG Key Generation and Setup Guide
# Part of DevOnboarder's framework-based bot architecture

set -euo pipefail

# Color output functions (DevOnboarder standard pattern)
red() { printf "\033[31m%s\033[0m\n" "$1"; }
green() { printf "\033[32m%s\033[0m\n" "$1"; }
yellow() { printf "\033[33m%s\033[0m\n" "$1"; }
blue() { printf "\033[34m%s\033[0m\n" "$1"; }
cyan() { printf "\033[36m%s\033[0m" "$1"; }

blue "=== DevOnboarder AAR Bot GPG Key Generator ==="
echo ""
echo "This script generates a new GPG key pair for the AAR Bot."
echo "Generated replacement for the old key (99CA270AD84AE20C)."
echo ""

# Corporate governance warning (DevOnboarder standard)
yellow "CRITICAL SECURITY REQUIREMENTS:"
echo ""
echo "This bot is part of DevOnboarder's enterprise GPG automation framework."
echo "ALL bot credentials MUST be managed through corporate governance:"
echo ""
echo "  - Corporate Account: developer@theangrygamershow.com (scarabofthespudheap)"
echo "  - Secondary GitHub Account: MANDATORY for bot credential management"
echo "  - Corporate Oversight: Account must be owned within corporate structure"
echo "  - Security Isolation: Separate from personal developer accounts"
echo "  - Emergency Procedures: Centralized account enables rapid token/key revocation"
echo ""
red "DO NOT use personal GitHub accounts for bot GPG key management."
red "Corporate governance is MANDATORY for enterprise security compliance."
echo ""

# Bot configuration (DevOnboarder standard)
BOT_NAME="DevOnboarder AAR Bot"
BOT_EMAIL="aar@theangrygamershow.com"
KEY_COMMENT="DevOnboarder AAR Bot - After Action Report Automation"

green "Bot Configuration:"
printf "  Name: %s\n" "$BOT_NAME"
printf "  Email: %s\n" "$BOT_EMAIL"
echo "  Purpose: After Action Report generation and portal automation"
echo "  Framework: AAR Framework"
echo "  Key Type: RSA 4096-bit (no passphrase for automation)"
echo ""

# Check if key already exists
blue "Checking for existing AAR Bot keys..."

if gpg --list-keys "$BOT_EMAIL" >/dev/null 2>&1; then
    yellow "WARNING: GPG key already exists for $BOT_EMAIL"
    echo ""
    echo "Existing key found. Options:"
    echo "1. Continue with existing key (recommended)"
    echo "2. Delete existing key and create new one"
    echo "3. Exit and manually resolve"
    echo ""
    printf "Enter choice (1-3): "
    read -r CHOICE

    case $CHOICE in
        1)
            printf "Using existing key...\n"
            SKIP_GENERATION=true
            ;;
        2)
            printf "Deleting existing key...\n"
            KEY_TO_DELETE=$(gpg --list-keys --with-colons "$BOT_EMAIL" | awk -F: '/^pub/ {print $5}' | head -1)
            if [[ -n "$KEY_TO_DELETE" ]]; then
                printf "y\ny\n" | gpg --delete-secret-keys "$KEY_TO_DELETE" || true
                printf "y\n" | gpg --delete-keys "$KEY_TO_DELETE" || true
                printf "Existing key deleted.\n"
            fi
            SKIP_GENERATION=false
            ;;
        3)
            echo "Exiting. Please resolve manually."
            exit 0
            ;;
        *)
            red "Invalid choice. Exiting."
            exit 1
            ;;
    esac
else
    echo "No existing key found. Will generate new key."
    SKIP_GENERATION=false
fi

echo ""

# Generate GPG key (if needed)
if [[ "$SKIP_GENERATION" != "true" ]]; then
    # Create temporary GPG home directory
    TEMP_GNUPG_HOME=$(mktemp -d)
    export GNUPGHOME="$TEMP_GNUPG_HOME"
    echo "Creating temporary GPG directory: $TEMP_GNUPG_HOME"
    blue "Generating GPG key for AAR Bot..."

    # Create temporary GPG batch file
    BATCH_FILE=$(mktemp)
    cat > "$BATCH_FILE" <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $BOT_NAME
Name-Email: $BOT_EMAIL
Name-Comment: $KEY_COMMENT
Expire-Date: 2y
%no-protection
%commit
EOF

    # Generate the key
    if gpg --batch --gen-key "$BATCH_FILE"; then
        green "GPG key generated successfully!"
    else
        red "ERROR: Failed to generate GPG key"
        rm -f "$BATCH_FILE"
        exit 1
    fi

    # Clean up batch file
    rm -f "$BATCH_FILE"
else
    blue "Using existing GPG key for AAR Bot..."
    # Use default GPG home for existing keys
    unset GNUPGHOME
fi

# Get the key ID
NEW_KEY_ID=$(gpg --list-keys --with-colons "$BOT_EMAIL" | awk -F: '/^pub/ {print $5}' | head -1)

if [[ -z "$NEW_KEY_ID" ]]; then
    red "ERROR: Could not retrieve key ID"
    exit 1
fi

echo ""
if [[ "$SKIP_GENERATION" != "true" ]]; then
    green "Key generated successfully!"
else
    green "Using existing key!"
fi
printf "  Key ID: %s\n" "$NEW_KEY_ID"
printf "  Email: %s\n" "$BOT_EMAIL"
echo ""

# Export keys
blue "Exporting keys..."

# Export public key
gpg --armor --export "$BOT_EMAIL" > "aar-bot-public.gpg"
echo "  Public key: aar-bot-public.gpg"

# Export private key
gpg --armor --export-secret-keys "$BOT_EMAIL" > "aar-bot-private.gpg"
echo "  Private key: aar-bot-private.gpg"

# Create base64 encoded private key for GitHub secrets
base64 -w 0 "aar-bot-private.gpg" > "aar-bot-private-base64.txt"
echo "  Base64 private key: aar-bot-private-base64.txt"

# Set security permissions (DevOnboarder standard)
chmod 600 aar-bot-private.gpg aar-bot-private-base64.txt 2>/dev/null || true
chmod 644 aar-bot-public.gpg 2>/dev/null || true

echo ""
green "=== NEXT STEPS ==="
echo ""
yellow "1. GitHub Repository Configuration:"
echo ""
echo "   Add these secrets to your GitHub repository:"
echo ""
echo "   Repository Secrets:"
echo "     AAR_BOT_GPG_PRIVATE = [content of aar-bot-private-base64.txt]"
echo ""
echo "   Repository Variables:"
printf "     AAR_BOT_GPG_KEY_ID = %s\n" "$NEW_KEY_ID"
printf "     AAR_BOT_NAME = %s\n" "$BOT_NAME"
printf "     AAR_BOT_EMAIL = %s\n" "$BOT_EMAIL"
echo ""
yellow "2. Corporate Account Setup (MANDATORY):"
echo ""
echo "   Upload the public key to the corporate GitHub account:"
echo "   - Account: developer@theangrygamershow.com (scarabofthespudheap)"
echo "   - Navigate to: Settings -> SSH and GPG keys -> New GPG key"
echo "   - Upload content from: aar-bot-public.gpg"
echo "   - Verify the key appears in the account GPG keys list"
echo ""
yellow "3. Test the AAR Implementation:"
echo ""
echo "   Test the AAR workflows:"
echo "   - Workflows: aar-portal.yml, aar-automation.yml"
echo "   - Execute via: Actions -> Generate AAR Portal -> Run workflow"
echo "   - Verify: GPG signature, email attribution, commit verification"
echo ""
yellow "4. Security Cleanup:"
echo ""
echo "   After uploading to GitHub:"
echo "   - Securely delete: aar-bot-private.gpg"
echo "   - Securely delete: aar-bot-private-base64.txt"
echo "   - Keep: aar-bot-public.gpg (for reference)"
echo ""
green "=== VALIDATION COMMANDS ==="
echo ""
echo "Verify the key was created correctly:"
printf "  gpg --list-keys %s\n" "$BOT_EMAIL"
printf "  gpg --list-secret-keys %s\n" "$BOT_EMAIL"
echo ""
echo "Test GPG signing (optional):"
printf "  echo 'test' | gpg --clearsign --default-key %s\n" "$BOT_EMAIL"
echo ""
echo "Key fingerprint:"
gpg --fingerprint "$BOT_EMAIL"
echo ""
green "=== AAR FRAMEWORK VALIDATION ==="
echo ""
echo "Once configured, this AAR Bot will:"
echo "- Sign all commits with GPG for cryptographic verification"
echo "- Use aar@theangrygamershow.com for clear attribution"
echo "- Operate independently from other framework bots"
echo "- Generate After Action Reports with verified provenance"
echo "- Demonstrate corporate governance compliance"
echo ""
blue "Framework isolation test ready for execution!"
echo ""

# Cleanup on exit (only if temp directory was created)
if [[ -n "${TEMP_GNUPG_HOME:-}" ]]; then
    trap 'rm -rf "$TEMP_GNUPG_HOME"' EXIT
fi

green "Setup complete! Follow the next steps above to configure GitHub."
