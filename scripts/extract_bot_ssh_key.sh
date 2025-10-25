#!/bin/bash
# Extract Priority Matrix Bot SSH public key
# Run this locally to get the public key for GitHub upload

set -euo pipefail

echo "Extracting Priority Matrix Bot SSH public key..."
echo "================================================"

# Check if we have the secret available
if [[ -z "${PMBOT_SSH_PRIVATE:-}" ]]; then
    echo " PMBOT_SSH_PRIVATE environment variable not set"
    echo ""
    echo "To get the key:"
    echo "1. Go to: https://github.com/theangrygamershowproductions/DevOnboarder/settings/secrets/actions"
    echo "2. Find PMBOT_SSH_PRIVATE secret"
    echo "3. Copy the base64 value"
    echo "4. Run: export PMBOT_SSH_PRIVATE='<base64-value>'"
    echo "5. Then run this script again"
    exit 1
fi

# Create temporary key
umask 077
TEMP_DIR=$(mktemp -d)
printf '%s' "$PMBOT_SSH_PRIVATE" | base64 -d > "$TEMP_DIR/bot_key"
chmod 600 "$TEMP_DIR/bot_key"

# Generate public key
if ssh-keygen -y -f "$TEMP_DIR/bot_key" > "$TEMP_DIR/bot_key.pub"; then
    echo " SSH public key extracted"
    echo ""
    echo "Copy this public key to GitHub:"
    echo "==============================="
    cat "$TEMP_DIR/bot_key.pub"
    echo "==============================="
    echo ""
    echo "Upload steps:"
    echo "1. Go to the bot account: https://github.com/settings/keys"
    echo "2. Click 'New SSH key'"
    echo "3. Title: 'Priority Matrix Bot Signing Key'"
    echo "4. Key type: 'Signing Key'"
    echo "5. Paste the public key above"
    echo "6. Click 'Add SSH key'"
else
    echo " Failed to generate public key"
    exit 1
fi

# Cleanup
rm -rf "$TEMP_DIR"
echo ""
echo "Temporary files cleaned up"
