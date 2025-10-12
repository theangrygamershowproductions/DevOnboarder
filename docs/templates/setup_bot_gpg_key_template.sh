#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Template for setting up GPG key for new automation bots
# Copy this script and customize for your specific bot
#
# Usage: bash scripts/setup_YOUR_BOT_NAME_gpg_key.sh
#
# This script generates a passphrase-free GPG key for automation,
# exports it for GitHub configuration, and provides setup instructions.

set -euo pipefail

echo "Setting up GPG key for {BOT_NAME}..."

# CUSTOMIZE THESE VALUES FOR YOUR BOT
BOT_NAME="{Bot Display Name}"
BOT_EMAIL="{bot-name}@theangrygamershow.com"
BOT_COMMENT="DevOnboarder {Bot Description}"

# Create temporary GPG batch file for key generation
GPG_BATCH_FILE=$(mktemp)
cat > "$GPG_BATCH_FILE" << EOF
%echo Generating GPG key for $BOT_NAME
Key-Type: RSA
Key-Length: 4096
Name-Real: $BOT_NAME
Name-Comment: $BOT_COMMENT
Name-Email: $BOT_EMAIL
Expire-Date: 2y
%no-protection
%commit
%echo GPG key generation complete
EOF

echo "Generating GPG key (this may take a moment)..."
gpg --batch --generate-key "$GPG_BATCH_FILE"

# Clean up batch file
rm "$GPG_BATCH_FILE"

# Get the key ID
KEY_ID=$(gpg --list-secret-keys --with-colons "$BOT_EMAIL" | awk -F: '/^sec:/ {print $5}')

if [ -z "$KEY_ID" ]; then
    error "Failed to generate or find GPG key"
    exit 1
fi

success "GPG key generated successfully!"
echo "Key ID: $KEY_ID"
echo ""

# Export private key (base64 encoded for GitHub secrets)
echo "Exporting private key for GitHub secrets..."
PRIVATE_KEY_B64=$(gpg --export-secret-key --armor "$KEY_ID" | base64 -w 0)

# Export public key for GitHub
echo "Exporting public key for GitHub..."
PUBLIC_KEY=$(gpg --export --armor "$KEY_ID")

echo ""
echo "=========================================="
check "GITHUB CONFIGURATION REQUIRED"
echo "=========================================="
echo ""
echo "1. ADD REPOSITORY SECRETS (Settings → Secrets and variables → Actions → Repository secrets):"
echo ""
echo "   Secret Name: {BOT_NAME_UPPER}_GPG_PRIVATE"
echo "   Secret Value:"
echo "$PRIVATE_KEY_B64"
echo ""
echo "2. ADD REPOSITORY VARIABLES (Settings → Secrets and variables → Actions → Repository variables):"
echo ""
echo "   Variable Name: {BOT_NAME_UPPER}_GPG_KEY_ID"
echo "   Variable Value: $KEY_ID"
echo ""
echo "   Variable Name: {BOT_NAME_UPPER}_NAME"
echo "   Variable Value: $BOT_NAME"
echo ""
echo "   Variable Name: {BOT_NAME_UPPER}_EMAIL"
echo "   Variable Value: $BOT_EMAIL"
echo ""
echo "3. ADD GPG PUBLIC KEY TO GITHUB ACCOUNT (https://github.com/settings/keys):"
echo ""
echo "   Click 'New GPG key' and paste this public key:"
echo "   =================================================="
echo "$PUBLIC_KEY"
echo "   =================================================="
echo ""
echo "4. UPDATE YOUR WORKFLOW:"
echo ""
echo "   Replace placeholders in your workflow file:"
echo "   - {BOT_NAME} → {BOT_NAME_UPPER} (for secrets/variables)"
echo "   - Update env variables in GPG setup step"
echo ""
echo "=========================================="
success "SETUP COMPLETE"
echo "=========================================="
echo ""
echo "Your workflow should now use these environment variables:"
echo ""
echo "env:"
echo "  BOT_GPG_PRIVATE: \${{ secrets.{BOT_NAME_UPPER}_GPG_PRIVATE }}"
echo "  BOT_GPG_KEY_ID: \${{ vars.{BOT_NAME_UPPER}_GPG_KEY_ID }}"
echo "  BOT_NAME: \${{ vars.{BOT_NAME_UPPER}_NAME }}"
echo "  BOT_EMAIL: \${{ vars.{BOT_NAME_UPPER}_EMAIL }}"
echo ""
echo "Test your setup:"
echo "1. Add the secrets/variables to GitHub"
echo "2. Upload the public key to GitHub"
echo "3. Run your workflow and verify commits are signed"
echo ""
echo "For troubleshooting, see: docs/guides/gpg-troubleshooting.md"
