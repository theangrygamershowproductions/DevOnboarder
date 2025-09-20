#!/bin/bash

# debug_ssh_secret_content.sh - Comprehensive SSH secret debugging
# Usage: ./scripts/debug_ssh_secret_content.sh

set -euo pipefail

echo "SSH Secret Content Debugging Tool"
echo "================================="

# Load the persistent key for reference
SSH_KEY_PATH="$HOME/.devonboarder-keys/pmbot_ed25519"

if [[ ! -f "$SSH_KEY_PATH" ]]; then
    echo "ERROR: SSH key not found at $SSH_KEY_PATH"
    echo "Run ./scripts/generate_persistent_gpg_keys.sh first"
    exit 1
fi

echo "1. Current local key validation:"
if ssh-keygen -y -f "$SSH_KEY_PATH" > /dev/null 2>&1; then
    echo "✅ Local key is valid"
else
    echo "❌ Local key is invalid"
    exit 1
fi

echo ""
echo "2. Key file details:"
echo "   Size: $(stat -c%s "$SSH_KEY_PATH") bytes"
echo "   Lines: $(wc -l < "$SSH_KEY_PATH")"
echo "   First line: $(head -1 "$SSH_KEY_PATH")"
echo "   Last line: $(tail -1 "$SSH_KEY_PATH")"

echo ""
echo "3. Key content for GitHub Secret (PMBOT_SSH_PRIVATE):"
echo "   Copy this EXACTLY to GitHub > Settings > Secrets:"
echo "   =================================================="
cat "$SSH_KEY_PATH"
echo "   =================================================="

echo ""
echo "4. Hexdump of key (for debugging):"
echo "   First 50 bytes:"
hexdump -C "$SSH_KEY_PATH" | head -3

echo ""
echo "   Last 50 bytes:"
hexdump -C "$SSH_KEY_PATH" | tail -3

echo ""
echo "5. Character analysis:"
echo "   Contains Windows line endings (CRLF):"
if grep -q $'\r' "$SSH_KEY_PATH"; then
    echo "   ❌ YES - This could cause GitHub Actions issues!"
    echo "   Run: dos2unix $SSH_KEY_PATH"
else
    echo "   ✅ NO - Uses Unix line endings (LF)"
fi

echo ""
echo "   Contains null bytes:"
if grep -q $'\0' "$SSH_KEY_PATH"; then
    echo "   ❌ YES - This will cause issues!"
else
    echo "   ✅ NO - No null bytes found"
fi

echo ""
echo "6. Testing GitHub Actions equivalent commands:"
printf '   printf method:\n'

# Test the exact command from our workflow
CONTENT=$(cat "$SSH_KEY_PATH")
printf '%s\n' "$CONTENT" > /tmp/test_printf_method
if ssh-keygen -y -f /tmp/test_printf_method > /dev/null 2>&1; then
    echo "   ✅ printf method produces valid key"
else
    echo "   ❌ printf method produces invalid key"
    echo "   Size: $(stat -c%s /tmp/test_printf_method) bytes"
    echo "   Lines: $(wc -l < /tmp/test_printf_method)"
fi

echo ""
echo "7. Recommended actions:"
echo "   1. Copy the key content from section 3 above"
echo "   2. Go to: https://github.com/theangrygamershowproductions/DevOnboarder/settings/secrets/actions"
echo "   3. Edit PMBOT_SSH_PRIVATE secret"
echo "   4. Paste the EXACT content (including header/footer lines)"
echo "   5. Save the secret"
echo "   6. Re-run the Priority Matrix workflow"

# Cleanup
rm -f /tmp/test_printf_method

echo ""
echo "Debugging complete."
