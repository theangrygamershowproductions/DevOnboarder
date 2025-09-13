---
consolidation_priority: P3
content_uniqueness_score: 4
merge_candidate: false
similarity_group: troubleshooting-troubleshooting
---

# CI Issue Automation Token Failures

## Overview

The DevOnboarder project uses Token Architecture v2.1 with a hierarchy of GitHub tokens for automated issue creation and management. This document covers common token-related failures and their resolution.

## Token Hierarchy

DevOnboarder follows this token priority order:

1. **CI_ISSUE_AUTOMATION_TOKEN** (preferred) - Fine-grained token for issue operations

2. **CI_BOT_TOKEN** (fallback) - General CI automation token

3. **GITHUB_TOKEN** (default) - GitHub Actions default token

## Common Failures

### HTTP 401: Bad Credentials

**Symptom**:

```text
Failed to create GitHub issue
Error: HTTP 401: Bad credentials (https://api.github.com/graphql)
Try authenticating with:  gh auth login

```

**Root Causes**:

1. **Token Expiration**: Fine-grained tokens expire and need renewal

2. **Invalid Token Format**: Token corrupted or incorrectly stored

3. **Insufficient Permissions**: Token lacks required repository permissions

4. **Token Revocation**: Token was manually revoked or regenerated

**Resolution Steps**:

1. **Check Token Status**:

   ```bash
   # Validate token architecture

   bash scripts/validate_token_architecture.sh

   # Check token permissions

   bash scripts/check_classic_token_scopes.sh
   ```

2. **Regenerate Expired Tokens**:

   - Go to GitHub Settings > Personal Access Tokens

   - Regenerate CI_ISSUE_AUTOMATION_TOKEN

   - Update repository secrets with new token

3. **Verify Token Permissions**:

   Required scopes for CI_ISSUE_AUTOMATION_TOKEN:
   - `issues: write` (create, close, comment on issues)

   - `metadata: read` (access repository metadata)

   - `pull_requests: read` (access PR information)

### Token Loading Failures

**Symptom**:

```text
Token environment loaded successfully
[timestamp] ERROR: Failed to create issue

```

**Root Cause**: Token loaded successfully but lacks required permissions.

**Resolution**: Verify token has correct repository access and permissions.

### Workflow Dispatch Token Issues

**Symptom**: Manual workflow dispatch fails with authentication errors.

**Root Cause**: Workflow dispatch requires different token permissions than PR-triggered events.

**Resolution**: Ensure CI_ISSUE_AUTOMATION_TOKEN has `actions: read` permission.

## Diagnostic Commands

```bash

# Full token architecture validation

bash scripts/validate_token_architecture.sh

# Generate token audit report

bash scripts/generate_token_audit_report.sh

# Check classic token scopes

bash scripts/check_classic_token_scopes.sh

```

## Prevention

1. **Regular Token Rotation**: Set calendar reminders for token renewal

2. **Monitoring**: Token validation runs on every CI execution

3. **Fallback Strategy**: Multiple tokens provide redundancy

4. **Documentation**: Keep token permissions documented and current

## Related Workflows

- `.github/workflows/pr-issue-automation.yml` - Primary consumer

- `.github/workflows/create-pr-tracking-issue.yml` - Issue creation automation

- `scripts/create_pr_tracking_issue.sh` - Core issue creation logic

## Emergency Recovery

If all tokens fail:

1. **Immediate**: Disable PR Issue Automation workflow temporarily

2. **Short-term**: Use GITHUB_TOKEN for basic operations

3. **Long-term**: Generate new fine-grained tokens with proper permissions
