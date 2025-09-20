---
title: "Codex Agents Documentation"

description: "Documentation for the Codex agents directory structure and metadata format including index.json structure"
document_type: "guide"
tags: ["agents", "codex", "automation", "documentation", "metadata"]
project: "core-agents"
created: "2025-09-13"
last_modified: "2025-09-13"
version: "1.0"
agent: "codex_agents_documentation"
purpose: "Documentation for the Codex agents directory structure and metadata format"
trigger: "agent system updates and documentation maintenance"
environment: "any"
output: "codex/agents/index.json"
permissions:
    - "repo:read"

codex_runtime: false
codex_dry_run: false
discord_role_required: ""
authentication_required: false
integration_log: "Codex agents system documentation"
---

# Codex Agents

This directory holds metadata about automation agents used in the DevOnboarder project.

## index.json

The canonical index lives at `.codex/agents/index.json` and contains an
`agents` array. Each entry has these fields:

- `name` – canonical agent identifier

- `role` – short description of what the agent does

- `path` – relative path to the agent documentation

- `triggers` – conditions that activate the agent

- `output` – artifact or result produced

The data mirrors the `codex-agent` YAML headers inside documentation files under `agents/`.
