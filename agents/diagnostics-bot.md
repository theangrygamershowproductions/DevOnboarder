---
author: DevOnboarder Team
codex-agent:
  name: Agent.DiagnosticsBot
  output: .codex/logs/diagnostics-bot.log
  role: Collects environment diagnostics and system health info
  scope: repo utilities
  triggers: manual or `python -m diagnostics`
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
permissions:
- repo:read
- actions:read
project: core-agents
similarity_group: documentation-documentation
status: active
tags:
- documentation
- documentation
title: Diagnostics Bot
updated_at: '2025-09-12'
visibility: internal
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
