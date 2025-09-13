---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: tools-dashboard.md-docs
status: active
tags:
- documentation
title: Tools Dashboard
updated_at: '2025-09-12'
visibility: internal
---

# 🛠️ DevOnboarder Tools & Maintenance Dashboard

**Last Updated**: 2025-08-01
**Status**: Active Maintenance Guide
**Purpose**: Centralized reference for all DevOnboarder maintenance, cleanup, and diagnostic tools

---

## 🧹 **Branch & Repository Cleanup Tools**

### Branch Management

| Tool | Purpose | Usage | Safety Level |
|------|---------|-------|-------------|
| `scripts/quick_branch_cleanup.sh` | Safe, routine branch cleanup | `bash scripts/quick_branch_cleanup.sh` | ✅ High (dry-run default) |
| `scripts/comprehensive_branch_cleanup.sh` | Thorough branch analysis | `bash scripts/comprehensive_branch_cleanup.sh` | ✅ High (configurable) |
| `scripts/manual_branch_cleanup.sh` | Interactive branch management | `bash scripts/manual_branch_cleanup.sh` | ⚠️ Medium (manual review) |

### Artifact Cleanup

| Tool | Purpose | Usage | Safety Level |
|------|---------|-------|-------------|
| `scripts/enhanced_root_artifact_guard.sh` | Repository pollution detection | `bash scripts/enhanced_root_artifact_guard.sh --check` | ✅ High |
| `scripts/clean_pytest_artifacts.sh` | Python test artifact cleanup | `bash scripts/clean_pytest_artifacts.sh` | ✅ High |
| `scripts/enforce_output_location.sh` | Root directory protection | `bash scripts/enforce_output_location.sh` | ✅ High |

---

## 📋 **Issue Management Tools**

### PR Review & Feedback Integration

| Tool | Purpose | Usage | Safety Level |
|------|---------|-------|-------------|
| `scripts/check_pr_inline_comments.sh` | Extract Copilot comments + resolution tracking | `bash scripts/check_pr_inline_comments.sh --summary <PR>` | ✅ High (read-only display, annotation storage) |

```bash

# Basic comment viewing

./scripts/check_pr_inline_comments.sh --summary 1330
./scripts/check_pr_inline_comments.sh --copilot-only --suggestions 1330
./scripts/check_pr_inline_comments.sh --open-browser 1330

# Resolution tracking workflow (NEW)

./scripts/check_pr_inline_comments.sh --annotate 1330
./scripts/check_pr_inline_comments.sh --resolution-summary 1330
./scripts/check_pr_inline_comments.sh --learning-export 1330

# CI integration

./scripts/check_pr_inline_comments.sh --verify-resolutions 1330
./scripts/check_pr_inline_comments.sh --format=json 1330

```### Issue Resolution

| Tool | Purpose | Usage | Safety Level |
|------|---------|-------|-------------|
| `scripts/review_resolved_issues.sh` | Systematic issue review | `bash scripts/review_resolved_issues.sh` | ✅ High (read-only) |
| `scripts/list_open_ci_issues.py` | List CI failure issues | `python scripts/list_open_ci_issues.py` | ✅ High (read-only) |
| `gh issue close <number>` | Close resolved issues | `gh issue close 1050 --comment "Resolved: details"` | ⚠️ Medium (manual) |

### Issue Patterns Resolved Today

- ✅ **CI Failure Issues**: Check for merged PRs → Close automatically

- ✅ **Artifact Pollution**: Run artifact guard → Close if clean

- 🔍 **Dependency Issues**: Review update status → Close if complete

---

## 🔧 **Maintenance Workflows**

### Daily/Weekly Maintenance

```bash

# 1. Review and close resolved issues

bash scripts/review_resolved_issues.sh

# 2. Clean up stale branches

bash scripts/quick_branch_cleanup.sh

# 3. Check repository hygiene

bash scripts/enhanced_root_artifact_guard.sh --check

# 4. Review open issues count

gh issue list --state open | wc -l

```

### Monthly Deep Cleanup

```bash

# 1. Comprehensive branch cleanup

bash scripts/comprehensive_branch_cleanup.sh

# 2. Log management

bash scripts/manage_logs.sh clean

# 3. Full validation suite

bash scripts/run_tests.sh

```

---

## 📊 **Monitoring & Diagnostics**

### CI Health Monitoring

| Tool | Purpose | Usage |
|------|---------|-------|
| `docs/ci-dashboard.md` | CI status overview | View current CI health |
| `scripts/run_tests.sh` | Full test suite | `bash scripts/run_tests.sh` |
| `scripts/run_tests_with_logging.sh` | Enhanced test logging | `bash scripts/run_tests_with_logging.sh` |

### Log Management

| Tool | Purpose | Usage |
|------|---------|-------|
| `scripts/manage_logs.sh list` | List all logs | `bash scripts/manage_logs.sh list` |
| `scripts/manage_logs.sh clean` | Clean old logs (7+ days) | `bash scripts/manage_logs.sh clean` |

| `scripts/manage_logs.sh archive` | Archive current logs | `bash scripts/manage_logs.sh archive` |

---

## 🔐 **Security & Compliance Tools**

### Enhanced Potato Policy

| Tool | Purpose | Usage |
|------|---------|-------|
| `scripts/check_potato_ignore.sh` | Validate Potato Policy compliance | `bash scripts/check_potato_ignore.sh` |
| `scripts/generate_potato_report.sh` | Security audit report | `bash scripts/generate_potato_report.sh` |
| `scripts/potato_policy_enforce.sh` | Enforce policy across files | `bash scripts/potato_policy_enforce.sh` |

### Token Management

| Tool | Purpose | Usage |
|------|---------|-------|
| `scripts/aar_security.py` | Token hierarchy analysis | `python scripts/aar_security.py` |
| `scripts/setup_aar_tokens.sh` | Token configuration guide | `bash scripts/setup_aar_tokens.sh` |

---

## 📝 **After Action Reporting (AAR)**

### AAR System Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| `scripts/generate_aar.py` | Generate CI failure reports | `python scripts/generate_aar.py --workflow-run-id <id>` |
| `scripts/aar_security.py` | Token security analysis | `python scripts/aar_security.py` |
| `scripts/validate_templates.py` | Template validation | `python scripts/validate_templates.py` |
| `scripts/file_version_tracker.py` | File change tracking | `python scripts/file_version_tracker.py` |

### AAR Workflow

1. **CI Failure Occurs** → Automatic issue creation via `codex.ci.yml`

2. **Generate AAR** → `python scripts/generate_aar.py --create-issue`

3. **Security Audit** → `python scripts/aar_security.py audit_token_usage`

4. **Close Issue** → When root cause resolved

---

## 🚀 **Quick Reference Commands**

### Most Common Maintenance Tasks

```bash

# Weekly cleanup routine

bash scripts/quick_branch_cleanup.sh
bash scripts/review_resolved_issues.sh
bash scripts/enhanced_root_artifact_guard.sh --check

# Before major releases

bash scripts/comprehensive_branch_cleanup.sh
bash scripts/run_tests_with_logging.sh
bash scripts/manage_logs.sh archive

# Emergency diagnostics

bash scripts/enhanced_ci_failure_analyzer.py
python scripts/generate_aar.py --workflow-run-id <latest_failure>

```

### Issue Management Quick Commands

```bash

# List open issues by type

gh issue list --label "ci-failure" --state open
gh issue list --label "dependencies" --state open
gh issue list --label "artifact-pollution" --state open

# Close resolved issues

gh issue close <number> --comment "Resolved: <description>"

# Bulk review

bash scripts/review_resolved_issues.sh

```

---

## 📈 **Automation Status**

### Currently Automated

- ✅ **CI Failure Detection**: Automatic issue creation

- ✅ **Artifact Pollution Monitoring**: Scheduled checks

- ✅ **Branch Protection**: Pre-commit hooks enforce standards

- ✅ **Log Centralization**: Mandatory policy enforcement

- ✅ **Security Policy**: Enhanced Potato Policy v2.0

### Manual Processes (Candidates for Automation)

- 🔧 **Issue Resolution Review**: Could be automated based on status patterns

- 🔧 **Branch Cleanup**: Could be scheduled weekly

- 🔧 **Log Archival**: Could be automated monthly

---

## 📚 **Related Documentation**

- **CI Status**: [`docs/ci-dashboard.md`](docs/ci-dashboard.md) - Live CI health monitoring

- **Contributing**: [`CONTRIBUTING.md`](CONTRIBUTING.md) - Development guidelines

- **Security**: [`SECURITY.md`](SECURITY.md) - Security policies and procedures

- **Agent System**: [`agents/index.md`](agents/index.md) - Codex agent documentation

---

## 🆘 **Troubleshooting Quick Links**

| Issue Type | Quick Fix | Tool |

|------------|-----------|------|
| **CI Failures** | Check [CI Dashboard](docs/ci-dashboard.md) | `scripts/enhanced_ci_failure_analyzer.py` |

| **Branch Conflicts** | Run branch cleanup | `scripts/quick_branch_cleanup.sh` |

| **Artifact Pollution** | Run artifact guard | `scripts/enhanced_root_artifact_guard.sh --auto-clean` |

| **Test Failures** | Enhanced test logging | `scripts/run_tests_with_logging.sh` |

| **Open Issues Backlog** | Issue resolution review | `scripts/review_resolved_issues.sh` |

---

**🎯 DevOnboarder Philosophy**: *"This project wasn't built to impress — it was built to work. Quietly. Reliably. And in service of those who need it."*

**Maintenance Principle**: Regular small cleanups prevent major problems. Use these tools consistently to maintain project health.
