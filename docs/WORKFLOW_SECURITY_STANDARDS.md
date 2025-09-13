---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: WORKFLOW_SECURITY_STANDARDS.md-docs
status: active
tags:
- documentation
title: Workflow Security Standards
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder Workflow Security Standards

## The Recurring Permissions Problem

Every new GitHub Actions workflow in DevOnboarder triggers security warnings because GitHub Actions defaults to **overly permissive** token permissions.

## Why This Happens

1. **Insecure Defaults**: GitHub workflows get broad permissions by default (`contents: write`, `actions: write`, etc.)

2. **Copy-Paste Development**: New workflows copy existing ones without security review

3. **No Template System**: DevOnboarder lacks standardized workflow templates

4. **Security-First Mindset Required**: Each workflow needs explicit permission analysis

## DevOnboarder Standards

### Job-Level Permissions Pattern

DevOnboarder uses **job-level permissions** for granular control:

```yaml
jobs:
  example-job:
    permissions:
      contents: read           # Minimal default for checkout

      pull-requests: write     # Only if PR comments needed

      issues: write           # Only if issue creation needed

    runs-on: ubuntu-latest
    steps:
      # ... job steps

```

### Common Permission Patterns

| Use Case | Required Permissions |
|----------|---------------------|
| **Basic CI/Testing** | `contents: read` |

| **PR Comments** | `contents: read`, `pull-requests: write` |

| **Issue Creation** | `contents: read`, `issues: write` |

| **Coverage Badge Updates** | `contents: write` (for commits) |

| **Artifact Upload** | `contents: read` (default with upload actions) |

### Workflow Security Checklist

- [ ] **Explicit permissions** defined at job level

- [ ] **Principle of least privilege** - only required permissions

- [ ] **No workflow-level permissions** unless all jobs need same access

- [ ] **Security review** for any `write` permissions

- [ ] **CodeQL validation** passes without warnings

## Prevention Strategy

### 1. Workflow Templates (Recommended)

Create `.github/workflow-templates/` with security-compliant templates:

- `basic-ci.yml` - Testing and validation

- `pr-automation.yml` - PR comments and automation

- `documentation.yml` - Documentation validation

- `security.yml` - Security scanning workflows

### 2. Pre-commit Validation

Add workflow permission validation to pre-commit hooks:

```bash

# Check all workflows have explicit permissions

scripts/validate_workflow_permissions.sh

```

### 3. Security Documentation

Document the "why" behind permission requirements so developers understand the security implications.

## Example: Milestone Validation Fix

**Before** (Security Warning):

```yaml
jobs:
  validate-milestones:
    runs-on: ubuntu-latest  # Missing permissions = default overprivileged

```

**After** (Security Compliant):

```yaml
jobs:
  validate-milestones:
    permissions:
      contents: read           # For checkout

      pull-requests: write     # For validation failure comments

    runs-on: ubuntu-latest

```

## Long-term Solution

1. **Create workflow templates** with security-first defaults

2. **Add permission validation** to CI pipeline

3. **Document permission patterns** for common use cases

4. **Security review process** for all new workflows

This transforms the recurring problem into a **systematic prevention framework**.
