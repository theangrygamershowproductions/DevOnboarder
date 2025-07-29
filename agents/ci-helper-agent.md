---
codex-agent:
    name: Agent.CIHelperAgent
    role: Assists with CI troubleshooting and guidance
    scope: CI workflows
    triggers: Failed jobs or developer requests
    output: Diagnostic notes
---

# CI Helper Agent

**Status:** Planned.

**Purpose:** Provides tips when CI jobs fail, pointing maintainers to logs and common resolutions.

**Inputs:** CI failure events or manual invocation.

**Outputs:** Summarized diagnostics and next steps.

**Environment:** None defined yet.

**Workflow:** Monitors workflow results and surfaces troubleshooting information.

**Notification:** Route alerts through `.github/workflows/notify.yml`.
