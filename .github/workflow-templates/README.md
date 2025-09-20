# DevOnboarder Workflow Templates

## Purpose

These templates provide **security-first** GitHub Actions workflows with explicit permissions to prevent the recurring issue of overly-permissive default permissions in new workflows.

## Problem Statement

### "Why when we add new CI jobs do we always have this issue?"

GitHub Actions defaults to overly broad permissions (`contents: write`, `actions: write`, etc.) for all workflows. This creates security risks and triggers CodeQL warnings. Every new workflow in DevOnboarder needs explicit permission review.

## Available Templates

### 1. `basic-ci.yml` - Testing and Validation

- **Use Case**: Standard CI/CD pipeline for testing

- **Permissions**: `contents: read` only

- **Features**: Python 3.12, Node.js 22, virtual environment, comprehensive testing

- **Coverage**: 95% test coverage enforcement

### 2. `pr-automation.yml` - Pull Request Management

- **Use Case**: PR labeling, commenting, validation

- **Permissions**: `contents: read`, `pull-requests: write`, `issues: write`

- **Features**: PR validation, automated labeling, failure notifications

### 3. `documentation.yml` - Documentation Quality

- **Use Case**: Markdown linting, Vale validation, doc structure checks

- **Permissions**: `contents: read` only

- **Features**: markdownlint, Vale prose linting, documentation validation

### 4. `security.yml` - Security Scanning

- **Use Case**: Security audits, dependency scanning, SARIF uploads

- **Permissions**: `contents: read`, `security-events: write`

- **Features**: Bandit scanning, safety checks, scheduled security audits

## Usage Guidelines

### 1. Copy Template

```bash
cp .github/workflow-templates/basic-ci.yml .github/workflows/my-new-workflow.yml

```

### 2. Customize for Your Use Case

- Update `name:` field

- Modify triggers in `on:` section

- Adjust steps for your specific needs

- **NEVER** add additional permissions without security review

### 3. Validate Permissions

```bash
./scripts/validate_workflow_permissions.sh

```

## Security Standards

### Principle of Least Privilege

Each workflow should only have the **minimum permissions** required:

| Permission | When Needed |
|------------|-------------|
| `contents: read` | Always (for checkout) |
| `contents: write` | Only for committing files (badges, auto-fixes) |
| `pull-requests: write` | Only for PR comments/labels |
| `issues: write` | Only for creating/updating issues |
| `security-events: write` | Only for uploading SARIF results |
| `actions: write` | **RARELY** - only for workflow dispatch |

### Permission Levels

- **Job-level permissions** (recommended) - Fine-grained control per job

- **Workflow-level permissions** - Only if all jobs need same access

### Example: Secure Job Definition

```yaml
jobs:
  my-secure-job:
    permissions:
      contents: read           # Required for checkout

      pull-requests: write     # Only if commenting on PRs

    runs-on: ubuntu-latest
    steps:
      # ... job steps

```

## DevOnboarder Integration

### Pre-commit Validation

Add to `.pre-commit-config.yaml`:

```yaml

- repo: local

  hooks:

    - id: validate-workflow-permissions

      name: Validate Workflow Permissions
      entry: ./scripts/validate_workflow_permissions.sh
      language: system
      files: \.github/workflows/.*\.(yml|yaml)$

```

### CI Integration

These templates follow DevOnboarder standards:

- **Virtual environment usage**: All Python commands use `.venv`

- **Quality gates**: 95% test coverage enforcement via `qc_pre_push.sh`

- **Security-first**: Explicit permissions prevent overly broad access

- **Consistent patterns**: Follow established DevOnboarder workflow architecture

## Troubleshooting

### Common Issues

1. **"Workflow has no permissions"**

   - **Solution**: Copy from appropriate template above

   - **Check**: Run `./scripts/validate_workflow_permissions.sh`

2. **"Permission denied" errors in workflow**

   - **Solution**: Add required permission to job's `permissions:` block

   - **Reference**: See DevOnboarder existing workflows for patterns

3. **CodeQL security warnings**

   - **Cause**: Missing explicit permissions (uses overly broad defaults)

   - **Solution**: Add explicit `permissions:` block to each job

## Integration with DevOnboarder Ecosystem

These templates integrate with:

- **Quality Control**: `scripts/qc_pre_push.sh` validation

- **Security Monitoring**: Automated security scanning

- **Documentation**: Auto-generated from workflow comments

- **Validation Framework**: Comprehensive CI health monitoring

## GitHub Actions Version Requirements

All templates use standardized action versions per DevOnboarder requirements:

```yaml

# ✅ REQUIRED - Current standardized versions

- uses: actions/checkout@v5        # Repository checkout

- uses: actions/setup-python@v5    # Python environment setup

- uses: actions/setup-node@v4      # Node.js environment setup

- uses: actions/cache@v4          # Dependency caching

```

**Documentation**: See `docs/standards/github-actions-versions.md` for complete version requirements and update procedures.

## Best Practices

1. **Start with minimal permissions** (`contents: read`)

2. **Add permissions incrementally** as needed

3. **Document why** each permission is required

4. **Use templates** instead of copying existing workflows

5. **Validate before committing** with validation script

---

**Security Note**: These templates implement DevOnboarder's security-first approach where **explicit is better than implicit** for all workflow permissions.
