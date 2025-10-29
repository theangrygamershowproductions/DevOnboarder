---
author: "TAGS Engineering"
codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: 2025-09-11
description: "DevOnboarder key systems, utilities, frameworks, and student guidance"

document_type: standards
merge_candidate: false
project: core-instructions
related_modules: 
similarity_group: troubleshooting-standards
source: .github/copilot-instructions.md
status: active
tags: 
title: "DevOnboarder Key Systems & Utilities"

updated_at: 2025-10-27
visibility: internal
---

# DevOnboarder Key Systems & Utilities

## Phase Framework Navigation

DevOnboarder uses a sophisticated multi-layer phase architecture. When students ask about phases:

**Essential References**:

- `PHASE_INDEX.md` - Comprehensive navigation guide for 7 active phase systems

- `PHASE_ISSUE_INDEX.md` - Single pane of glass for phase-to-issue traceability

- Phase systems operate independently with distinct scopes (Terminal Output, MVP Timeline, Token Architecture, Infrastructure, etc.)

**Key Insight**: Multiple "Phase 2" systems exist simultaneously serving different strategic purposes - this is intentional, not duplication.

## Token Architecture v2.1 System

**15 Enhanced Scripts** across 3 implementation phases with self-contained token loading:

**Phase 1 (Critical)**: 5 scripts including `setup_discord_bot.sh`
**Phase 2 (Automation)**: 7 scripts including `monitor_ci_health.sh`, `ci_gh_issue_wrapper.sh`
**Phase 3 (Developer)**: 3 scripts including `validate_token_architecture.sh`

**Token Hierarchy**: `CI_ISSUE_AUTOMATION_TOKEN`  `CI_BOT_TOKEN`  `GITHUB_TOKEN`

**Key Scripts**:

- `scripts/enhanced_token_loader.sh` - Primary token loading system

- `scripts/load_token_environment.sh` - Legacy fallback loader

- `scripts/complete_system_validation.sh` - Validates entire token architecture

## Essential Automation Scripts (100)

### Quality Control

- `scripts/qc_pre_push.sh` - 95% quality validation (8 metrics: YAML linting, Python linting, formatting, type checking, test coverage, documentation quality, commit messages, security scanning)

- `scripts/validation_summary.sh` - Terminal output violation summary

- `scripts/validate_terminal_output.sh` - Terminal compliance validation

### Environment Management

- `scripts/smart_env_sync.sh` - Centralized environment variable synchronization

- `scripts/env_security_audit.sh` - Environment variable security validation

- `scripts/setup-env.sh` - Development environment initialization

### CI/CD & Issue Management

- `scripts/manage_ci_failure_issues.sh` - Automated CI failure issue management

- `scripts/close_resolved_issues.sh` - Automated issue cleanup

- `scripts/generate_aar.sh` - After Action Report generation for CI failures

- `scripts/check_pr_inline_comments.sh` - GitHub Copilot inline comments extraction

### Security & Compliance

- `scripts/check_potato_ignore.sh` - Enhanced Potato Policy enforcement

- `scripts/enforce_output_location.sh` - Root Artifact Guard validation

- `scripts/security_audit.sh` - Comprehensive security scanning

### Testing & Validation

- `scripts/run_tests.sh` - Comprehensive test runner with dependency hints

- `scripts/run_tests_with_logging.sh` - Enhanced test runner with persistent logging

- `scripts/manage_logs.sh` - Advanced log management system

## AAR System (After Action Reports)

**Purpose**: Automated CI failure analysis and resolution guidance

**Key Commands**:

```bash
make aar-setup           # Complete AAR system setup

make aar-generate WORKFLOW_ID=12345                    # Generate AAR for workflow

make aar-generate WORKFLOW_ID=12345 CREATE_ISSUE=true  # Generate AAR  GitHub issue

```

**Features**: Token management, environment loading, compliance validation, GitHub integration, offline mode

## Quality Control Framework

**qc_pre_push.sh validates 8 critical metrics**:

1. **YAML Linting** - Configuration file validation

2. **Python Linting** - Code quality with Ruff

3. **Python Formatting** - Black code formatting

4. **Type Checking** - MyPy static analysis

5. **Test Coverage** - Minimum 95% coverage requirement

6. **Documentation Quality** - Vale documentation linting

7. **Commit Messages** - Conventional commit format

8. **Security Scanning** - Bandit security analysis

**95% Quality Threshold**: ALL changes must pass comprehensive QC validation before merging.

## Multi-Environment Architecture

**Services & Ports**:

- DevOnboarder Server: 8000

- XP API: 8001

- Auth Server: 8002

- Dashboard Service: 8003

- Discord Integration: 8081

- PostgreSQL: 5432

**Environment Detection**: Guild ID-based routing for Discord bot (`TAGS: DevOnboarder` vs `TAGS: C2C`)

## Common Student Guidance Patterns

**For setup issues**: Direct to virtual environment activation and `pip install -e .[test]`
**For commit issues**: Use `scripts/safe_commit.sh "message"` instead of direct `git commit`
**For quality issues**: Run `./scripts/qc_pre_push.sh` to validate before pushing
**For token issues**: Check Token Architecture documentation and use enhanced loaders
**For phase confusion**: Direct to `PHASE_INDEX.md` for navigation guidance
