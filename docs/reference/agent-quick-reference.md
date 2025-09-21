---
title: "DevOnboarder Agent Quick Reference"
description: "Quick reference guide for common AI agent tasks and commands in DevOnboarder
  development workflow"
author: "TAGS DevSecOps Manager"
project: "DevOnboarder"
version: "v1.0.0"
status: "active"
visibility: "internal"
created_at: "2025-09-21"
updated_at: "2025-09-21"
canonical_url: "https://codex.theangrygamershow.com/docs/devonboarder/agent-quick-reference"
related_components:
- development_workflow
- testing
- quality_control
- virtual_environment
codex_scope: "DevOnboarder"
codex_role: "reference"
codex_type: "documentation"
codex_runtime: "development"
tags: ["reference", "quick-guide", "development", "testing", "commands"]
document_type: "reference"
similarity_group: reference-reference
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# DevOnboarder Agent Quick Reference

## Most Common Agent Tasks

**Run tests**: `source .venv/bin/activate && ./scripts/run_tests.sh`

**Commit changes**: `./scripts/safe_commit.sh "TYPE(scope): description"`

**Start services**: `make deps && make up` (uses ports 8001, 8002, 8081, 8003)

**Fix CI failures**: `./scripts/analyze_ci_patterns.sh`

**Quality check**: `./scripts/qc_pre_push.sh` (must pass 95% threshold)

**Terminal hangs**: Remove ALL emojis/Unicode, use plain ASCII only

**Virtual environment**: Always activate with `source .venv/bin/activate` first

**Discord environments**:

- Dev: Guild ID 1386935663139749998
- Prod: Guild ID 1065367728992571444

**When confused**: Run `./scripts/qc_pre_push.sh` - it validates everything
