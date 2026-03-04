---
title: "DevOnboarder — Execution Plan"
description: "TAGS Quality Assurance Framework platform strategy and current execution focus."
author: "TAGS Engineering"
created_at: "2026-03-04"
updated_at: "2026-03-04"
tags: ["TAGS", "DevOnboarder", "QA", "planning"]
project: "DevOnboarder"
document_type: "PLAN"
status: "active"
visibility: "internal"
codex_scope: "tags.ecosystem.devonboarder"
codex_role: "cto"
codex_type: "execution-plan"
codex_runtime: "production"
---

# DevOnboarder — Execution Plan

## Overview

DevOnboarder is the **TAGS Quality Assurance Framework** providing:
- Automated QA validation (95%+ code quality enforcement)
- CI/CD pipeline management and orchestration
- Multi-service development environment bootstrapping
- Ecosystem automation and tooling

## Current Execution Focus

### v3.0 (Production, Main Branch)

- Core QA framework with FastAPI + Discord.js + React
- PostgreSQL database, Traefik orchestration
- 95%+ test coverage across all services
- GitHub Actions CI/CD with comprehensive automation

### v3+ Stability (Active)

Focus on hardening, performance, and governance:
- SHA pinning for all GitHub Actions
- Comprehensive pre-commit enforcement
- Policy-driven governance and audit
- Documentation and knowledge transfer

## Initiatives & Features

### Time Tracking Metrics

A new feature initiative adding **developer productivity telemetry** to DevOnboarder:
- Custom VS Code extension (separate repo)
- Backend metrics API inside DevOnboarder
- Privacy-first design (local-first, opt-in sync)
- **Planning documents**: [`docs/features/time-tracking-metrics/`](docs/features/time-tracking-metrics/)

See feature planning pack for full architecture and phased backlog.

---

## v4 Planning (2026+)

Next-generation DevOnboarder roadmap:
- Cross-IDE support (Neovim, Cursor, etc.)
- Distributed tracing and observability
- Advanced policy enforcement (RBAC, audit)
- Ecosystem expansion and integration

---

## Key References

- **README.md** — Project overview and quickstart
- **CHANGELOG.md** — Release history and version tracking
- **docs/features/** — Feature initiative planning packs
