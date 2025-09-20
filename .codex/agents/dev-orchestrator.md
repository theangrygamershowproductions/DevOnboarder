---
agent: dev-orchestrator

consolidation_priority: P3
content_uniqueness_score: 4
description: Coordinates development deployments via dev orchestration script with GitHub workflow dispatch integration
document_type: specification
environment: CI
merge_candidate: false
output: .codex/logs/dev-orchestrator.log
permissions:

- workflows:write

purpose: Orchestrates development environment deployments
similarity_group: agents-agents
tags:

- orchestration

- deployment

- ci

- development

title: Dev Orchestrator Agent
trigger: on_push_to_dev
---

# Dev Orchestrator Agent

**Status:** Active.

**Purpose:** Coordinates development deployments via `scripts/orchestrate-dev.sh`.

**Inputs:** GitHub workflow dispatch or push to the `dev` branch.

**Outputs:** Logs confirming the orchestration request and remote coordination.

**Environment:**

- Requires `DEV_ORCHESTRATION_BOT_KEY` provided as `ORCHESTRATION_KEY`.

- Optionally set `ORCHESTRATOR_URL` (default: `https://orchestrator.example.com`).

**Workflow:**

- The workflow calls `scripts/orchestrate-dev.sh`

- The script POSTs orchestration instructions to a remote service.

**Logging:** Output goes to `.codex/logs/dev-orchestrator.log`

**Permissions Required:**

- `workflows:write` — to trigger sub-jobs or notify results
