#!/bin/bash
# extract_github_ssh_public_key.sh
# Extract public key from the SSH private key stored in GitHub Secrets
# This helps resolve SSH signature verification issues

set -euo pipefail

echo "Extracting public key from GitHub Secrets SSH private key..."

# Check if we have the same private key that's in GitHub Secrets
if [ -f ~/.devonboarder-keys/pmbot_ed25519 ]; then
    echo "Using local SSH private key to extract public key..."

    # Extract public key from private key
    ssh-keygen -y -f ~/.devonboarder-keys/pmbot_ed25519 > /tmp/extracted_public_key.pub

    echo "Extracted public key:"
    cat /tmp/extracted_public_key.pub

    echo
    echo "Key fingerprint:"
    ssh-keygen -lf /tmp/extracted_public_key.pub

    echo
    echo "Updating .gitsigners with extracted public key..."

    # Read the public key and email
    PUBLIC_KEY=$(cat /tmp/extracted_public_key.pub)
    EMAIL="bot+priority-matrix@theangrygamershow.com"

    # Update .gitsigners file
    echo "$EMAIL $PUBLIC_KEY" > .gitsigners

    echo "Updated .gitsigners:"
    cat .gitsigners

    # Clean up
    rm -f /tmp/extracted_public_key.pub

    echo "SSH public key extraction complete"
else
    echo "ERROR: SSH private key not found at ~/.devonboarder-keys/pmbot_ed25519"
    exit 1
fi
