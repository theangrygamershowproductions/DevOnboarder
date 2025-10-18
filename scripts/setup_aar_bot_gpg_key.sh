#!/bin/bash
# Template for setting up GPG key for new automation bots
# Copy this script and customize for your specific bot
#
# Usage: bash scripts/setup_YOUR_BOT_NAME_gpg_key.sh
#
# This script generates a passphrase-free GPG key for automation,
# exports it for GitHub configuration, and provides setup instructions.

set -euo pipefail

echo "Setting up GPG key for AAR Bot..."

# CUSTOMIZE THESE VALUES FOR YOUR BOT
BOT_NAME="DevOnboarder AAR Bot"
BOT_EMAIL="aarbot@theangrygamershow.com"
BOT_COMMENT="DevOnboarder After Action Report Automation Bot"

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
    echo " Failed to generate or find GPG key"
    exit 1
fi

echo " GPG key generated successfully!"
echo "Key ID: $KEY_ID"
echo ""

# Export private key (base64 encoded for GitHub secrets)
echo "Exporting private key for GitHub secrets..."
gpg --export-secret-key --armor "$KEY_ID" | base64 -w 0
echo ""

# Export public key for GitHub
echo "Exporting public key for GitHub..."
PUBLIC_KEY=$(gpg --export --armor "$KEY_ID")

echo ""
echo "=========================================="
echo " GITHUB CONFIGURATION REQUIRED"
echo "=========================================="
echo ""
echo "1. ADD REPOSITORY SECRETS (Settings  Secrets and variables  Actions  Repository secrets):"
echo ""
echo "   Secret Name: AARBOT_GPG_PRIVATE"
echo "   Secret Value: (copy the base64 output above)"
echo ""
echo "2. Create GitHub Repository Variable:"
echo "   Go to: Settings  Security  Secrets and variables  Actions  Variables"
echo "   Variable Name: AARBOT_GPG_KEY_ID"
echo "   Variable Value: $KEY_ID"
echo "   Variable Name: AARBOT_NAME"
echo "   Variable Value: DevOnboarder AAR Bot"
echo "   Variable Name: AARBOT_EMAIL"
echo "   Variable Value: aarbot@theangrygamershow.com"
echo "3. ADD GPG PUBLIC KEY TO CORPORATE-MANAGED GITHUB ACCOUNT:"
echo ""
echo "     CRITICAL SECURITY REQUIREMENT:"
echo "   - Use SECONDARY GitHub account owned by corporate structure"
echo "   - DO NOT use personal developer accounts for bot tokens/keys"
echo "   - Example: developer@theangrygamershow.com (scarabofthespudheap)"
echo "   - Ensures privilege separation and emergency kill switch capability"
echo ""
echo "   Navigate to: https://github.com/settings/keys (on corporate bot account)"
echo "   Click 'New GPG key' and paste this public key:"
echo "   =================================================="
echo "$PUBLIC_KEY"
echo "   =================================================="
echo ""
echo "4. UPDATE YOUR WORKFLOW:"
echo ""
echo "   Replace placeholders in your workflow file:"
echo "   - {BOT_NAME}  AARBOT (for secrets/variables)"
echo "   - Update env variables in GPG setup step"
echo ""
echo "=========================================="
echo " SETUP COMPLETE"
echo "=========================================="
echo ""
echo "Your workflow should now use these environment variables:"
echo ""
echo "env:"
echo "  BOT_GPG_PRIVATE: \${{ secrets.AARBOT_GPG_PRIVATE }}"
echo "  BOT_GPG_KEY_ID: \${{ vars.AARBOT_GPG_KEY_ID }}"
echo "  BOT_NAME: \${{ vars.AARBOT_NAME }}"
echo "  BOT_EMAIL: \${{ vars.AARBOT_EMAIL }}"
echo ""
echo "Test your setup:"
echo "1. Add the secrets/variables to GitHub"
echo "2. Upload the public key to GitHub"
echo "3. Run your workflow and verify commits are signed"
echo ""
echo "For troubleshooting, see: docs/guides/gpg-troubleshooting.md"
