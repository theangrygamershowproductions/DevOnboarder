---
similarity_group: guides-guides
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# Priority Matrix Bot SSH Key Setup Guide

## Overview

This guide configures the `scarabofthespudhead` GitHub account for automated Priority Matrix Bot commits with verified SSH signatures.

## Configuration Steps

### 1. Extract SSH Public Key

The bot's SSH private key is stored in GitHub secrets as `PMBOT_SSH_PRIVATE`. To get the public key:

#### Option A: Via Workflow (Recommended)

```bash
# Run the extraction workflow
gh workflow run extract-bot-ssh-key.yml

# Check workflow output
gh run list --workflow=extract-bot-ssh-key.yml --limit=1
gh run view <run-id> --log
```

#### Option B: Manual Extraction (if you have the private key)

```bash
# If private key is available locally
echo "$PMBOT_SSH_PRIVATE" | ssh-keygen -y -f /dev/stdin
```

### 2. Upload SSH Key to scarabofthespudhead Account

1. **Switch to scarabofthespudhead account**:
   - Log out of current GitHub account
   - Log in as `scarabofthespudhead`
   - Navigate to: Settings → SSH and GPG keys

2. **Add SSH Key**:
   - Click "New SSH key"
   - Title: "Priority Matrix Bot - DevOnboarder"
   - Key type: Authentication key
   - Paste the public key from Step 1

3. **Verify Configuration**:
   - Email associated: `developer@theangrygamershow.com`
   - Account: `scarabofthespudhead`
   - Repository access: Ensure account has access to DevOnboarder

### 3. Update Bot Configuration

The following variables are already configured:

```yaml
PMBOT_NAME: "Priority Matrix Bot"
PMBOT_EMAIL: "developer@theangrygamershow.com"
```

### 4. Test Signature Verification

After configuration, trigger the Priority Matrix Bot workflow:

```bash
# Check recent bot commits for verification status
gh api repos/theangrygamershowproductions/DevOnboarder/commits \
  --jq '.[] | select(.commit.author.name == "Priority Matrix Bot") | {sha: .sha, verified: .commit.verification.verified, reason: .commit.verification.reason}'
```

## Expected Results

### Before Configuration

```json
{
  "sha": "60de2890...",
  "verified": false,
  "reason": "no_user"
}
```

### After Configuration

```json
{
  "sha": "new-commit...",
  "verified": true,
  "reason": "valid"
}
```

## Troubleshooting

### SSH Key Not Associated

- **Issue**: `"reason": "no_user"`
- **Solution**: Ensure SSH public key is uploaded to scarabofthespudhead account

### Wrong Email Association

- **Issue**: Bot commits show different email
- **Solution**: Verify `PMBOT_EMAIL` variable matches GitHub account email

### Account Access Issues

- **Issue**: Bot cannot push to repository
- **Solution**: Ensure scarabofthespudhead has write access to DevOnboarder

## Verification Commands

```bash
# Check bot configuration
gh variable list | grep PMBOT

# Monitor Priority Matrix workflow runs
gh run list --workflow=priority-matrix-synthesis.yml --limit=5

# Verify signature status
gh api repos/theangrygamershowproductions/DevOnboarder/commits \
  --jq '.[] | select(.commit.author.name == "Priority Matrix Bot") | {sha: .sha[0:8], date: .commit.author.date, verified: .commit.verification.verified}'
```

## Security Notes

- SSH private key remains secure in GitHub secrets
- Only public key is uploaded to GitHub account
- Bot commits are cryptographically signed
- Audit trail maintained through verified signatures

## Related Files

- `.github/workflows/priority-matrix-synthesis.yml` - Bot workflow
- `.github/workflows/extract-bot-ssh-key.yml` - Key extraction
- `scripts/extract_bot_ssh_key.sh` - Local key management
