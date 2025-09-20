#!/usr/bin/env bash
set -euo pipefail

# DevOnboarder Priority Matrix Bot SSH Signing Setup
# This script helps generate SSH keys for bot commit signing

echo "Priority Matrix Bot SSH Signing Key Generator"
echo "============================================="
echo ""

# Get bot details
BOT_NAME="${1:-Priority Matrix Bot}"
BOT_EMAIL="${2:-bot+priority-matrix@theangrygamershow.com}"
KEY_FILE="${3:-pmbot_signing_key}"

echo "Bot Identity:"
echo "  Name: $BOT_NAME"
echo "  Email: $BOT_EMAIL"
echo "  Key file: $KEY_FILE"
echo ""

# Check if key already exists
if [[ -f "$KEY_FILE" ]]; then
    echo "ERROR: Key file '$KEY_FILE' already exists!"
    echo "Remove it first or specify a different filename."
    exit 1
fi

# Generate SSH key for signing
echo "Generating Ed25519 SSH signing key..."
ssh-keygen -t ed25519 -C "$BOT_NAME <$BOT_EMAIL>" -f "$KEY_FILE" -N ""

echo ""
echo "✅ SSH key pair generated successfully!"
echo ""
echo "Files created:"
echo "  📄 $KEY_FILE (private key - for GitHub Actions secrets)"
echo "  📄 $KEY_FILE.pub (public key - for GitHub machine user)"
echo ""
echo "Next steps:"
echo ""
echo "1. Add the PUBLIC key to your bot's GitHub account:"
echo "   • Login to the machine user account"
echo "   • Go to Settings → SSH and GPG keys → New signing key"
echo "   • Choose 'Signing key' (not regular SSH key)"
echo "   • Paste the contents of: $KEY_FILE.pub"
echo ""
echo "2. Add the PRIVATE key to GitHub Actions secrets:"
echo "   • Go to your repository → Settings → Secrets and variables → Actions"
echo "   • Add secret: PMBOT_SSH_PRIVATE"
echo "   • Paste the contents of: $KEY_FILE"
echo ""
echo "3. Add bot identity secrets:"
echo "   • PMBOT_NAME: $BOT_NAME"
echo "   • PMBOT_EMAIL: $BOT_EMAIL"
echo ""
echo "4. Security cleanup:"
echo "   • After adding to GitHub, delete the local files:"
echo "   • rm $KEY_FILE $KEY_FILE.pub"
echo ""
echo "🔒 The bot email must be associated with the machine user account for verification."
echo ""

# Display the keys for easy copying
echo "Public key (for GitHub Signing Keys):"
echo "======================================"
cat "$KEY_FILE.pub"
echo ""
echo ""
echo "Private key (for GitHub Actions secret PMBOT_SSH_PRIVATE):"
echo "=========================================================="
cat "$KEY_FILE"
echo ""
echo ""
echo "⚠️  SECURITY: Delete these files after copying to GitHub!"
echo "   rm $KEY_FILE $KEY_FILE.pub"
