---
author: "TAGS Engineering"
codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: REFERENCE
consolidation_priority: P3
content_uniqueness_score: 5
created_at: 2025-09-11
description: "Essential pipeline, quality control, and troubleshooting guide for CI/CD"

document_type: quick-reference
merge_candidate: false
project: core-instructions
similarity_group: quick-reference-quick-reference
status: active
tags: 
title: "CI/CD Specialist Quick Reference - DevOnboarder"

updated_at: 2025-10-27
visibility: internal
---

# CI/CD Specialist Quick Reference - DevOnboarder

## 🎯 **Pipeline Architecture Overview**

### **Critical Infrastructure Components**

- **22 GitHub Actions workflows** providing complete automation coverage

- **Root Artifact Guard** enforces zero tolerance for repository pollution

- **CI Triage Guard** provides pattern recognition for recurring failures

- **AAR System** for automated CI failure analysis and resolution

### **Essential Reading (Priority Order)**

1. **`ci-hygiene-artifact-management.md`** - Pipeline policies, artifact hygiene

2. **`quality-control-policy.md`** - QC standards, 95% thresholds

3. **`ci-troubleshooting-framework.md`** - Failure analysis, AAR system

## 🛡️ **Quality Control Framework**

### **95% Quality Threshold (8 Critical Metrics)**

**Script**: `./scripts/qc_pre_push.sh`

**Metrics Validated**:

1. **YAML Linting** - Configuration file validation

2. **Python Linting** - Code quality with Ruff

3. **Python Formatting** - Black code formatting

4. **Type Checking** - MyPy static analysis

5. **Test Coverage** - Minimum 95% coverage requirement

6. **Documentation Quality** - Vale documentation linting

7. **Commit Messages** - Conventional commit format

8. **Security Scanning** - Bandit security analysis

### **Coverage Thresholds**

- **Python backend**: 96% (enforced in CI)

- **TypeScript bot**: 100% (enforced in CI)

- **React frontend**: 100% statements, 98.43% branches

## 🚨 **Critical CI Failure Patterns**

### **Terminal Output Violations (ZERO TOLERANCE)**

**Problem**: Scripts using emojis, Unicode, or multi-line echo cause immediate terminal hanging

**Detection**: `scripts/validate_terminal_output.sh`

**Enforcement**: Pre-commit hooks block violations

**Emergency Fix**:

```bash

# Replace problematic patterns

echo " Success"  echo "Success"
echo -e "Line1\nLine2"  echo "Line1"; echo "Line2"

```

### **Root Artifact Pollution**

**Problem**: Test artifacts created in repository root cause CI failures

**Detection**: `scripts/enforce_output_location.sh`

**Protected Locations**:

- `logs/` - All test/build outputs

- `.venv/` - Python virtual environment

- `frontend/node_modules/` - Frontend dependencies only

**Emergency Cleanup**:

```bash
./scripts/manage_logs.sh cache clean
./scripts/final_cleanup.sh

```

### **Virtual Environment Violations**

**Problem**: System installation bypasses environment isolation

**Detection**: Tool availability outside `.venv/`

**Enforcement**: All Python commands must use `python -m module` syntax

**Quick Fix**:

```bash
source .venv/bin/activate
pip install -e .[test]
python -m pytest  # NOT: pytest

```

##  **AAR (After Action Report) System**

### **CI Failure Analysis Commands**

```bash

# Setup AAR system

make aar-setup

# Generate AAR for specific workflow

make aar-generate WORKFLOW_ID=12345

# Generate AAR  GitHub issue

make aar-generate WORKFLOW_ID=12345 CREATE_ISSUE=true

```

### **AAR Features**

- **Token Management**: DevOnboarder No Default Token Policy compliance

- **Environment Loading**: Automatic `.env` variable loading

- **Compliance Validation**: Markdown standards enforcement

- **GitHub Integration**: Automatic issue creation for failures

- **Offline Mode**: Generates reports without tokens

##  **Monitoring & Health Checks**

### **CI Health Monitoring**

```bash

# Check CI health status

./scripts/monitor_ci_health.sh

# Analyze failure patterns

./scripts/analyze_ci_patterns.sh

# Comprehensive diagnostic

./scripts/ci_failure_diagnoser.py

```

### **Key Health Indicators**

- **Workflow Success Rate**: Target >95%

- **Queue Time**: Target <5 minutes

- **Artifact Pollution**: Target 0 violations

- **Terminal Output Violations**: Target 0 violations (ZERO TOLERANCE)

## FAST: **Emergency Response Procedures**

### **Pipeline Hanging (Terminal Output)**

**Symptoms**: Workflows hang indefinitely at terminal output steps

**Immediate Action**:

1. Identify violating script: `scripts/validate_terminal_output.sh`

2. Fix patterns: Remove emojis, Unicode, multi-line echo

3. Validate: Run script locally before re-triggering

### **Coverage Drops Below Threshold**

**Symptoms**: Tests pass but coverage validation fails

**Immediate Action**:

1. Check coverage report: `logs/coverage_data_*`

2. Identify uncovered lines: `python -m pytest --cov=src --cov-report=html`

3. Add tests or exclude non-testable code

### **Artifact Pollution Violations**

**Symptoms**: "Root Artifact Guard" failures in CI

**Immediate Action**:

1. Run cleanup: `./scripts/final_cleanup.sh`

2. Validate: `./scripts/enforce_output_location.sh`

3. Fix script output locations to use `logs/` directory

### **Pre-commit Hook Failures**

**Symptoms**: Commits blocked by formatting/linting issues

**Immediate Action**:

1. Use safe commit: `./scripts/safe_commit.sh "message"`

2. Never use `--no-verify` (ZERO TOLERANCE POLICY)

3. Review auto-fix suggestions in enhanced error analysis

##  **Diagnostic Commands**

### **Quality Validation**

```bash

# Comprehensive quality check

./scripts/qc_pre_push.sh

# Individual validations

python -m ruff check src/
python -m black --check src/
python -m mypy src/
python -m pytest --cov=src --cov-fail-under=95

```

### **Environment Validation**

```bash

# Python environment check

python -m diagnostics

# Node environment check

npm run status --prefix bot

# Docker service health

docker compose ps

```

### **CI-Specific Diagnostics**

```bash

# Check GitHub CLI availability

gh auth status

# Validate CI environment

bash scripts/validate_ci_environment.sh

# Check CI-specific environment variables

bash scripts/env_security_audit.sh

```

##  **Automation Tools**

### **Issue Management**

```bash

# Close resolved CI issues

./scripts/close_resolved_issues.sh

# Batch close CI noise

./scripts/batch_close_ci_noise.sh

# Manage CI failure issues

./scripts/manage_ci_failure_issues.sh

```

### **Branch Cleanup**

```bash

# Comprehensive branch analysis

./scripts/comprehensive_branch_cleanup.sh

# Quick merged branch cleanup

./scripts/quick_branch_cleanup.sh

```

### **Log Management**

```bash

# List all CI logs

./scripts/manage_logs.sh list

# Clean old logs (7 days)

./scripts/manage_logs.sh clean

# Archive current logs

./scripts/manage_logs.sh archive

```

## GROW: **Success Metrics & KPIs**

### **Pipeline Health Targets**

- **Build Success Rate**: >95%

- **Average Build Time**: <10 minutes

- **Queue Wait Time**: <5 minutes

- **Artifact Violations**: 0 (enforced)

- **Terminal Output Violations**: 0 (enforced)

### **Quality Metrics**

- **Code Coverage**: 95% maintained

- **Security Vulnerabilities**: 0 high/critical

- **Documentation Quality**: Vale score >90%

- **Commit Message Compliance**: >95%

### **Operational Excellence**

- **CI Failure Resolution Time**: <2 hours

- **Automated Issue Closure Rate**: >80%

- **AAR Generation Coverage**: 100% for major failures

---

**Emergency Contact**: Use AAR system for complex failures or escalate via GitHub issues with `ci-emergency` label.
