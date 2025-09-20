---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: security-security
status: active
tags:

- documentation

title: Token Permissions Matrix
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder Token Permissions Matrix

**Version**: 2.0 - Enhanced Token Governance

**Last Updated**: $(date +%Y-%m-%d)
**Policy**: No Default Token Policy v1.0
**Classification**: Internal Use - Security Critical

## 📋 Complete Token Authorization Guide

Following the **No Default Token Policy**, this matrix defines exact permissions and usage patterns for all DevOnboarder automation tokens. This document serves as the authoritative reference for token governance, security auditing, and compliance validation.

## Token Classification System

### Primary Classification Categories

- **CI_AUTOMATION**: Primary CI/CD pipeline automation tokens

- **SPECIALIZED_BOT**: Task-specific automation with defined scopes

- **MONITORING**: Health monitoring and observability tokens

- **SECURITY**: Security audit and compliance enforcement tokens

- **ORCHESTRATION**: Multi-service coordination and deployment tokens

### Risk Assessment Framework

- **🔴 HIGH**: Full repository access or organization-level permissions

- **🟡 MEDIUM**: Limited repository access with write permissions

- **🟢 LOW**: Read-only or minimal scope permissions

## 🔐 Primary CI Automation Tokens

| Token Name | Bot Identity | Classification | Risk | GitHub Permissions | Authorized Usage | Active Workflows |
|------------|--------------|----------------|------|-------------------|------------------|------------------|
| `CI_ISSUE_AUTOMATION_TOKEN` | `devonboarder-ci` | CI_AUTOMATION | 🟡 MEDIUM | `issues:write`, `pull_requests:write`, `contents:read`, `metadata:read` | Primary CI automation, issue creation, PR management, quality gates | `ci.yml`, `ci-health.yml`, `pr-automation.yml`, `codex.ci.yml` |
| `DIAGNOSTICS_BOT_KEY` | `devonboarder-diagnostics` | CI_AUTOMATION | 🟢 LOW | `issues:write`, `contents:read`, `actions:read`, `metadata:read` | Root Artifact Guard, CI health monitoring, log parsing, diagnostic reporting | `ci.yml`, `diagnostics-post.yml`, `enforce-output-location.yml` |
| `CI_BOT_TOKEN` | `devonboarder-ci-fallback` | CI_AUTOMATION | 🟡 MEDIUM | `actions:read`, `contents:read`, `metadata:read`, `packages:read` | CI pipeline support, artifact access, fallback automation | `ci.yml`, `auto-fix.yml` |

## 🔍 Specialized Automation Tokens

| Token Name | Bot Identity | Classification | Risk | GitHub Permissions | Authorized Usage | Active Scripts |
|------------|--------------|----------------|------|-------------------|------------------|----------------|
| `CHECKLIST_BOT_TOKEN` | `devonboarder-checklist` | SPECIALIZED_BOT | 🟡 MEDIUM | `pull_requests:write`, `contents:read`, `metadata:read` | PR checklist enforcement, quality validation, standards compliance | `validate_pr_checklist.sh`, `standards_enforcement_assessment.sh` |
| `AAR_BOT_TOKEN` | `devonboarder-aar` | SPECIALIZED_BOT | 🟡 MEDIUM | `issues:write`, `pull_requests:read`, `contents:read`, `metadata:read` | After Actions Report generation, post-merge reporting, incident analysis | `generate_aar.sh`, `audit_retro_actions.sh` |
| `CI_HEALTH_KEY` | `devonboarder-health` | MONITORING | 🟢 LOW | `actions:read`, `issues:write`, `metadata:read` | CI pipeline health monitoring, stability metrics, performance tracking | `monitor_ci_health.sh`, `update_ci_dashboard.sh` |

## 🔐 Advanced Governance Tokens

| Token Name | Bot Identity | Classification | Risk | GitHub Permissions | Authorized Usage | Integration Points |
|------------|--------------|----------------|------|-------------------|------------------|--------------------|
| `MONITORING_BOT_TOKEN` | `devonboarder-monitor` | MONITORING | 🟢 LOW | `contents:read`, `metadata:read`, `actions:read` | General system monitoring, metric collection, observability | `monitor_ci_health.sh`, `analyze_ci_patterns.sh` |
| `SECURITY_AUDIT_TOKEN` | `devonboarder-security` | SECURITY | 🟡 MEDIUM | `contents:read`, `metadata:read`, `security_events:read`, `actions:read` | Security scanning, vulnerability assessment, compliance auditing | `security_audit.sh`, `audit_token_usage.py`, `validate_token_cleanup.sh` |
| `ORCHESTRATOR_BOT_TOKEN` | `devonboarder-orchestrator` | ORCHESTRATION | 🔴 HIGH | `contents:write`, `metadata:read`, `actions:write`, `pull_requests:write`, `issues:write` | Multi-service orchestration, automated PR creation, deployment coordination | `dev-orchestrator.yml`, `prod-orchestrator.yml`, `staging-orchestrator.yml` |
| `INFRASTRUCTURE_BOT_TOKEN` | `devonboarder-infrastructure` | ORCHESTRATION | 🔴 HIGH | `contents:write`, `metadata:read`, `actions:write`, `packages:write` | Infrastructure automation, deployment pipelines, package management | Infrastructure workflows, deployment scripts |
| `AGENT_COORDINATOR_TOKEN` | `devonboarder-agent-coord` | ORCHESTRATION | 🟡 MEDIUM | `contents:read`, `metadata:read`, `actions:read`, `issues:write` | Agent coordination, task delegation, workflow orchestration | Agent validation scripts, coordination workflows |
| `ADVANCED_MONITOR_TOKEN` | `devonboarder-adv-monitor` | MONITORING | 🟡 MEDIUM | `contents:read`, `metadata:read`, `actions:read`, `issues:write` | Advanced monitoring with issue creation, pattern analysis | Advanced monitoring workflows, alerting systems |
| `CLEANUP_CI_FAILURE_KEY` | `devonboarder-cleanup` | MONITORING | 🟢 LOW | `issues:write` | Automated CI failure issue cleanup | `close_resolved_issues.sh`, `batch_close_ci_noise.sh` |

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
