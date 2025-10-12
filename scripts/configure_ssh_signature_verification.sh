#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# configure_ssh_signature_verification.sh
# Configure Git SSH signature verification for DevOnboarder
# This resolves the "No signature" issue for SSH-signed commits

set -euo pipefail

echo "Configuring SSH signature verification for DevOnboarder..."

# Configure Git to use SSH signature verification
git config --local gpg.ssh.allowedSignersFile .gitsigners

# Verify configuration
if git config --get gpg.ssh.allowedSignersFile >/dev/null 2>&1; then
    success "SSH signature verification configured"
    echo "SSH allowed signers file: $(git config --get gpg.ssh.allowedSignersFile)"
else
    error "Failed to configure SSH signature verification"
    exit 1
fi

# Test signature verification if SSH-signed commits exist
if git log --show-signature --oneline -5 | grep -q "Good.*signature"; then
    success "SSH signatures are now being verified"
    echo "Recent signed commits:"
    git log --show-signature --oneline -5 | grep "Good.*signature" | head -3
else
    echo "INFO: No SSH-signed commits found in recent history to verify"
fi

echo "SSH signature verification setup complete"
