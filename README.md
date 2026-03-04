---
title: "Time Tracking Metrics"
description: "TAGS-native time tracking and developer productivity telemetry (planning-only)."
author: "TAGS Engineering"
created_at: "2026-03-04"
updated_at: "2026-03-04"
tags: ["TAGS", "DevOnboarder", "metrics", "vscode", "privacy"]
project: "DevOnboarder"
document_type: "README"
status: "planning"
visibility: "internal"
codex_scope: "tags.ecosystem.planning"
codex_role: "cto"
codex_type: "overview"
codex_runtime: "planning-only"
---

# Time Tracking Metrics (TAGS-native)

A **TAGS-native** time tracking and developer productivity telemetry system driven by a **custom VS Code extension** and backed by **DevOnboarder**.

**Status:** planning artifacts only. No implementation is introduced in this pass.

---

## What this is (and is not)

### This is

- Active time tracking inside VS Code
- Local-first storage and compute
- Policy-driven syncing of aggregates
- Personal/team/org dashboards with access controls
- Optional public profiles (publishable aggregates only, opt-in)

### This is not

- Surveillance
- Content capture
- Keystroke logging
- Clipboard/screenshot capture
- A default leaderboard machine

---

## Architecture (one screen)

- **VS Code Extension**
    - Captures activity signals (focus/edit/open/close)
    - Computes active time + sessions locally
    - Stores locally; syncs aggregates by default

- **DevOnboarder Metrics API**
    - Ingests session summaries
    - Applies retention/visibility policy
    - Serves dashboards + exports

- **Dashboards**
    - Personal, team, org views
    - Guardrails to prevent metric abuse

---

## Privacy Controls (Modes)

- **Mode A (default): Aggregates Only**
    - No file references leave the device.

- **Mode B (opt-in): Hashed File References**
    - Enables time-per-file trends without disclosing names.

- **Mode C (opt-in): Labeled Modules**
    - Developer defines local labels; only labels sync.

**Hard commitment:** no code/text content is ever transmitted.

---

## Planned API (for the extension)

- `POST /api/metrics/sessions` — submit session summaries
- `GET /api/metrics/me` — personal metrics
- `GET /api/metrics/team/:teamId` — team aggregates (authorized)
- `GET /api/metrics/public/:handle` — published aggregates only (opt-in)

---

## Planning docs

- `PLAN.md` — technical architecture + decision points
- `TODO.md` — phased backlog (6–10) + verification gates
- `roadmap.md` — version milestones (v0.1 → v3.0)
- `README.md` — this overview
