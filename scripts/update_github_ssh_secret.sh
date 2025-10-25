#!/bin/bash
# update_github_ssh_secret.sh
# Update the GitHub Secret PMBOT_SSH_PRIVATE with the current SSH key

set -euo pipefail

echo "GitHub Secret Update Instructions"
echo "================================="
echo

# Get the current SSH private key in base64 format
if [ ! -f ~/.devonboarder-keys/pmbot_ed25519 ]; then
    echo " SSH private key not found at ~/.devonboarder-keys/pmbot_ed25519"
    exit 1
fi

BASE64_KEY=$(base64 -w 0 ~/.devonboarder-keys/pmbot_ed25519)

echo "Current SSH key fingerprint:"
ssh-keygen -lf ~/.devonboarder-keys/pmbot_ed25519.pub

echo
echo "To fix the SSH signature verification issue:"
echo "1. Go to GitHub repository Settings > Secrets and Variables > Actions"
echo "2. Find the secret 'PMBOT_SSH_PRIVATE'"
echo "3. Click 'Update' and replace the value with:"
echo
echo "===== COPY THIS BASE64 KEY ====="
echo "$BASE64_KEY"
echo "=================================="
echo
echo "4. Save the secret"
echo "5. The next Priority Matrix workflow run will use the correct SSH key"
echo "6. The commit signatures will then properly verify with our .gitsigners file"

echo
echo "Verification:"
echo "After updating the GitHub secret, you can verify by:"
echo "- git log --show-signature --oneline should show 'Good git signature'"
echo "- No more 'No principal matched' errors"

echo
echo "Current local configuration:"
echo "- SSH private key: ~/.devonboarder-keys/pmbot_ed25519"
echo "- SSH public key: ~/.devonboarder-keys/pmbot_ed25519.pub"
echo "- .gitsigners file: $(pwd)/.gitsigners"
echo "- Git SSH config: $(git config --get gpg.ssh.allowedSignersFile 2>/dev/null || echo 'Not configured')"
