# Codex Agents

This directory holds metadata about automation agents used in the DevOnboarder project.

## index.json

`index.json` contains an `agents` array. Each entry has these fields:

- `name` – canonical agent identifier
- `role` – short description of what the agent does
- `path` – relative path to the agent documentation
- `triggers` – conditions that activate the agent
- `output` – artifact or result produced

The data mirrors the `codex-agent` YAML headers inside documentation files under `agents/`.
