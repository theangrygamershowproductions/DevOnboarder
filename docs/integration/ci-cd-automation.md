---
author: TAGS Engineering

codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: GitHub Actions workflows, automation scripts, CI/CD patterns, and comprehensive
  automation ecosystem
document_type: standards
merge_candidate: false
project: core-instructions
related_modules:

- quality-control-policy.md

- common-integration-points.md

similarity_group: ci-automation
source: .github/copilot-instructions.md
status: active
tags:

- devonboarder

- ci-cd

- github-actions

- automation

- workflows

title: DevOnboarder CI/CD Automation
updated_at: '2025-09-11'
visibility: internal
---

# DevOnboarder CI/CD & Automation

## GitHub Actions Workflows

- **ci.yml**: Main test pipeline with 95% coverage enforcement

- **pr-automation.yml**: PR automation framework

- **auto-fix.yml**: Automated fixes and formatting

- **ci-health.yml**: CI pipeline monitoring

- **security-audit.yml**: Security scanning

- **potato-policy-focused.yml**: Enhanced Potato Policy enforcement

- **validate-permissions.yml**: Bot permissions validation

- **documentation-quality.yml**: Automated Vale and markdownlint

- **env-doc-alignment.yml**: Environment variable documentation sync

- **branch-cleanup.yml**: Automated branch maintenance

- **ci-monitor.yml**: Continuous CI health monitoring

- **markdownlint.yml**: Dedicated markdown style enforcement

- **review-known-errors.yml**: Pattern recognition for recurring issues

- **audit-retro-actions.yml**: Retrospective action item auditing

- **dev-orchestrator.yml**: Development environment orchestration

- **prod-orchestrator.yml**: Production environment orchestration

- **staging-orchestrator.yml**: Staging environment orchestration

## Critical Scripts

- `scripts/automate_pr_process.sh`: PR automation

- `scripts/pr_decision_engine.sh`: Strategic decision engine

- `scripts/assess_pr_health.sh`: PR health assessment

- `scripts/check_pr_inline_comments.sh`: GitHub Copilot inline comments extraction

- `scripts/run_tests.sh`: Comprehensive test runner

- `scripts/check_potato_ignore.sh`: Potato Policy enforcement

- `scripts/generate_potato_report.sh`: Security audit reporting

- `scripts/check_commit_messages.sh`: Commit message validation

- `scripts/enforce_output_location.sh`: Root Artifact Guard enforcement

- `scripts/clean_pytest_artifacts.sh`: Comprehensive artifact cleanup

- `scripts/manage_logs.sh`: Advanced log management system

- `scripts/validate_agents.py`: Agent validation with JSON schema

- `scripts/validate-bot-permissions.sh`: Bot permission verification

- `scripts/qc_pre_push.sh`: 95% quality threshold validation (8 metrics)

## AAR (After Action Report) System

DevOnboarder includes a comprehensive AAR system for automated CI failure analysis:

**Make Targets**:

```bash
make aar-env-template     # Create/update .env with AAR tokens

make aar-setup           # Complete AAR system setup with validation

make aar-check           # Validate AAR system status and configuration

make aar-validate        # Check AAR templates for markdown compliance

make aar-generate WORKFLOW_ID=12345                    # Generate AAR for workflow

make aar-generate WORKFLOW_ID=12345 CREATE_ISSUE=true  # Generate AAR + GitHub issue

```

**AAR Features**:

- **Token Management**: Follows DevOnboarder No Default Token Policy v1.0

- **Environment Loading**: Automatically loads `.env` variables

- **Compliance Validation**: Ensures markdown standards (MD007, MD009, MD022, MD032)

- **GitHub Integration**: Creates issues for CI failures when tokens configured

- **Offline Mode**: Generates reports without tokens for local analysis

- **Workflow Analysis**: Detailed failure analysis with logs and context

## Automation Ecosystem

DevOnboarder includes 100+ automation scripts in `scripts/` covering:

- **CI Health Monitoring**: `monitor_ci_health.sh`, `analyze_ci_patterns.sh`

- **Security Auditing**: `potato_policy_enforce.sh`, `security_audit.sh`

- **Environment Management**: `setup-env.sh`, `check_dependencies.sh`

- **Issue Management**: `close_resolved_issues.sh`, `batch_close_ci_noise.sh`

- **Quality Assurance**: `validate_pr_checklist.sh`, `standards_enforcement_assessment.sh`

- **Artifact Management**: `clean_pytest_artifacts.sh`, `enforce_output_location.sh`

- **Log Management**: `run_tests_with_logging.sh`, `manage_logs.sh`

- **Agent Validation**: `validate_agents.py`, `validate-bot-permissions.sh`

## Virtual Environment in CI

All CI commands use proper virtual environment context:

```yaml

# Example GitHub Actions step

- name: Run Python tests

  run: |
      source .venv/bin/activate
      python -m pytest --cov=src --cov-fail-under=95

- name: Validate OpenAPI

  run: |
      source .venv/bin/activate
      python -m openapi_spec_validator src/devonboarder/openapi.json

```

## Error Handling Requirements

- **GitHub CLI availability**: Always check with fallbacks

- **Variable initialization**: Initialize all variables early

- **Exit codes**: Proper error propagation in shell scripts

- **Virtual environment checks**: Verify environment before tool execution

- **Root Artifact Guard**: Automatic pollution detection and blocking

- **CI Triage Guard**: Pattern recognition for recurring CI failures

- **Automated issue creation**: For persistent failures via `codex.ci.yml`

- **Log persistence**: Enhanced logging via `run_tests_with_logging.sh`
