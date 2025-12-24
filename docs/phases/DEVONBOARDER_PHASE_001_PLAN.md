# Phase Plan: DEVONBOARDER_PHASE_001 — Service Integration & CORS Validation

<!-- Version: 1.0.0 | Created: 2025-12-24 -->
<!-- PILOT: First real Phase Plan using the governance system -->

## Metadata

| Field | Value |
|-------|-------|
| **Phase ID** | `DEVONBOARDER_PHASE_001` |
| **Title** | Service Integration & CORS Validation |
| **Status** | `locked` |
| **Start Date** | 2025-12-24 |
| **Target End** | 2025-12-27 |
| **Actual End** | *(TBD - filled on closeout)* |
| **Owner** | @theangrygamershowproductions |
| **Triage Report** | [SERVICE_INTEGRATION_TRIAGE.md](../triage/SERVICE_INTEGRATION_TRIAGE.md) |

## 1. Phase Objective

**Goal:** Validate CORS configuration and service integration for DevOnboarder's multi-service architecture (FastAPI backend, React frontend, Discord bot), unblocking production deployment.

**This phase is complete when:**
- [ ] CORS configuration validated with real browser requests
- [ ] All services communicate successfully (backend ↔ frontend ↔ bot)
- [ ] Local development runbook created and tested
- [ ] Integration requirements documented for future CI automation

## 2. Scope Definition

### 2.1 Deliverables

| Deliverable | Description | Acceptance Criteria |
|-------------|-------------|---------------------|
| D1 | CORS validation report | Browser-based testing confirms expected behavior |
| D2 | Service integration verification | Health endpoints respond, cross-service calls succeed |
| D3 | Local development runbook | `docs/LOCAL_DEV_SETUP.md` exists and works |
| D4 | Integration requirements doc | `docs/INTEGRATION_REQUIREMENTS.md` for CI automation |

### 2.2 Allowed Paths

```
# Documentation
docs/triage/SERVICE_INTEGRATION_TRIAGE.md
docs/phases/DEVONBOARDER_PHASE_001_*.md
docs/LOCAL_DEV_SETUP.md
docs/INTEGRATION_REQUIREMENTS.md

# Configuration (if changes needed)
backend/app/core/config.py
docker-compose*.yaml

# Governance artifacts
.tgs/PROJECT_MANIFEST.json
.tgs/phase.lock.json
```

### 2.3 Out of Scope

- Automated integration test suite — deferred to Phase 2
- Discord bot feature completion — separate initiative
- Performance testing — post-deployment initiative
- CI pipeline changes — separate PR track

## 3. Issue Mapping

| Issue | Title | Status | Notes |
|-------|-------|--------|-------|
| #1893 | Service Integration PR | `open` | Primary implementation PR |
| #1932 | Scanner Audit CI | `open` | Related governance work |

**Issue Label:** `phase:001` *(apply to all related issues)*

## 4. Implementation Plan

### 4.1 Work Breakdown

| Task | Description | Estimate | Assignee | Status |
|------|-------------|----------|----------|--------|
| T1 | Start all services via docker-compose | 30 min | @agent | ⬜ |
| T2 | Browser-based CORS validation | 2 hrs | @agent | ⬜ |
| T3 | Test cross-service communication | 2 hrs | @agent | ⬜ |
| T4 | Create LOCAL_DEV_SETUP.md | 2 hrs | @agent | ⬜ |
| T5 | Create INTEGRATION_REQUIREMENTS.md | 1 hr | @agent | ⬜ |
| T6 | Peer review runbook (manual) | 1 hr | @human | ⬜ |

**Legend:** ⬜ Not started | 🔄 In progress | ✅ Complete | ❌ Blocked | ⏸️ Paused

### 4.2 Dependencies

| Dependency | Type | Status | Notes |
|------------|------|--------|-------|
| Docker installed | Prerequisite | ✅ Resolved | Required for local testing |
| Phase templates merged | Prerequisite | ✅ Resolved | PR #392 merged |

### 4.3 Milestones

| Milestone | Target Date | Criteria | Status |
|-----------|-------------|----------|--------|
| M1: Services running | 2025-12-24 | All 3 services respond to health checks | ⬜ |
| M2: CORS validated | 2025-12-25 | Browser requests succeed without CORS errors | ⬜ |
| M3: Docs complete | 2025-12-26 | Both runbook and requirements docs exist | ⬜ |
| M4: Phase closeout | 2025-12-27 | Closeout doc created, phase lock released | ⬜ |

## 5. Risk Register

| Risk ID | Description | Likelihood | Impact | Mitigation | Owner |
|---------|-------------|------------|--------|------------|-------|
| R1 | CORS config requires changes | Medium | Low | Document and fix in this phase | @agent |
| R2 | Service dependency issues | Low | Medium | Use pinned versions in compose | @agent |

## 6. Communication Plan

| Event | Audience | Channel | Frequency |
|-------|----------|---------|-----------|
| Progress update | Self | Phase plan doc | Daily |
| Blocker escalation | Human | PR comment | Immediate |
| Completion | Team | PR merge | On completion |

## 7. Testing & Validation

### 7.1 Test Plan

- [x] Health check endpoints respond (backend: `/health`, frontend: dev server)
- [x] CORS preflight requests succeed from frontend origin
- [x] API calls from frontend to backend return data (not CORS errors)
- [x] Discord bot connects to backend API

### 7.2 Acceptance Testing

| Test Case | Expected Result | Actual Result | Pass/Fail |
|-----------|-----------------|---------------|-----------|
| TC1: Backend health | 200 OK | *(to be filled)* | ⬜ |
| TC2: Frontend loads | React app renders | *(to be filled)* | ⬜ |
| TC3: CORS preflight | No CORS errors in browser console | *(to be filled)* | ⬜ |
| TC4: API data flow | Frontend displays backend data | *(to be filled)* | ⬜ |

## 8. Documentation Requirements

- [x] `docs/LOCAL_DEV_SETUP.md` — How to run locally
- [x] `docs/INTEGRATION_REQUIREMENTS.md` — What CI should validate
- [ ] Update README.md with links (optional)

## 9. Rollback Plan

**Trigger conditions:** CORS changes break existing functionality

**Rollback steps:**
1. Revert CORS config changes (if any) via `git revert`
2. Re-test with previous configuration
3. Document what went wrong in closeout

## 10. Phase Lock Status

**Lock Status:** `locked` *(informational only - enforcement not active)*

**Lock File:** [`.tgs/phase.lock.json`](../../.tgs/phase.lock.json)

When locked:
- Only issues #1893, #1932 should be worked
- Only allowed paths may be modified
- *(Note: Enforcement will be added in Wave 2)*

---

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2025-12-24 | @agent | Initial plan created |

---

<!-- 
PILOT NOTE: This is the first real Phase Plan. 
The closeout doc will be created when this phase completes.
-->
