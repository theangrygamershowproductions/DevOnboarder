---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: security-security
status: active
tags:
- documentation
title: Readme
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder Security Standards

## Quick References

- **NPM Security Quick Reference**: `../NPM_SECURITY_QUICK_REFERENCE.md`

- **Terminal Output Policy**: `../TERMINAL_OUTPUT_VIOLATIONS.md`

- **Enhanced Potato Policy**: `../enhanced-potato-policy.md`

## Comprehensive Standards

### Dependency Management

- **NPM Security Standards**: `npm-security-standards.md`

    - Root pollution prevention

    - Service-specific dependency management

    - Documentation tooling approach

    - Emergency cleanup procedures

### Access Control

- **Token Permissions Matrix**: `token-permissions-matrix.md`

    - GitHub token hierarchy

    - Service access patterns

    - Permission boundaries

## Policy Enforcement

DevOnboarder uses automated enforcement for security standards:

- **Root Artifact Guard**: Prevents repository pollution

- **Pre-commit hooks**: Validates compliance before commits

- **CI validation**: Repository-wide security checks

- **Terminal Output Policy**: Enforces plain ASCII in commands

## Integration Points

These security standards integrate with:

- Quality Control Framework (95% validation threshold)

- Virtual Environment Policy (isolation principles)

- Pre-commit Hook System (automatic enforcement)

- CI/CD Pipeline (continuous validation)

---

**Maintenance**: Security standards are updated as new threats emerge

**Enforcement**: Active via automated quality gates
**Scope**: All DevOnboarder development activities
