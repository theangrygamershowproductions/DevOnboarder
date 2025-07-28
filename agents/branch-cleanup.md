---
codex-agent:
    name: Agent.BranchCleanup
    role: Deletes stale merged branches
    scope: repository maintenance
    triggers: Nightly schedule or `codex:cleanup` label
    output: Deleted branch log
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
