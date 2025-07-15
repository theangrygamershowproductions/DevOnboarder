---
codex-agent:
  name: Agent.DiagnosticsBot
  role: Collects environment diagnostics and system health info
  scope: local and CI diagnostics
  triggers: Invocation of `python -m diagnostics`
  output: System check report
---

# Diagnostics Bot

**Status:** Active.

**Purpose:** Runs health checks and verifies environment variables using the diagnostics module.

**Inputs:** Developer invocation via the command line.

**Outputs:** Summary of system readiness and detected problems.

**Environment:** Reads variables used by the diagnostics scripts.

**Workflow:** Executes diagnostics and prints results. Alerts route through the notify workflow when issues arise.

**Notification:** Route alerts through `.github/workflows/notify.yml`.
