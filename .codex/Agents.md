---
title: "Codex Agent Policy"

description: "Documentation requirements and standards for Codex agent files including YAML headers, index registration, and notification workflows"

document_type: policy
project: DevOnboarder
consolidation_priority: P3
content_uniqueness_score: 4
merge_candidate: false
similarity_group: codex-codex
tags: 
updated_at: 2025-10-27
---

# Codex Agent Policy

All documentation under `agents/` must start with a `codex-agent` YAML header. This header defines the agent name, its role, and other metadata used by automation. Each agent file must also appear in `.codex/agents/index.json` so Codex can map roles during orchestration.

All agents send human‑facing messages through the centralized `notify.yml` workflow. Trigger it with:

```bash
gh workflow run notify.yml -f data=<json>

```

The workflow aggregates notifications via `scripts/process_notifications.py` and posts them to a single issue instead of sending disparate emails.

See [../agents/index.md](../agents/index.md) for the full list of agents and sample YAML headers.
