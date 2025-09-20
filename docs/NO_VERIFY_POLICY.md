---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: NO_VERIFY_POLICY.md-docs
status: active
tags:

- documentation

title: No Verify Policy
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder --no-verify Policy Enforcement

## CRITICAL: Zero Tolerance Policy

DevOnboarder has a **ZERO TOLERANCE POLICY** for unauthorized `--no-verify` usage. This flag bypasses quality gates and undermines the project's "quiet reliability" philosophy.

## Policy Requirements

### 🥔 Potato Approval System

All `--no-verify` usage MUST have explicit Potato Approval through one of these mechanisms:

1. **Emergency Approval File**: `.potato_emergency_approval` (1-hour validity)

2. **Script-based Approval**: Interactive approval process

3. **Documentation Approval**: Explicit comment in code

### Emergency Approval Process

#### 1. Automatic Detection

- `scripts/validate_no_verify_usage.sh` scans for unauthorized usage

- Pre-commit hooks block unauthorized attempts

- CI pipeline validates all commits

#### 2. Emergency Request Process

```bash

# Use the git safety wrapper for emergency commits

./scripts/git_safety_wrapper.sh commit --no-verify -m "Emergency fix"

```

This triggers:

- Emergency justification questions

- Impact assessment requirement

- Rollback plan documentation

- 1-hour time-limited approval

- Comprehensive audit logging

#### 3. Required Emergency Justification

- **Production Outage**: Service down affecting users

- **Critical Security Fix**: Immediate security vulnerability patch

- **Data Loss Prevention**: Preventing irreversible data loss

- **Regulatory Compliance**: Legal/compliance deadline

#### 4. Approval Documentation Format

```bash

# POTATO: EMERGENCY APPROVED - 2025-08-05 - [INITIALS]

# REASON: [Specific emergency reason]

# IMPACT: [What happens if not bypassed immediately]

# ROLLBACK: [How to properly fix after emergency]

git commit --no-verify -m "EMERGENCY: [description]"

```

## Enforcement Mechanisms

### 1. Validation Scripts

- `scripts/validate_no_verify_usage.sh` - Comprehensive scanning

- `scripts/git_safety_wrapper.sh` - Interactive approval process

- Pre-commit hooks with validation

- CI pipeline enforcement

### 2. Detection Patterns

- Shell scripts: `git.*--no-verify`

- Documentation: `--no-verify` references

- Git aliases: Commands that bypass hooks

- Commit messages: Emergency indicators

### 3. Audit Trail

- All emergency usage logged to `logs/git_safety_*.log`

- Approval files tracked with timestamps

- Automatic cleanup after 1 hour

- CI pipeline audit reports

## Violation Response

### Immediate Actions

1. **Block the commit/push** - No exceptions

2. **Require proper fix** - Address root cause

3. **Document violation** - Audit trail maintenance

4. **Education reminder** - Policy reinforcement

### Quality Gate Resolution

Instead of bypassing, fix the actual issues:

```bash

# Check what's failing

./scripts/qc_pre_push.sh

# Fix specific issues

python -m ruff check --fix .
python -m black .
markdownlint --fix docs/

# Commit properly

git commit -m "Fix quality issues identified by QC"

```

## Examples

### ❌ FORBIDDEN - Unauthorized Usage

```bash

# These will be blocked by validation

git commit --no-verify -m "Quick fix"
git push --no-verify origin main
git commit --no-verify -m "Skip linting"

```

### ✅ AUTHORIZED - Emergency Usage

```bash

# POTATO: EMERGENCY APPROVED - 2025-08-05 - PL

# REASON: Production auth service crashed, users cannot login

# IMPACT: Complete service outage affecting all users

# ROLLBACK: Will fix linting violations in immediate follow-up PR

git commit --no-verify -m "EMERGENCY: Fix auth service crash in user validation"

```

### ✅ PREFERRED - Proper Quality Resolution

```bash

# Fix the actual issues instead of bypassing

./scripts/qc_pre_push.sh  # Identify issues

python -m ruff check --fix .  # Fix Python issues

markdownlint --fix docs/  # Fix documentation

git commit -m "Resolve quality gate violations"

```

## Integration Points

### Pre-commit Hooks

```yaml

# .pre-commit-config.yaml addition

- repo: local

  hooks:
    - id: validate-no-verify

      name: Validate --no-verify usage
      entry: ./scripts/validate_no_verify_usage.sh
      language: script
      stages: [commit, push]

```

### CI Pipeline

```yaml

# GitHub Actions integration

- name: Validate No-Verify Usage

  run: |
    bash scripts/validate_no_verify_usage.sh
    if [ $? -ne 0 ]; then
      echo "Unauthorized --no-verify usage detected"
      exit 1
    fi

```

### Git Aliases Prevention

```bash

# Check for problematic aliases

git config --global --get-regexp alias | grep -E "(--no-verify|bypass|skip)"
git config --local --get-regexp alias | grep -E "(--no-verify|bypass|skip)"

```

## Monitoring and Metrics

### Usage Statistics

- Emergency approvals granted per month

- Most common emergency reasons

- Average time between emergency and fix

- Quality gate bypass frequency

### Health Indicators

- Zero unauthorized usage (target)

- Emergency approval ratio < 1% of commits

- Quality gate success rate > 95%

- Average fix time < 24 hours post-emergency

## Training and Documentation

### Developer Onboarding

1. **Quality Gate Philosophy**: Understanding "quiet reliability"

2. **Proper Issue Resolution**: Fix root causes, not symptoms

3. **Emergency Procedures**: When and how to use emergency approvals

4. **Audit Compliance**: Documentation and tracking requirements

### Troubleshooting Guide

- Common quality gate failures and fixes

- Emergency approval process walkthrough

- Post-emergency cleanup procedures

- Escalation paths for complex issues

## Policy Updates

This policy may only be modified with:

1. **Project Lead Approval** (Potato Approval)

2. **Documentation Update** in this file

3. **Script Updates** to reflect policy changes

4. **Team Communication** of policy changes

---

**Last Updated**: 2025-08-05

**Policy Version**: 1.0.0
**Enforcement**: Active
**Violations**: Zero Tolerance
