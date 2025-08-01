# DevOnboarder Token Permissions Matrix

## 📋 Complete Token Authorization Guide

Following the **No Default Token Policy**, this matrix defines exact permissions and usage patterns for all DevOnboarder automation tokens.

### 🔐 Primary CI Automation Tokens

| Token Name | Bot Identity | GitHub Permissions | Authorized Usage | Workflows |
|------------|--------------|-------------------|------------------|-----------|
| `CI_ISSUE_AUTOMATION_TOKEN` | `devonboarder-ci` | `issues:write`, `pull_requests:write`, `contents:read`, `metadata:read` | Primary CI automation, issue creation, PR management | `ci.yml`, `ci-health.yml`, `pr-automation.yml` |
| `DIAGNOSTICS_BOT_KEY` | `devonboarder-diagnostics` | `issues:write`, `contents:read`, `actions:read` | Root Artifact Guard, CI health monitoring, log parsing | `ci.yml`, `diagnostics-post.yml`, `enforce-output-location.yml` |

### 🔍 Specialized Automation Tokens

| Token Name | Bot Identity | GitHub Permissions | Authorized Usage | Scripts |
|------------|--------------|-------------------|------------------|---------|
| `CHECKLIST_BOT_TOKEN` | `devonboarder-checklist` | `pull_requests:write`, `contents:read` | PR checklist enforcement, quality validation | `validate_pr_checklist.sh`, `standards_enforcement_assessment.sh` |
| `AAR_BOT_TOKEN` | `devonboarder-aar` | `issues:write`, `pull_requests:read`, `contents:read` | After Actions Report generation, post-merge reporting | `generate_aar.sh`, `audit_retro_actions.sh` |
| `CI_HEALTH_KEY` | `devonboarder-health` | `actions:read`, `issues:write` | CI pipeline health monitoring, stability metrics | `monitor_ci_health.sh`, `update_ci_dashboard.sh` |
| `CLEANUP_CI_FAILURE_KEY` | `devonboarder-cleanup` | `issues:write` | Automated CI failure issue cleanup | `close_resolved_issues.sh`, `batch_close_ci_noise.sh` |

### 🔬 Analysis and Pattern Recognition

| Token Name | Bot Identity | GitHub Permissions | Authorized Usage | Purpose |
|------------|--------------|-------------------|------------------|---------|
| `CI_ISSUE_TOKEN` | `devonboarder-issue-creator` | `issues:write`, `pull_requests:read` | Automated issue creation for CI failures | CI failure tracking and resolution |
| `REVIEW_KNOWN_ERRORS_KEY` | `devonboarder-reviewer` | `contents:read`, `issues:write` | Pattern recognition for recurring issues | Error runbook maintenance |
| `CI_HELPER_AGENT_KEY` | `devonboarder-helper` | `contents:write`, `actions:read` | Dashboard updates, CI assistance | Status reporting and documentation |

### 🏗️ Orchestration Tokens (Restricted)

| Token Name | Bot Identity | Environment | GitHub Permissions | Usage Restrictions |
|------------|--------------|-------------|-------------------|-------------------|
| `PROD_ORCHESTRATION_BOT_KEY` | `devonboarder-prod-orch` | Production | `actions:write`, `contents:read` | **Production only** - Never use in PR/CI flows |
| `DEV_ORCHESTRATION_BOT_KEY` | `devonboarder-dev-orch` | Development | `actions:write`, `contents:read` | Development workflow coordination only |

### 🛡️ Security and Quality Tokens

| Token Name | Bot Identity | GitHub Permissions | Authorized Usage | Security Level |
|------------|--------------|-------------------|------------------|----------------|
| `SECURITY_AUDIT_TOKEN` | `devonboarder-security` | `security_events:read`, `issues:write`, `contents:read` | Enhanced Potato Policy enforcement | **High Security** |
| `VALIDATE_PERMISSIONS_TOKEN` | `devonboarder-permissions` | `administration:read`, `issues:write` | Bot permission auditing and validation | **Administrative** |

### Deprecated

| Token Name | Status | Reason | Replacement |
|------------|--------|--------|-------------|
| `CI_BOT_TOKEN` | DEPRECATED | Shared across workflows; lacks scoping | Use scoped tokens |
| `BOT_PR_WRITE_TOKEN` | DEPRECATED | Replaced by scoped PR commenting | `CHECKLIST_BOT_TOKEN` or `AAR_BOT_TOKEN` |

### Prohibited

| Token Name | Status | Reason | Alternative |
|------------|--------|--------|-------------|
| `GITHUB_TOKEN` | PROHIBITED | Violates No Default Token Policy - lacks proper scoping | Use scoped automation tokens |

