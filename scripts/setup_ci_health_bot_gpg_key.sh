#!/bin/bash

# setup_ci_health_bot_gpg_key.sh
# DevOnboarder CI Health Framework Bot GPG Key Generation and Setup Guide
# Part of DevOnboarder's framework-based bot architecture POC

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

printf '%s=== DevOnboarder CI Health Framework Bot GPG Setup ===%s\n' "$BLUE" "$NC"
printf "\n"
printf "This script sets up GPG credentials for the CI Health Framework Bot.\n"
printf "Part of framework-based bot architecture proof of concept.\n"
printf "\n"

# Validate we're in the DevOnboarder project root
if [[ ! -f "pyproject.toml" ]] || ! grep -q "devonboarder" pyproject.toml 2>/dev/null; then
    printf '%sERROR: Must be run from DevOnboarder project root%s\n' "$RED" "$NC"
    exit 1
fi

# Corporate governance warning
printf '%sCRITICAL SECURITY REQUIREMENTS:%s\n' "$YELLOW" "$NC"
printf "\n"
printf "This bot is part of DevOnboarder's enterprise GPG automation framework.\n"
printf "ALL bot credentials MUST be managed through corporate governance:\n"
printf "\n"
printf "  • Corporate Account: developer@theangrygamershow.com (scarabofthespudheap)\n"
printf "  • Secondary GitHub Account: MANDATORY for bot credential management\n"
printf "  • Corporate Oversight: Account must be owned within corporate structure\n"
printf "  • Security Isolation: Separate from personal developer accounts\n"
printf "  • Emergency Procedures: Centralized account enables rapid token/key revocation\n"
printf "\n"
printf '%sDO NOT use personal GitHub accounts for bot GPG key management.%s\n' "$RED" "$NC"
printf '%sCorporate governance is MANDATORY for enterprise security compliance.%s\n' "$RED" "$NC"
printf "\n"

# Bot configuration
BOT_NAME="CI Health Framework Bot"
BOT_EMAIL="ci-health@theangrygamershow.com"
KEY_COMMENT="DevOnboarder CI Health Framework Bot - POC"

printf '%sBot Configuration:%s\n' "$GREEN" "$NC"
printf "  Name: %s\n" "$BOT_NAME"
printf "  Email: %s\n" "$BOT_EMAIL"
printf "  Purpose: CI monitoring and health analysis automation\n"
printf "  Framework: CI Health Framework\n"
printf "  Key Type: RSA 4096-bit (no passphrase for automation)\n"
printf "\n"

# Generate GPG key
printf '%sGenerating GPG key for CI Health Framework Bot...%s\n' "$BLUE" "$NC"

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
    printf '%sGPG key generated successfully!%s\n' "$GREEN" "$NC"
else
    printf '%sERROR: Failed to generate GPG key%s\n' "$RED" "$NC"
    rm -f "$BATCH_FILE"
    exit 1
fi

# Clean up batch file
rm -f "$BATCH_FILE"

# Get the key ID
KEY_ID=$(gpg --list-keys --with-colons "$BOT_EMAIL" | awk -F: '/^pub/ {print $5}' | head -1)

if [[ -z "$KEY_ID" ]]; then
    printf '%sERROR: Could not retrieve key ID%s\n' "$RED" "$NC"
    exit 1
fi

printf "\n"
printf '%sKey generated successfully!%s\n' "$GREEN" "$NC"
printf "  Key ID: %s\n" "$KEY_ID"
printf "  Email: %s\n" "$BOT_EMAIL"
printf "\n"

# Export keys
printf '%sExporting keys...%s\n' "$BLUE" "$NC"

# Export public key
gpg --armor --export "$BOT_EMAIL" > "ci-health-bot-public.gpg"
printf "  Public key: ci-health-bot-public.gpg\n"

# Export private key
gpg --armor --export-secret-keys "$BOT_EMAIL" > "ci-health-bot-private.gpg"
printf "  Private key: ci-health-bot-private.gpg\n"

# Create base64 encoded private key for GitHub secrets
base64 -w 0 "ci-health-bot-private.gpg" > "ci-health-bot-private-base64.txt"
printf "  Base64 private key: ci-health-bot-private-base64.txt\n"

printf "\n"
printf '%s=== NEXT STEPS ===%s\n' "$GREEN" "$NC"
printf "\n"
printf '%s1. GitHub Repository Configuration:%s\n' "$YELLOW" "$NC"
printf "\n"
printf "   Add these secrets to your GitHub repository:\n"
printf "\n"
printf "   Repository Secrets:\n"
printf "     CI_HEALTH_BOT_GPG_PRIVATE = [content of ci-health-bot-private-base64.txt]\n"
printf "\n"
printf "   Repository Variables:\n"
printf "     CI_HEALTH_BOT_GPG_KEY_ID = %s\n" "$KEY_ID"
printf "     CI_HEALTH_BOT_NAME = %s\n" "$BOT_NAME"
printf "     CI_HEALTH_BOT_EMAIL = %s\n" "$BOT_EMAIL"
printf "\n"
printf '%s2. Corporate Account Setup (MANDATORY):%s\n' "$YELLOW" "$NC"
printf "\n"
printf "   Upload the public key to the corporate GitHub account:\n"
printf "   • Account: developer@theangrygamershow.com (scarabofthespudheap)\n"
printf "   • Navigate to: Settings → SSH and GPG keys → New GPG key\n"
printf "   • Upload content from: ci-health-bot-public.gpg\n"
printf "   • Verify the key appears in the account GPG keys list\n"
printf "\n"
printf '%s3. Test the POC Implementation:%s\n' "$YELLOW" "$NC"
printf "\n"
printf "   Create and run the test workflow:\n"
printf "   • Workflow: .github/workflows/test-ci-health-framework-bot.yml\n"
printf "   • Execute via: Actions → Test CI Health Framework Bot → Run workflow\n"
printf "   • Verify: GPG signature, email attribution, commit verification\n"
printf "\n"
printf '%s4. Security Cleanup:%s\n' "$YELLOW" "$NC"
printf "\n"
printf "   After uploading to GitHub:\n"
printf "   • Securely delete: ci-health-bot-private.gpg\n"
printf "   • Securely delete: ci-health-bot-private-base64.txt\n"
printf "   • Keep: ci-health-bot-public.gpg (for reference)\n"
printf "\n"
printf '%s=== VALIDATION COMMANDS ===%s\n' "$GREEN" "$NC"
printf "\n"
printf "Verify the key was created correctly:\n"
printf "  gpg --list-keys %s\n" "$BOT_EMAIL"
printf "  gpg --list-secret-keys %s\n" "$BOT_EMAIL"
printf "\n"
printf "Test GPG signing (optional):\n"
printf "  echo 'test' | gpg --clearsign --default-key %s\n" "$BOT_EMAIL"
printf "\n"
printf '%s=== POC VALIDATION ===%s\n' "$GREEN" "$NC"
printf "\n"
printf "Once configured, this CI Health Framework Bot will:\n"
printf "• Sign all commits with GPG for cryptographic verification\n"
printf "• Use ci-health@theangrygamershow.com for clear attribution\n"
printf "• Operate independently from other framework bots\n"
printf "• Validate framework-based bot architecture approach\n"
printf "• Demonstrate corporate governance compliance\n"
printf "\n"
printf '%sFramework isolation test ready for execution!%s\n' "$BLUE" "$NC"
printf "\n"

# Set restrictive permissions on key files
chmod 600 ci-health-bot-private.gpg ci-health-bot-private-base64.txt 2>/dev/null || true
chmod 644 ci-health-bot-public.gpg 2>/dev/null || true

printf '%sSetup complete! Follow the next steps above to configure GitHub.%s\n' "$GREEN" "$NC"
