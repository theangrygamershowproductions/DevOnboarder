---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: GitHub issue draft for Training Simulation Module (TSM) enhancement feature
document_type: draft
merge_candidate: false
project: DevOnboarder
similarity_group: docs-
status: active
tags:
- draft
- github-issue
- tsm
- enhancement
title: TSM GitHub Issue Draft
updated_at: '2025-09-12'
visibility: internal
---

# Feature: Training Simulation Module (TSM)

## Labels

- `enhancement`

- `training`

- `roadmap`

## Description

The Training Simulation Module (TSM) is a proposed feature that creates a **gamified training environment for junior developers** inside DevOnboarder. Its purpose is to intentionally generate errors, capture them in CI, and use Codex + AAR loops to teach doctrine through repeatable scenarios.

The module introduces a **leveling system**:

- **Level 0 (Sandbox)**: Developer faces intentionally broken patterns (e.g., missing `.gitignore` entries, malformed PR checklist).

- **Level 1 (CI Enforcement Basics)**: Must pass real CI guardrails (Potato Policy, markdownlint, Vale).

- **Level 2 (Codex/AAR Integration)**: Learns to trigger Codex auto-fixes and generate After Action Reports (AARs) from errors.

- **Level 3 (Production Ready)**: Permissions lifted; contributes to production with minimal supervision.

This feature will not be part of the initial MVP but should be tracked as a **post-MVP roadmap item**.

## Acceptance Criteria

- [ ] A sandbox mode that simulates common mistakes

- [ ] A clear leveling system tied to CI pass/fail events

- [ ] Integration with Codex agents for auto-fixes and AAR generation

- [ ] Documented progression path for moving from sandbox to production readiness

## Priority

Roadmap (Phase 3+)

## Notes

- This feature aligns with the **"disciplined mad scientist"** philosophy: using mistakes as training data

- Future potential: evolve TSM into an **internal certification or bootcamp system**

## Strategic Context

This feature supports DevOnboarder's mission to create reliable, automated onboarding systems by transforming common development mistakes into structured learning opportunities. The TSM would complement the existing Codex agent ecosystem and AAR framework already in place.

## Implementation Considerations

- Leverage existing CI infrastructure (Terminal Output Policy, Root Artifact Guard, etc.)

- Build on established AAR generation system (`scripts/generate_aar.sh`)

- Integrate with current Codex agent validation framework

- Align with Strategic Repository Splitting Implementation timeline (post-October 2025)
