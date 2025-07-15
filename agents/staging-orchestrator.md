---
codex-agent:
  name: Agent.StagingOrchestrator
  role: Orchestrates staging environment deployments
  scope: .github/workflows/staging-orchestrator.yml
  triggers: Push to staging or manual dispatch
  output: Deployment job logs
---

# Staging Orchestrator Agent

**Status:** Active.

**Purpose:** Coordinates staging deployments via `scripts/orchestrate-staging.sh`.

**Inputs:** GitHub workflow dispatch or push to `staging`.

**Outputs:** Logs confirming the orchestration request.

**Environment:** Requires `STAGING_ORCHESTRATION_BOT_KEY` provided as `ORCHESTRATION_KEY`.

**Workflow:** The workflow calls `scripts/orchestrate-staging.sh`, which POSTs to the orchestration service.

**Notification:** Route alerts through `.github/workflows/notify.yml`.
