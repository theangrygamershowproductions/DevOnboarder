# Required Status Checks for Main Branch Protection

**Last Updated**: August 10, 2025  
**Source**: Drift-proof validation system with live PR check verification  
**Status**: ✅ DRIFT PROTECTION ACTIVE

This document defines the exact status check names required for main branch protection in DevOnboarder.

## 🛡️ Drift-Proof Validation System

DevOnboarder now includes comprehensive drift detection and validation:

### Validation Scripts

1. **`scripts/assert_required_checks.sh <pr-number>`**
   - Compares required checks in `protection.json` vs live PR check runs
   - Detects if branch protection is ineffective due to name mismatches
   - Supports both jq and Python fallback for parsing

2. **`scripts/verify-branch-protection.sh`**
   - Validates server branch protection state vs local `protection.json`
   - Detects configuration drift in boolean settings and contexts
   - Ensures protection configuration remains synchronized

3. **`scripts/audit-workflow-headers.sh`**
   - Validates all workflows have proper token and policy documentation
   - Ensures compliance with Universal Workflow Permissions Policy
   - Checks for maintenance and purpose documentation

### Automated CI Guards

- **Guard Required Checks** (`.github/workflows/guard-required-checks.yml`)
    - Triggers on workflow/toolchain file changes
    - Automatically validates required checks against live PRs

- **Audit Workflow Headers** (`.github/workflows/audit-workflow-headers.yml`)
    - Triggers on workflow file modifications
    - Ensures header compliance across all workflows

## Validation Commands

```bash
# Check required checks against live PR
./scripts/assert_required_checks.sh 1123

# Verify branch protection state
./scripts/verify-branch-protection.sh

# Audit workflow headers
./scripts/audit-workflow-headers.sh

# Matrix drift protection (existing)
./scripts/matrix_drift_protection.sh

# Skip behavior confirmation (existing)
./scripts/skip_behavior_confirmation.sh
```

## ⚠️ CRITICAL: Branch Protection Configuration

DevOnboarder implements a **three-tier status check system** for production-ready governance:

### Must-Have Policy Guards

These checks **MUST PASS** before any merge to main:

- `Version Policy Audit/Verify Node 22.x + Python 3.12.x Policy (pull_request)` ✅ VERIFIED
- `Validate Permissions/check (pull_request)` ✅ VERIFIED
- `Pre-commit Validation/Validate pre-commit hooks (pull_request)` ✅ VERIFIED

### Quality & Security Checks (Strongly Recommended)

Core quality and security validation:

- `CI/test (3.12, 22) (pull_request)` ✅ VERIFIED
- `AAR System Validation/Validate AAR System (pull_request)` ✅ VERIFIED
- `Orchestrator/orchestrate (pull_request)` ✅ VERIFIED
- `CodeQL/Analyze (python) (dynamic)` ✅ VERIFIED
- `CodeQL/Analyze (javascript-typescript) (dynamic)` ✅ VERIFIED

### Optional Safety Rails

Additional protection for comprehensive validation:

- `Root Artifact Monitor/Root Artifact Guard (pull_request)` ✅ VERIFIED
- `Terminal Output Policy Enforcement/Enforce Terminal Output Policy (pull_request)` ✅ VERIFIED
- `Enhanced Potato Policy Enforcement/enhanced-potato-policy (pull_request)` ✅ VERIFIED
- `Documentation Quality/validate-docs (pull_request)` ✅ VERIFIED

## Implementation

### GitHub CLI Command

Apply branch protection with all required checks:

```bash
OWNER=theangrygamershowproductions
REPO=DevOnboarder

gh api \
  -X PUT \
  repos/$OWNER/$REPO/branches/main/protection \
  -H "Accept: application/vnd.github+json" \
  --input protection.json
```

### Verification Steps

1. **Check Protection Applied**: Visit GitHub Settings → Branches → main
2. **Verify Required Checks**: Confirm all 12 status checks are listed
3. **Test Protection**: Create test PR and verify merge blocking until checks pass
4. **Monitor Effectiveness**: Ensure policy guards pass immediately, red jobs turn green after workflow permission fixes

## Maintenance

### When Check Names Change

If workflow names or job names change, update:

1. `protection.json` - Update the `contexts` array
2. This documentation file
3. Re-apply branch protection with updated configuration

### Audit Trail

- **Created**: 2025-08-10 (DevOnboarder CI Issues Fix)
- **Purpose**: Prevent merging until critical quality gates pass
- **Scope**: All merges to main branch
- **Authority**: Universal Workflow Permissions Policy + Required Status Checks

## Troubleshooting

### Common Issues

1. **Check Name Mismatch**: Use `gh pr checks` on active PR to get exact names
2. **Matrix Job Names**: Include matrix parameters in check names (e.g., `(3.12, 22)`)
3. **Dynamic vs Static**: CodeQL shows `(dynamic)`, pre-commit shows `(pull_request)`

### Emergency Override

⚠️ **NEVER use admin override** except for genuine emergencies with project lead approval and documented justification in AAR system.

### Policy Enforcement

This configuration enforces DevOnboarder's "quiet reliability" philosophy by ensuring:

- **Version consistency** across all environments
- **Permission validation** prevents security vulnerabilities
- **Quality gates** maintain 95%+ coverage and standards
- **Documentation quality** via automated linting
- **Security scanning** via CodeQL and enhanced policies
