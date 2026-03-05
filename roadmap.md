---
title: "DevOnboarder — Roadmap"
description: "Version milestones and strategic direction for TAGS QA Framework."
author: "TAGS Engineering"
created_at: "2026-03-04"
updated_at: "2026-03-04"
tags: ["TAGS", "DevOnboarder", "roadmap", "versions"]
project: "DevOnboarder"
document_type: "roadmap"
status: "active"
visibility: "internal"
versioning_strategy: "semantic"
codex_scope: "tags.ecosystem.devonboarder"
codex_role: "cto"
codex_type: "strategy"
codex_runtime: "production"
---

# DevOnboarder — Roadmap

## v3.0 (Current, Production)

**Released**: 2025-11-28  
**Status**: Stable, v3 feature freeze active through 2026-01-01

- Core QA framework (FastAPI + Discord.js + React)
- 95%+ code quality enforcement
- GitHub Actions CI/CD orchestration
- SHA pinning and policy enforcement
- PostgreSQL + Traefik infrastructure

---

## v3.1+ (Patch/Stability, Active)

**Timeline**: 2026-Q1  
**Focus**: Hardening, performance optimization, governance

- Dependency security patches and updates
- CI performance tuning and caching
- Documentation and onboarding improvements
- Policy audit and compliance enforcement

---

## v4.0 (Planned, 2026-Q2+)

**Features**:
- Cross-IDE support (Neovim, Cursor, JetBrains)
- Advanced observability and distributed tracing
- Role-based access control (RBAC) with fine-grained policy
- Ecosystem integrations (MCP servers, external tools)

---

## Feature Initiatives

### Time Tracking Metrics

**Roadmap**: [`docs/features/time-tracking-metrics/roadmap.md`](docs/features/time-tracking-metrics/roadmap.md)

- **v0.1**: VS Code extension with local tracking
- **v1.0**: Backend API + personal dashboard
- **v2.0**: Team analytics and aggregates
- **v3.0**: Public opt-in profiles

---

## Release Cadence

- **Patch releases** (v3.1, v3.2, ...): Monthly
- **Minor releases** (v4.0, v5.0, ...): Quarterly
- **Feature initiatives**: Follow own roadmap (e.g., Time Tracking Metrics phases 6–10)

See CHANGELOG.md for detailed release history and version tracking.
