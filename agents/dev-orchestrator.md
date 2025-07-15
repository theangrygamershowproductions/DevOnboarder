---
codex-agent:
  name: Agent.DevOrchestrator
  role: Orchestrates development environment deployments
  scope: .github/workflows/dev-orchestrator.yml
  triggers: Push to dev or manual dispatch
  output: Deployment job logs
---

# Dev Orchestrator Agent

**Status:** Active.

**Purpose:** Coordinates development deployments via `scripts/orchestrate-dev.sh`.

**Inputs:** GitHub workflow dispatch or push to `dev`.

**Outputs:** Logs confirming the orchestration request.

**Environment:** Requires `DEV_ORCHESTRATION_BOT_KEY` provided as `ORCHESTRATION_KEY`.

**Workflow:** The workflow calls `scripts/orchestrate-dev.sh`, which POSTs to the orchestration service.

**Notification:** Route alerts through `.github/workflows/notify.yml`.
