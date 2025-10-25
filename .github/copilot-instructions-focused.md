---
title: "DevOnboarder Agent Instructions - Focused Version"
description: "Essential 50-line AI agent guidance for DevOnboarder development workflow and quality standards"
author: "TAGS DevSecOps Manager"
project: "DevOnboarder"
version: "v1.0.0"
status: "active"
visibility: "internal"
created_at: "2025-09-21"
updated_at: "2025-09-21"
canonical_url: "https://codex.theangrygamershow.com/docs/devonboarder/copilot-instructions-focused"
related_components:
  - github_copilot
  - development_workflow
  - quality_gates
codex_scope: "DevOnboarder"
codex_role: "ai_agent"
codex_type: "instruction"
codex_runtime: "github_copilot"
tags: ["ai-agent", "development", "quality-gates", "focused", "essential"]
document_type: "instruction"
---

# GitHub Copilot Instructions for DevOnboarder

## Essential AI Agent Guide

DevOnboarder is a multi-service onboarding platform built to "work quietly and reliably." Key principle: **never bypass quality gates**.

### Critical First Steps

**ALWAYS use virtual environment**: `source .venv/bin/activate` before any Python commands
**NEVER use direct git commit**: Use `./scripts/safe_commit.sh "TYPE(scope): message"`
**ZERO TOLERANCE terminal policy**: Only plain ASCII text in echo commands (NO emojis/Unicode - causes system hangs)

### Architecture Essentials

**Multi-service setup** with specific ports:

- Auth Service: 8002 (Discord OAuth  JWT)
- XP API: 8001 (gamification)
- Discord Integration: 8081
- Frontend: 8081 (React)
- Database: 5432 (PostgreSQL prod, SQLite dev)

**Multi-environment Discord routing**:

```typescript
const guildId = interaction.guild?.id;
const isDevEnvironment = guildId === "1386935663139749998"; // TAGS: DevOnboarder
const isProdEnvironment = guildId === "1065367728992571444"; // TAGS: C2C
```

### Development Workflow

**Setup**: `make deps && make up` (starts all services via Docker)
**Testing**: `./scripts/run_tests.sh` (includes dependency hints)
**Quality gates**: `./scripts/qc_pre_push.sh` (95% threshold across 8 metrics)
**Service health**: Individual testing via `devonboarder-api`, `devonboarder-auth`, `devonboarder-integration`

### Key Patterns

**FastAPI services** follow consistent pattern with `/health` endpoints and CORS middleware
**Traefik reverse proxy** uses dual routing (subdomain primary, path-based fallback)
**Centralized logging** required in `logs/` directory
**Root Artifact Guard** prevents pollution in repository root

### Automation Ecosystem

100 scripts handle validation, CI/CD, and automation. Key ones:

- `scripts/validate_terminal_output.sh` - Terminal compliance (CRITICAL)
- `scripts/automate_pr_process.sh` - Full PR automation
- `scripts/analyze_ci_patterns.sh` - AI-powered CI failure analysis

**Branch workflow**: Feature branches from `main`, trunk-based development
**Quality requirements**: 95% test coverage, conventional commits, markdown compliance
