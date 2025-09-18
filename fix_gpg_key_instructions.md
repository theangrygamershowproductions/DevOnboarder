# Fix Priority Matrix Bot SSH Key

## Current Issue

The PMBOT_SSH_PRIVATE secret contains an invalid SSH key format.

## Required Format

The key should be in OpenSSH format:

```text
-----BEGIN OPENSSH PRIVATE KEY-----
[key content]
-----END OPENSSH PRIVATE KEY-----
```

## How to Generate Correct Key

```bash
# Generate new SSH key pair
ssh-keygen -t ed25519 -C "bot+priority-matrix@theangrygamershow.com" -f pmbot_key -N ""

# The private key (pmbot_key) should be copied to PMBOT_SSH_PRIVATE secret
# The public key (pmbot_key.pub) should be added to GitHub SSH keys
```

## Alternative: Generate in GitHub Codespaces

```bash
# In a secure environment
ssh-keygen -t ed25519 -C "priority-matrix-bot" -f ~/.ssh/pmbot -N ""
cat ~/.ssh/pmbot  # Copy this to PMBOT_SSH_PRIVATE secret
cat ~/.ssh/pmbot.pub  # Add this to GitHub account SSH keys
```
