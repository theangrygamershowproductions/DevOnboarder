---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: aar-protection-system.md-docs
status: active
tags:
- documentation
title: Aar Protection System
updated_at: '2025-09-12'
visibility: internal
---

# AAR Protection System

This document describes the multi-layer protection system for archived After Action Reports (AARs) to prevent accidental edits while allowing controlled access.

## Protection Layers

### 1. Pre-commit Protection (.pre-commit-config.yaml)

- Added `prevent-archived-doc-edits` hook with regex pattern matching

- Blocks commits that modify files matching `docs/ci/*-archived.md`

- Provides clear error messages when protection is triggered

### 2. GitHub Actions Workflow (.github/workflows/protect-archived-aar.yml)

- PR-level protection that blocks merges unless approved

- Requires specific label (`approved-crit-change`) for bypass

- Only allows edits from authorized team members

- Comprehensive logging and status reporting

### 3. CODEOWNERS Protection (.github/CODEOWNERS)

- Added protection rules for `docs/ci/*-archived.md` files

- Requires review from @reesey275

- Wildcard patterns for comprehensive coverage

## Protection Behavior

1. **Local Protection**: Pre-commit hooks prevent accidental commits

2. **PR Protection**: GitHub Actions workflow blocks unauthorized merges

3. **Review Protection**: CODEOWNERS requires team review

## Bypass Procedures

For authorized edits to archived documents:

1. Add `approved-crit-change` label to PR

2. Ensure PR is created by authorized team member (@reesey275)

3. Pass CODEOWNERS review requirements

4. Pre-commit hooks can be bypassed with `--no-verify` (emergency only)

## Files Protected

- `docs/ci/ci-modernization-2025-09-01-archived.md`

- Any file matching pattern `docs/ci/*-archived.md`

This implementation provides bulletproof protection while maintaining controlled access for necessary updates.
