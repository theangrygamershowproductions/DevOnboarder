#!/bin/bash

# setup_ci_health_bot_gpg_key.sh
# DevOnboarder CI Health Framework Bot GPG Key Generation and Setup Guide
# Part of DevOnboarder's framework-based bot architecture POC

set -euo pipefail

# Color output functions (DevOnboarder standard pattern)
red() { printf "\033[31m%s\033[0m\n" "$1"; }
green() { printf "\033[32m%s\033[0m\n" "$1"; }
yellow() { printf "\033[33m%s\033[0m\n" "$1"; }
blue() { printf "\033[34m%s\033[0m\n" "$1"; }
cyan() { printf "\033[36m%s\033[0m" "$1"; }

blue "=== DevOnboarder CI Health Framework Bot GPG Setup ==="
echo ""
echo "This script sets up GPG credentials for the CI Health Framework Bot."
echo "Part of framework-based bot architecture proof of concept."
echo ""

# Validate we're in the DevOnboarder project root
if [[ ! -f "pyproject.toml" ]] || ! grep -q "devonboarder" pyproject.toml 2>/dev/null; then
    red "ERROR: Must be run from DevOnboarder project root"
    exit 1
fi

# Corporate governance warning
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

# Bot configuration
BOT_NAME="CI Health Framework Bot"
BOT_EMAIL="ci-health@theangrygamershow.com"
KEY_COMMENT="DevOnboarder CI Health Framework Bot - POC"

green "Bot Configuration:"
printf "  Name: %s\n" "$BOT_NAME"
printf "  Email: %s\n" "$BOT_EMAIL"
echo "  Purpose: CI monitoring and health analysis automation"
echo "  Framework: CI Health Framework"
echo "  Key Type: RSA 4096-bit (no passphrase for automation)"
echo ""

# Check if key already exists
blue "Checking for existing CI Health Bot keys..."

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
    blue "Generating GPG key for CI Health Framework Bot..."

    # Create temporary GPG batch file
    BATCH_FILE=$(mktemp)
    cat > "$BATCH_FILE" << EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: ${BOT_NAME}
Name-Email: ${BOT_EMAIL}
Name-Comment: ${KEY_COMMENT}
Expire-Date: 2y
%no-protection
%commit
EOF

    # Generate the key
    if gpg --batch --generate-key "$BATCH_FILE"; then
        green "GPG key generated successfully!"
    else
        red "ERROR: Failed to generate GPG key"
        rm -f "$BATCH_FILE"
        exit 1
    fi

    # Clean up batch file
    rm -f "$BATCH_FILE"
else
    blue "Using existing GPG key for CI Health Framework Bot..."
fi

# Get the key ID
KEY_ID=$(gpg --list-keys --with-colons "$BOT_EMAIL" | awk -F: '/^pub/ {print $5}' | head -1)

if [[ -z "$KEY_ID" ]]; then
    red "ERROR: Could not retrieve key ID"
    exit 1
fi

echo ""
if [[ "$SKIP_GENERATION" != "true" ]]; then
    green "Key generated successfully!"
else
    green "Using existing key!"
fi
printf "  Key ID: %s\n" "$KEY_ID"
printf "  Email: %s\n" "$BOT_EMAIL"
echo ""

# Export keys
blue "Exporting keys..."

# Export public key
gpg --armor --export "$BOT_EMAIL" > "ci-health-bot-public.gpg"
echo "  Public key: ci-health-bot-public.gpg"

# Export private key
gpg --armor --export-secret-keys "$BOT_EMAIL" > "ci-health-bot-private.gpg"
echo "  Private key: ci-health-bot-private.gpg"

# Create base64 encoded private key for GitHub secrets
base64 -w 0 "ci-health-bot-private.gpg" > "ci-health-bot-private-base64.txt"
echo "  Base64 private key: ci-health-bot-private-base64.txt"

echo ""
green "=== NEXT STEPS ==="
echo ""
yellow "1. GitHub Repository Configuration:"
echo ""
echo "   Add these secrets to your GitHub repository:"
echo ""
echo "   Repository Secrets:"
echo "     CI_HEALTH_BOT_GPG_PRIVATE = [content of ci-health-bot-private-base64.txt]"
echo ""
echo "   Repository Variables:"
printf "     CI_HEALTH_BOT_GPG_KEY_ID = %s\n" "$KEY_ID"
printf "     CI_HEALTH_BOT_NAME = %s\n" "$BOT_NAME"
printf "     CI_HEALTH_BOT_EMAIL = %s\n" "$BOT_EMAIL"
echo ""
yellow "2. Corporate Account Setup (MANDATORY):"
echo ""
echo "   Upload the public key to the corporate GitHub account:"
echo "   - Account: developer@theangrygamershow.com (scarabofthespudheap)"
echo "   - Navigate to: Settings -> SSH and GPG keys -> New GPG key"
echo "   - Upload content from: ci-health-bot-public.gpg"
echo "   - Verify the key appears in the account GPG keys list"
echo ""
yellow "3. Test the POC Implementation:"
echo ""
echo "   Create and run the test workflow:"
echo "   - Workflow: .github/workflows/test-ci-health-framework-bot.yml"
echo "   - Execute via: Actions -> Test CI Health Framework Bot -> Run workflow"
echo "   - Verify: GPG signature, email attribution, commit verification"
echo ""
yellow "4. Security Cleanup:"
echo ""
echo "   After uploading to GitHub:"
echo "   - Securely delete: ci-health-bot-private.gpg"
echo "   - Securely delete: ci-health-bot-private-base64.txt"
echo "   - Keep: ci-health-bot-public.gpg (for reference)"
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
green "=== POC VALIDATION ==="
echo ""
echo "Once configured, this CI Health Framework Bot will:"
echo "- Sign all commits with GPG for cryptographic verification"
echo "- Use ci-health@theangrygamershow.com for clear attribution"
echo "- Operate independently from other framework bots"
echo "- Validate framework-based bot architecture approach"
echo "- Demonstrate corporate governance compliance"
echo ""
blue "Framework isolation test ready for execution!"
echo ""

# Set restrictive permissions on key files
chmod 600 ci-health-bot-private.gpg ci-health-bot-private-base64.txt 2>/dev/null || true
chmod 644 ci-health-bot-public.gpg 2>/dev/null || true

green "Setup complete! Follow the next steps above to configure GitHub."
