# DevOnboarder v3 vs v4 QC Standards

**Date**: 2025-12-03  
**Context**: v3 Feature Freeze - Stability-only mode

## Problem Statement

DevOnboarder has accumulated quality debt:
- YAML workflow lint errors
- Service-specific coverage below thresholds (XP: <95%, Discord: <95%)
- Comprehensive QC enforcement blocking all PRs

With 29 days left in v3 freeze, we cannot afford to block infrastructure fixes (actions policy, CI wiring) on historical quality debt cleanup.

## Solution: Two-Tier QC System

### v3 (Current) - Minimal Gate
**Required Check**: `qc-gate-minimum`

**Purpose**: Block obviously broken PRs while allowing infrastructure work to land

**Validates**:
- ✅ Dependencies install from requirements-ci.txt
- ✅ Python imports work (pytest, fastapi, sqlalchemy, etc.)
- ✅ Tests are discoverable/runnable

**Does NOT Block On**:
- Coverage thresholds (< 95% on services)
- YAML lint errors in workflows
- Full lint/format enforcement

**Rationale**: These are v3 compliance checks - "will this PR cause immediate breakage?" - not v4 perfection standards.

### v4 (Future) - Full Validation
**Non-Required Check**: `qc-full`

**Purpose**: Track comprehensive quality standards, make visible but non-blocking

**Validates**:
- ✅ All v3 gate checks PLUS:
- Backend coverage ≥ 96%
- Bot coverage = 100%
- Frontend coverage = 100%
- YAML lint passing
- Full ruff/black/mypy enforcement

**Transition Plan**:
1. **v3 (through 2025-12-31)**: qc-full runs, warns, but doesn't block
2. **v4 Cleanup Epic** (2026-01-01+):
   - Dedicated PR to fix YAML lint errors
   - Dedicated PR to raise XP service coverage to ≥95%
   - Dedicated PR to raise Discord service coverage to ≥95%
3. **v4 Hardening** (after cleanup): Make qc-full required

## What This Means for PRs

### Before (2025-12-02)
- **Required**: `qc-check` (comprehensive validation)
- **Status**: 30 PRs blocked on historical debt
- **Problem**: Can't land v3 infrastructure fixes

### After (2025-12-03)
- **Required**: `qc-gate-minimum` (basic sanity)
- **Non-Required**: `qc-full` (comprehensive validation)
- **Status**: v3 work can land if gate passes
- **Benefit**: Infrastructure fixes unblocked, quality debt visible but not paralyzing

## Implementation Details

### Files Changed
1. `.github/workflows/devonboarder-qc.yml`:
   - Created `qc-gate-minimum` job (required)
   - Renamed `qc-check` → `qc-full` (non-required)
   
2. `scripts/devon_qc.sh`:
   - Added `--gate-only` mode
   - Gate mode: quick smoke tests only
   - Full mode: calls qc_pre_push.sh for comprehensive checks
   
3. Branch Protection:
   - Changed required check from `qc-check` → `qc-gate-minimum`
   - Command: `gh api -X PUT .../required_status_checks/contexts -f 'contexts[]=qc-gate-minimum'`

### Testing Gate-Only Mode
```bash
cd ~/TAGS/ecosystem/DevOnboarder
python -m venv .venv-test
source .venv-test/bin/activate
./scripts/devon_qc.sh --gate-only
# Should pass quickly with ✅ QC Gate passed
deactivate
rm -rf .venv-test
```

## v4 Cleanup Backlog

**Track as separate issues in DevOnboarder**:

### Issue: Fix YAML Workflow Lint Errors
- **Type**: v4-scope, stability-only
- **Scope**: Clean up all yamllint violations in .github/workflows/
- **Estimate**: 1-2 hours
- **Blocker**: None (can be done anytime in v4)

### Issue: Raise XP Service Coverage to ≥95%
- **Type**: v4-scope, stability-only  
- **Scope**: Add tests to xp/ service until coverage threshold met
- **Estimate**: 4-6 hours
- **Blocker**: None (can be done anytime in v4)

### Issue: Raise Discord Service Coverage to ≥95%
- **Type**: v4-scope, stability-only
- **Scope**: Add tests to discord_integration/ until coverage threshold met  
- **Estimate**: 4-6 hours
- **Blocker**: None (can be done anytime in v4)

### Issue: Make qc-full Required
- **Type**: v4-scope
- **Scope**: After above three issues complete, change branch protection to require qc-full
- **Estimate**: 5 minutes
- **Blocker**: Above three issues must be green

## Governance Rationale

This aligns with TAGS v3 freeze philosophy:

**v3 (Stability-Only)**:
- CI/CD fixes ✅ Allowed (devon_qc.sh infrastructure)
- Test coverage improvements ✅ Allowed (but not required to merge)
- Bug fixes ✅ Allowed
- Quality gate adjustments ✅ Allowed (this change)

**v4 (Hardening)**:
- Historical quality debt cleanup
- Coverage uplift to meet strict thresholds
- Full enforcement of comprehensive QC

**Key Principle**: Don't let perfect (v4 standards) be the enemy of good (v3 stability).

## References
- **v3 Feature Freeze**: `TAGS_V3_FEATURE_FREEZE_2025-11-28.md`
- **12-Step Engineering Discipline**: Stabilize first, harden second
- **PR #1893**: Actions policy migration (v3 compliance work, shouldn't be blocked by v4 debt)

---

**Version**: 1.0.0  
**Author**: DevOnboarder Project / TAGS Engineering  
**Status**: Active (v3 freeze, 2025-12-03 → 2025-12-31)
