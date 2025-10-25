#!/bin/bash
set -euo pipefail

# Verify GPG Key Setup for Priority Matrix Bot
# Checks if keys exist and provides GitHub configuration links

PERSISTENT_KEY_DIR="$HOME/.devonboarder-keys"
PRIVATE_KEY_FILE="$PERSISTENT_KEY_DIR/pmbot_ed25519"
PUBLIC_KEY_FILE="$PERSISTENT_KEY_DIR/pmbot_ed25519.pub"

echo "Priority Matrix Bot Key Verification"
echo "===================================="

# Check if keys exist
if [[ -f "$PRIVATE_KEY_FILE" && -f "$PUBLIC_KEY_FILE" ]]; then
    echo " Keys found in persistent location"
    echo "   Private: $PRIVATE_KEY_FILE"
    echo "   Public: $PUBLIC_KEY_FILE"
    echo ""

    # Verify key format
    if grep -q "BEGIN OPENSSH PRIVATE KEY" "$PRIVATE_KEY_FILE"; then
        echo " Private key format: OpenSSH (correct)"
    else
        echo " Private key format: Invalid"
        exit 1
    fi

    if grep -q "ssh-ed25519" "$PUBLIC_KEY_FILE"; then
        echo " Public key format: ED25519 (correct)"
    else
        echo " Public key format: Invalid"
        exit 1
    fi

    echo ""
    echo "GitHub Configuration Links:"
    echo "=========================="
    echo "1. Private Key Secret: https://github.com/theangrygamershowproductions/DevOnboarder/settings/secrets/actions"
    echo "   Secret Name: PMBOT_SSH_PRIVATE"
    echo ""
    echo "2. Public Key SSH: https://github.com/settings/ssh/new"
    echo "   Title: Priority Matrix Bot - DevOnboarder"
    echo ""

    echo "Quick Copy Commands:"
    echo "==================="
    echo "# Copy private key to clipboard (Linux):"
    echo "cat $PRIVATE_KEY_FILE | xclip -selection clipboard"
    echo ""
    echo "# Copy public key to clipboard (Linux):"
    echo "cat $PUBLIC_KEY_FILE | xclip -selection clipboard"
    echo ""
    echo "# Display private key:"
    echo "cat $PRIVATE_KEY_FILE"
    echo ""
    echo "# Display public key:"
    echo "cat $PUBLIC_KEY_FILE"

else
    echo " Keys not found in persistent location"
    echo "   Run: ./scripts/generate_persistent_gpg_keys.sh"
    exit 1
fi
