---
author: DevOnboarder Security Team
consolidation_priority: P2
content_uniqueness_score: 4
created_at: '2025-10-12'
description: Tier 3 maintainer procedures for secure external PR handling with manual intervention capabilities
document_type: procedures
merge_candidate: false
project: DevOnboarder
similarity_group: external-pr-security
status: active
tags:
- security
- procedures
- external-pr
- maintainer
title: External PR Security - Tier 3 Maintainer Procedures
updated_at: '2025-10-12'
visibility: internal
version: 1.0
---

# External PR Security - Tier 3 Maintainer Procedures

## Goal & Context

**Primary Goal**: Provide secure manual intervention procedures for external pull requests requiring maintainer privileges while maintaining audit trails and security controls.

**Business Context**: External contributors cannot trigger certain automated workflows due to GitHub's fork restrictions. Tier 3 procedures enable maintainers to safely perform necessary actions while maintaining security and compliance.

**Technical Context**: Leverages GitHub CLI with personal access tokens for authenticated operations, ensuring all actions are traceable and auditable.

## Requirements & Constraints

**Security Requirements**:
- All actions must use personal access tokens, never repository secrets
- Audit trail must be maintained for all manual interventions
- Token scopes must be minimal necessary for the operation
- Actions must be logged with timestamps and operator identification

**Operational Constraints**:
- Manual procedures only when automation fails
- Must verify PR legitimacy before intervention
- Cannot bypass core security validations
- Must follow established approval workflows

## Use Cases

### Manual PR Commenting
**Actor**: Repository Maintainer
**Goal**: Comment on external PR when automation cannot
**Steps**:
1. Verify PR validation status
2. Authenticate with personal token
3. Post appropriate comment
4. Log the manual intervention

### Workflow Dispatch Override
**Actor**: Repository Admin
**Goal**: Manually trigger workflows for external PRs
**Steps**:
1. Confirm PR meets dispatch criteria
2. Use personal token for authentication
3. Dispatch workflow with proper parameters
4. Document the override reason

## Dependencies

**Required Tools**:
- GitHub CLI (`gh`) - Command-line interface for GitHub operations
- Personal Access Token - For authenticated operations
- Terminal access - For command execution
- Repository maintainer permissions - For privileged operations

**System Requirements**:
- GitHub CLI version 2.0+
- Valid personal access token with required scopes
- Network access to GitHub API
- Terminal environment with bash support

## Overview

Tier 3 procedures provide manual maintainer intervention capabilities for external pull requests that require privileged operations or human judgment. These procedures ensure security while enabling necessary maintainer actions for legitimate external contributions.

## Security Context

**Tier 3 - Maintainer Override Zone**
- Full repository permissions available
- Manual workflow dispatch allowed
- Personal access tokens required for external communication
- Audit trail mandatory for all actions

## Prerequisites

### Required Permissions
- Repository maintainer or admin access
- Personal Access Token (PAT) with appropriate scopes:
  - `repo` (full repository access)
  - `workflow` (workflow management)
  - `issues` (issue management)
  - `pull_requests` (PR management)

### Environment Setup
```bash
# Set your personal access token securely
export GH_TOKEN="your_personal_access_token_here"

# Verify authentication
gh auth status
```

## Common External PR Scenarios

### Scenario 1: Manual PR Comment (Cannot Auto-Comment)

**Problem**: External PR validation completed but cannot automatically comment due to fork restrictions.

**Solution**:
```bash
# Comment on external PR using personal token
gh pr comment 123 \
  --body "✅ Validation passed! Your code looks good. We'll review and merge shortly."

# Alternative: View PR details first
gh pr view 123 --json title,author
```

### Scenario 2: Manual Workflow Dispatch

**Problem**: Need to trigger privileged workflow for external PR processing.

**Solution**:
```bash
# Dispatch workflow manually for external PR
gh workflow run "External PR Privileged Operations" \
  -f ref="refs/pull/123/head" \
  -f pr_number="123"

# Check workflow run status
gh run list --workflow="External PR Privileged Operations" --limit 5
```

### Scenario 3: Emergency Auto-Fix Application

**Problem**: External PR has fixable issues but cannot auto-fix due to fork restrictions.

**Procedure**:
```bash
# 1. Checkout the external PR locally
gh pr checkout 123
git checkout -b fix-external-pr-123

# 2. Apply fixes manually
# Edit files as needed...

# 3. Commit and push fixes
git add .
git commit -m "FIX: Address validation issues in external PR #123"
git push origin fix-external-pr-123

# 4. Create comment with fix details
gh pr comment 123 \
  --body "I've applied fixes for the validation issues. Please review the changes in branch 'fix-external-pr-123'."

# 5. Close temporary branch after merge
git branch -d fix-external-pr-123
```

### Scenario 4: Security Review Override

**Problem**: External PR passes automated validation but requires security review.

**Procedure**:
```bash
# 1. Review PR security implications
gh pr view 123 --json files,author,reviews

# 2. Check for security-related files
gh pr diff 123 | grep -E "\.(key|pem|env|secret)"

# 3. Add security review label
gh pr edit 123 --add-label "security-reviewed"

# 4. Approve and merge if appropriate
gh pr review 123 --approve --body "Security review completed. Approved for merge."
gh pr merge 123 --squash --delete-branch
```

### Scenario 5: Tracking Issue Management

**Problem**: Need to update or close tracking issues for external PRs.

**Procedure**:
```bash
# Find tracking issue for PR
gh issue list --label "external-pr-tracking" --search "PR #123"

# Update tracking issue
gh issue comment ISSUE_NUMBER \
  --body "✅ Code review completed. ✅ Security review passed. Ready for merge."

# Close tracking issue after merge
gh issue close ISSUE_NUMBER \
  --reason "completed" \
  --comment "External PR #123 successfully merged."
```

## Advanced Procedures

### Batch Processing Multiple External PRs

```bash
# List all open external PRs
gh pr list --json number,title,author --jq '.[] | select(.author.type == "User") | "\(.number): \(.title) by @\(.author.login)"'

# Process multiple PRs
for pr in 123 124 125; do
  echo "Processing PR #$pr..."
  gh pr comment "$pr" --body "Batch processing: Validation in progress..."
done
```

### Emergency Security Response

**For Critical Security Issues in External PRs:**

```bash
# 1. Immediately block the PR
gh pr edit PR_NUMBER --add-label "security-blocked"

# 2. Create security incident issue
gh issue create \
  --title "🚨 SECURITY: External PR #PR_NUMBER Contains Sensitive Data" \
  --body "External PR #PR_NUMBER has been blocked due to security concerns." \
  --label "security-incident,external-pr"

# 3. Notify security team
gh issue comment ISSUE_NUMBER \
  --body "@security-team Please review external PR #PR_NUMBER immediately."

# 4. Log security action
echo "$(date): SECURITY BLOCK - External PR #PR_NUMBER" >> security_audit.log
```

### Fork Repository Analysis

**When Investigating Suspicious External PRs:**

```bash
# Get detailed PR information
gh pr view PR_NUMBER --json headRepository,author,commits,reviews

# Check fork repository
FORK_REPO=$(gh pr view PR_NUMBER --json headRepository --jq '.headRepository.nameWithOwner')
gh repo view "$FORK_REPO" --json createdAt,updatedAt,forkCount

# Analyze commit history
gh pr view PR_NUMBER --json commits --jq '.commits[].oid' | \
  xargs -I {} gh api repos/$FORK_REPO/commits/{} --jq '.commit.message'
```

## Audit Trail Requirements

### Mandatory Logging

All Tier 3 interventions must be logged:

```bash
# Log maintainer actions
log_entry() {
    local pr_number="$1"
    local action="$2"
    local details="$3"

    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ"): EXTERNAL-PR-$pr_number: $action: $details" >> maintainer_actions.log

    # Also log to GitHub issue if tracking
    gh issue comment TRACKING_ISSUE \
      --body "**Maintainer Action Logged**: $action - $details"
}
```

### Usage Examples:
```bash
log_entry "123" "COMMENT" "Posted validation results to external PR"
log_entry "124" "MERGE" "Manually merged after security review"
log_entry "125" "BLOCK" "Security violation detected - PR blocked"
```

## Error Handling

### Common Issues and Solutions

#### Issue: Authentication Failed
```bash
# Check token status
gh auth status

# Refresh token if needed
gh auth login

# Verify token scopes
gh auth token
```

#### Issue: Permission Denied
```bash
# Check repository permissions
gh repo view --json viewerPermission

# Verify token has required scopes
# Go to https://github.com/settings/tokens and check scopes
```

#### Issue: Workflow Dispatch Failed
```bash
# Check workflow exists and is properly configured
gh workflow list | grep "External PR"

# Verify workflow file syntax
gh workflow run "External PR Privileged Operations" --list-inputs
```

## Security Best Practices

### Token Management
- **Never expose tokens** in logs or comments
- **Rotate tokens regularly** (recommended: monthly)
- **Use minimum required scopes** for each operation
- **Store tokens securely** (system keyring or secure environment)

### Communication Guidelines
- **Be professional** in all external communications
- **Provide clear guidance** on next steps
- **Reference documentation** when possible
- **Maintain audit trail** of all interactions

### Risk Assessment
- **Always assess security implications** before manual actions
- **Err on the side of caution** for suspicious external PRs
- **Escalate to security team** for high-risk scenarios
- **Document security decisions** for future reference

## Emergency Contacts

- **Security Team**: @tags-devsecops
- **DevOnboarder Maintainers**: @theangrygamershowproductions/maintainers
- **Infrastructure Team**: @theangrygamershowproductions/infrastructure

## Quick Reference Commands

```bash
# View external PR
gh pr view PR_NUMBER

# Comment on external PR
gh pr comment PR_NUMBER --body "MESSAGE"

# Merge external PR (after approval)
gh pr merge PR_NUMBER --squash --delete-branch

# Dispatch privileged workflow
gh workflow run "External PR Privileged Operations" -f pr_number=PR_NUMBER

# Check workflow status
gh run list --workflow="External PR Privileged Operations" --limit 3

# Log maintainer action
echo "$(date): ACTION - PR #PR_NUMBER: DESCRIPTION" >> maintainer_actions.log
```

---

**Last Updated**: October 12, 2025
**Security Level**: Tier 3 - Maintainer Override
**Audience**: Repository maintainers and security team
**Related Documentation**:
- [External PR Security Guide](EXTERNAL_PR_SECURITY_GUIDE.md)
- [DevOnboarder Security Standards](../WORKFLOW_SECURITY_STANDARDS.md)