#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"

# test_ssh_secret_formats.sh - Test different SSH secret formatting approaches
# Usage: ./scripts/test_ssh_secret_formats.sh

set -euo pipefail

echo "Testing SSH Secret Format Handling Methods"
echo "=========================================="

# Load the persistent key for testing
SSH_KEY_PATH="$HOME/.devonboarder-keys/pmbot_ed25519"

if [[ ! -f "$SSH_KEY_PATH" ]]; then
    error "SSH key not found at $SSH_KEY_PATH"
    echo "Run ./scripts/generate_persistent_gpg_keys.sh first"
    exit 1
fi

# Read the SSH key content
SSH_KEY_CONTENT=$(cat "$SSH_KEY_PATH")

echo "Original key validation:"
ssh-keygen -y -f "$SSH_KEY_PATH" > /dev/null 2>&1 && success "VALID" || error "INVALID"

# Test different writing methods
TEST_DIR="/tmp/ssh_test_$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo ""
echo "Testing Method 1: Direct echo"
echo "$SSH_KEY_CONTENT" > test_key_1
chmod 600 test_key_1
ssh-keygen -y -f test_key_1 > /dev/null 2>&1 && success "Method 1: VALID" || error "Method 1: INVALID"

echo ""
echo "Testing Method 2: printf with %s"
printf '%s' "$SSH_KEY_CONTENT" > test_key_2
chmod 600 test_key_2
ssh-keygen -y -f test_key_2 > /dev/null 2>&1 && success "Method 2: VALID" || error "Method 2: INVALID"

echo ""
echo "Testing Method 3: printf with %s and newline"
printf '%s\n' "$SSH_KEY_CONTENT" > test_key_3
chmod 600 test_key_3
ssh-keygen -y -f test_key_3 > /dev/null 2>&1 && success "Method 3: VALID" || error "Method 3: INVALID"

echo ""
echo "Testing Method 4: cat with heredoc"
cat > test_key_4 << EOF
$SSH_KEY_CONTENT
EOF
chmod 600 test_key_4
ssh-keygen -y -f test_key_4 > /dev/null 2>&1 && success "Method 4: VALID" || error "Method 4: INVALID"

echo ""
echo "Testing Method 5: base64 encode/decode"
SSH_KEY_B64=$(base64 -w 0 "$SSH_KEY_PATH")
echo "$SSH_KEY_B64" | base64 -d > test_key_5
chmod 600 test_key_5
ssh-keygen -y -f test_key_5 > /dev/null 2>&1 && success "Method 5: VALID" || error "Method 5: INVALID"

echo ""
echo "File size comparison:"
echo "Original: $(stat -c%s "$SSH_KEY_PATH") bytes"
echo "Method 1: $(stat -c%s test_key_1) bytes"
echo "Method 2: $(stat -c%s test_key_2) bytes"
echo "Method 3: $(stat -c%s test_key_3) bytes"
echo "Method 4: $(stat -c%s test_key_4) bytes"
echo "Method 5: $(stat -c%s test_key_5) bytes"

echo ""
echo "GitHub Secret Format for Repository Secrets:"
echo "Key name: PMBOT_SSH_PRIVATE"
echo "Key value (copy this exactly):"
echo "----------------------------------------"
cat "$SSH_KEY_PATH"
echo "----------------------------------------"

echo ""
echo "GitHub Secret Format for Base64 (if needed):"
echo "Key name: PMBOT_SSH_PRIVATE_B64"
echo "Key value:"
echo "----------------------------------------"
echo "$SSH_KEY_B64"
echo "----------------------------------------"

# Cleanup
cd /
rm -rf "$TEST_DIR"

echo ""
echo "Test completed. Use the working method in your GitHub workflow."
