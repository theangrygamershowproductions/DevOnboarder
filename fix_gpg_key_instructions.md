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

## Recent Testing

- ✅ Environment Secrets approach tested - still experiencing libcrypto errors
- ✅ SSH key validates perfectly in local environment
- 🔄 Investigating workflow-level secret processing methods

If all checklist items pass and errors persist, the issue is likely in how the workflow processes multi-line secrets rather than the secret content itself.
