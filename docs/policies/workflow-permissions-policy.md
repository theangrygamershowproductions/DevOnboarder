# Universal Workflow Permissions Policy

**Policy Version**: 1.0
**Part of**: DevOnboarder Universal Version Policy
**Effective**: 2025-08-09
**Security Classification**: Critical

## Executive Summary

All GitHub Actions workflows MUST include explicit `permissions:` blocks to comply with DevOnboarder security standards and prevent CodeQL warnings.

## Core Requirements

### 1. Explicit Permissions Mandatory

**ALL workflows must include a `permissions:` block.**

```yaml
# ✅ REQUIRED - Minimal permissions template
name: Workflow Name

permissions:
  contents: read

on:
  # ... triggers
```

### 2. Standard Permission Patterns

| Workflow Type | Required Permissions | Use Case |
|--------------|---------------------|----------|
| **Read-Only** | `contents: read` | Version validation, diagnostics, linting |
| **CI Pipeline** | `contents: read, actions: read, checks: write` | Test execution, status reporting |
| **PR Automation** | `contents: read, pull-requests: write, issues: write` | PR comments, issue creation |

### 3. Security Principles

- **Principle of Least Privilege**: Only grant necessary permissions
- **Explicit Over Implicit**: No reliance on default GitHub token permissions
- **CodeQL Compliance**: Prevents "Workflow does not contain permissions" warnings
- **Audit Trail**: Clear permission documentation for security reviews

## Implementation

### Automated Validation

```bash
# Validate all workflows for permissions compliance
bash scripts/validate_workflow_permissions.sh
```

### Pre-Commit Integration

The Universal Version Policy includes workflow permissions validation in pre-commit hooks to prevent non-compliant workflows from being committed.

### Emergency Exceptions

Any workflow requiring broader permissions MUST:

1. Document the business justification
2. Include `# POTATO: SECURITY-EXCEPTION - [reason]` comment
3. Undergo security review process

## Enforcement

- **Pre-commit hooks**: Block commits of non-compliant workflows
- **CI validation**: `validate_workflow_permissions.sh` runs on every PR
- **CodeQL scanning**: Automated security analysis flags violations
- **Required status checks**: Permissions validation must pass before merge

## Migration Guide

For existing workflows missing permissions, add minimal permissions:

```yaml
permissions:
  contents: read
```

Upgrade to specific permissions as needed:

```yaml
permissions:
  contents: read
  pull-requests: write  # For PR automation
  issues: write        # For issue creation
```

## Benefits

- ✅ **Security Compliance**: Meets GitHub security best practices
- ✅ **CodeQL Clean**: Eliminates security scan warnings
- ✅ **Audit Ready**: Clear permission documentation
- ✅ **Principle of Least Privilege**: Minimal required permissions
- ✅ **Consistency**: Standardized across all workflows

## Exception Process

**Requesting Enhanced Permissions** (e.g., `contents: write`):

1. **Document justification** in workflow comments explaining why enhanced permissions are required
2. **Submit PR** with maintainer review request via CODEOWNERS
3. **Security review** must demonstrate necessity and scope limitation

Example exception request format:

```yaml
# PERMISSION EXCEPTION: contents: write required for automated releases
# Justification: Workflow creates Git tags and GitHub releases
# Scope: Limited to release branch only
# Approved by: @maintainer-handle
permissions:
    contents: write
```

---

**Related Policies**: No Default Token Policy, DevOnboarder Universal Version Policy
**Validation Script**: `scripts/validate_workflow_permissions.sh`
**Orchestrator Config**: `.codex/orchestrator/config.yml` → `workflow_permissions`
