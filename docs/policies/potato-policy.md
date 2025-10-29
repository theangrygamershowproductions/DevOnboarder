---
author: "TAGS Engineering"
codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: 2025-09-11
description: "Automated security mechanism protecting sensitive files from accidental"

document_type: standards
merge_candidate: false
project: core-instructions
related_modules: 
similarity_group: ci-automation
source: .github/copilot-instructions.md
status: active
tags: 
title: "DevOnboarder Enhanced Potato Policy"

updated_at: 2025-10-27
visibility: internal
---

# DevOnboarder Enhanced Potato Policy

## 🥔 Enhanced Potato Policy

DevOnboarder implements a unique **Enhanced Potato Policy** - an automated security mechanism that protects sensitive files from accidental exposure. This is a core architectural feature that affects all development work:

**Protected Patterns**:

- `Potato.md` - SSH keys, setup instructions

- `*.env` - Environment variables

- `*.pem`, `*.key` - Private keys and certificates

- `secrets.yaml/yml` - Configuration secrets

**Enforcement Points**:

- `.gitignore`, `.dockerignore`, `.codespell-ignore` must contain "Potato" entries

- Pre-commit hooks via `scripts/check_potato_ignore.sh`

- CI validation in `potato-policy-focused.yml` workflow

- Automatic violation reporting and issue creation

**Developer Impact**: Any attempt to remove "Potato" entries or expose sensitive files will fail CI and require project lead approval with changelog documentation.

**Validation Commands**:

```bash

# Check Potato Policy compliance

bash scripts/check_potato_ignore.sh

# Generate security audit report

bash scripts/generate_potato_report.sh

# Enforce policy across all ignore files

bash scripts/potato_policy_enforce.sh

```

**What Gets Protected**:

- SSH keys and certificates in `Potato.md`

- Database credentials in environment files

- API tokens and webhooks configurations

- Any file matching protected patterns

**Enforcement Points Detail**:

- **Pre-commit**: `scripts/check_potato_ignore.sh` validates ignore files

- **CI/CD**: `potato-policy-focused.yml` workflow enforces compliance

- **Docker builds**: `.dockerignore` prevents sensitive files in images

- **Spell checking**: `.codespell-ignore` prevents exposure via docs
