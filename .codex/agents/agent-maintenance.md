---
codex-agent: agent-maintenance
purpose: Migrates and standardizes Codex agents
trigger: manual
environment: local or CI
output: .codex/logs/agent-maintenance.log
permissions:
    - repo:write
    - contents:read
---

# Agent Maintenance

**Status:** Active.

**Purpose:** Migrates all legacy Codex agent files from `agents/` into `.codex/agents/`, applies formatting and metadata standards, and builds an updated agent registry and permission index.

**Inputs:** Developer-initiated Codex task.

**Outputs:** Renewed `.codex/agents/` files, `index.md`, and `permissions.yml`.

**Workflow:**

1. Locate all `.md` files inside `agents/`
2. Normalize filenames and migrate to `.codex/agents/`
3. Apply standard metadata and format
4. Update `.codex/agents/index.md`
5. Generate or revise `.codex/permissions.yml`

**Logging:** Output goes to `.codex/logs/agent-maintenance.log`

**Permissions Required:**

-   `repo:write` — to create/update agent files
-   `contents:read` — to process existing documentation
