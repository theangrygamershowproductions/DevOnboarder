---
author: TAGS Engineering

codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: Directory layout standards, configuration file organization, and project
  structure guidelines
document_type: standards
merge_candidate: false
project: core-instructions
related_modules:

- architecture-overview.md

- plugin-development.md

similarity_group: development-standards
source: .github/copilot-instructions.md
status: active
tags:

- devonboarder

- file-structure

- directory-layout

- configuration

- organization

title: DevOnboarder File Structure Conventions
updated_at: '2025-09-11'
visibility: internal
---

# DevOnboarder File Structure & Conventions

## Directory Layout

```text
── .venv/                     # Python virtual environment (NEVER commit)

── src/devonboarder/          # Python backend application

── src/xp/                    # XP/gamification service

── src/discord_integration/   # Discord OAuth and role management service

── src/feedback_service/      # User feedback collection service

── src/llama2_agile_helper/   # LLM integration service

── src/routes/                # Additional API routes

── src/utils/                 # Shared utilities (CORS, Discord, roles)

── bot/                       # Discord bot (TypeScript)

── frontend/                  # React application

── auth/                      # Authentication service

── tests/                     # Test suites

── docs/                      # Documentation

── scripts/                   # Automation scripts (100 scripts)

── .github/workflows/         # GitHub Actions (22 workflows)

── config/                    # Configuration files

── codex/                     # Agent documentation and tasks

── plugins/                   # Optional Python extensions

```

## Key Configuration Files

- `pyproject.toml`: Python dependencies and tools config

- `package.json`: Node.js dependencies (bot & frontend)

- `docker-compose.ci.yaml`: CI pipeline configuration

- `config/devonboarder.config.yml`: Application configuration

- `.tool-versions`: Environment version requirements (Python 3.12, Node.js 22)

- `.env.ci`: CI-specific environment variables (auto-generated)

- `schema/agent-schema.json`: JSON schema for agent validation

- `Makefile`: Development targets (deps, up, test, openapi, AAR system)

## CI Environment Pattern

The project uses `.env.ci` for CI-specific settings that differ from development:

```bash

# CI uses sanitized test values

DATABASE_URL=sqlite:///./test_devonboarder.db
DISCORD_BOT_TOKEN=ci_test_discord_bot_token_placeholder
CI=true
NODE_ENV=test
PYTHON_ENV=test

```

## Essential Development Tools

- **AAR (After Action Report) System**: Automated CI failure analysis with `make aar-*` commands

- **QC Pre-Push Script**: `./scripts/qc_pre_push.sh` validates 8 quality metrics (95% threshold)

- **CLI Shortcuts**: Optional `.zshrc` integration with `devonboarder-activate`, `gh-dashboard`
