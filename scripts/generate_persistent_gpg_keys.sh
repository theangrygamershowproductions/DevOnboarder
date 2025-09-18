#!/bin/bash
set -euo pipefail

# Generate Persistent GPG Keys for Priority Matrix Bot
# This script creates SSH keys outside the workspace to prevent deletion
# and provides instructions for GitHub secret configuration

echo "Priority Matrix Bot GPG Key Generator"
echo "======================================"

# Create persistent key directory outside workspace
PERSISTENT_KEY_DIR="$HOME/.devonboarder-keys"
mkdir -p "$PERSISTENT_KEY_DIR"

# Key file paths
PRIVATE_KEY_FILE="$PERSISTENT_KEY_DIR/pmbot_ed25519"
PUBLIC_KEY_FILE="$PERSISTENT_KEY_DIR/pmbot_ed25519.pub"

echo "Creating persistent SSH key pair..."
echo "Key directory: $PERSISTENT_KEY_DIR"

# Generate ED25519 key (recommended for bot authentication)
ssh-keygen -t ed25519 \
    -C "priority-matrix-bot@devonboarder" \
    -f "$PRIVATE_KEY_FILE" \
    -N "" \
    -q

echo "Keys generated successfully!"
echo ""

# Display key information
echo "PRIVATE KEY (for PMBOT_SSH_PRIVATE secret):"
echo "==========================================="
cat "$PRIVATE_KEY_FILE"
echo ""

echo "PUBLIC KEY (for GitHub SSH keys):"
echo "================================="
cat "$PUBLIC_KEY_FILE"
echo ""

# Create setup instructions
cat > "$PERSISTENT_KEY_DIR/setup_instructions.md" << 'EOF'
# Priority Matrix Bot SSH Key Setup Instructions

## 1. Add Private Key to GitHub Secrets

1. Go to: https://github.com/theangrygamershowproductions/DevOnboarder/settings/secrets/actions
2. Find or create secret: `PMBOT_SSH_PRIVATE`
3. Copy the ENTIRE private key content (including BEGIN/END lines)
4. Paste into the secret value

## 2. Add Public Key to GitHub Account

1. Go to: https://github.com/settings/ssh/new
2. Title: "Priority Matrix Bot - DevOnboarder"
3. Copy the public key content
4. Paste into the key field
5. Click "Add SSH key"

## 3. Verify Setup

After adding both keys, the Priority Matrix Auto-Synthesis workflow should pass.

## Key Files Location

- Private key: ~/.devonboarder-keys/pmbot_ed25519
- Public key: ~/.devonboarder-keys/pmbot_ed25519.pub
- These files persist outside the workspace and won't be deleted on push/updates
EOF

echo "Setup Instructions:"
echo "=================="
echo "1. Keys are saved in: $PERSISTENT_KEY_DIR"
echo "2. Setup instructions: $PERSISTENT_KEY_DIR/setup_instructions.md"
echo "3. Private key to copy: $PRIVATE_KEY_FILE"
echo "4. Public key to copy: $PUBLIC_KEY_FILE"
echo ""

# Secure the private key
chmod 600 "$PRIVATE_KEY_FILE"
chmod 644 "$PUBLIC_KEY_FILE"

echo "Security permissions set correctly"
echo "Keys will persist across workspace updates"
echo ""

# Offer to copy to clipboard if available
if command -v xclip >/dev/null 2>&1; then
    echo "Copy private key to clipboard? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        xclip -selection clipboard < "$PRIVATE_KEY_FILE"
        echo "Private key copied to clipboard"
        echo "Paste this into PMBOT_SSH_PRIVATE secret"
    fi
elif command -v pbcopy >/dev/null 2>&1; then
    echo "Copy private key to clipboard? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        pbcopy < "$PRIVATE_KEY_FILE"
        echo "Private key copied to clipboard"
        echo "Paste this into PMBOT_SSH_PRIVATE secret"
    fi
fi

echo ""
echo "Next steps:"
echo "1. Copy private key to GitHub secret PMBOT_SSH_PRIVATE"
echo "2. Copy public key to GitHub SSH keys"
echo "3. Test the workflow"
