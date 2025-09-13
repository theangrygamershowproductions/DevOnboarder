---
author: DevOnboarder Team
codex-agent:
  name: Agent.BranchCleanup
  output: Deleted branch log
  role: Deletes stale merged branches
  scope: repository maintenance
  triggers: Nightly schedule or `codex:cleanup` label
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: core-agents
similarity_group: documentation-documentation
status: active
tags:
- documentation
title: Branch Cleanup
updated_at: '2025-09-12'
visibility: internal
---

# Branch Cleanup Agent

**Status:** Proposed.

**Purpose:** Remove merged branches that haven't been updated in the last 30 days.

This keeps the remote namespace tidy and prevents confusion over old feature
branches.

**Inputs:**

- Remote git history

- Environment variables controlling branch selection

**Outputs:**

- Log of deleted branches or a dry-run summary

**Environment:**

- `DRY_RUN` – when `true`, list branches without deleting (default `true`)

- `BASE_BRANCH` – branch used to check merge status (default `main`)

- `DAYS_STALE` – age threshold in days before deletion (default `30`)

**Workflow:**
The nightly workflow runs `scripts/cleanup_branches.sh`. Maintainers can also

trigger it by adding the `codex:cleanup` label to an issue or pull request.
The script excludes protected branches like `main`, `dev` and `release/*`.

**Notification:** Any failures are sent through `.github/workflows/notify.yml`.
