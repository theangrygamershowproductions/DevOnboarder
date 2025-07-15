---
codex-agent:
  name: Agent.ProdOrchestrator
  role: Orchestrates production environment deployments
  scope: .github/workflows/prod-orchestrator.yml
  triggers: Push to main or manual dispatch
  output: Deployment job logs
---

# Prod Orchestrator Agent

**Status:** Active.

**Purpose:** Coordinates production deployments via `scripts/orchestrate-prod.sh`.

**Inputs:** GitHub workflow dispatch or push to `main`.

**Outputs:** Logs confirming the orchestration request.

**Environment:** Requires `PROD_ORCHESTRATION_BOT_KEY` provided as `ORCHESTRATION_KEY`.

**Workflow:** The workflow calls `scripts/orchestrate-prod.sh`, which POSTs to the orchestration service.

**Notification:** Route alerts through `.github/workflows/notify.yml`.
