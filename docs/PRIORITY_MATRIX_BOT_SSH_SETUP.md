# Priority Matrix Bot SSH Signing Setup Guide

This document provides instructions for configuring SSH-based commit signing for the Priority Matrix Bot, ensuring compliance with DevOnboarder's branch protection requirements using a simpler approach than GPG.

**Status**: Ready for testing with GitHub secrets configured.

## Overview

SSH commit signing provides cryptographic verification of bot commits without the complexity of GPG key management. This maintains DevOnboarder's "quiet reliability" philosophy while meeting branch protection requirements.

## One-Time Setup Requirements

### 1. Create Dedicated Machine User Account

Create a GitHub machine user account specifically for the Priority Matrix Bot:

- **Recommended username**: `tags-priority-matrix-bot`
- **Email**: `bot+priority-matrix@theangrygamershow.com`
- **Purpose**: Dedicated service account for automated Priority Matrix enhancements

### 2. Generate SSH Key Pair

On a trusted, secure machine, generate a dedicated SSH key for commit signing:

```bash
# Generate Ed25519 SSH key for commit signing
ssh-keygen -t ed25519 -C "Priority Matrix Bot <bot+priority-matrix@theangrygamershow.com>" -f pmbot_signing_key

# This creates:
# - pmbot_signing_key (private key - for GitHub Actions secrets)
# - pmbot_signing_key.pub (public key - for GitHub machine user)
```

### 3. Configure GitHub Machine User

1. **Add SSH Signing Key**:
   - Login to the machine user account
   - Go to **Settings → SSH and GPG keys → New signing key**
   - **Important**: Choose "Signing key" (not regular SSH key)
   - Upload contents of `pmbot_signing_key.pub`

2. **Grant Repository Access**:
   - Add machine user as collaborator with **Write** permissions
   - Or add to appropriate team with **Write** access

## Required GitHub Actions Secrets

Add these secrets to your repository (**Settings → Secrets and variables → Actions**):

| Secret Name | Description | Value |
|-------------|-------------|-------|
| `PMBOT_SSH_PRIVATE` | Complete private key | Contents of `pmbot_signing_key` file |
| `PMBOT_NAME` | Bot display name for commits | `Priority Matrix Bot` |
| `PMBOT_EMAIL` | Bot email for commits | `bot+priority-matrix@theangrygamershow.com` |

**Note**: The email must be associated with the machine user account for verification to work.

## Security Best Practices

### Key Management

1. **Secure Storage**:
   - Store private key only in GitHub Actions secrets
   - Delete local copies after setup
   - Use Ed25519 for modern cryptographic security

2. **Access Control**:
   - Dedicated machine user (no personal accounts)
   - Use existing Token Architecture v2.1 for push authentication
   - Separate concerns: SSH signing for verification, tokens for authorization

3. **Monitoring**:
   - Monitor for unauthorized commits from bot account
   - Regular audit of machine user permissions
   - Check for SSH signing failures in workflow logs

### Operational Security

1. **Fail-Safe Design**:
   - Fallback to manual instructions if signing fails
   - No automatic bypass of security controls
   - Clear error reporting for troubleshooting

2. **Least Privilege**:
   - Bot only operates on same-repo PRs
   - SSH key only used for signing (not repository access)
   - Limited to metadata-only changes

## Implementation

### Workflow Integration

The workflow automatically sets up SSH signing:

```yaml
- name: Setup SSH commit signing
  shell: bash
  env:
    PMBOT_SSH_PRIVATE: ${{ secrets.PMBOT_SSH_PRIVATE }}
    PMBOT_NAME: ${{ secrets.PMBOT_NAME }}
    PMBOT_EMAIL: ${{ secrets.PMBOT_EMAIL }}
  run: |
    set -euo pipefail
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo "$PMBOT_SSH_PRIVATE" > ~/.ssh/ci_signing_key
    chmod 600 ~/.ssh/ci_signing_key

    # Git: use SSH signing
    git config --global user.name  "$PMBOT_NAME"
    git config --global user.email "$PMBOT_EMAIL"
    git config --global gpg.format ssh
    git config --global user.signingkey ~/.ssh/ci_signing_key

    # Create public key file from private key for git reference
    ssh-keygen -y -f ~/.ssh/ci_signing_key > ~/.ssh/ci_signing_key.pub

    # Enable commit signing by default
    git config --global commit.gpgsign true
```

### Commit Process

After setup, regular `git commit` commands will automatically sign:

```bash
git add docs/ agents/ .codex/agents/ *.md
git commit -m "FEAT(docs): auto-synthesize Priority Matrix fields [signed]"
# Commit is automatically SSH-signed and will show "Verified" badge
```

## Verification & Testing

### Local Verification

After setup, verify SSH signing works:

```bash
# Check any signed commit from the bot
git log --show-signature --grep="Priority Matrix"

# Look for SSH signature verification
```

### CI Testing

Test the workflow with a documentation change:

1. Create PR with changes to `docs/` files
2. Verify Priority Matrix Bot commits show "Verified" badge
3. Check workflow logs for successful SSH setup
4. Confirm PR can merge without signature verification issues

## Troubleshooting

### Common Issues

1. **"SSH signing failed"**:
   - Check `PMBOT_SSH_PRIVATE` secret is set correctly
   - Verify machine user email matches `PMBOT_EMAIL`
   - Ensure SSH signing key is added to machine user account as "Signing key"

2. **"Push rejected"**:
   - Verify machine user has Write permissions
   - Check Token Architecture v2.1 tokens are configured
   - Ensure branch protection allows bot commits

3. **"Commit not verified"**:
   - Confirm SSH public key is added as **Signing key** (not regular SSH key)
   - Check machine user email matches commit email
   - Verify private key format is correct

### Debug Commands

```bash
# In workflow, add debug step:
- name: Debug SSH signing
  run: |
    git config --get gpg.format
    git config --get user.signingkey
    git config --get commit.gpgsign
    ssh-keygen -l -f ~/.ssh/ci_signing_key.pub
```

## Advantages over GPG

1. **Simpler Setup**: No GPG tooling or passphrase management
2. **Modern Crypto**: Ed25519 provides excellent security
3. **Fewer Secrets**: Only one private key needed
4. **Better CI Support**: SSH is more CI-friendly than GPG
5. **Maintenance**: No key expiry management (unless desired)

## Migration from GPG

If migrating from GPG setup:

1. Set up SSH signing following this guide
2. Test SSH signing works correctly
3. Remove GPG-related secrets:
   - `PMBOT_GPG_PRIVATE`
   - `PMBOT_GPG_PASSPHRASE`
   - `PMBOT_GPG_KEYID`
4. Keep `PMBOT_NAME` and `PMBOT_EMAIL` (same for both)

---

*This setup ensures DevOnboarder's Priority Matrix Bot maintains "quiet reliability" while meeting branch protection requirements with minimal complexity.*
