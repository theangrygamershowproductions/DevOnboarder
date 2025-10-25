---
author: TAGS Engineering

codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: 95% quality threshold validation with comprehensive QC metrics enforcement
  across all development work
document_type: standards
merge_candidate: false
project: core-instructions
related_modules:

- terminal-output-policy.md

- code-quality-requirements.md

similarity_group: policies-standards
source: .github/copilot-instructions.md
status: active
tags:

- devonboarder

- quality-control

- policy

- validation

- testing

- coverage

title: DevOnboarder Quality Control Policy
updated_at: '2025-09-11'
visibility: internal
---

e: ".github/copilot-instructions.md"

extraction_date: "2025-09-11"
module_type: "policy"
priority: "critical"
description: "95% Quality Control Rule with 8 critical metrics"
enforcement: "mandatory"
related_modules: ["terminal-output-policy.md", "code-quality-requirements.md"]
---

DevOnboarder Quality Control Policy

==================================================

 CRITICAL: 95% Quality Control Rule
==================================================

**ALL changes must pass comprehensive QC validation before merging**:

```bash

# MANDATORY: Activate virtual environment first

source .venv/bin/activate

# Run comprehensive QC checks

./scripts/qc_pre_push.sh

# Only push if 95% threshold is met

git push

```

QC Validation Checklist (8 Critical Metrics)
==================================================

1. **YAML Linting** - Configuration file validation

2. **Python Linting** - Code quality with Ruff

3. **Python Formatting** - Black code formatting

4. **Type Checking** - MyPy static analysis

5. **Test Coverage** - Minimum 95% coverage requirement

6. **Documentation Quality** - Vale documentation linting

7. **Commit Messages** - Conventional commit format

8. **Security Scanning** - Bandit security analysis

Coverage Thresholds
==================================================

- **Python backend**: 96% (enforced in CI)

- **TypeScript bot**: 100% (enforced in CI)

- **React frontend**: 100% statements, 98.43% branches

Test Commands (Virtual Environment Required)
==================================================

```bash

# CRITICAL: Install dependencies first in virtual environment

source .venv/bin/activate  # Activate venv

pip install -e .[test]     # Install Python deps

npm ci --prefix bot        # Install bot deps

npm ci --prefix frontend   # Install frontend deps

# Run tests with coverage

python -m pytest --cov=src --cov-fail-under=95
npm run coverage --prefix bot
npm run coverage --prefix frontend

# Alternative: Use project test runner with hints

./scripts/run_tests.sh

# Quality Control: MANDATORY before push (95% threshold)

./scripts/qc_pre_push.sh

```

**Test Pattern**: The `scripts/run_tests.sh` automatically detects `ModuleNotFoundError` and provides installation hints if dependencies are missing.

Enhanced Test Execution
==================================================

```bash

# Standard test runner (CI compatible)

bash scripts/run_tests.sh

# Enhanced test runner with persistent logging

bash scripts/run_tests_with_logging.sh

# Clean pytest artifacts (enforced by Root Artifact Guard)

bash scripts/clean_pytest_artifacts.sh

```

Log Management Framework
==================================================

```bash

# Comprehensive log management system

bash scripts/manage_logs.sh list      # List all log files

bash scripts/manage_logs.sh clean     # Clean logs older than 7 days

bash scripts/manage_logs.sh archive   # Archive current logs

bash scripts/manage_logs.sh purge     # Remove all logs (with confirmation)

```
