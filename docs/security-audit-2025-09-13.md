---
similarity_group: security-audit-2025-09-13.md-docs

content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---

# Security Audit - 2025-09-13

We ran dependency audits for Python and Node packages and scanned the code with Bandit.

## Python (`pip-audit`)

### ⚠️ Ignored Vulnerabilities (Require Periodic Review)

The following vulnerabilities are currently ignored:

```text

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
Next review due: 2025-12-13

No known vulnerabilities found
Name         Skip Reason
------------ ---------------------------------------------------------------------------

devonboarder Dependency not found on PyPI and could not be audited: devonboarder (0.1.0)

## Python Static Analysis (`bandit -r src -ll`)

Run started:2025-09-13 10:57:17.837869

Test results:
    No issues identified.

Code scanned:
    Total lines of code: 1662
    Total lines skipped (#nosec): 0
    Total potential issues skipped due to specifically being disabled (e.g., #nosec BXXX): 6

Run metrics:
    Total issues (by severity):
        Undefined: 0
        Low: 7
        Medium: 0
        High: 0
    Total issues (by confidence):
        Undefined: 0
        Low: 0
        Medium: 1
        High: 6
Files skipped (0):

## Node (`npm audit --audit-level=high`)

### frontend

found 0 vulnerabilities

### bot

found 0 vulnerabilities
