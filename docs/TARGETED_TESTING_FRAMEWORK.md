---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: TARGETED_TESTING_FRAMEWORK.md-docs
status: active
tags:
- documentation
title: Targeted Testing Framework
updated_at: '2025-09-12'
visibility: internal
---

# Targeted Testing Framework - DevOnboarder

## Overview

DevOnboarder now supports **targeted test execution** instead of running the entire 47-step validation suite every time. This eliminates the need to wait for the full pipeline and allows for focused, efficient development.

## Quick Start

### 🚀 Most Common Commands

```bash

# Quick linting check before commit

bash scripts/quick_validate.sh lint

# Run only frontend tests

bash scripts/quick_validate.sh frontend

# Run only Python tests

bash scripts/quick_validate.sh step "Python Tests"

# See what would run without executing

bash scripts/quick_validate.sh dry frontend

# List all available sections and steps

bash scripts/quick_validate.sh list

```

## Available Sections

| Section | Key | Steps | Purpose |
|---------|-----|-------|---------|
| **VALIDATION & LINTING** | `validation` | 7 | YAML, Shellcheck, Commit Messages, Language Versions, Black, Ruff, MyPy |

| **DOCUMENTATION & QUALITY** | `documentation` | 9 | Vale, Bot Permissions, OpenAPI, PR Summary, Docstring Coverage |

| **CORE BUILD & TEST PIPELINE** | `build` | 4 | Generate Secrets, Environment Audit, QC Validation, Python Tests |

| **FRONTEND TESTING** | `frontend` | 4 | Dependencies, Linting, Tests, Build |

| **BOT TESTING** | `bot` | 4 | Dependencies, Linting, Tests, Build |

| **SECURITY & AUDITING** | `security` | 5 | Bandit, NPM Audit, Security Audit, Pip Audit |

| **CONTAINERIZATION & SECURITY** | `docker` | 2 | Docker Build, Trivy Security Scan |

| **SERVICE INTEGRATION TESTING** | `services` | 5 | Start Services, Health Checks, Diagnostics |

| **ADVANCED FRONTEND TESTING** | `e2e` | 4 | Playwright Setup, E2E Tests, Performance, Accessibility |

| **FINAL CHECKS** | `cleanup` | 3 | Root Artifact Guard, Clean Artifacts, Stop Services |

## Command Reference

### Main Validation Script

```bash

# Full validation suite (47 steps)

bash scripts/validate_ci_locally.sh

# Run specific section

bash scripts/validate_ci_locally.sh --section validation
bash scripts/validate_ci_locally.sh --section frontend
bash scripts/validate_ci_locally.sh --section security

# Run specific step

bash scripts/validate_ci_locally.sh --step "Python Tests"
bash scripts/validate_ci_locally.sh --step 21

# Dry run (preview without executing)

bash scripts/validate_ci_locally.sh --dry-run --section build

# List all sections and steps

bash scripts/validate_ci_locally.sh --list

# Help

bash scripts/validate_ci_locally.sh --help

```

### Quick Validation Helper

```bash

# Quick shortcuts

bash scripts/quick_validate.sh lint      # All linting checks

bash scripts/quick_validate.sh test      # All tests (Python, Frontend, Bot)

bash scripts/quick_validate.sh security  # All security checks

bash scripts/quick_validate.sh frontend  # Frontend validation

bash scripts/quick_validate.sh bot       # Bot validation

bash scripts/quick_validate.sh build     # Build pipeline

# Fast checks (no Docker/services)

bash scripts/quick_validate.sh fast

# Targeted troubleshooting

bash scripts/quick_validate.sh fix-yaml    # Only YAML linting

bash scripts/quick_validate.sh fix-shell   # Only Shellcheck

bash scripts/quick_validate.sh fix-python  # Python linting and tests

# Advanced usage

bash scripts/quick_validate.sh step "Python Tests"
bash scripts/quick_validate.sh dry frontend

```

## Development Workflow Examples

### Before Committing

```bash

# Quick check of common issues

bash scripts/quick_validate.sh lint

```

### Working on Frontend

```bash

# Test only frontend changes

bash scripts/quick_validate.sh frontend

# Preview what would run

bash scripts/quick_validate.sh dry frontend

```

### Fixing Specific Issues

```bash

# Fix YAML linting issues

bash scripts/quick_validate.sh fix-yaml

# Fix Python linting and tests

bash scripts/quick_validate.sh fix-python

# Run specific failing step

bash scripts/quick_validate.sh step "Bot Tests"

```

### Security Review

```bash

# Run all security checks

bash scripts/quick_validate.sh security

```

### Fast Development Loop

```bash

# Run fast checks (no Docker builds)

bash scripts/quick_validate.sh fast

```

## Performance Comparison

| Command | Steps | Time | Use Case |
|---------|-------|------|----------|
| Full validation | 47 | ~10-15 min | Before major PR |
| `quick_validate.sh lint` | 7 | ~30 sec | Before commit |
| `quick_validate.sh frontend` | 4 | ~1-2 min | Frontend changes |
| `quick_validate.sh fast` | ~25 | ~3-5 min | No Docker overhead |
| Single step | 1 | ~5-30 sec | Specific issue |

## Benefits

1. **⚡ Speed**: Run only what you need instead of waiting for full 47-step suite

2. **🎯 Focus**: Target specific areas of concern

3. **🔍 Debug**: Isolate and fix specific failures

4. **💡 Learning**: Understand what each section does

5. **🚀 Productivity**: Faster feedback loop during development

## Advanced Features

### Dry Run Mode

Preview what would execute without running commands:

```bash
bash scripts/validate_ci_locally.sh --dry-run --section build

```

### Step Listing

See all available sections and steps:

```bash
bash scripts/validate_ci_locally.sh --list

```

### Comprehensive Logging

Each run creates timestamped logs:

- Main log: `logs/comprehensive_ci_validation_TIMESTAMP.log`

- Individual step logs: `logs/step_N_stepname.log`

### Error Analysis

Built-in troubleshooting guidance:

- Failed step logs automatically identified

- Quick view commands provided

- Real-time monitoring support

## Integration with Existing Workflow

The targeted testing framework is fully compatible with existing DevOnboarder workflows:

- ✅ Uses same virtual environment setup

- ✅ Same logging and error reporting

- ✅ Same quality thresholds and requirements

- ✅ Full validation still available when needed

- ✅ No changes to CI/CD pipeline

## Troubleshooting

### Common Issues

1. **Step not found**: Use `--list` to see available steps

2. **Section not found**: Use `--list` to see available sections

3. **Permission issues**: Ensure virtual environment is activated

4. **Playwright sudo requests**: Use targeted execution to skip E2E tests

### Debug Commands

```bash

# List all available options

bash scripts/validate_ci_locally.sh --list

# Check what would run

bash scripts/validate_ci_locally.sh --dry-run --section SECTION

# Run with verbose output

bash scripts/validate_ci_locally.sh --step "STEP" 2>&1 | tee debug.log

```

---

**Created**: August 7, 2025

**Purpose**: Eliminate "hit and miss" development with focused, efficient validation
**Coverage**: 95%+ of GitHub Actions CI pipeline with targeted execution
