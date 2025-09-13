---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: reports-reports
status: active
tags:
- documentation
title: Branch Cleanup Analysis
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder Branch Cleanup Analysis

## Current Situation

Based on analysis of `.git/refs/`, we have the following branches:

### Local Branches

- `main` (current, protected)

- `clean-bootstrapping`

- `feat/scope-alignment-clarification` (recently created)

- `fix/potato-md-ignore-docs`

### Remote Branches (on origin)

- `main` (protected)

- `clean-bootstrapping`

- `alert-autofix-1`

- `a30joe-codex/add-fastapi-endpoints-for-feedback`

- `codex/add-fastapi-endpoints-for-feedback`

- `codex/add-step-to-check-python-dependencies-in-ci`

- `codex/create-bot-permissions.yaml-configuration`

- `codex/create-qa-checklist-markdown-and-command-module`

- `codex/modify-security-audit-script-and-documentation`

- `codex/update-eslint-and-typescript-versions`

- `codex/verify-github-actions-workflow-success`

- `docs/update-discord-bot-documentation`

- `hpehw1-codex/create-qa-checklist-markdown-and-command-module`

## Recommended Actions

### Immediate Cleanup Candidates

**High Priority (likely merged):**

- `codex/*` branches - These appear to be from automated Codex contributions that should be cleaned up

- `alert-autofix-1` - Likely an automated fix that has been merged

- `a30joe-codex/*` and `hpehw1-codex/*` - User-specific Codex branches

**Review Required:**

- `clean-bootstrapping` - Check if this work is complete and merged

- `fix/potato-md-ignore-docs` - Verify if this fix has been applied

**Keep:**

- `feat/scope-alignment-clarification` - Recently created, current work

- `feat/potato-ignore-policy-focused` - Protected branch for massive CI fixes

- `main` - Protected base branch

### Safe Cleanup Commands

To safely clean up the obvious candidates, run these commands:

```bash

# Switch to main branch

git checkout main

# Fetch latest and prune deleted remote branches

git fetch origin --prune

# Check which branches are merged (safe to delete)

git branch --merged main

# Delete merged local branches (exclude protected branches)

git branch --merged main | grep -v "main" | grep -v "^\*" | grep -v "feat/potato-ignore-policy-focused" | xargs -r git branch -d

# For remote cleanup, check what's been merged to main

git branch -r --merged origin/main

# Delete specific remote branches that are clearly stale

# (Run these one at a time and verify each)

git push origin --delete codex/add-fastapi-endpoints-for-feedback
git push origin --delete codex/add-step-to-check-python-dependencies-in-ci
git push origin --delete codex/create-bot-permissions.yaml-configuration
git push origin --delete codex/create-qa-checklist-markdown-and-command-module
git push origin --delete codex/modify-security-audit-script-and-documentation
git push origin --delete codex/update-eslint-and-typescript-versions
git push origin --delete codex/verify-github-actions-workflow-success
git push origin --delete a30joe-codex/add-fastapi-endpoints-for-feedback
git push origin --delete hpehw1-codex/create-qa-checklist-markdown-and-command-module
git push origin --delete docs/update-discord-bot-documentation
git push origin --delete alert-autofix-1

```

### Automated Cleanup

The project already has automated branch cleanup configured:

1. **GitHub Actions Workflow**: `.github/workflows/branch-cleanup.yml`

2. **Cleanup Script**: `scripts/cleanup_branches.sh`

3. **Manual Tools**: `scripts/manual_branch_cleanup.sh` and `scripts/comprehensive_branch_cleanup.sh`

To trigger automated cleanup:

```bash

# Run existing cleanup script in dry-run mode

DRY_RUN=true bash scripts/cleanup_branches.sh

# Run actual cleanup

DRY_RUN=false bash scripts/cleanup_branches.sh

```

### Prevention Strategy

1. **Enable automatic branch deletion** in GitHub repository settings

2. **Use the existing branch-cleanup workflow** which runs nightly

3. **Add branch protection rules** for important branches

4. **Educate contributors** to delete feature branches after merging

## Next Steps

1. **Immediate**: Run the safe cleanup commands above to remove obvious stale branches

2. **Review**: Check `clean-bootstrapping` and `fix/potato-md-ignore-docs` branches for completion status

3. **Automate**: Ensure the nightly branch cleanup workflow is enabled

4. **Monitor**: Set up alerts for excessive branch accumulation

This cleanup will significantly reduce the branch clutter while maintaining safety for active development work.
