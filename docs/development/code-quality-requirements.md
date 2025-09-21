---
author: TAGS Engineering

codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: Comprehensive code quality standards including linting rules, testing
  requirements, and enforcement policies
document_type: standards
merge_candidate: false
project: core-instructions
related_modules:

- quality-control-policy.md

- development-workflow.md

similarity_group: development-standards
source: .github/copilot-instructions.md
status: active
tags:

- devonboarder

- code-quality

- linting

- testing

- standards

title: DevOnboarder Code Quality Requirements
updated_at: '2025-09-11'
visibility: internal
---

# DevOnboarder Code Quality Requirements

## ⚠️ CRITICAL: Linting Rule Policy

**NEVER modify linting configuration files without explicit human approval**:

- `.markdownlint.json` - Markdown formatting standards

- `.eslintrc*` - JavaScript/TypeScript linting rules

- `.ruff.toml`/`pyproject.toml` - Python linting configuration

- `.prettierrc*` - Code formatting rules

- Any other linting/formatting configuration files

**Policy Enforcement**:

- **Fix content issues** in files to meet existing standards

- **Do NOT suggest** changing linting rules to avoid errors

- **Assume all linting rules** are intentionally configured

- **Only modify configs** when explicitly requested by a human

**Rationale**: Linting rules represent established project quality standards and governance decisions. Changing rules to avoid fixing legitimate issues undermines code quality consistency.

## ⚠️ MANDATORY: Markdown Standards Compliance

**ALL markdown content MUST comply with project linting rules before creation**:

- **MD022**: Headings surrounded by blank lines (before and after)

- **MD032**: Lists surrounded by blank lines (before and after)

- **MD031**: Fenced code blocks surrounded by blank lines (before and after)

- **MD007**: Proper list indentation (4 spaces for nested items)

- **MD009**: No trailing spaces (except 2 for line breaks)

**Pre-Creation Requirements**:

1. Review existing compliant markdown in the repository

2. Follow established spacing and formatting patterns

3. Never create content that will fail markdownlint validation

4. Treat linting rules as requirements, not post-creation fixes

**Example Compliant Format**:

```markdown

## Section Title

Paragraph text with proper spacing.

- List item with blank line above

- Second list item

    - Nested item with 4-space indentation

    - Another nested item

Another paragraph after blank line.

### Subsection

More content following the same pattern.

```

**Process Violation**: Creating non-compliant markdown that requires post-creation fixes violates the "quiet reliability" philosophy and wastes development cycles. Pre-commit hooks will block commits with markdown violations.

## ⚠️ CRITICAL: CI Hygiene & Artifact Management

**Root Artifact Guard System**: DevOnboarder enforces strict artifact hygiene to prevent repository pollution:

**Protected Root Directory**:

- **NEVER** create artifacts in repository root (`./`)

- **ALL** test/build outputs must go to designated directories:

    - `logs/` - Coverage files, test results, Vale output

    - `.venv/` - Python virtual environment

    - `frontend/node_modules/` - Frontend dependencies only

    - `bot/node_modules/` - Bot dependencies only

**Enforcement Mechanism**:

```bash

# Root Artifact Guard runs on every commit

bash scripts/enforce_output_location.sh

# Automatically blocks commits with violations

# ❌ ./pytest-of-* directories in root

# ❌ ./.coverage* files in root (should be logs/)

# ❌ ./vale-results.json in root (should be logs/)

# ❌ ./node_modules in root (should be frontend/bot/)

# ❌ ./test.db or cache files in root

```

**CI Triage Guard Framework**: Comprehensive automation monitors and maintains CI health:

- **22+ GitHub Actions workflows** provide complete automation coverage

- **Auto-fixing**: Automatic formatting via `auto-fix.yml` workflow

- **Failure tracking**: `codex.ci.yml` opens issues for persistent failures

- **Permissions validation**: `validate-permissions.yml` enforces bot policies

- **Documentation quality**: Automated Vale and markdownlint enforcement

- **Security monitoring**: Continuous dependency and security audits

**Node Modules Hygiene Standard**:

```bash

# ✅ CORRECT - Install in service directories

cd frontend && npm ci
cd bot && npm ci

# ❌ WRONG - Never install in repository root

npm ci  # Creates ./node_modules/ - BLOCKED by Root Artifact Guard

```

## Python Standards

- **Python version**: 3.12 (enforced via `.tool-versions`)

- **Virtual environment**: MANDATORY - all Python tools via `.venv`

- **Linting**: `python -m ruff` with line-length=88, target-version="py312"

- **Testing**: `python -m pytest` with coverage requirements

- **Formatting**: `python -m black` for code formatting

- **Type hints**: Required for all functions

- **Docstrings**: Required for all public functions (use NumPy style)

```python
def greet(name: str) -> str:
    """Return a friendly greeting.

    Parameters
    ----------
    name:

        The name to greet.

    Returns
    -------
    str

        A greeting string.
    """
    return f"Hello, {name}!"

```

## TypeScript Standards

- **Node.js version**: 22 (enforced via `.tool-versions`)

- **Package management**: `npm ci` for reproducible installs

- **Testing**: Jest for bot, Vitest for frontend

- **ESLint + Prettier**: Enforced formatting

- **100% coverage** for bot service

## Testing Requirements

### ⚠️ CRITICAL: 95% Quality Control Rule

**ALL changes must pass comprehensive QC validation before merging**:

```bash

# MANDATORY: Activate virtual environment first

source .venv/bin/activate

# Run comprehensive QC checks

./scripts/qc_pre_push.sh

# Only push if 95% threshold is met

git push

```

**QC Validation Checklist (8 Critical Metrics)**:

1. **YAML Linting** - Configuration file validation

2. **Python Linting** - Code quality with Ruff

3. **Python Formatting** - Black code formatting

4. **Type Checking** - MyPy static analysis

5. **Test Coverage** - Minimum 95% coverage requirement

6. **Documentation Quality** - Vale documentation linting

7. **Commit Messages** - Conventional commit format

8. **Security Scanning** - Bandit security analysis

### Coverage Thresholds

- **Python backend**: 96%+ (enforced in CI)

- **TypeScript bot**: 100% (enforced in CI)

- **React frontend**: 100% statements, 98.43%+ branches

### Test Commands (Virtual Environment Required)

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

**Enhanced Test Execution**:

```bash

# Standard test runner (CI compatible)

bash scripts/run_tests.sh

# Enhanced test runner with persistent logging

bash scripts/run_tests_with_logging.sh

# Clean pytest artifacts (enforced by Root Artifact Guard)

bash scripts/clean_pytest_artifacts.sh

```

**Log Management Framework**:

```bash

# Comprehensive log management system

bash scripts/manage_logs.sh list      # List all log files

bash scripts/manage_logs.sh clean     # Clean logs older than 7 days

bash scripts/manage_logs.sh archive   # Archive current logs

bash scripts/manage_logs.sh purge     # Remove all logs (with confirmation)

```

## Pre-Commit Requirements - MANDATORY PROCESS

**CRITICAL**: ALL commits MUST follow this process to prevent CI failures and maintain "quiet reliability":

**MANDATORY PRE-COMMIT CHECKLIST**:

1. **Check commit message format FIRST** - Reference approved types before writing message

2. **ALWAYS use `scripts/safe_commit.sh`** - NEVER use `git commit` directly

3. **Verify format**: `<TYPE>(<scope>): <subject>` with approved TYPE

4. **Validate before staging** - Run relevant checks for changed files

**Approved Commit Types** (memorize these):

- **Standard**: FEAT, FIX, DOCS, STYLE, REFACTOR, TEST, CHORE, SECURITY, BUILD

- **Extended**: PERF, CI, OPS, REVERT, WIP, INIT, TAG, POLICY, HOTFIX, CLEANUP

**FORBIDDEN Practices**:

- ❌ Using `git commit` directly (bypasses validation)

- ❌ Using unapproved types like `MERGE`, `UPDATE`, `MISC`

- ❌ Missing scope in commit messages

- ❌ Using `--no-verify` without explicit Potato Approval

## Commit Message Standards

**MANDATORY**: Use conventional commit format: `<TYPE>(<scope>): <subject>`

**Required Format**:

- `TYPE`: FEAT, FIX, DOCS, STYLE, REFACTOR, TEST, CHORE, CI (uppercase)

- `scope`: Optional component (bot, frontend, auth, ci, etc.)

- `subject`: Imperative mood, descriptive and concise

**Good Examples**:

- `FEAT(auth): add user authentication endpoint with JWT validation`

- `FIX(bot): resolve Discord connection timeout handling`

- `DOCS(setup): update multi-environment configuration guide`

- `CHORE(ci): ensure latest GitHub CLI binary is used`

**Bad Examples**:

- `update` / `fix` / `misc` / `Applying previous commit`

- `Add feature` (missing TYPE format)

**Validation**: Enforced by `scripts/check_commit_messages.sh` in CI
