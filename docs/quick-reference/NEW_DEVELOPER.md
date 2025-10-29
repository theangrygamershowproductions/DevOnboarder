---
author: "TAGS Engineering"
codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: REFERENCE
consolidation_priority: P3
content_uniqueness_score: 5
created_at: 2025-09-11
description: "Essential documentation pathway for developers new to DevOnboarder"

document_type: quick-reference
merge_candidate: false
project: core-instructions
similarity_group: quick-reference-quick-reference
status: active
tags: 
title: "New Developer Quick Start - DevOnboarder"

updated_at: 2025-10-27
visibility: internal
---

# New Developer Quick Start - DevOnboarder

## 🎯 **Your First 15 Minutes**

### **Step 1: Environment Setup (5 minutes)**

**Read**: `docs/policies/virtual-environment-policy.md`

**Critical Commands**:

```bash

# Create virtual environment

python -m venv .venv
source .venv/bin/activate

# Install dependencies

pip install -e .[test]
npm ci --prefix bot
npm ci --prefix frontend

```

### **Step 2: Development Workflow (5 minutes)**

**Read**: `docs/development/development-workflow.md`

**Critical Commands**:

```bash

# Create feature branch

git checkout -b feat/your-feature-name

# Safe commit process

./scripts/safe_commit.sh "FEAT(component): your change description"

```

### **Step 3: Quality Validation (5 minutes)**

**Read**: `docs/policies/quality-control-policy.md`

**Critical Commands**:

```bash

# Pre-push quality check

./scripts/qc_pre_push.sh

# Test runner

./scripts/run_tests.sh

```

## 🚨 **Common New Developer Issues**

### **Problem**: `ModuleNotFoundError` when running tests

**Solution**: `docs/troubleshooting/common-issues-resolution.md`  Virtual Environment section

**Quick Fix**:

```bash
source .venv/bin/activate
pip install -e .[test]

```

### **Problem**: Commit fails with pre-commit errors

**Solution**: `docs/development/development-workflow.md`  Safe Commit section

**Quick Fix**:

```bash

# Never use git commit directly

./scripts/safe_commit.sh "FEAT(scope): your message"

```

### **Problem**: Tests pass locally but fail in CI

**Solution**: `docs/troubleshooting/common-issues-resolution.md`  CI Differences section

**Common Causes**:

- Missing virtual environment activation

- Missing type stubs in pyproject.toml

### **Problem**: Terminal output causes hanging

**Solution**: `docs/policies/terminal-output-policy.md`  Safe Patterns section

**Remember**:

-  Never use emojis in echo commands

-  Never use multi-line echo

-  Use individual echo commands with plain text

## 📚 **Essential Reading Order**

### **Week 1 Priority**

1. **`virtual-environment-policy.md`** - Must read first

2. **`development-workflow.md`** - Git process

3. **`quality-control-policy.md`** - QC requirements

4. **`terminal-output-policy.md`** - Prevent hanging issues

5. **`common-issues-resolution.md`** - Troubleshooting reference

### **Week 2 Expansion**

1. **`commit-message-standards.md`** - Proper commit format

2. **`testing-requirements.md`** - Coverage requirements

3. **`code-quality-requirements.md`** - Linting standards

### **As Needed**

- **`service-integration-patterns.md`** - When working with APIs

- **`discord-bot-patterns.md`** - When working with Discord bot

- **`enhanced-potato-policy.md`** - When handling sensitive files

## FAST: **Development Workflow Cheat Sheet**

### **Starting New Work**

```bash

# 1. Update main branch

git checkout main
git pull origin main

# 2. Create feature branch

git checkout -b feat/descriptive-name

# 3. Activate environment

source .venv/bin/activate

# 4. Verify setup

./scripts/qc_pre_push.sh

```

### **Making Changes**

```bash

# 1. Make your changes

# 2. Test locally

./scripts/run_tests.sh

# 3. Quality check

./scripts/qc_pre_push.sh

# 4. Safe commit

./scripts/safe_commit.sh "TYPE(scope): description"

```

### **Before Push**

```bash

# Final validation

./scripts/qc_pre_push.sh

# Push (only if QC passes)

git push origin feat/your-branch

```

##  **Essential Scripts for New Developers**

### **Quality Control**

- `./scripts/qc_pre_push.sh` - Validates 8 quality metrics

- `./scripts/run_tests.sh` - Comprehensive test runner

- `./scripts/safe_commit.sh` - Prevents commit failures

### **Environment Management**

- `source .venv/bin/activate` - Always activate first

- `pip install -e .[test]` - Install dependencies

### **Troubleshooting**

- `python -m diagnostics` - Verify environment

- `./scripts/manage_logs.sh list` - Check log files

##  **Getting Help**

### **Documentation Issues**

**Check**: `docs/quick-reference/MODULE_OVERVIEW.md` for navigation

### **Setup Problems**

**Check**: `docs/troubleshooting/common-issues-resolution.md`

### **CI Failures**

**Check**: `docs/troubleshooting/ci-troubleshooting-framework.md`

### **Git/Commit Issues**

**Check**: `docs/development/development-workflow.md`

---

**Next Steps**: Once comfortable with basics, explore service-specific documentation based on your assigned tasks.
