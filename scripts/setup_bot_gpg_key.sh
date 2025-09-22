#!/bin/bash
# Setup GPG key for Priority Matrix Bot without passphrase
# This replaces SSH signing with GPG for consistent signature verification

set -euo pipefail

echo "Setting up GPG key for Priority Matrix Bot..."

# Bot configuration
BOT_NAME="Priority Matrix Bot"
BOT_EMAIL="developer@theangrygamershow.com"
BOT_COMMENT="DevOnboarder Automation Bot"

# Create temporary GPG batch file for key generation
GPG_BATCH_FILE=$(mktemp)
cat > "$GPG_BATCH_FILE" << EOF
%echo Generating GPG key for Priority Matrix Bot
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
KEY_ID=$(gpg --list-secret-keys --keyid-format LONG "$BOT_EMAIL" | grep sec | awk '{print $2}' | cut -d'/' -f2)

if [[ -z "$KEY_ID" ]]; then
    echo "ERROR: Failed to create or find GPG key"
    exit 1
fi

echo "GPG key created successfully!"
echo "Key ID: $KEY_ID"
echo "Email: $BOT_EMAIL"

# Export the private key (armor format)
PRIVATE_KEY_FILE=$(mktemp)
gpg --armor --export-secret-keys "$KEY_ID" > "$PRIVATE_KEY_FILE"

echo ""
echo "=== GPG Key Setup Complete ==="
echo "Key ID: $KEY_ID"
echo "Private key exported to: $PRIVATE_KEY_FILE"
echo ""
echo "Next steps:"
echo "1. Upload private key to GitHub secrets as PMBOT_GPG_PRIVATE:"
echo "   gh secret set PMBOT_GPG_PRIVATE --repo theangrygamershowproductions/DevOnboarder < '$PRIVATE_KEY_FILE'"
echo ""
echo "2. Add key ID to GitHub variables:"
echo "   gh variable set PMBOT_GPG_KEY_ID --value '$KEY_ID' --repo theangrygamershowproductions/DevOnboarder"
echo ""
echo "3. Export public key to GitHub (for verification):"
echo "   gpg --armor --export '$KEY_ID'"
echo ""
echo "Public key (add to GitHub GPG keys if needed):"
gpg --armor --export "$KEY_ID"

# Store key info for later use
echo "KEY_ID=$KEY_ID" > logs/bot_gpg_setup.env
echo "PRIVATE_KEY_FILE=$PRIVATE_KEY_FILE" >> logs/bot_gpg_setup.env

echo ""
echo "Key information saved to: logs/bot_gpg_setup.env"
echo "IMPORTANT: Keep the private key file secure and delete after uploading to GitHub!"
