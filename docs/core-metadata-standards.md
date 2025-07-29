---
title: "Core Instructions Metadata Standards"
description: "Standardized YAML frontmatter structure for all prompt files and documentation"
author: "DevOnboarder Team"
created_at: "2025-07-28"
updated_at: "2025-07-28"
tags: ["codex", "metadata", "standards", "yaml", "frontmatter", "documentation"]
project: "DevOnboarder"
document_type: "standards"
status: "active"
visibility: "internal"
codex_scope: "DEVOPS"
codex_role: "Engineering"
codex_type: "STANDARDS"
codex_runtime: true
integration_status: "production_ready"
virtual_env_required: true
ci_integration: true
---

# Core Instructions Metadata Standards

## Overview

This document defines the standardized YAML frontmatter structure that must be used across all files in the DevOnboarder ecosystem to ensure consistency, automated discovery, and proper integration with Codex agents and CI monitoring systems.

## DevOnboarder Integration Context

Following DevOnboarder's **"quiet reliability"** philosophy, these metadata standards ensure:

- **Virtual Environment Compatibility**: All validation tools run in `.venv` context
- **CI Integration**: Automated validation via GitHub Actions workflows
- **Agent Discovery**: Consistent patterns for `.codex/agents/index.json`
- **Quality Assurance**: Enforced via pre-commit hooks and markdown linting

## Required Fields for All Files

### Core Identification

```yaml
title: "Descriptive Title Following DevOnboarder Conventions"
description: "Clear, concise description of the file's purpose"
author: "DevOnboarder Team"
created_at: "YYYY-MM-DD"
updated_at: "YYYY-MM-DD"
```

### Categorization

```yaml
tags: ["array", "of", "relevant", "tags"]
project: "DevOnboarder"
document_type: "agent|charter|checklist|handoff|standards|guide|status"
status: "active|draft|deprecated|production_ready"
visibility: "internal|public|restricted"
```

### Codex Integration

```yaml
codex_scope: "DEVOPS|CI|MONITORING|QUALITY"
codex_role: "CI_Monitor|Auto_Fix|DevSecOps_Manager|Engineering"
codex_type: "AGENT|CHARTER|CHECKLIST|HANDOFF|STANDARDS|GUIDE"
codex_runtime: true|false
```

### DevOnboarder-Specific Fields

```yaml
integration_status: "production_ready|draft_mode|pending_authentication"
virtual_env_required: true
ci_integration: true
```

## Agent-Specific Requirements

### CI Monitoring Agents

```yaml
---
codex-agent: true
name: "ci-monitor"
type: "monitoring"
permissions: ["read", "issues"]
description: "Automated CI status monitoring and failure classification"
trigger: "pr_update|file_change|manual"
environment: "CI|development"
output: "logs/ci-monitor.log"
virtual_env_required: true
---
```

### Auto-Fix Agents

```yaml
---
codex-agent: true
name: "code-quality-auto-fix"
type: "automation"
permissions: ["read", "write", "issues"]
description: "Automatically detects and fixes common linting issues"
trigger: "pre-commit|file-change|pr-update"
environment: "CI|development"
output: "logs/auto-fix.log"
virtual_env_required: true
---
```

## Field Definitions (DevOnboarder Extensions)

### integration_status

- **Type**: String
- **Required**: For integration documents
- **Values**: "production_ready", "draft_mode", "pending_authentication"
- **Purpose**: DevOnboarder deployment status tracking

### virtual_env_required

- **Type**: Boolean
- **Required**: For technical documents
- **Value**: true (following DevOnboarder's mandatory virtual environment policy)
- **Purpose**: Environment requirement enforcement

### ci_integration

- **Type**: Boolean
- **Required**: For CI-related documents
- **Value**: true
- **Purpose**: GitHub Actions workflow integration flag

### codex-agent

- **Type**: Boolean
- **Required**: For agent files
- **Value**: true
- **Purpose**: Agent discovery system compatibility

## Validation Framework

### Virtual Environment Setup

```bash
# CRITICAL: All validation must run in virtual environment
source .venv/bin/activate
pip install -e .[test]
```

### Validation Commands

```bash
# Validate agent metadata (DevOnboarder pattern)
python scripts/validate_agent_files.py

# Check Codex agent index consistency
python scripts/validate-bot-permissions.sh

# Markdown compliance (mandatory)
npx markdownlint-cli2 "**/*.md" --config .markdownlint.json

# YAML structure validation
python -c "import yaml; yaml.safe_load(open('docs/example.md').read().split('---')[1])"
```

### CI Integration

```yaml
# .github/workflows/metadata-validation.yml
name: Metadata Validation
on: [push, pull_request]

jobs:
  validate-metadata:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python Virtual Environment
        run: |
          python -m venv .venv
          source .venv/bin/activate
          pip install -e .[test]

      - name: Validate Agent Files
        run: |
          source .venv/bin/activate
          python scripts/validate_agent_files.py

      - name: Check Markdown Compliance
        run: |
          npm ci --prefix . --no-save
          npx markdownlint-cli2 "**/*.md"
```

## DevOnboarder Document Types

### Extended Document Types

- **agent**: Codex agent specifications with YAML frontmatter
- **guide**: Comprehensive how-to documentation
- **status**: Integration and deployment status reports
- **framework**: System architecture and component documentation
- **standards**: Quality and compliance requirements
- **handoff**: Cross-team integration documentation

### Example: CI Monitoring Framework Documentation

```yaml
---
title: "CI Monitoring Framework"
description: "Automated CI status monitoring and reporting tools"
tags: ["ci", "monitoring", "automation", "devops"]
author: "DevOnboarder Team"
created_at: "2025-07-28"
updated_at: "2025-07-28"
project: "DevOnboarder"
document_type: "guide"
status: "active"
visibility: "internal"
codex_scope: "DEVOPS"
codex_role: "CI_Monitor"
codex_type: "GUIDE"
codex_runtime: true
integration_status: "production_ready"
virtual_env_required: true
ci_integration: true
---
```

## Quality Assurance Integration

### Pre-commit Hook Validation

```yaml
# .pre-commit-config.yaml integration
repos:
  - repo: local
    hooks:
      - id: validate-metadata
        name: Validate YAML Frontmatter
        entry: python scripts/validate_agent_files.py
        language: system
        pass_filenames: false
        always_run: true
```

### Markdown Compliance Requirements

Following DevOnboarder's **mandatory markdown standards**:

- **MD022**: Headings surrounded by blank lines
- **MD032**: Lists surrounded by blank lines
- **MD031**: Fenced code blocks surrounded by blank lines
- **MD007**: Proper list indentation (4 spaces for nested items)
- **MD009**: No trailing spaces

**Pre-creation Requirement**: All metadata documentation must pass `markdownlint-cli2` validation before commit.

## Security and Access Control

### Authentication Integration

```yaml
# For authenticated agent files
discord_role_required: "CEO|CTO|CFO|CMO|COO"
authentication_required: true
integration_guards_active: true
live_triggers_enabled: false  # During draft mode
```

### DevOnboarder Security Standards

- **Enhanced Potato Policy**: Sensitive files automatically protected
- **Virtual Environment Isolation**: All tools run in `.venv` context
- **Root Artifact Guard**: Prevents repository pollution
- **CI Triage Guard**: Automated failure detection and issue creation

## Integration with Existing Systems

### Codex Agent Index

```json
// .codex/agents/index.json
{
  "agents": [
    {
      "name": "ci-monitor",
      "file": "agents/ci-monitor.md",
      "type": "monitoring",
      "status": "production_ready",
      "virtual_env_required": true
    }
  ]
}
```

### GitHub Actions Integration

The metadata standards integrate with DevOnboarder's **22+ GitHub Actions workflows**:

- **ci.yml**: Main test pipeline with metadata validation
- **markdownlint.yml**: Enforces markdown compliance
- **validate-permissions.yml**: Bot permissions validation
- **auto-fix.yml**: Automatic quality fixes
- **ci-monitor.yml**: Continuous CI health monitoring

## Troubleshooting

### Common Metadata Issues

1. **Virtual Environment Missing**:

    ```bash
    # ✅ Solution
    source .venv/bin/activate
    pip install -e .[test]
    python scripts/validate_agent_files.py
    ```

2. **Markdown Compliance Failures**:

    ```bash
    # ✅ Check and fix
    npx markdownlint-cli2 "docs/your-file.md" --fix
    ```

3. **YAML Syntax Errors**:

    ```bash
    # ✅ Validate YAML structure
    python -c "import yaml; yaml.safe_load(open('docs/file.md').read().split('---')[1])"
    ```

### Integration Status Checking

```bash
# Check current integration status
source .venv/bin/activate
python .codex/scripts/ci-monitor.py --health-check

# Validate all agent files
python scripts/validate_agent_files.py

# Generate integration status report
python .codex/scripts/ci-monitor.py --integration-status
```

## Benefits

### For DevOnboarder Project

✅ **Consistent Discovery**: Automated agent and document indexing
✅ **Quality Assurance**: Enforced standards via CI/CD pipeline
✅ **Integration Ready**: Compatible with existing automation
✅ **Security Compliant**: Follows Enhanced Potato Policy
✅ **Environment Safe**: Virtual environment compatibility

### for Development Teams

✅ **Clear Structure**: Predictable metadata patterns
✅ **Automated Validation**: Pre-commit and CI enforcement
✅ **Self-Documenting**: Metadata provides context and purpose
✅ **Integration Path**: Clear path from draft to production
✅ **Quality Gates**: Automatic compliance checking

---

**Prepared by**: DevOnboarder Team
**Review Required by**: DevSecOps Manager
**Approval Required for**: New file creation and metadata updates
**Next Review Date**: Monthly metadata standards review
**Document Classification**: Internal - DevOnboarder Engineering
**Virtual Environment**: Required for all validation commands
**CI Integration**: Active via GitHub Actions workflows
**Quality Assurance**: Enforced via pre-commit hooks and markdown linting
