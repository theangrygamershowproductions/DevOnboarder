---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
phase: MVP
project: DevOnboarder
similarity_group: codex-codex
status: active
tags:

- documentation

title: Codex.Plan
updated: 04 July 2025 10:00 (EST)
updated_at: '2025-09-12'
version: v0.3.0
visibility: internal
---

# DevOnboarder – Codex Execution Plan

This document defines the roadmap and execution logic for Codex tasks during the
MVP push. It is synchronized with `codex.tasks.json` and ensures unified
delivery across the backend (auth, XP), Discord bot, and future frontend
modules.

---

## 🎯 MVP Goals

| Feature           | Description                                              | Status     |
| ----------------- | -------------------------------------------------------- | ---------- |

| Discord OAuth2    | Let users authenticate and receive session tokens        |  Done    |
| XP API            | Serve XP, level, and onboarding progress                 |  Done    |
| XP Submission     | Allow users to earn XP via bot or web actions            |  Done    |
| Discord Bot       | Handle `/verify`, `/profile`, and `/contribute` commands |  Done    |
| Contributor Roles | Flag admin/verified users via Discord roles              |  Done    |
| Frontend Scaffold | Display onboarding/XP state via session token            |  Pending |

---

## 🧩 Task Breakdown

###  Phase 1: Authentication

- [auth-001] Add Discord OAuth endpoints (`/login`, `/callback`)

- Store Discord user identity

- Issue JWT and respond with session payload

---

###  Phase 2: XP Interaction

- [xp-001] Create XP grant route (`/api/user/contribute`)

- Accept POST from bot or frontend

- Validate token, log contribution, award XP

---

###  Phase 3: Discord Bot Integration

- [bot-001] Fix `/api/user/level` fetch with missing `username`

- [bot-002] Refactor bot commands into `/commands/verify.ts`, `/profile.ts`, etc.

---

###  Phase 4: Frontend Bridge

- [frontend-001] Add React component to:

    - Show level, XP, onboarding state

    - Display “Start Onboarding” if phase is `intro`

    - Show Discord username/avatar from JWT payload

---

### WORK: Phase 5: Llama2 Agile Helper Integration

- [agile-001] Connect Llama2 Agile Helper agent for sprint summaries and backlog

  suggestions. See
  [codex task templates](../../codex/tasks/).

---

## 📆 Upcoming Milestones

| Date       | Task ID         | Target Version |
| ---------- | --------------- | -------------- |

| 2025-07-05 | integration-001 | v0.4.0         |
| 2025-07-12 | feedback-001    | v0.5.0         |
| 2025-07-19 | feedback-002    | v0.5.0         |
| 2025-07-26 | agile-001       | v0.5.0         |

---

## 🧠 Codex Strategy

- **Branch**: `main`

- **Trigger**: Codex will watch `codex.tasks.json` and `codex.plan.md` to assign/track completion

- **Expected Output**: Codex will generate:

    - `src/auth_service/routes/discord_oauth.py`

    - `src/xp_api/routes/contribute.py`

    - `bot/src/commands/verify.ts`

    - `bot/src/commands/profile.ts`

    - `bot/src/commands/contribute.ts`

    - `frontend/src/components/Login.tsx`

---

## PIN: Notes

- All `.env` values required for these modules are documented in `docs/env.md`

- `docs/CHANGELOG.md` should be updated automatically per Codex task output

- Codex must resolve all missing imports and extend database models in `models/` as needed

---

**Let's ship it.** 
