---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: docs-
status: active

tags:

- documentation

title: Coverage Masking Complete
updated_at: '2025-09-12'
visibility: internal
---

# Coverage Masking Solution - Implementation Complete

**Date**: September 5, 2025
**Status**:  IMPLEMENTED AND VALIDATED
**Priority**: CRITICAL

## Summary

Successfully resolved the **coverage masking problem** where pytest-cov was tracking all imported modules despite `--cov=src/xp` specifications.

## Root Cause

`pyproject.toml` configuration `source = ["src"]` overrode command-line coverage scoping, causing all services under `src/` to be tracked regardless of specific service targeting.

## Solution Implemented

- **Service-specific `.coveragerc` files** that completely override main configuration

- **Command pattern**: `pytest --cov --cov-config=.coveragerc.servicename`

- **Perfect isolation**: XP service now reports 49 statements, 100% coverage (not masked by other services)

## Validated Results

-  XP Service: 49 statements, 0 missed, 100% coverage

-  Discord Service: 59 statements, 0 missed, 100% coverage

-  No coverage masking: Each service reports only its own coverage

## Critical Files Created

- `.coveragerc.xp` - XP service isolation

- `.coveragerc.auth` - Auth service isolation

- `.coveragerc.discord` - Discord integration isolation

- `docs/COVERAGE_MASKING_SOLUTION.md` - Full documentation

- Updated CI workflow with service-specific configurations

## Next Steps

- Commit these changes to preserve the solution

- Update other services with their own `.coveragerc` files as needed

- Monitor per-service coverage trends for ROI-optimized testing

**Impact**: Transforms DevOnboarder from coverage-masked centralized testing to strategic per-service quality accountability.
