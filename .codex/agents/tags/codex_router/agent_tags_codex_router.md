---
title: "codex_router"
description: "Routes PRs/issues to target agents based on labels/paths/CI context."
author: "TAGS Engineering"
version: "1.0.0"
created_at: "2025-08-09"
updated_at: "2025-08-09"
tags: ["router", "codex", "triage"]
project: "DevOnboarder"
document_type: "agent"
status: "experimental"
visibility: "internal"
codex_scope: "tags"
codex_role: "router"
codex_type: "system-agent"
codex_runtime: "ci"
---

# Codex Router Agent

## Purpose

Routes PRs/issues to target agents based on labels, file paths, and CI context. This is the primary routing agent that determines which specialized agents should handle specific requests.

## Inputs

- **PR/Issue metadata**: Labels, title, description, file changes
- **CI context**: Build status, test results, coverage data
- **Repository context**: File paths, branch information

## Outputs

- **Routing decision**: Which agents should handle the request
- **Labels**: Applied to PR/issue for tracking
- **Comments**: Notification of routing decisions

## Guardrails

- **No source edits**: Router never modifies source code directly
- **Respect ci_triage_guard**: Always check guard status before routing
- **Audit logging**: All routing decisions are logged

## Routing Matrix

| Condition | Target Agent | Description |
|-----------|--------------|-------------|
| `label:codex:coverage` | `coverage_orchestrator` | Coverage-related requests |
| `path:frontend/**` | `codex_frontend` | Frontend changes (future) |
| `path:bot/**` | `codex_bot` | Bot changes (future) |
| `path:docs/**` | `codex_docs` | Documentation changes (future) |
| `ci_failure` | `ci_triage_guard` | CI infrastructure issues |

## Implementation

The router examines incoming requests and applies routing rules defined in the orchestrator configuration. It maintains state about agent availability and can queue requests when agents are busy.

### Key Functions

1. **Label Analysis**: Parse existing labels to determine routing needs
2. **Path Analysis**: Examine changed files to identify affected components
3. **Context Analysis**: Consider CI status and repository state
4. **Agent Selection**: Choose appropriate agents based on routing rules
5. **Notification**: Inform users of routing decisions

## Configuration

Routing rules are defined in `.codex/orchestrator/config.yml` and can be updated without code changes.
