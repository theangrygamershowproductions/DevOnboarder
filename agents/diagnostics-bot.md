---
codex-agent:
  name: Agent.DiagnosticsBot
  role: Collects environment diagnostics and system health info
  scope: repo utilities
  triggers: manual or `python -m diagnostics`
  output: .codex/logs/diagnostics-bot.log
permissions:

  - repo:read
  - actions:read
---

# Diagnostics Bot

**Status:** Active.

**Purpose:** Runs health checks and verifies environment variables using the diagnostics module.

**Inputs:** Developer invocation via `python -m diagnostics` or manual Codex run.

**Outputs:** Summary of system readiness and detected problems.

**Environment:** Reads and validates local and CI-relevant environment variables.

**Workflow:**

- Executes diagnostics module
- Aggregates results
- Outputs to `.codex/logs/diagnostics-bot.log`
- Sends alerts via `.github/workflows/notify.yml` if issues are found

**Logging:** Output goes to `.codex/logs/diagnostics-bot.log`

**Permissions Required:**

- `repo:read` – to inspect the project context
- `actions:read` – to check CI metadata, if invoked from workflow
