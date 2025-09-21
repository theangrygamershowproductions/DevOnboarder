---
author: DevOnboarder Team

codex-agent:
  name: Agent.AgentMaintenance
  output: .codex/logs/agent-maintenance.log
  role: Migrates and standardizes Codex agents
  scope: local or CI
  triggers: manual
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
permissions:

- repo:write

- contents:read

project: core-agents
similarity_group: documentation-documentation
status: active
tags:

- documentation

title: Agent Maintenance
updated_at: '2025-09-12'
visibility: internal
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

- `repo:write` — to create/update agent files

- `contents:read` — to process existing documentation
