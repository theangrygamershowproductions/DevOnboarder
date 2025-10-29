#!/bin/bash
set -euo pipefail

# Fix GitHub SSH Secret for Priority Matrix Bot
# Provides multiple solutions for SSH key format issues

echo "GitHub SSH Secret Troubleshooting Tool"
echo "====================================="

PERSISTENT_KEY_DIR="$HOME/.devonboarder-keys"
PRIVATE_KEY_FILE="$PERSISTENT_KEY_DIR/pmbot_ed25519"

if [[ ! -f "$PRIVATE_KEY_FILE" ]]; then
    echo " Private key not found at: $PRIVATE_KEY_FILE"
    echo "Run: ./scripts/generate_persistent_gpg_keys.sh"
    exit 1
fi

echo " Current key validation:"
if ssh-keygen -y -f "$PRIVATE_KEY_FILE" > /dev/null 2>&1; then
    echo " Local SSH key is valid"
else
    echo " Local SSH key is invalid"
    exit 1
fi

echo ""
echo " SOLUTION 1: Direct SSH Key (Copy-Paste)"
echo "=========================================="
echo "Go to: https://github.com/theangrygamershowproductions/DevOnboarder/settings/secrets/actions"
echo "Secret Name: PMBOT_SSH_PRIVATE"
echo "Value (copy EXACTLY including blank lines):"
echo ""
echo "-----BEGIN COPY HERE-----"
cat "$PRIVATE_KEY_FILE"
echo "-----END COPY HERE-----"
echo ""

echo " SOLUTION 2: Base64 Encoded Version"
echo "====================================="
echo "If Solution 1 fails due to newline issues:"
echo "Secret Name: PMBOT_SSH_PRIVATE_B64"
echo "Value:"
echo ""
base64 -w 0 "$PRIVATE_KEY_FILE"
echo ""
echo ""

echo " SOLUTION 3: Single-Line with Escaped Newlines"
echo "=============================================="
echo "Secret Name: PMBOT_SSH_PRIVATE_ESCAPED"
echo "Value:"
echo ""
sed ':a;N;$!ba;s/\n/\\n/g' "$PRIVATE_KEY_FILE"
echo ""
echo ""

echo " SOLUTION 4: JSON-Safe Version"
echo "==============================="
echo "Secret Name: PMBOT_SSH_PRIVATE_JSON"
echo "Value:"
echo ""
python3 -c "
import json
with open('$PRIVATE_KEY_FILE', 'r') as f:
    content = f.read()
print(json.dumps(content))
" 2>/dev/null || echo "Python not available for JSON encoding"
echo ""

echo " WORKFLOW MODIFICATION OPTIONS"
echo "==============================="
echo "If secrets continue to have issues, we can modify the workflow to:"
echo "1. Use base64 decoding: echo \$PMBOT_SSH_PRIVATE_B64 | base64 -d"
echo "2. Use environment files instead of direct secrets"
echo "3. Use GitHub CLI to set secrets programmatically"
echo ""

echo "TARGET: RECOMMENDED STEPS"
echo "=================="
echo "1. Try Solution 1 first (direct copy-paste)"
echo "2. If that fails, try Solution 2 (base64)"
echo "3. If both fail, let us know for workflow modifications"
echo ""

echo " After updating the secret:"
echo "- Re-run the Priority Matrix workflow"
echo "- Or push a small change to trigger it"
echo "- Check the 'Setup SSH commit signing' step for success"
