---
author: DevOnboarder Team
codex-agent:
  name: Agent.ProdOrchestrator
  output: Deployment job logs
  role: Orchestrates production environment deployments
  scope: .github/workflows/prod-orchestrator.yml
  triggers: Push to main or manual dispatch
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
title: Prod Orchestrator
updated_at: '2025-09-12'
visibility: internal
---

# Prod Orchestrator Agent

**Status:** Active.

**Purpose:** Coordinates production deployments via `scripts/orchestrate-prod.sh`.

**Inputs:** GitHub workflow dispatch or push to `main`.

**Outputs:** Logs confirming the orchestration request.

**Environment:** Requires `PROD_ORCHESTRATION_BOT_KEY` provided as `ORCHESTRATION_KEY`. Optionally set `ORCHESTRATOR_URL` (default `https://orchestrator.example.com`).

**Workflow:** The workflow calls `scripts/orchestrate-prod.sh`, which POSTs to the orchestration service.

**Notification:** Route alerts through `.github/workflows/notify.yml`.
