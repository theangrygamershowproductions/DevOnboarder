---
codex-agent:
  name: Agent.DevOrchestrator
  role: Orchestrates development environment deployments and Codex agent maintenance
  scope: .github/workflows/dev-orchestrator.yml
  triggers: Push to dev or manual dispatch
  output: Deployment job logs
---

# Dev Orchestrator Agent

**Status:** Active.

**Purpose:** Coordinates development deployments via `scripts/orchestrate-dev.sh` and manages Codex agent maintenance tasks.

**Inputs:** GitHub workflow dispatch, push to `dev`, or manual task invocation.

**Outputs:** Logs confirming orchestration and/or agent migration.

**Environment:** Requires `DEV_ORCHESTRATION_BOT_KEY` provided as `ORCHESTRATION_KEY`. Optionally set `ORCHESTRATOR_URL` (default `https://orchestrator.example.com`).

**Workflow:** 
- For deployments: Calls `scripts/orchestrate-dev.sh`, which POSTs to the orchestration service.
- For Codex agent maintenance: Processes local agents and migrates them into `.codex/agents`.

**Notification:** Route alerts through `.github/workflows/notify.yml`.

---

## codex
title: Agent Renewal & Migration v2
trigger: manual
context: workspace
output: updated agent files, index.md, permissions.yml
scope: file-system

## instructions

You are responsible for migrating and standardizing all existing Codex agent definitions located in the `agents/` directory.

Perform the following actions for each `.md` file inside `agents/`:

1. **Copy the file into `.codex/agents/`**
   - Normalize the filename: use lowercase, hyphenated names like `ci-helper-agent.md`, `diagnostics-bot.md`, etc.

2. **At the top of each file**, ensure a complete Codex metadata block is present. If missing or partial, replace it with:

   ```yaml
   ---
   agent: [normalized filename without extension]
   purpose: [Brief purpose of this agent]
   trigger: [event or workflow that triggers this agent]
   environment: any
   output: .codex/logs/[filename].log
   permissions:
     - issues:write
     - repo:read
   ---
   ```

3. **Standardize the content structure** below the metadata:

   - `# [Agent Name]`
   - `**Purpose:** ...`
   - `**Inputs:** ...`
   - `**Outputs:** ...`
   - `**Environment:** ...`
   - `**Workflow:** ...`
   - `**Logging:** Output goes to .codex/logs/[agent-name].log`
   - `**Permissions Required:** ...`

4. **Update or create `.codex/agents/index.md`** with a table listing each agent:
   - Filename
   - Agent name
   - Purpose
   - Trigger
   - Output path
   - Metadata status (✅/❌)

5. **Create or update `.codex/permissions.yml`** with each agent and the permissions it needs.

After completing the migration, remove the original `agents/` directory if no longer needed.

Do not execute any agents. This is a migration task only.
