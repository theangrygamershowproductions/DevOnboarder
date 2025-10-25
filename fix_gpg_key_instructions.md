---
similarity_group: docs-

content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---

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

ssh-keygen -t ed25519 -C "botpriority-matrix@theangrygamershow.com" -f pmbot_key -N ""

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

## Advanced Troubleshooting: Environment vs Repository Secrets

If your SSH key secret is set both in Environment Secrets and Repository Secrets, but your job is still failing with "Invalid SSH private key format", check these common issues:

### 1. Secret Precedence & Access

GitHub Actions precedence: Environment > Repository > Organization

**Critical Requirements**:

- Workflow must explicitly specify the environment:

  ```yaml
  jobs:
    priority-matrix-synthesis:
      environment: CI  # Must match your Environment name

  ```

- Secret names are case-sensitive and must match exactly

### 2. Correct Secret Reference

Verify your workflow references secrets correctly:

```yaml
env:
  PMBOT_SSH_PRIVATE: ${{ secrets.PMBOT_SSH_PRIVATE }}

```

### 3. Secret Content Validation

Common format issues:

- Missing header: `-----BEGIN OPENSSH PRIVATE KEY-----`

- Missing footer: `-----END OPENSSH PRIVATE KEY-----`

- Extra spaces or incorrect line breaks

- Copy-paste truncation

### 4. Workflow Security Context

Secrets are blocked in these scenarios:

- Pull requests from forks

- Workflows without proper environment specification

- Branch restrictions on secrets

### 5. Environment Override Verification

Environment secrets only override Repository secrets when:

- Workflow specifies the correct environment name

- Environment is not restricted to specific branches/workflows

## Summary Checklist

- [ ] Workflow explicitly uses correct environment (`environment: CI`)

- [ ] Secret names match exactly in workflow and GitHub UI

- [ ] Secret content includes proper OpenSSH headers/footers

- [ ] Workflow runs in authorized context (not fork PR)

- [ ] Environment secrets not restricted to specific branches

## SOLUTION FOUND: Base64 Encoding Required

**Root Cause Identified**: Shell variable corruption of binary SSH key data

**Problem**: SSH keys contain binary data that gets corrupted when stored in shell variables, even with proper `printf '%s\n'` handling.

**Solution**: Use base64 encoding to safely pass SSH keys through GitHub Secrets and shell processing.

### Updated GitHub Secret Setup

1. **Generate base64-encoded key**:

   ```bash
   base64 -w 0 ~/.devonboarder-keys/pmbot_ed25519
   ```

2. **Update GitHub Secret**:

   - Go to: <https://github.com/theangrygamershowproductions/DevOnboarder/settings/secrets/actions>

   - Edit secret: `PMBOT_SSH_PRIVATE`

   - Value: `LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0K...` (base64 string)

3. **Workflow decodes it safely**:

   ```bash
   echo "$PMBOT_SSH_PRIVATE" | base64 -d > ~/.ssh/ci_signing_key
   ```

### Testing Results

-  Direct file copy: VALID SSH key

-  Shell variable method: CORRUPTED (previous approach)

-  Base64 encoding/decoding: Preserves binary data integrity

### Implementation Status

-  Workflow updated to use base64 decoding

-  Base64-encoded secret content generated

- SYNC: GitHub Secret updated - testing base64 decode validation

- SYNC: Ready for GitHub Secret update and testing

This approach eliminates shell variable corruption while maintaining DevOnboarder Terminal Output Policy compliance.
