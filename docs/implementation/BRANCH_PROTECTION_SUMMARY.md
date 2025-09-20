---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: implementation-implementation
status: active
tags:

- documentation

title: Branch Protection Summary
updated_at: '2025-09-12'
visibility: internal
---

# Branch Protection Summary for DevOnboarder

## Protected Branches

The following branches are now protected across all cleanup scripts and will **NEVER** be automatically deleted:

### Core Protected Branches

- `main` - Primary development branch

- `dev` - Development integration branch

- `staging` - Staging environment branch

- `HEAD` - Git reference pointer

### Special Protected Branches

- `feat/potato-ignore-policy-focused` - **Protected for massive CI fixes**

## Protection Implementation

Branch protection has been implemented across all cleanup utilities:

### 1. Comprehensive Branch Cleanup (`scripts/comprehensive_branch_cleanup.sh`)

- **Protected Array**: `PROTECTED_BRANCHES=("main" "dev" "staging" "HEAD" "feat/potato-ignore-policy-focused")`

- **Function**: `is_protected_branch()` checks against this array

- **Behavior**: Protected branches are marked as 🔒 and skipped from all deletion operations

### 2. Manual Branch Cleanup (`scripts/manual_branch_cleanup.sh`)

- **Merged Branch Filter**: Excludes `feat/potato-ignore-policy-focused` from deletion candidates

- **Stale Branch Analysis**: Excludes from both local and remote stale branch reports

- **Interactive Safety**: Won't offer protected branches for deletion

### 3. Automated Cleanup (`scripts/cleanup_branches.sh`)

- **Branch Loop Filter**: `[[ "$b" == "feat/potato-ignore-policy-focused" ]] && continue`

- **Remote Protection**: Prevents deletion of remote `feat/potato-ignore-policy-focused` branch

- **Nightly Workflow**: Protection applies to automated nightly cleanup

### 4. Quick Cleanup (`scripts/quick_branch_cleanup.sh`)

- **Merged Filter**: `grep -v "feat/potato-ignore-policy-focused"`

- **Interactive Protection**: Won't list protected branch as deletion candidate

### 5. Documentation (`BRANCH_CLEANUP_ANALYSIS.md`)

- **Command Examples**: Updated to exclude protected branches

- **Safe Commands**: All suggested cleanup commands now protect the special branch

## Verification Commands

To verify branch protection is working:

```bash

# Test comprehensive cleanup (dry run)

DRY_RUN=true ./scripts/comprehensive_branch_cleanup.sh

# Test manual cleanup (will show protected status)

./scripts/manual_branch_cleanup.sh

# Test automated cleanup (dry run)

DRY_RUN=true ./scripts/cleanup_branches.sh

# Check if branch exists and is protected

git branch | grep "feat/potato-ignore-policy-focused" || echo "Branch not found locally"
git branch -r | grep "feat/potato-ignore-policy-focused" || echo "Branch not found remotely"

```

## Safety Guarantees

1. **Multiple Layers**: Protection implemented across all cleanup tools

2. **Explicit Exclusion**: Branch name explicitly excluded from filters

3. **Interactive Confirmation**: Manual tools won't offer protected branches for deletion

4. **Dry Run Testing**: All tools support dry-run mode for safe testing

5. **Documentation**: Commands in documentation exclude protected branches

## Creating the Protected Branch

If the `feat/potato-ignore-policy-focused` branch doesn't exist yet, create it with:

```bash

# Create the branch for CI fixes

git checkout -b feat/potato-ignore-policy-focused

# Push to remote to establish it

git push -u origin feat/potato-ignore-policy-focused

```

## CI Integration

The branch protection is integrated with:

- **Nightly Cleanup Workflow**: `.github/workflows/branch-cleanup.yml`

- **CI Pipeline**: Will respect protection during automated cleanup

- **Manual Triggers**: Protection applies to manual cleanup triggers

This ensures that the `feat/potato-ignore-policy-focused` branch will remain safe for massive CI fixes and won't be accidentally deleted by any automated or manual cleanup operations.
