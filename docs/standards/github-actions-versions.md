---
author: DevOnboarder Team

ci_integration: true
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Standards documentation
document_type: standards
merge_candidate: false
project: DevOnboarder
similarity_group: standards-standards
status: active
tags:

- standards

- policy

- documentation

title: Github Actions Versions
updated_at: '2025-09-12'
virtual_env_required: true
visibility: internal
---

# GitHub Actions Version Requirements

**Document Type**: Technical Standard
**Status**: ACTIVE
**Effective Date**: September 7, 2025
**Owner**: DevOnboarder CI Team

## Overview

This document establishes standardized GitHub Actions version requirements for all DevOnboarder workflows. These standards prevent CI failures, security vulnerabilities, and ensure consistent behavior across all workflows.

## Standard Action Versions

### Core Actions (MANDATORY)

```yaml

# ✅ REQUIRED - Current standardized versions

- uses: actions/checkout@v5        # Repository checkout

- uses: actions/setup-python@v5    # Python environment setup

- uses: actions/setup-node@v4      # Node.js environment setup

- uses: actions/cache@v4          # Dependency caching

```

### Security & Workflow Actions

```yaml

# ✅ REQUIRED - Security and workflow management

- uses: ibiqlik/action-yamllint@v3     # YAML linting

- uses: github/super-linter@v6         # Multi-language linting (if used)

- uses: codecov/codecov-action@v4      # Coverage reporting (if used)

```

## Version Selection Criteria

### Security-First Approach

- **Latest stable versions**: Prioritize current major versions for security patches

- **SHA pinning**: All workflows use SHA-pinned versions (implemented in CI modernization)

- **Vulnerability monitoring**: Regular updates for security advisories

### Compatibility Requirements

- **Python 3.12**: Compatible with DevOnboarder's mandatory Python version

- **Node.js 22**: Compatible with DevOnboarder's mandatory Node.js version

- **Ubuntu latest**: All actions must work with GitHub's ubuntu-latest runners

## Enforcement Infrastructure

### Pre-commit Validation

All workflow files validated by:

```bash

# YAML linting with standardized configuration

yamllint .github/workflows/**/*.yml -c .github/.yamllint-config

```

### CI Pipeline Validation

- **validate-yaml job**: Runs on every PR and push

- **Actionlint integration**: Validates GitHub Actions syntax and versions

- **Shellcheck integration**: Validates embedded shell scripts

### Automated Updates

- **Dependabot**: Monitors action versions for security updates

- **CI Modernization Process**: Systematic updates documented in `docs/ci/ci-modernization-2025-09-01.md`

## Migration Guidelines

### Updating Action Versions

```bash

# 1. Update workflow templates first

find .github/workflow-templates/ -name "*.yml" -exec sed -i 's/actions\/checkout@v4/actions\/checkout@v5/g' {} \;

# 2. Update existing workflows

find .github/workflows/ -name "*.yml" -exec sed -i 's/actions\/checkout@v4/actions\/checkout@v5/g' {} \;

# 3. Validate changes

yamllint .github/workflows/**/*.yml -c .github/.yamllint-config

# 4. Test in CI before merging

```

### Breaking Changes

When major version updates introduce breaking changes:

1. **Impact Assessment**: Review action changelogs and DevOnboarder usage

2. **Testing**: Validate in development branch first

3. **Documentation**: Update this document and workflow templates

4. **Team Communication**: Notify team of changes via PR review process

## Workflow Templates Integration

### Template Standards

All templates in `.github/workflow-templates/` must use current versions:

- **basic-ci.yml**: Standard CI pipeline template

- **pr-automation.yml**: PR automation template

- **documentation.yml**: Documentation validation template

- **security.yml**: Security scanning template

### Template Validation

Templates validated by:

```bash

# Validate all workflow templates

bash scripts/validate_workflow_permissions.sh --templates

```

## Compliance Monitoring

### Regular Audits

- **Monthly**: Review action versions for security updates

- **Quarterly**: Comprehensive audit of all workflow files

- **On-demand**: When security advisories are published

### Automated Reporting

```bash

# Generate version compliance report

find .github/workflows/ -name "*.yml" -exec grep -H "uses:" {} \; | \
    sort | uniq -c | sort -nr > reports/action-versions.txt

```

## Troubleshooting

### Common Version Issues

**Problem**: `Error: The process '/usr/bin/git' failed with exit code 128`
**Cause**: Outdated checkout action without proper token configuration
**Solution**: Upgrade to `actions/checkout@v5` with explicit token

**Problem**: Python setup fails with `##[error]Version 3.12 with arch x64 not found`
**Cause**: Outdated setup-python action
**Solution**: Upgrade to `actions/setup-python@v5`

**Problem**: Node.js version mismatch errors
**Cause**: Inconsistent setup-node versions across workflows
**Solution**: Standardize on `actions/setup-node@v4`

### Version Compatibility Matrix

| Action | DevOnboarder Version | Python 3.12 | Node.js 22 | Ubuntu Latest |
|--------|---------------------|--------------|------------|---------------|
| checkout@v5 | ✅ Current | ✅ | ✅ | ✅ |
| setup-python@v5 | ✅ Current | ✅ | N/A | ✅ |
| setup-node@v4 | ✅ Current | N/A | ✅ | ✅ |
| cache@v4 | ✅ Current | ✅ | ✅ | ✅ |

## Implementation History

### CI Modernization 2025-09-01

**Major Update**: Comprehensive version standardization

- Updated all workflows from mixed v3/v4 to standardized versions

- Implemented SHA pinning across all workflows

- Added actionlint configuration for validation

- Removed obsolete workflows causing syntax errors

**Commit Reference**: See `docs/ci/ci-modernization-2025-09-01.md`

### Template Creation 2025-09-07

**Infrastructure Addition**: Workflow templates for consistent CI

- Created 4 security-first workflow templates

- Integrated with DevOnboarder's CI permissions framework

- Established template validation infrastructure

## Related Documentation

- **CI Permissions Framework**: `docs/CI_PERMISSIONS_SOLUTION.md`

- **CI Modernization**: `docs/ci/ci-modernization-2025-09-01.md`

- **Strategic Foundation Systems**: `docs/STRATEGIC_FOUNDATION_SYSTEMS.md`

- **Workflow Templates**: `.github/workflow-templates/README.md`

## Approval & Review

**Next Review Date**: December 7, 2025 (Quarterly)
**Review Criteria**: Security updates, compatibility, DevOnboarder evolution

---

**Established**: September 7, 2025

**Authority**: DevOnboarder CI Modernization Framework
**Compliance**: Mandatory for all DevOnboarder workflows
**Enforcement**: Pre-commit hooks + CI validation + Template system
