---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: documentation-documentation
status: active
tags:

- documentation

title: Readme
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder Scripts Directory

This directory contains automation scripts that support the project's "quiet reliability" philosophy through comprehensive tooling and logging.

## Core Development Scripts

###  Pre-commit and Validation

#### `verify_and_commit.sh`

**Purpose**: Comprehensive pre-commit verification and commit processing with full logging

**Usage**:

```bash

# Use default commit message for agent validation system

./scripts/verify_and_commit.sh

# Use custom commit message

./scripts/verify_and_commit.sh "FEAT(api): add new user endpoint"

# Show help

./scripts/verify_and_commit.sh --help

```

**Features**:

-  **Aggressive pre-run cleanup**: Clears ALL test artifacts before validation for clean diagnosis

-  Validates pre-commit YAML configuration

-  Runs all pre-commit hooks with comprehensive logging

-  Ensures virtual environment activation (mandatory)

-  Stages all changes and commits with proper message format

-  Outputs all logs to `logs/` directory for troubleshooting

-  Follows project's conventional commit standards

-  Automatic test artifact cleanup before validation

#### `validate_agents.py`

**Purpose**: Validates agent frontmatter against JSON schema with RBAC support

**Usage**: `python scripts/validate_agents.py`

**Validation**: 25 agent files, supports both nested and flat formats

### 🧪 Testing and Coverage

#### `run_tests.sh`

**Purpose**: Standard test runner with coverage reporting

**Features**: 95% coverage requirement, outputs to `test-results/`

#### `run_tests_with_logging.sh`

**Purpose**: Enhanced test runner with persistent logging

**Features**: Comprehensive logging to `logs/` directory, coverage data archiving

###  Quality Assurance

#### `qc_docs.sh`

**Purpose**: Enhanced documentation quality control with automatic markdown formatting

**Usage**:

```bash

# Check all documentation for formatting issues

./scripts/qc_docs.sh

# Automatically fix formatting issues

./scripts/qc_docs.sh --fix

# Process specific file

./scripts/qc_docs.sh --file docs/ci/document.md --fix

```

**Features**:

-  **Automatic markdown formatting**: Fixes MD009, MD022, MD032, MD031 violations

-  **Integrated validation**: Combines markdownlint and Vale checks

-  **DevOnboarder standards**: Enforces project markdown conventions

-  **Backup creation**: Preserves original files during fixes

-  **Batch processing**: Handles all markdown files or specific targets

-  **Quality reporting**: Comprehensive summary with actionable feedback

#### `fix_markdown_formatting.py`

**Purpose**: Core markdown formatting engine for DevOnboarder documents

**Usage**: `python scripts/fix_markdown_formatting.py <filepath>`

**Features**:

-  **Precise fixes**: Targets specific markdownlint violations

-  **Safety first**: Creates backups before modifications

-  **Detailed reporting**: Shows exactly what issues were fixed

-  **DevOnboarder compliant**: Follows project quality standards

#### `check_docs.sh`

**Purpose**: Documentation quality checks (markdownlint, Vale)

**Outputs**: `logs/docs_check_TIMESTAMP.log`

#### `check_potato_ignore.sh`

**Purpose**: Potato Policy enforcement - prevents sensitive file exposure

**Outputs**: `logs/potato_check_TIMESTAMP.log`

#### `validate.sh`

**Purpose**: Comprehensive validation suite (network, tools, documentation)

**Features**: Aggregates all validation checks, excludes tests (run via separate hook)

### FOLDER: Log Management

#### `manage_logs.sh`

**Purpose**: Log file management with retention policies and pytest artifact cleanup

**Usage**:

```bash

# List all log files and sizes

bash scripts/manage_logs.sh list

# Clean logs older than 7 days (includes pytest artifacts)

bash scripts/manage_logs.sh clean

# Clean with custom retention period

bash scripts/manage_logs.sh --days 3 clean

# Dry-run to see what would be cleaned

bash scripts/manage_logs.sh --dry-run clean

# Archive current logs

bash scripts/manage_logs.sh archive

# Purge all logs (with confirmation)

bash scripts/manage_logs.sh purge

```

**Features**:

-  **Pytest artifact cleanup**: Automatically removes `logs/pytest-of-*` temporary directories

-  **Test artifact management**: Cleans old test runs, coverage data, validation logs

-  **Retention policies**: Configurable days-to-keep (default: 7 days)

-  **Dry-run support**: Preview changes before execution

-  **Archive functionality**: Create timestamped log archives

-  **Safe purge**: Confirmation required for complete log removal

#### `clean_pytest_artifacts.sh`

**Purpose**: Dedicated pytest artifact cleanup to eliminate false positives

**Usage**:

```bash

# Clean pytest sandbox artifacts

bash scripts/clean_pytest_artifacts.sh

```

**Features**:

-  **Removes pytest-of-\* directories**: Eliminates false positive "import foo" results

-  **Cleans old test artifacts**: Removes stale test runs, coverage data, validation logs

-  **Integrated into workflow**: Runs automatically in pre-commit hooks and verify script

-  **CI compatibility**: Prevents log pollution during continuous integration

#### `analyze_logs.sh`

**Purpose**: Log directory analysis and reporting

**Usage**:

```bash

# Analyze current log state

bash scripts/analyze_logs.sh

```

**Features**:

-  **Automatic cleanup**: Cleans artifacts before analysis for accuracy

-  **Categorized reporting**: Groups logs by type (test runs, validation, ESLint)

-  **Size analysis**: Shows total files and disk usage

-  **Recent activity**: Displays last 5 modified files with timestamps

#### `monitor_ci_health.sh`

**Purpose**: CI pipeline monitoring and health assessment

**Features**: Pattern analysis, failure detection, automated reporting

### SYNC: Git Utilities

#### `check_pr_inline_comments.sh`

**Purpose**: Extract and track GitHub Copilot inline comments with resolution documentation

**Features**:

- Display comments with file/line context and browser integration

- Interactive resolution annotation system

- Learning pattern export for documentation

- Resolution verification for CI integration

- Enhanced display showing suggestions  resolutions side-by-side

**Usage**:

```bash

# Basic comment viewing

./scripts/check_pr_inline_comments.sh --summary PR_NUMBER
./scripts/check_pr_inline_comments.sh --copilot-only --suggestions PR_NUMBER
./scripts/check_pr_inline_comments.sh --open-browser PR_NUMBER

# Resolution tracking workflow

./scripts/check_pr_inline_comments.sh --annotate PR_NUMBER
./scripts/check_pr_inline_comments.sh --resolution-summary PR_NUMBER
./scripts/check_pr_inline_comments.sh --learning-export PR_NUMBER
./scripts/check_pr_inline_comments.sh --verify-resolutions PR_NUMBER

# CI/Automation integration

./scripts/check_pr_inline_comments.sh --format=json PR_NUMBER

```

**Resolution Tracking**: Stores resolution annotations in `.devonboarder/pr_resolutions/` with action, reasoning, commit hash, and learning notes for comprehensive Documentation as Infrastructure support.

**Features**:

-  **Copilot Integration**: Efficiently extract GitHub Copilot code suggestions

-  **Comment Filtering**: Filter by user type, suggestions, or file

-  **Browser Integration**: One-command opening of all comment URLs

-  **Automation Ready**: JSON output for CI/CD pipeline integration

-  **Summary Analytics**: Comment statistics by file and user

-  **Quick Actions**: Streamlined review workflow for PR feedback

#### `commit_changes.sh`

**Purpose**: Interactive commit utility with smart message generation

**Usage**:

```bash

# Run interactively with guided prompts

./scripts/commit_changes.sh

```

**Features**:

-  **Smart staging**: Prompts to stage unstaged changes

-  **Intelligent suggestions**: Auto-generates multiple commit message options based on file analysis

-  **Interactive selection**: Choose from suggested messages or enter custom

-  **File analysis**: Shows what files are being committed and suggests appropriate types

-  **Status reporting**: Displays final git status and recent commits

#### `commit_message_guide.sh`

**Purpose**: Educational tool to learn DevOnboarder commit message conventions

**Usage**:

```bash

# Learn commit message patterns and get help

./scripts/commit_message_guide.sh

```

**Features**:

-  **Examples library**: Comprehensive examples for each commit type (FEAT, FIX, DOCS, etc.)

-  **Interactive builder**: Step-by-step commit message construction

-  **Current change analysis**: Analyzes your staged files and suggests appropriate commit types

-  **Scope guidance**: Learn when and how to use different scopes (auth, bot, scripts, etc.)

-  **Format validation**: Learn the proper structure and rules

#### `sync_with_remote.sh`

**Purpose**: Comprehensive git synchronization with conflict detection

**Usage**:

```bash

# Safe sync with full conflict handling

./scripts/sync_with_remote.sh

```

**Features**:

-  **Conflict detection**: Handles pull/push rejections safely

-  **Branch awareness**: Works with any current branch

-  **Safety checks**: Validates uncommitted changes before operations

-  **Recovery guidance**: Provides clear error messages and next steps

#### `simple_sync.sh`

**Purpose**: Quick pull and push for conflict-free scenarios

**Usage**:

```bash

# Fast sync when no conflicts expected

./scripts/simple_sync.sh

```

**Features**:

-  **Speed optimized**: Minimal checks for fast operations

-  **Main branch focused**: Specifically targets origin/main

-  **Basic logging**: Simple operation status reporting

## Development Workflow Integration

### Pre-commit Hooks

All hooks output comprehensive logs to the `logs/` directory:

- **pytest**: `logs/pytest_TIMESTAMP.log`

- **agent validation**: `logs/agent_validation_TIMESTAMP.log`

- **docs quality**: `logs/docs_check_TIMESTAMP.log`

- **environment checks**: `logs/env_docs_check_TIMESTAMP.log`

- **ESLint**: `logs/frontend_eslint_TIMESTAMP.log`, `logs/bot_eslint_TIMESTAMP.log`

### Logging Standards

All scripts follow these logging conventions:

- **Timestamped logs**: Format `YYYYMMDD_HHMMSS`

- **Persistent storage**: All logs saved to `logs/` directory

- **Retention policy**: Managed via `manage_logs.sh`

- **Automatic cleanup**: Test artifacts cleaned before validation

- **Structured output**: JSON where applicable, readable text for diagnostics

### Virtual Environment Requirements

**MANDATORY**: All Python scripts require virtual environment activation:

```bash
source .venv/bin/activate

```

This ensures reproducible builds and matches CI/production environments.

### Recommended Commit Process

#### Option 1: Comprehensive validation (for critical changes)

```bash

# 1. Activate virtual environment

source .venv/bin/activate

# 2. Use comprehensive verification script (includes automatic cleanup)

./scripts/verify_and_commit.sh

# 3. Sync with remote safely

./scripts/sync_with_remote.sh

# 4. Check logs for any issues

bash scripts/analyze_logs.sh

```

#### Option 2: Interactive workflow (for regular development)

```bash

# 1. Activate virtual environment

source .venv/bin/activate

# 2. Interactive commit with smart defaults

./scripts/commit_changes.sh

# 3. Safe remote sync with conflict handling

./scripts/sync_with_remote.sh

```

#### Option 3: Quick workflow (for simple updates)

```bash

# 1. Activate virtual environment

source .venv/bin/activate

# 2. Quick commit and sync (when confident no conflicts)

./scripts/commit_changes.sh && ./scripts/simple_sync.sh

```

This ensures all quality checks pass before commit and provides full diagnostic logs.

### Troubleshooting

If pre-commit hooks fail:

1. **Check recent logs**: `bash scripts/analyze_logs.sh`

2. **Review specific failures**: `cat logs/[hook_name]_*.log`

3. **Clean test artifacts**: `bash scripts/clean_pytest_artifacts.sh`

4. **Manual hook testing**: `pre-commit run [hook-id] --verbose`

## Dependencies and Requirements

### Required Tools

- Python 3.12 with virtual environment (`.venv/`)

- Node.js 22 for frontend/bot linting

- Git with conventional commit message format

- pre-commit framework

### Required Python Packages

- pytest, pytest-cov (testing)

- jsonschema, pyyaml (agent validation)

- ruff, black (linting and formatting)

- openapi-spec-validator (API validation)

## Script Philosophy

DevOnboarder scripts embody the project's core principles:

- **Comprehensive logging** for troubleshooting and audit trails

- **Virtual environment isolation** for reproducible builds

- **Automated quality enforcement** via pre-commit hooks

- **Clean state management** with automatic artifact cleanup

- **Quiet reliability** - scripts work consistently without user intervention

- **Developer experience** - clear outputs and helpful error messages

This automation ecosystem supports the project's goal to "work quietly and reliably" while maintaining high quality standards across all development activities.

## Log Management Philosophy

The enhanced log management system follows these principles:

- **Automatic cleanup**: Test artifacts are cleaned before each validation cycle

- **Retention policies**: Old logs are rotated to prevent disk bloat

- **Accurate analysis**: Clean state ensures reliable log analysis

- **CI efficiency**: Smaller log directories improve performance

- **Debugging clarity**: Recent logs are easier to locate and analyze

This ensures that the log directory remains a useful diagnostic tool without becoming a source of pollution or false positives.
