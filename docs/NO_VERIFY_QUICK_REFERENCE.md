---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: NO_VERIFY_QUICK_REFERENCE.md-docs
status: active
tags:

- documentation

title: No Verify Quick Reference
updated_at: '2025-09-12'
visibility: internal
---

# --no-verify Policy Quick Reference

## 🚨 ZERO TOLERANCE POLICY

DevOnboarder has **ZERO TOLERANCE** for unauthorized `--no-verify` usage.

##  FORBIDDEN

```bash

# These commands are BLOCKED

git commit --no-verify -m "Quick fix"
git push --no-verify origin main
git commit --no-verify -m "Skip linting"

```

##  EMERGENCY PROCESS

**Only for true emergencies** (production outage, security fix):

```bash

# Use the safety wrapper for emergencies

./scripts/git_safety_wrapper.sh commit --no-verify -m "EMERGENCY: description"

```

This triggers:

- Emergency justification questions

- Impact assessment requirement

- Rollback plan documentation

- 1-hour time-limited approval

- Comprehensive audit logging

##  PREFERRED SOLUTION

**Fix the actual issues instead of bypassing:**

```bash

# Identify what's failing

./scripts/qc_pre_push.sh

# Fix Python issues

python -m ruff check --fix .
python -m black .

# Fix documentation issues

markdownlint --fix docs/

# Commit properly

git commit -m "Fix quality gate violations"

```

##  CHECK COMPLIANCE

```bash

# Validate current compliance

./scripts/validate_no_verify_usage.sh

# Show enforcement system status

./scripts/show_no_verify_enforcement.sh

```

##  EMERGENCY APPROVAL FORMAT

```bash

# POTATO: EMERGENCY APPROVED - 2025-08-05 - [INITIALS]

# REASON: [Specific emergency reason]

# IMPACT: [What happens if not bypassed immediately]

# ROLLBACK: [How to properly fix after emergency]

git commit --no-verify -m "EMERGENCY: [description]"

```

## ⚖️ ENFORCEMENT

- **Pre-commit hooks**: Block unauthorized usage

- **CI pipeline**: Validate all commits

- **Git aliases**: Detect bypass attempts

- **Audit logging**: Track all emergency usage

- **1-hour limit**: Emergency approvals expire

---

**Remember**: DevOnboarder's "quiet reliability" depends on quality gates.

Fix issues properly rather than bypassing them.
