# Universal Development Experience Policy

**Policy Version**: 1.0
**Part of**: DevOnboarder Universal Version Policy
**Effective**: 2025-08-09
**Classification**: Developer Experience Critical

## Executive Summary

The Universal Development Experience Policy eliminates recurring workflow disruptions by automating common formatting and quality issues that repeatedly derail development velocity.

## Problem Statement

**Recurring Workflow Disruptions Identified:**

1. **Trailing Whitespace Hook Failures** - Constant re-staging cycle disruption
2. **End-of-file Fixer** - Files modified after staging
3. **CodeQL Permissions Warnings** - Missing workflow permissions (RESOLVED)
4. **Terminal Output Policy Violations** - Emoji/Unicode in workflows (RESOLVED)
5. **YAML Indentation Issues** - Inconsistent spacing patterns

## Core Principles

### 1. Predictable Development Flow

- **Zero Surprise Modifications**: Tools should not modify files after staging
- **Single Pass Success**: Quality gates should pass on first attempt when possible
- **Clear Error Messages**: When failures occur, provide actionable guidance

### 2. Automated Prevention

- **Editor Integration**: Configure tools to prevent issues during development
- **Pre-Save Hooks**: Format files before they reach version control
- **Intelligent Staging**: Understand when files will be modified by hooks

## Solutions Framework

### 1. Trailing Whitespace Management

**Problem**: `trailing-whitespace` hook constantly modifies files after staging

**Solution**: Multi-layered prevention approach

#### Editor Configuration (.editorconfig)

```ini
# DevOnboarder Universal Editor Configuration
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space

[*.{yml,yaml}]
indent_size = 2
trim_trailing_whitespace = true

[*.{md,markdown}]
trim_trailing_whitespace = false  # Preserve line breaks in markdown
max_line_length = 88

[*.{py,pyx}]
indent_size = 4
max_line_length = 88

[*.{js,ts,json}]
indent_size = 2
```

#### VSCode Workspace Settings

```json
{
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "editor.formatOnSave": true,
  "editor.formatOnPaste": true
}
```

#### Pre-commit Hook Optimization

**Current Issue**: Hooks run in order, causing cascading modifications

**Proposed**: Reorder hooks for optimal flow:

```yaml
repos:
  # 1. FORMATTING FIRST (most likely to modify)
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer

  # 2. CODE FORMATTERS (after whitespace cleanup)
  - repo: https://github.com/psf/black
    hooks:
      - id: black

  # 3. LINTERS (after formatting)
  - repo: https://github.com/charliermarsh/ruff-pre-commit
    hooks:
      - id: ruff

  # 4. VALIDATION (final check, no modifications)
  - repo: local
    hooks:
      - id: yaml-lint
      - id: terminal-output-policy
```

### 2. Smart Commit Workflow

**Enhanced Safe Commit Process:**

```bash
#!/bin/bash
# Enhanced safe_commit.sh with whitespace intelligence

# 1. Pre-format files before staging
echo "🔧 Pre-formatting files..."
pre-commit run trailing-whitespace --all-files || true
pre-commit run end-of-file-fixer --all-files || true

# 2. Stage files after pre-formatting
git add "$@"

# 3. Run remaining hooks (should not modify files)
echo "🔍 Running validation hooks..."
pre-commit run --hook-stage commit

# 4. Commit if validation passes
git commit -m "$1"
```

### 3. Development Environment Standards

#### Required Editor Extensions

**VSCode (Recommended):**

- `EditorConfig.EditorConfig` - Automatic formatting rules
- `ms-python.black-formatter` - Python formatting
- `charliermarsh.ruff` - Python linting
- `redhat.vscode-yaml` - YAML formatting and validation

#### Git Configuration

```bash
# Automatic end-of-line normalization
git config core.autocrlf false
git config core.eol lf

# Automatic whitespace cleanup
git config core.whitespace trailing-space,space-before-tab
git config apply.whitespace fix
```

## Implementation Plan

### Phase 1: Editor Configuration (Immediate)

- [ ] Add `.editorconfig` to repository root
- [ ] Add `.vscode/settings.json` with formatting rules
- [ ] Update developer setup documentation

### Phase 2: Pre-commit Optimization (Week 1)

- [ ] Reorder pre-commit hooks for optimal flow
- [ ] Enhance `safe_commit.sh` with pre-formatting
- [ ] Test new workflow with development team

### Phase 3: Documentation and Training (Week 2)

- [ ] Update developer onboarding guide
- [ ] Create troubleshooting documentation
- [ ] Add workflow disruption metrics tracking

## Success Metrics

- **Reduced Re-staging Events**: Target 80% reduction in "files modified by hooks"
- **Faster Commit Cycles**: Average commit time reduction by 30 seconds
- **Developer Satisfaction**: Survey feedback on workflow interruptions
- **CI Stability**: Reduced pre-commit related CI failures

## Troubleshooting Guide

### Common Scenarios

**Scenario**: Files keep getting modified by trailing-whitespace hook

**Solution**:

```bash
# Run pre-formatting before staging
pre-commit run trailing-whitespace --all-files
git add .
git commit -m "Your message"
```

**Scenario**: Editor not automatically trimming whitespace

**Solution**:

```bash
# Check EditorConfig is installed and .editorconfig exists
ls -la .editorconfig
# Install EditorConfig extension in your editor
```

## Integration with Universal Version Policy

This policy integrates with:

- **Universal Workflow Permissions Policy**: Consistent quality gates
- **Terminal Output Policy**: Emoji-free automation
- **Node 22.x + Python 3.12.x Standards**: Environment consistency

---

**Related Tools**: `.editorconfig`, `safe_commit.sh`, `.pre-commit-config.yaml`
**Status**: Implementation Ready
**Next Review**: 2025-09-09
