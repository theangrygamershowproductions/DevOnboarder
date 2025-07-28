# DevOnboarder Scripts Directory

This directory contains automation scripts that support the project's "quiet reliability" philosophy through comprehensive tooling and logging.

## Core Development Scripts

### 🔧 Pre-commit and Validation

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

- ✅ **Aggressive pre-run cleanup**: Clears ALL test artifacts before validation for clean diagnosis
- ✅ Validates pre-commit YAML configuration
- ✅ Runs all pre-commit hooks with comprehensive logging
- ✅ Ensures virtual environment activation (mandatory)
- ✅ Stages all changes and commits with proper message format
- ✅ Outputs all logs to `logs/` directory for troubleshooting
- ✅ Follows project's conventional commit standards
- ✅ Automatic test artifact cleanup before validation

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

### 📊 Quality Assurance

#### `check_docs.sh`

**Purpose**: Documentation quality checks (markdownlint, Vale)

**Outputs**: `logs/docs_check_TIMESTAMP.log`

#### `check_potato_ignore.sh`

**Purpose**: Potato Policy enforcement - prevents sensitive file exposure

**Outputs**: `logs/potato_check_TIMESTAMP.log`

#### `validate.sh`

**Purpose**: Comprehensive validation suite (network, tools, documentation)

**Features**: Aggregates all validation checks, excludes tests (run via separate hook)

### 🗂️ Log Management

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

- ✅ **Pytest artifact cleanup**: Automatically removes `logs/pytest-of-*` temporary directories
- ✅ **Test artifact management**: Cleans old test runs, coverage data, validation logs
- ✅ **Retention policies**: Configurable days-to-keep (default: 7 days)
- ✅ **Dry-run support**: Preview changes before execution
- ✅ **Archive functionality**: Create timestamped log archives
- ✅ **Safe purge**: Confirmation required for complete log removal

#### `clean_pytest_artifacts.sh`

**Purpose**: Dedicated pytest artifact cleanup to eliminate false positives

**Usage**:

```bash
# Clean pytest sandbox artifacts
bash scripts/clean_pytest_artifacts.sh
```

**Features**:

- ✅ **Removes pytest-of-* directories**: Eliminates false positive "import foo" results
- ✅ **Cleans old test artifacts**: Removes stale test runs, coverage data, validation logs
- ✅ **Integrated into workflow**: Runs automatically in pre-commit hooks and verify script
- ✅ **CI compatibility**: Prevents log pollution during continuous integration

#### `analyze_logs.sh`

**Purpose**: Log directory analysis and reporting

**Usage**:

```bash
# Analyze current log state
bash scripts/analyze_logs.sh
```

**Features**:

- ✅ **Automatic cleanup**: Cleans artifacts before analysis for accuracy
- ✅ **Categorized reporting**: Groups logs by type (test runs, validation, ESLint)
- ✅ **Size analysis**: Shows total files and disk usage
- ✅ **Recent activity**: Displays last 5 modified files with timestamps

#### `monitor_ci_health.sh`

**Purpose**: CI pipeline monitoring and health assessment

**Features**: Pattern analysis, failure detection, automated reporting

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

```bash
# 1. Activate virtual environment
source .venv/bin/activate

# 2. Use comprehensive verification script (includes automatic cleanup)
./scripts/verify_and_commit.sh

# 3. Check logs for any issues
bash scripts/analyze_logs.sh
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
