---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: security-audit-2025-07-30.md-docs
status: active
tags:
- documentation
title: Security Audit 2025 07 30
updated_at: '2025-09-12'
visibility: internal
---

# Security Audit - 2025-07-30

We ran dependency audits for Python and Node packages and scanned the code with Bandit.

## Python (`pip-audit`)

### ⚠️ Ignored Vulnerabilities (Require Periodic Review)

The following vulnerabilities are currently ignored:

```bash

# DevOnboarder pip-audit ignore configuration

# This file contains security vulnerabilities that cannot be fixed

# due to upstream maintainer decisions or lack of available patches

#
# CRITICAL: All ignored vulnerabilities must be documented in

# docs/security-ignore-registry.md with quarterly review schedules

#
# GHSA-wj6h-64fc-37mp: Timing attack in python-ecdsa on P-256 curve

# - Affects: ecdsa 0.19.1 (required by python-jose for JWT functionality)

# - Severity: Low (timing attacks affect signing operations, not verification)

# - Status: No planned fix according to maintainers (considered 'out of scope')

# - Impact: DevOnboarder uses JWT verification (not signing) so minimal risk

# - First ignored: 2025-07-30

# - Next review: 2025-10-30

GHSA-wj6h-64fc-37mp

```

**ACTION REQUIRED**: These ignored vulnerabilities should be reviewed quarterly.
Next review due: 2025-10-30

```text
Found 1 known vulnerability in 1 package
Name  Version ID                  Fix Versions
----- ------- ------------------- ------------

ecdsa 0.19.1  GHSA-wj6h-64fc-37mp
Name         Skip Reason
------------ ---------------------------------------------------------------------------

devonboarder Dependency not found on PyPI and could not be audited: devonboarder (0.1.0)

```
