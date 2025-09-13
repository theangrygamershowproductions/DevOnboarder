---
author: DevOnboarder Team
codex-agent:
  name: Agent.StagingOrchestrator
  output: Deployment job logs
  role: Orchestrates staging environment deployments
  scope: .github/workflows/staging-orchestrator.yml
  triggers: Push to staging or manual dispatch
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
- documentation
title: Staging Orchestrator
updated_at: '2025-09-12'
visibility: internal
---

# Staging Orchestrator Agent

**Status:** Active.

**Purpose:** Coordinates staging deployments via `scripts/orchestrate-staging.sh`.

**Inputs:** GitHub workflow dispatch or push to `staging`.

**Outputs:** Logs confirming the orchestration request.

**Environment:** Requires `STAGING_ORCHESTRATION_BOT_KEY` provided as `ORCHESTRATION_KEY`. Optionally set `ORCHESTRATOR_URL` (default `https://orchestrator.example.com`).

**Workflow:** The workflow calls `scripts/orchestrate-staging.sh`, which POSTs to the orchestration service.

**Notification:** Route alerts through `.github/workflows/notify.yml`.
