---
similarity_group: PRIORITY_MATRIX_BOT_SETUP.md-docs

content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---

# Priority Matrix Bot GPG Setup Guide

This document provides comprehensive instructions for configuring GPG-signed commits for the Priority Matrix Bot, ensuring compliance with DevOnboarder's branch protection requirements.

## Overview

The Priority Matrix Bot automatically enhances documentation with metadata fields for similarity detection and document deduplication. With DevOnboarder's branch protection requiring GPG signatures, the bot now uses dedicated GPG keys for secure, signed commits.

## One-Time Setup Requirements

### 1. Create Dedicated Machine User Account

Create a GitHub machine user account specifically for the Priority Matrix Bot:

- **Recommended username**: `tags-priority-matrix-bot`

- **Email**: `priority-matrix@theangrygamershow.com`

- **Purpose**: Dedicated service account for automated Priority Matrix enhancements

### 2. Generate GPG Key Pair

On a trusted, secure machine, generate a dedicated GPG key:

```bash

# Generate RSA 4096-bit key with 2-year expiry

gpg --quick-generate-key "Priority Matrix Bot <priority-matrix@theangrygamershow.com>" rsa4096 sign 2y

# List keys to get the key ID

gpg --list-secret-keys --keyid-format LONG

# Copy the KEYID (long hex value, e.g., ABCDEF1234567890)

export KEYID=ABCDEF1234567890

# Export public key (for GitHub)

gpg --armor --export $KEYID > pmbot-public.asc

# Export private key (for GitHub Actions secrets)

gpg --pinentry-mode loopback --passphrase "<CHOOSE-STRONG-PASSPHRASE>" \
  --armor --export-secret-keys $KEYID > pmbot-private.asc

# Generate revocation certificate (store offline securely!)

gpg --output pmbot-revocation.crt --gen-revoke $KEYID

```

### 3. Configure GitHub Machine User

1. **Add GPG Public Key**:

   - Login to the machine user account

   - Go to **Settings  SSH and GPG keys  New GPG key**

   - Upload contents of `pmbot-public.asc`

2. **Grant Repository Access**:

   - Add machine user as collaborator with **Write** permissions

   - Or add to appropriate team with **Write** access

## Required GitHub Actions Secrets

Add these secrets to your repository (**Settings  Secrets and variables  Actions**):

### Core GPG Configuration

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `PMBOT_GPG_PRIVATE` | Complete private key (ASCII armored) | `-----BEGIN PGP PRIVATE KEY BLOCK-----\n...` |
| `PMBOT_GPG_PASSPHRASE` | GPG key passphrase | `secure-randomly-generated-passphrase` |
| `PMBOT_GPG_KEYID` | GPG key ID (long format) | `ABCDEF1234567890` |
| `PMBOT_NAME` | Bot display name for commits | `Priority Matrix Bot` |
| `PMBOT_EMAIL` | Bot email for commits | `priority-matrix@theangrygamershow.com` |

### Optional Authentication (Recommended)

| Secret Name | Description | Usage |
|-------------|-------------|-------|
| `PMBOT_PAT` | Fine-grained Personal Access Token | For enhanced security and cross-fork support |

**PMBOT_PAT Scopes** (if using):

- **Contents**: Read & Write

- **Pull Requests**: Read & Write

- **Expiry**: 90 days (short rotation cycle)

## Security Best Practices

### Key Management

1. **Secure Storage**:

   - Store `pmbot-revocation.crt` offline (1Password/Bitwarden)

   - Use strong, unique passphrase (generated, not memorable)

   - Set calendar reminder for key rotation (every 2 years)

2. **Access Control**:

   - Dedicated machine user (no personal accounts)

   - Fine-grained PAT with minimal required scopes

   - Regular secret rotation (90-day cycle for PATs)

3. **Monitoring**:

   - Add alerts for GPG signing failures

   - Monitor for unauthorized commits from bot account

   - Regular audit of machine user permissions

### Operational Security

1. **Fail-Safe Design**:

   - Fallback to manual instructions if signing fails

   - No automatic bypass of security controls

   - Clear error reporting for troubleshooting

2. **Least Privilege**:

   - Bot only operates on same-repo PRs

   - No fork support (prevents credential exposure)

   - Limited to metadata-only changes

## Implementation Components

### Files Added/Modified

- `.github/scripts/setup-gpg-signing.sh` - GPG configuration script

- `.github/workflows/priority-matrix-synthesis.yml` - Updated workflow with signing

- `docs/PRIORITY_MATRIX_BOT_SETUP.md` - This documentation

### Workflow Changes

1. **Security Guards**:

   ```yaml
   if: >
     github.event.pull_request.head.repo.full_name == github.repository
     && !startsWith(github.head_ref, 'dependabot/')
     && !github.event.pull_request.head.repo.fork
   ```

2. **GPG Setup Step**:

   - Imports private key securely

   - Configures Git identity and signing

   - Caches passphrase for job duration

3. **Signed Commits**:

   - All Priority Matrix commits are GPG signed

   - Proper attribution to Priority Matrix Bot

   - Meaningful commit messages with enhancement details

4. **Fallback Mechanism**:

   - Posts helpful comment if signing fails

   - Provides manual instructions for developers

   - No separate PR creation (maintains "quiet reliability")

## Verification & Testing

### Local Verification

After setup, verify GPG signing works:

```bash

# Check any signed commit from the bot

git log --show-signature --grep="Priority Matrix"

# Look for: "Good signature from 'Priority Matrix Bot <...>'"

```

### CI Testing

Test the workflow with a documentation change:

1. Create PR with changes to `docs/` files

2. Verify Priority Matrix Bot commits are signed

3. Check fallback comment appears if signing fails

4. Confirm PR can merge without signature verification issues

## Troubleshooting

### Common Issues

1. **"GPG signing failed"**:

   - Check all required secrets are set

   - Verify GPG key hasn't expired

   - Ensure passphrase is correct

2. **"Push rejected"**:

   - Verify machine user has Write permissions

   - Check branch protection settings allow bot commits

   - Ensure token has correct scopes

3. **"Key not trusted"**:

   - GPG setup script handles trust automatically

   - Check machine user has uploaded public key to GitHub

### Debug Commands

```bash

# In workflow, add debug step

- name: Debug GPG

  run: |
    gpg --list-keys
    git config --get user.signingkey
    git config --get commit.gpgsign

```

## Maintenance Schedule

### Regular Tasks

- **Monthly**: Monitor bot commit signatures

- **Quarterly**: Rotate PMBOT_PAT (90-day expiry)

- **Annually**: Review and audit machine user permissions

- **Bi-annually**: Prepare for GPG key rotation (before expiry)

### Key Rotation (Every 2 Years)

1. Generate new GPG key pair

2. Update GitHub Actions secrets

3. Add new public key to machine user account

4. Test in staging environment

5. Remove old public key after verification

6. Update offline revocation certificate storage

## Security Incident Response

### If GPG Key is Compromised

1. **Immediate Actions**:

   - Revoke compromised key using offline revocation certificate

   - Remove public key from machine user account

   - Disable/rotate all associated secrets

2. **Recovery**:

   - Generate new GPG key pair

   - Update all secrets with new key

   - Test workflow operation

   - Document incident and improvements

### If Machine User is Compromised

1. **Immediate Actions**:

   - Disable machine user account

   - Revoke all associated tokens/keys

   - Review recent commits for unauthorized changes

2. **Recovery**:

   - Create new machine user account

   - Generate new GPG key pair and tokens

   - Reconfigure all secrets

   - Implement additional monitoring

---

*This setup ensures DevOnboarder's Priority Matrix Bot maintains "quiet reliability" while meeting branch protection requirements.*
