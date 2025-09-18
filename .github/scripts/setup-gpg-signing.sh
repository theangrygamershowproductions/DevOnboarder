#!/usr/bin/env bash
set -euo pipefail

# DevOnboarder Priority Matrix Bot GPG Setup
# Configures GPG signing for automated commits with security best practices

# Required environment variables
: "${PMBOT_GPG_PRIVATE:?PMBOT_GPG_PRIVATE secret is required}"
: "${PMBOT_GPG_PASSPHRASE:?PMBOT_GPG_PASSPHRASE secret is required}"
: "${PMBOT_GPG_KEYID:?PMBOT_GPG_KEYID secret is required}"
: "${PMBOT_NAME:?PMBOT_NAME secret is required}"
: "${PMBOT_EMAIL:?PMBOT_EMAIL secret is required}"

echo "Setting up GPG signing for Priority Matrix Bot..."

# Create GPG directory with secure permissions
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg

# Import private key
echo "Importing GPG private key..."
echo "$PMBOT_GPG_PRIVATE" | gpg --batch --import

# Configure GPG agent for CI environment
echo "Configuring GPG agent for CI..."
echo "allow-loopback-pinentry" >> ~/.gnupg/gpg-agent.conf || true
echo "max-cache-ttl 7200" >> ~/.gnupg/gpg-agent.conf || true
echo "default-cache-ttl 7200" >> ~/.gnupg/gpg-agent.conf || true

# Restart GPG agent to pick up configuration
gpgconf --kill gpg-agent || true

# Set ultimate trust for the imported key (non-interactive)
echo "Setting ultimate trust for bot key..."
KEYFP=$(gpg --list-keys --with-colons "$PMBOT_EMAIL" | awk -F: '/^fpr:/ {print $10; exit}')
if [ -n "$KEYFP" ]; then
    printf "5\ny\n" | gpg --command-fd 0 --expert --edit-key "$KEYFP" trust quit
else
    echo "ERROR: Could not find fingerprint for $PMBOT_EMAIL"
    exit 1
fi

# Configure Git identity and signing
echo "Configuring Git identity and signing..."
git config --global user.name "$PMBOT_NAME"
git config --global user.email "$PMBOT_EMAIL"
git config --global user.signingkey "$PMBOT_GPG_KEYID"
git config --global commit.gpgsign true

# Configure GPG program settings
git config --global gpg.program gpg
GPG_TTY=$(tty 2>/dev/null || echo "not-a-tty")
export GPG_TTY

# Pre-sign the passphrase to cache it
echo "Caching GPG passphrase..."
echo "test" | gpg --batch --pinentry-mode loopback --passphrase "$PMBOT_GPG_PASSPHRASE" --sign --armor > /dev/null || true

echo "GPG signing setup completed successfully"

# Verify setup
echo "Verifying GPG setup..."
gpg --list-secret-keys --keyid-format LONG "$PMBOT_EMAIL"
git config --get user.signingkey

echo "Priority Matrix Bot GPG signing is ready"
