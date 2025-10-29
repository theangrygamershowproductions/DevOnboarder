---
task: "Implement Codex Catch System: Coverage Decay Mitigation"
priority: high
status: staged
created: 2025-08-04
assigned: development-team
dependencies: "["terminal-output-cleanup-phases.md", "phase2_terminal_output_compliance.md"]"
related_files: [
validation_required: true
staging_reason: "awaiting terminal output cleanup completion and CI stability improvements"
consolidation_priority: P3
content_uniqueness_score: 4
merge_candidate: false
similarity_group: docs-devonboarder
updated_at: 2025-10-27
---

# Codex Catch System Implementation Task

## Overview

Implement comprehensive coverage decay mitigation system following DevOnboarder standards for quiet reliability and virtual environment enforcement.

## Implementation Readiness

###  **Ready Components**

- Core script designs validated

- DevOnboarder compliance patterns established

- Token hierarchy implementation planned

- Virtual environment enforcement patterns defined

### ⏳ **Staging Dependencies**

- **Terminal Output Cleanup**: Must reach ≤10 violations (currently 22)

- **CI Stability**: Phase 2 completion required

- **Token Security Review**: Ensure proper hierarchy implementation

## Phase 1: Core Coverage Scripts

### 1.1 Coverage Parsing (`scripts/parse_coverage.py`)

- Extract numeric coverage from `logs/coverage.xml`

- Virtual environment enforcement with `ensure_venv()`

- Error handling for missing files

- Plain ASCII output only (no emojis/Unicode)

### 1.2 Coverage Decay Detection (`scripts/check_coverage_decay.py`)

- Compare current vs baseline coverage from `logs/last_coverage.txt`

- Exit nonzero on coverage drops (fail CI)

- Support `--allow-drop` flag and `ALLOW_COVERAGE_DROP` env var

- Centralized logging to `logs/coverage_delta.log`

- Terminal output compliance (single echo commands, ASCII only)

### 1.3 Baseline Management (`scripts/save_coverage.py`)

- Update `logs/last_coverage.txt` only after main branch success

- Never update during PR builds to prevent masking decay

- Virtual environment validation mandatory

## Phase 2: Test Backlog Management

### 2.1 Backlog Logger (`scripts/log_codex_test_backlog.sh`)

- Append auto-generated files to `codex/todo/test_backlog.md`

- Bash script with proper error handling

- Centralized logging pattern: `logs/log_codex_test_backlog_*.log`

### 2.2 Issue Management (`scripts/manage_test_backlog_issues.py`)

- Create GitHub issues for backlog items needing tests

- **Token hierarchy compliance**: `CI_ISSUE_AUTOMATION_TOKEN`  `CI_BOT_TOKEN`  `GITHUB_TOKEN`

- Avoid duplicate issue creation via existing issue detection

- Virtual environment enforcement with validation

## Phase 3: CI Integration

### 3.1 Workflow Updates (`.github/workflows/ci.yml`)

- Add coverage generation: `pytest --cov-report=xml:logs/coverage.xml`

- Add coverage decay check after tests (fail on regression)

- Add baseline update on main branch success only

- Token hierarchy implementation for GitHub authentication

- Artifact upload for `logs/coverage.xml` and analytics

### 3.2 Pre-commit Integration (`.pre-commit-config.yaml`)

- Add coverage decay check hook with virtual environment context

- Prevent commits that would cause coverage regression

## Phase 4: Configuration & Documentation

### 4.1 Configuration (`config/codex-catch-config.yml`)

- Coverage thresholds and file paths

- Test backlog automation settings

- Token hierarchy and authentication toggles

### 4.2 Documentation (`docs/codex-catch-system.md`)

- System overview, usage, and troubleshooting

- Integration with existing DevOnboarder automation

- Maintenance procedures and health monitoring

## DevOnboarder Compliance Requirements

### **Critical Standards Enforcement**

- **Virtual Environment**: All scripts must activate `.venv` and validate

- **Centralized Logging**: All logs go to `logs/` directory exclusively

- **Terminal Output**: Plain ASCII, individual echo commands only

- **No System Installs**: All dependencies in `pyproject.toml`

- **Token Hierarchy**: Proper GitHub authentication fallback chain

- **Root Artifact Guard**: No artifacts in repository root

### **Security & Quality Integration**

- **Enhanced Potato Policy**: Protect sensitive patterns in ignore files

- **Markdown Compliance**: All docs pass markdownlint validation

- **Error Handling**: Comprehensive error checking and logging

- **CI Hygiene**: Proper artifact management and cleanup

## Terminal Output Compliance

### **Enforcement Pattern (MANDATORY)**

```bash

#  REQUIRED - DevOnboarder compliant

echo "Coverage check completed successfully"
echo "Current coverage: 95.2%"
echo "Baseline coverage: 94.8%"
echo "Delta: 0.4%"

#  FORBIDDEN - Causes immediate hanging

echo " Coverage maintained"  # Emojis cause hanging

echo "🎯 Ready for deployment"  # Unicode causes hanging

echo "Status: $STATUS_VAR"     # Variable expansion causes hanging

```

### **Safe Variable Handling**

```bash

#  CORRECT - Use printf for variables

printf "Current coverage: %.2f%%\n" "$COVERAGE"
printf "Baseline: %.2f%%\n" "$BASELINE"

# Store results first, then echo

RESULT=$(python scripts/parse_coverage.py logs/coverage.xml)
echo "Coverage parsing completed"
printf "Result: %s\n" "$RESULT"

```

## Implementation Notes

### **Token Authentication Pattern**

```bash

# DevOnboarder token hierarchy implementation

if [ -n "${CI_ISSUE_AUTOMATION_TOKEN:-}" ]; then
    export GITHUB_TOKEN="$CI_ISSUE_AUTOMATION_TOKEN"
    echo "Using CI_ISSUE_AUTOMATION_TOKEN for authentication"
elif [ -n "${CI_BOT_TOKEN:-}" ]; then
    export GITHUB_TOKEN="$CI_BOT_TOKEN"
    echo "Using CI_BOT_TOKEN for authentication"
elif [ -n "${GITHUB_TOKEN:-}" ]; then
    echo "Using GITHUB_TOKEN for authentication"
else
    echo "No authentication token available, skipping GitHub operations"
    exit 0
fi

```

### **Virtual Environment Pattern**

```python

def ensure_venv():
    """Ensure we're running in virtual environment (MANDATORY)."""
    if not hasattr(sys, 'real_prefix') and not sys.base_prefix != sys.prefix:
        print(" Must run in virtual environment")
        sys.exit(1)

```

## Testing Strategy

### **Unit Tests** (`tests/test_codex_catch_system.py`)

- Coverage parsing validation with mock XML data

- Baseline management logic testing

- Error handling scenarios and edge cases

- GitHub integration mocking and token hierarchy testing

### **Integration Tests** (`scripts/test_codex_catch_integration.sh`)

- End-to-end workflow validation in clean environment

- CI integration testing with artifact verification

- Token hierarchy validation and fallback testing

## Success Criteria

- [ ] **Coverage Decay Prevention**: 100% prevention of coverage regressions

- [ ] **Test Backlog Tracking**: Automatic tracking of all untested auto-generated code

- [ ] **GitHub Integration**: Issues created for coverage violations with proper labels

- [ ] **DevOnboarder Standards**: All scripts pass quality validation

- [ ] **CI Integration**: Seamless integration with existing workflows

- [ ] **Documentation**: Complete, validated, and maintainable

- [ ] **Team Training**: Clear usage instructions and troubleshooting

## Risk Mitigation

- **Terminal Hanging Prevention**: Strict ASCII-only output enforcement

- **Token Security**: Proper hierarchy implementation and validation

- **Virtual Environment**: Mandatory activation and validation checks

- **Artifact Pollution**: Root Artifact Guard enforcement

- **CI Reliability**: Comprehensive error handling and graceful fallbacks

## Staging Exit Criteria

### **Ready for Implementation When:**

- [ ] Terminal output violations reduced to ≤10 (from current 22)

- [ ] Phase 2 terminal compliance completed

- [ ] CI stability improvements deployed

- [ ] Token hierarchy patterns validated in existing workflows

- [ ] Pre-commit hook framework ready for coverage integration

### **Implementation Phases**

1. **Phase 1**: Core scripts with comprehensive testing

2. **Phase 2**: CI integration and validation with existing workflows

3. **Phase 3**: Deploy with monitoring and team documentation

4. **Phase 4**: Team training and workflow optimization

---

**Status**: Staged - Ready for implementation pending dependency completion

**Dependencies**: Terminal Output Cleanup Phase 2, CI Stability Improvements
**Next Review**: After Phase 2 terminal compliance reaches target thresholds
**Integration Point**: Seamless addition to existing DevOnboarder automation ecosystem
