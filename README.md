---
title: "DevOnboarder"
description: "TAGS QA Framework & CI/CD system for automated development environment onboarding, quality assurance, and team productivity."
author: "TAGS Engineering"
created_at: "2025-01-01"
updated_at: "2026-03-04"
tags: ["TAGS", "QA", "CI/CD", "automation", "DevOnboarder"]
project: "DevOnboarder"
document_type: "README"
status: "active"
visibility: "internal"
codex_scope: "tags.ecosystem.devonboarder"
codex_role: "devops"
codex_type: "project-overview"
codex_runtime: "production"
---

# DevOnboarder

**TAGS Quality Assurance Framework & CI/CD Automation System**

The primary DevOnboarder tooling providing:
- **Automated QA validation** (95%+ code quality enforcement)
- **CI/CD pipeline management** with comprehensive automation
- **Development environment bootstrapping** for TAGS ecosystem
- **Multi-service orchestration** (FastAPI, Discord.js, React, PostgreSQL, Traefik)

---

## 🎯 Core Mission

Provide DevOnboarder serves as the centralized QA framework for TAGS ecosystem—automating quality gates, managing CI/CD workflows, orchestrating multi-service development environments, and enabling rapid onboarding of new team members.

---

## 📋 Planning Documents (4-Document System)

The formalized planning structure for DevOnboarder project evolution:

- **[PLAN.md](PLAN.md)** — Technical architecture, design decisions, implementation strategy
- **[TODO.md](TODO.md)** — Phased backlog with verification gates and acceptance criteria
- **[roadmap.md](roadmap.md)** — Version milestones (v3.0+) and strategic direction
- **[CHANGELOG.md](CHANGELOG.md)** — Release history and version tracking

---

## 🚀 Current Feature Initiatives

### Time Tracking Metrics

TAGS-native developer productivity telemetry system (planning phase).

Planning documents: [`docs/features/time-tracking-metrics/`](docs/features/time-tracking-metrics/)
- [PLAN.md](docs/features/time-tracking-metrics/PLAN.md) — Architecture and design
- [TODO.md](docs/features/time-tracking-metrics/TODO.md) — Phases 6–10 backlog
- [roadmap.md](docs/features/time-tracking-metrics/roadmap.md) — V0.1 → V3.0 milestones

---

## 🌟 Core Features

### Quality Assurance Framework

- **95%+ Code Quality Enforcement** — Automated validation across Python, Node.js, and infrastructure
- **Pre-commit Hooks** — Markdown linting, shell validation, Python formatting (Black, isort, flake8)
- **GitHub Actions CI/CD** — Automated testing, security scanning, deployment workflows
- **Coverage Tracking** — Backend 96%+, Bot 100%, Frontend 100%

### Service Architecture

- **Backend**: FastAPI microservices with JWT authentication
- **Bot**: TypeScript Discord.js bot with multi-guild routing
- **Frontend**: React + Vite with responsive design
- **Database**: PostgreSQL with SQLAlchemy ORM
- **Orchestration**: Docker Compose with Traefik reverse proxy

### Development Tools

- **Template System** — Create new TAGS-compliant projects instantly
- **Universal QC** — Project-aware quality control that detects and validates automatically
- **Safe Commit Wrapper** — Enforces conventional commits with comprehensive validation
- **MCP Integration** — Model Context Protocol server ecosystem (25 production servers)

---

## 🚀 Quick Start

```bash
cd ~/TAGS/ecosystem/DevOnboarder

# Activate environment
source .venv/bin/activate

# Install dependencies
pip install -e .[test]
npm ci --prefix bot
npm ci --prefix frontend

# Run quality checks
./scripts/qc_pre_push.sh

# Start development environment
docker compose -f docker-compose.dev.yaml up
```

---

## 📚 Documentation

### Core Documentation
- **AGENTS.md** — AI assistant integration guidelines
- **CONTRIBUTING.md** — Development workflow and pull request procedures
- **ACTIONS_POLICY.md** — GitHub Actions workflow management and SHA pinning
- **SECURITY.md** — Security policies and vulnerability reporting

### Technical References
- **docs/github-review-process-guide.md** — Review procedures and best practices
- **docs/TERMINAL_OUTPUT_POLICY.md** — Output formatting and ZERO TOLERANCE enforcement
- **DEVONBOARDER_V3_COMPLETION_SUMMARY.md** — v3 feature completeness status

---

## 🔌 Related Projects

- **[time-tracking-metrics-vscode](../time-tracking-metrics-vscode/)** — VS Code extension for TAGS time tracking metrics
- **[tags-mcp-servers](../tags-mcp-servers/)** — 25-server MCP ecosystem backend
- **[core-instructions](../core-instructions/)** — Shared patterns and templates

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow, testing requirements, and pull request procedures.

---

## 📈 Monitoring & Health

```bash
# TAGS ecosystem overview
tags_overview

# Quality control
qc

# Project-specific validation
./scripts/qc_pre_push.sh
```

---

**Status**: Active (v3.0+)  
**Maintainers**: TAGS Engineering  
**License**: Internal (TAGS Ecosystem)
