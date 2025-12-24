# DevOnboarder Dependency Debt – 2025-12-08

This document captures dependency-level security and maintenance debt
identified during the v3 freeze that is **deliberately deferred** to
Phase 4 (platform refactor and CI hardening).

## Scope

- Repository: DevOnboarder
- Date: 2025-12-08
- Related docs:
  - DEVONBOARDER_CI_RECON_2025-12-05.md
  - CI_PLATFORM_DESIGN_2026.md
  - CI_PATTERN_INVENTORY_2025-12-06.md
  - V3_RELEASE_GATE_STATUS_2025-12-06.md

---

## 1. js-yaml – Prototype Pollution (Dependabot #12, #13, #17, #18)

- **Package**: `js-yaml`
- **Severity**: Medium
- **Locations**: dev/build tooling (lint, config utilities, etc.)
- **Issue**: Prototype pollution via unsafe schema/loader usage
- **Why deferred**:
  - Dev-only / tooling surface
  - Likely to be replaced or upgraded wholesale during Phase 4
  - May require coordinated updates across multiple Node workspaces

**Phase 4 Plan**:

- Fold into JS tooling refresh as part of:
  - CI Platform Consolidation (tags-workflows + AI-CI-Toolkit)
  - Frontend/bot dependency normalization
- Acceptance: `js-yaml` updated or removed across all workspaces, no advisories open.

---

## 2. tar – Race Condition in ci-toolkit (Dependabot #9)

- **Package**: `tar`
- **Severity**: Medium
- **Location**: ci-toolkit / build-time context only
- **Issue**: Potential race condition when extracting archives
- **Why deferred**:
  - Only used in CI/build pipeline, not runtime
  - Will likely change when CI tool packaging is standardized in Phase 4

**Phase 4 Plan**:

- Address as part of CI toolchain hardening in:
  - Workstream C (CI Platform Consolidation)
  - Any dedicated `AI-CI-Toolkit` refresh
- Acceptance: `tar` updated to non-vulnerable range or usage removed.

---

## 3. Governance Note

- All **critical/high** runtime or CI supply-chain vulnerabilities are handled
  immediately (patch/minor bumps on v3-safe branches).
- This file exists to:
  - Avoid "forgotten" Dependabot alerts
  - Keep v3 freeze honest while not ignoring real issues
  - Feed Phase 4 planning with concrete, dated evidence.

---

## 4. Related Work

- **Fixed in v3**: glob 10.4.5 → 10.5.0 (high severity, command injection)
  - PR: `deps/security-2025-12-08`
  - Addressed alerts: #19, #20, #21
  - Status: ✅ Merged (2025-12-08)

---

**Next Review**: Phase 4 kickoff (Q1 2026)
