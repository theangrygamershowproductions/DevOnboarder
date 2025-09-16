---
agent: README
codex-agent:
  environment: any
  name: Agent.AgentsDocumentation
  output: .codex/logs/agents-documentation.log
  role: Documentation for Codex agent infrastructure and integration
  scope: DevOnboarder agent system overview and file listing
  triggers: when users need to understand agent infrastructure
consolidation_priority: P3
content_uniqueness_score: 4
description: Optional infrastructure for enhanced Codex integration and automation with agent documentation, prompt indexing, and validation configuration
document_type: guide
environment: any
merge_candidate: false
output: .codex/logs/README.log
permissions:
- repo:read
purpose: Agent purpose description needed
similarity_group: agent-agent
tags:
- codex
- infrastructure
- automation
- agents
title: Codex Integration Infrastructure
trigger: manual
---

# Codex Integration Infrastructure

This directory contains optional infrastructure for enhanced Codex integration and automation.

## Files

### `index.json`

Comprehensive index of all prompts, roles, and organizations in the repository. Provides:

- Metadata about all available prompts

- File paths and organizational structure

- Runtime readiness status

- Validation configuration details

### `validate_prompts.sh`

Bash script for comprehensive prompt validation including:

- YAML frontmatter structure validation

- Required field verification

- Codex-specific metadata checking

- JSON index validation

## Usage

### Manual Validation

```bash

# Run comprehensive prompt validation

./.codex/validate_prompts.sh

```

### CI Integration

The validation script is automatically executed by the GitHub workflow at `.github/workflows/validate-structure.yml`.

## Codex Compatibility

All prompts in this repository follow Codex standards:

### Required YAML Frontmatter

```yaml
---
title: "ORG:ROLE:TYPE"

description: "Clear description of the prompt's purpose"
tags: ["codex", "org", "role", "type"]
author: "TAGS Engineering"
created_at: "2025-07-21"
updated_at: "2025-07-21"
codex_scope: "ORG"
codex_role: "ROLE"
codex_type: "TYPE"
codex_runtime: false
---

```

### Naming Convention

- **Prompts**: `agent_<org>_<role>.md`

- **Charters**: `charter_<org>_<role>.md`

- **Checklists**: `checklist_<org>_<role>.md`

### Title Format

All titles follow the pattern: `ORG:ROLE:TYPE`

- Example: `TAGS:CFO:PROMPT`

- Example: `CRFV:COO:CHARTER`

## Future Enhancements

### Runtime Execution

When `codex_runtime: true` is enabled, prompts will be available for:

- Live execution via `codex-runner`

- API integration and automation

- Dynamic prompt composition

### Role Expansion

The infrastructure supports adding:

- New organizations

- Additional C-suite roles (CEO, CTO, CMO, CHRO)

- Cross-organizational collaboration prompts

## Validation Status

✅ **Current Status**: All prompts are Codex-ready

- YAML frontmatter validated

- Metadata compliance confirmed

- File structure standardized

- CI validation enabled

The repository can be consumed by Codex systems immediately without modification.
