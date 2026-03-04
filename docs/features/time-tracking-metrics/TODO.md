---
title: "Time Tracking Metrics — Implementation Phases"
description: "Phased backlog for VS Code extension, backend API, dashboards, and public exposure."
author: "TAGS Engineering"
created_at: "2026-03-04"
updated_at: "2026-03-04"
tags: ["TAGS", "DevOnboarder", "phases", "metrics"]
project: "DevOnboarder"
document_type: "TODO"
status: "planning"
visibility: "internal"
codex_scope: "tags.ecosystem.planning"
codex_role: "cto"
codex_type: "execution-plan"
codex_runtime: "planning-only"
---

# TODO — Time Tracking Metrics (Phases 6–10)

## Phase 6 — VS Code Extension Foundation

Deliverables

- Extension scaffold + packaging strategy (VSIX first)
- Activity capture layer (focus/edit/open/close)
- Active time engine (idle detection + manual pause)
- Local store (events → sessions compaction)
- Config + privacy modes (Mode A default)
- Minimal UI: status bar indicator + commands

Acceptance criteria

- Session summaries are correct in local-only mode
- No content capture possible by design
- Manual pause/resume works reliably
- Idle and focus-loss behavior matches defaults

Verification gates

- Privacy audit checklist passes
- Local store survives restart + crash recovery
- Config toggles behave deterministically

---

## Phase 7 — Backend Time Metrics API (DevOnboarder)

Deliverables

- `POST /api/metrics/sessions` ingest
- AuthN/AuthZ integration (developer/teamlead/admin/public)
- Postgres tables + indexes
- Retention policy primitives (policy + job)
- Basic query endpoints (`/me`, team aggregates)

Acceptance criteria

- Extension can sync session batches successfully
- Developer can read own metrics
- Team lead only sees authorized aggregates
- Policy changes are auditable (who/when/what)

Verification gates

- Request validation + schema versioning enforced
- Rate limiting applied to ingest
- Zero leakage of private fields in team/org queries

---

## Phase 8 — Analytics Dashboard

Deliverables

- Personal dashboard: daily/weekly totals, project breakdown, language breakdown
- Team dashboard: aggregate trendlines + rollups
- Export: personal data export (CSV/JSON)

Acceptance criteria

- Dashboards match server truth
- Privacy constraints enforced in API + UI
- No default leaderboards

Verification gates

- Query performance meets baseline targets
- Snapshot tests for key API responses (contract stability)

---

## Phase 9 — Public API Exposure (Opt-in Profiles)

Deliverables

- Publish/unpublish mechanism (explicit opt-in)
- Public endpoints returning publishable aggregates only
- Caching + rate limiting
- Public API documentation + examples

Acceptance criteria

- Published data is opt-in and reversible
- No private data can be inferred via public API
- Contract is versioned and backward compatible

Verification gates

- Security review on publish surface + enumeration resistance
- Abuse testing (scraping, brute-force handles)

---

## Phase 10 — Developer Metrics Platform

Deliverables

- Org-level analytics dashboards
- Policy controls: retention/visibility/export
- Optional correlations (PR/commit metadata) behind explicit opt-in + governance
- Extension update strategy + compatibility matrix

Acceptance criteria

- Strategic metrics value without surveillance creep
- Governance controls are auditable and least-privilege
- System remains usable in local-only mode (degraded operation)

Verification gates

- Governance compliance checks wired into CI
- Metrics drift monitoring (schema + computation integrity)
