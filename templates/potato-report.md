---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Template for generating Potato Policy audit reports with standardized security analysis
document_type: template
merge_candidate: false
project: DevOnboarder
similarity_group: documentation-documentation
status: active
tags:

- template

- potato-policy

- security

- audit

title: Potato Policy Report Template
updated_at: '2025-09-12'
visibility: internal
---

# 🥔 Potato Policy Audit Report

**Generated:** $(date -Iseconds)

**Repository:** theangrygamershowproductions/DevOnboarder

**Branch:** $(git branch --show-current)

**Commit:** $(git rev-parse --short HEAD)

##  Policy Status Overview

[![🥔 Potato Policy](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/potato-policy-focused.yml/badge.svg)](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/potato-policy-focused.yml)

## 🛡️ Protected Files

The Potato Policy enforces protection for the following sensitive file patterns:

- `Potato.md` - SSH keys, environment setup instructions

- `*.env` - Environment variables and secrets

- `*.pem` - Private keys and certificates

- `*.key` - Cryptographic keys

- `secrets.yaml` / `secrets.yml` - Configuration secrets

- `.env.local` / `.env.production` - Environment-specific configs

##  Ignore File Compliance

### .gitignore Status

```bash
$(grep -E "(Potato\.md|\*\.env|\*\.pem|\*\.key|secrets\.ya?ml|\.env\.(local|production))" .gitignore 2>/dev/null || echo " Missing entries")

```

### .dockerignore Status

```bash
$(grep -E "(Potato\.md|\*\.env|\*\.pem|\*\.key|secrets\.ya?ml|\.env\.(local|production))" .dockerignore 2>/dev/null || echo " Missing entries")

```

### .codespell-ignore Status

```bash
$(grep -E "(Potato\.md|\*\.env|\*\.pem|\*\.key|secrets\.ya?ml|\.env\.(local|production))" .codespell-ignore 2>/dev/null || echo " Missing entries")

```

## 🚨 Recent Violations

$(if [ -f "logs/potato-violations.log" ]; then echo "### Last 10 Violations"; tail -10 logs/potato-violations.log || echo "No violations on record"; else echo "No violation log found - system is compliant"; fi)

##  Enforcement Actions

**Automatic Remediation:**  Enabled

**GitHub Issue Creation:** $(if command -v gh &> /dev/null && [ -n "${GITHUB_TOKEN:-}" ]; then echo " Enabled"; else echo " Disabled (no GitHub CLI or token)"; fi)

**Audit Logging:**  Enabled

**CI/CD Integration:**  Active

## GROW: Compliance Metrics

**Policy Checks Run:** $(git log --oneline --grep="potato\|Potato" | wc -l || echo "0")

**Last Policy Update:** $(git log -1 --format="%ci" -- scripts/potato_policy_enforce.sh || echo "Unknown")

**Protected File Patterns:** 8

**Ignore Files Monitored:** 3

---

_This report was generated automatically by the Potato Policy audit system._

_For more information, see [docs/about-potato.md](../docs/about-potato.md)_
