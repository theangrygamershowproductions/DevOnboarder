---
codex-agent:
  name: Agent.CIBot
  role: Manages CI failure issues
  scope: CI workflows
  triggers: Failed CI runs and nightly cleanup
  output: Open or closed ci-failure issues
---

# CI Bot

**Status:** Active.

**Purpose:** Automatically open, update, and close issues labeled `ci-failure` when CI jobs fail or succeed.

**Inputs:** Completed CI workflow runs and scheduled cleanup tasks.

**Outputs:** GitHub issues summarizing failing steps or confirmation that prior issues were closed.

**Environment:** Uses `${{ secrets.CI_BOT_TOKEN }}` for authentication.

**Permissions:** Requires `issues: write` to manage failure issues.

**Workflow:** The workflow calls the bot after each run. It uses the token to create or update the failure issue. When builds succeed, the bot closes any open issues. A nightly cleanup job ensures stale issues are removed.

**Escalation:** If issue automation fails repeatedly, notify maintainers via `.github/workflows/notify.yml` to review logs and rotate the token.

**Notification:** Route alerts through `.github/workflows/notify.yml`.
