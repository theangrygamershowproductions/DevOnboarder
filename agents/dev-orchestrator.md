---
author: "DevOnboarder Team"
codex-agent: 
name: Agent.DevOrchestrator
output: "Deployment job logs"
role: "Orchestrates development environment deployments"
scope: .github/workflows/dev-orchestrator.yml
triggers: "Push to dev or manual dispatch"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Documentation description needed"

document_type: documentation
merge_candidate: false
permissions: 
- workflows: write
project: core-agents
similarity_group: documentation-documentation
status: active
tags: 
title: "Dev Orchestrator"

updated_at: 2025-10-27
visibility: internal
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
