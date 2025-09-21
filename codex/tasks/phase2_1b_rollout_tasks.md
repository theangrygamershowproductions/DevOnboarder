---
title: Phase 2.1B Rollout Task List

project: DevOnboarder
codex_scope: rollout-phase2-1b
codex_role: project_maintainer
codex_type: task_index
status: active
created_at: 2025-08-03
tags:
  - rollout

  - codex-tasks

  - versioning

  - ci-hardening

---

## 🎯 Objective

Track and execute all required tasks for DevOnboarder Phase 2.1B rollout, focusing on documentation versioning, CLI fallback hardening, and public-facing readiness.

---

## 🗂️ Phase 2.1B - Core Task List

### 📚 Documentation Versioning

* [ ] Create `docs/v1/` directory structure

* [ ] Move existing `docs/` content into `docs/v1/`

* [ ] Add redirect stubs in root `docs/` to versioned equivalents

* [ ] Update internal links across all Markdown files to point to `/v1/`

* [ ] Create `docs/README.md` with index of all versioned documentation

### 🧪 CI CLI Resilience

* [ ] Fully remove all `--json` and `--jq` usage from GitHub CLI calls

* [ ] Harden all `gh` fallback logic (regex URL parsing, error traps)

* [ ] Add `pip check` and `python -m ensurepip` to CI sanity check

* [ ] Implement `ci_fallback_detector.py` to flag network/infra-related CI failures

### 🔓 Public Readiness & Disclosure Controls

* [ ] Audit repo for internal-only files and flags (`DO_NOT_SHARE`, `POTATO_IGNORE`, etc.)

* [ ] Enforce `visibility: internal` vs `public` in metadata headers

* [ ] Add `SECURITY.md` and confirm license terms

* [ ] Add `docs/disclosure/README.md` with Codex Agent boundaries

### 🧭 Routing and Governance Sync

* [ ] Align all `.codex/agents/*` with new repo structures

* [ ] Validate cross-repo orchestration callouts from core-instructions

* [ ] Ensure each agent has correct `codex_scope`, `codex_role`, `codex_type`, and `visibility`

---

## 🔐 Dependencies

* Phase 1B repo separation must be complete

* Codex routing framework must be updated to handle multi-repo architecture

---

Prepared by: Codex Orchestrator

Date: 2025-08-03
