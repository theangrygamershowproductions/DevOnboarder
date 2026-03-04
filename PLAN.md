---
title: "Time Tracking Metrics — Technical Architecture"
description: "TAGS-native developer productivity telemetry via VS Code extension + DevOnboarder backend."
author: "TAGS Engineering"
created_at: "2026-03-04"
updated_at: "2026-03-04"
tags: ["TAGS", "DevOnboarder", "metrics", "telemetry", "vscode", "privacy"]
project: "DevOnboarder"
related_components: ["VSCode Extension", "Metrics API", "Analytics Dashboard", "Public API (opt-in)"]
document_type: "PLAN"
status: "planning"
visibility: "internal"
codex_scope: "tags.ecosystem.planning"
codex_role: "cto"
codex_type: "architecture"
codex_runtime: "planning-only"
---

# Time Tracking Metrics — PLAN (Technical Architecture)

## 0) Terminology Lock

**This system is named:** **Time Tracking Metrics**  
Avoid external tool naming in docs, configs, UI, and code identifiers.

---

## 1) Objective

Build a **TAGS-native** time tracking and developer productivity telemetry system driven by a **custom VS Code extension** integrated with **DevOnboarder** as the backend system-of-record.

### Goals

- Track **active developer time** in VS Code with defensible logic.
- Be **privacy-first** by design (no content capture).
- Be **local-first** with explicit sync controls.
- Provide **personal + team + org analytics** with strong access control.
- Allow **public metrics exposure only by explicit opt-in** (publishable aggregates).

### Non-goals (hard boundaries)

- No keystroke logging.
- No clipboard capture.
- No screenshots.
- No code/text/content exfiltration.
- No background “always-on” tracking outside VS Code (v0.x).
- No default leaderboards or rank-order “hours” charts.

---

## 2) System Architecture

### 2.1 Components

1. **VS Code Extension (Client)**

   - Captures VS Code activity signals.
   - Computes sessions + active time locally.
   - Stores locally; syncs **aggregates** by default.
   - Canonical implementation repo: `https://github.com/theangrygamershowproductions/time-tracking-metrics-vscode`

2. **DevOnboarder Metrics API (Server)**

   - Ingests session summaries.
   - Validates auth, applies policy (visibility, retention).
   - Persists canonical records (Postgres-first).

3. **Analytics Dashboard (UI)**

   - Personal dashboard (developer).
   - Team dashboard (team lead).
   - Org dashboard (admin/exec).
   - Export tooling (personal export; admin policy-bound export).

4. **(Optional later) Rollup/warehouse**

   - Only when scale demands it; Postgres rollups first.

### 2.2 Data Flow

VS Code signals → local computation → local store → queued sync → DevOnboarder API → Postgres → dashboards / exports → (optional) public API.

---

## 3) VS Code Extension — Architecture

### 3.1 Activity Signals (v0.1)

Collected (timestamps + metadata only):

- Window focus/blur (active VS Code vs inactive)
- File open/close (file *reference*, not content)
- Document change events (timestamp + language id, not diff)
- Workspace/repo context (project identity)
- Manual pause/resume state
- Optional: debug session start/stop (later toggle)

Explicitly not collected:

- Raw file contents
- Keystrokes
- Clipboard
- Full file paths leaving device (unless opt-in mode)

### 3.2 Active Time Engine (default model)

Active time accumulates when all are true:

- VS Code window is focused
- User is not manually paused
- Last activity is within idle threshold

**Defaults**

- Idle threshold: **120 seconds**
- Auto-pause on focus loss: **enabled**
- Manual pause/resume control: **enabled** (status bar + command palette)

### 3.3 Local Storage

Recommended storage model:

- **Events (ephemeral)**: retained 7 days (rolling), then compacted
- **Sessions (summaries)**: retained 90 days locally (configurable)

Suggested implementation options (pick later):

- SQLite (preferred for resilience)
- JSONL (acceptable for v0.1, but easier to corrupt)

### 3.4 Sync Queue

- Local queue with retry/backoff
- Batch submit session summaries
- Sync can be disabled entirely (local-only mode)

---

## 4) Privacy Model (Modes)

### Mode A — Aggregates Only (default)

- No file identifiers leave the device.
- Sync: totals by **project + language + session**.

### Mode B — Hashed File References (opt-in)

- File reference is hashed locally with a per-user salt.
- Server cannot reverse names/paths.
- Enables time-per-file trends without disclosure.

### Mode C — Labeled Modules (opt-in)

- Developer defines friendly labels locally (e.g., “Auth Module”, “Docs”).
- Only labels sync; raw paths never sync.

**Hard rule:** No code content ever transmitted in any mode.

---

## 5) DevOnboarder Integration

### 5.1 Planned API Surface

**Ingest**

- `POST /api/metrics/sessions` — submit session summary batch

**Query**

- `GET /api/metrics/me` — personal metrics
- `GET /api/metrics/team/:teamId` — team aggregates (authorized)
- `GET /api/metrics/org` — org aggregates (authorized)
- `GET /api/metrics/public/:handle` — published aggregates only (opt-in)

**Admin**

- `POST /api/metrics/policy` — retention + visibility policy
- `POST /api/metrics/publish` — publish/unpublish controls

### 5.2 Data Model (server-side, conceptual)

- `metrics_sessions`
- `metrics_rollups_daily`
- `metrics_project_map`
- `metrics_policy`
- `metrics_public_profiles`

---

## 6) Domain & Endpoint Strategy (planning intent)

- Internal/dev endpoint may use `*.tags.dev.home` during early rollout.
- Future external/public hostnames should use `*.theangrygamershow.com`.
- Public endpoints must remain **publish-only aggregates** (no private leakage surface).

---

## 7) Analytics (Derived Metrics) — Safe by Default

v0.x:

- Active time per day/week
- Time by project
- Time by language/file type category
- Session count + average session length
- Optional: focus ratio (active / (active + idle))

v1.x–v2.x (opt-in correlations):

- PR/commit metadata correlation (no content), gated by policy
- Team trendlines and workstream allocation

**Guardrail:** No default UI that rewards longer hours. If leadership wants it, they can go write that bad idea down and sign it in blood.

---

## 8) Decision Points (Canonical)

These are the knobs that can change later **without rewriting architecture**:

1. **Tracking breadth**
   - Coding-only (default) vs all IDE activity

2. **Idle threshold**
   - Default 120s; allow config range 60–300s

3. **File granularity**
   - None (default) **(Mode A — Aggregates Only)** vs hashed refs **(Mode B)** vs labeled modules **(Mode C)**

4. **Team visibility model**
   - Aggregates-only (default) vs expanded detail by policy

5. **Release strategy**
   - Separate extension versioning (recommended) vs bundled with DevOnboarder

### Locked Values (v0.1 baseline)

1. Tracking breadth: coding-only
2. Idle threshold: 120 seconds
3. File granularity: None (default)
4. Team visibility model: aggregates-only
5. Release strategy: separate versioning (extension + API)

---

## 9) Governance Alignment (implementation constraint)

When implementation begins:

- CI/workflows must follow TAGS security hardening expectations (SHA pinning, runner policy, no unverified actions, etc.).
- Access control must be least privilege; audit logs must exist for publish actions and policy changes.

(Details belong in governance docs; this plan just declares constraints.)
