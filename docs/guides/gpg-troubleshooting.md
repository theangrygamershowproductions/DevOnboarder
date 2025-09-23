---
similarity_group: guides-guides
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# GPG Signing Troubleshooting Guide

This guide helps diagnose and resolve common issues with GPG signing in DevOnboarder automated workflows.

## Quick Diagnostics

### Check GPG Key Status

```bash

# List all GPG keys

gpg --list-keys

# List secret keys (should include your bot's key)

gpg --list-secret-keys

# Check specific key details

gpg --list-keys {KEY_ID}
```bash

## Verify Git Configuration

```bash

# Check git GPG configuration

git config --list | grep -E "(user\.|gpg\.|commit\.)"

# Should show

# user.name=Your Bot Name

# user.email=your-bot@theangrygamershow.com

# user.signingkey={YOUR_KEY_ID}

# commit.gpgsign=true

# gpg.format=openpgp

```bash

## Test GPG Signing

```bash

# Test GPG signing manually

git commit --allow-empty -m "Test GPG signing" -S

# Verify the signature

git log --show-signature -1
```bash

## Common Issues and Solutions

### Issue: "gpg: signing failed: No secret key"

**Cause**: GPG private key not properly imported or configured.

**Solution**:

```bash

# Re-import the GPG private key

echo "$BOT_GPG_PRIVATE" | base64 -d | gpg --batch --import --quiet

# Verify key was imported

gpg --list-secret-keys

# Set trust level

echo -e "5\ny\n" | gpg --batch --command-fd 0 --expert --edit-key "$BOT_GPG_KEY_ID" trust quit
```bash

## Issue: "gpg: signing failed: Bad passphrase"

**Cause**: GPG key was created with a passphrase, but automation requires passphrase-free keys.

**Solution**: Regenerate the GPG key without a passphrase using the setup script:

```bash
bash scripts/setup_bot_gpg_key.sh
```bash

The script uses `%no-protection` to create passphrase-free keys for automation.

### Issue: "error: gpg failed to sign the data"

**Cause**: GPG configuration or environment issues.

**Solutions**:

```bash

# Check GPG agent status

echo "test" | gpg --clearsign

# Restart GPG agent if needed

gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

# Set GPG_TTY for terminal

export GPG_TTY=$(tty)

# Verify git configuration

git config --global gpg.format openpgp
git config --global user.signingkey "$BOT_GPG_KEY_ID"
```bash

## Issue: "Permission denied" during GitHub push

**Cause**: Insufficient token permissions or incorrect token hierarchy.

**Solution**: Verify token configuration in workflow:

```yaml

- name: Checkout repository

  uses: actions/checkout@v5
  with:
    token: ${{ secrets.CI_ISSUE_AUTOMATION_TOKEN || secrets.CI_BOT_TOKEN || secrets.GITHUB_TOKEN }}
```bash

Token hierarchy (from most to least privileged):
1. `CI_ISSUE_AUTOMATION_TOKEN` - Full repository access
2. `CI_BOT_TOKEN` - Standard bot operations
3. `GITHUB_TOKEN` - Basic workflow operations

### Issue: Commits show as unverified on GitHub

**Cause**: GPG public key not uploaded to GitHub or email mismatch.

**Solution**:

1. **Upload public key to GitHub**:

   ```bash
   # Export public key
   gpg --armor --export $BOT_GPG_KEY_ID

   # Copy output and paste at: https://github.com/settings/keys
   # Choose "GPG keys" section
```bash

1. **Verify email matches**:

   - GPG key email must match git commit email
   - Both must be associated with the GitHub account

### Issue: "fatal: could not read Username for 'https://github.com'"

**Cause**: Missing or incorrect authentication token in workflow.

**Solution**: Ensure proper token configuration:

```yaml

- name: Checkout repository

  uses: actions/checkout@v5
  with:
    fetch-depth: 0
    token: ${{ secrets.CI_ISSUE_AUTOMATION_TOKEN || secrets.CI_BOT_TOKEN || secrets.GITHUB_TOKEN }}
```bash

### Issue: Workflow runs but no commits are made

**Cause**: No changes detected or staging issues.

**Debug Steps**:

```bash

# Add debugging to your workflow

- name: Debug git status

  run: |
    echo "Git status before changes:"
    git status --porcelain

    echo "Git status after automation:"
    git status --porcelain

    echo "Staged changes:"
    git diff --cached --name-only
```bash

**Common fixes**:

- Ensure files are properly staged: `git add path/to/files`
- Check if changes were actually made by your automation
- Verify file paths in staging commands

## Issue: "gpg: can't connect to the agent: IPC connect call failed"

**Cause**: GPG agent not running or communication issues.

**Solution**:

```bash

# In your workflow, ensure proper GPG setup

- name: Setup GPG environment

  run: |
    # Kill any existing agent
    gpgconf --kill gpg-agent || true

    # Start fresh agent
    gpgconf --launch gpg-agent

    # Import key
    echo "$BOT_GPG_PRIVATE" | base64 -d | gpg --batch --import --quiet
```bash

## Validation Checklist

Use this checklist to verify your GPG setup is working correctly:

### Local Validation

- [ ] GPG key generated successfully without passphrase
- [ ] Private key exported and base64-encoded
- [ ] Public key uploaded to GitHub account
- [ ] Git configuration set correctly
- [ ] Manual commit signing works: `git commit -S -m "test"`
- [ ] Signature verification works: `git log --show-signature -1`

### GitHub Secrets/Variables Validation

- [ ] `{BOT_NAME}_GPG_PRIVATE` secret added to repository
- [ ] `{BOT_NAME}_GPG_KEY_ID` variable added to repository
- [ ] `{BOT_NAME}_NAME` variable matches GPG key name
- [ ] `{BOT_NAME}_EMAIL` variable matches GPG key email
- [ ] Token hierarchy configured in workflow checkout

### Workflow Validation

- [ ] GPG setup step imports key successfully
- [ ] Git configuration step completes without errors
- [ ] Commit step creates signed commits
- [ ] Push step succeeds with proper permissions
- [ ] GitHub shows commits as "Verified"

## Advanced Debugging

### Enable Verbose GPG Logging

Add to your workflow for detailed GPG debugging:

```yaml

- name: Debug GPG setup

  run: |
    # Enable verbose GPG output
    export GPG_VERBOSE=1

    # Show detailed key information
    gpg --list-keys --with-colons --with-fingerprint

    # Test signing with verbose output
    echo "test" | gpg --verbose --clearsign
```bash

### Monitor Git Operations

Add git debugging to your workflow:

```yaml

- name: Debug git operations

  run: |
    # Enable git debugging
    export GIT_TRACE=1
    export GIT_CURL_VERBOSE=1

    # Show git configuration
    git config --list --show-origin

    # Test commit with debugging
    git commit --dry-run -m "test commit"
```bash

### Check GitHub API Limits

If pushes fail intermittently:

```bash

# Check API rate limits

curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit
```bash

## Getting Help

If you're still experiencing issues:

1. **Review working examples**: Study `priority-matrix-synthesis.yml` workflow
2. **Check DevOnboarder logs**: Review CI logs for detailed error messages
3. **Validate with QC tools**: Run `scripts/qc_pre_push.sh` to check for issues
4. **Test locally first**: Always test GPG setup on local machine before CI
5. **Create minimal repro**: Test with simplified workflow to isolate issues

## Prevention Best Practices

### Key Management

- Always use passphrase-free keys for automation
- Store private keys securely in GitHub secrets
- Rotate keys periodically (document the process)
- Never commit private keys to repository

### Workflow Design

- Include proper error handling and fallback notifications
- Use token hierarchy for authentication
- Validate GPG setup before attempting commits
- Include debugging steps for troubleshooting

### Testing Strategy

- Test GPG setup locally before deploying workflows
- Use test branches for workflow validation
- Monitor workflow runs after deployment
- Validate commits show as verified on GitHub

---

**Last Updated**: September 22, 2025
**Version**: 1.0
**Related**: Adding Automated Workflows Guide, Token Architecture v2.1
