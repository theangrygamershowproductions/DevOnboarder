---
author: DevOnboarder Team
codex-agent:
  name: Agent.DocumentationQuality
  output: .codex/logs/documentation-quality.log
  role: Automated markdown validation and quality enforcement
  scope: documentation quality checks
  triggers: documentation changes and PR validation
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
permissions:
- repo:read
- repo:write
project: core-agents
similarity_group: documentation-documentation
status: active
tags:
- documentation
- documentation
title: Documentation Quality
updated_at: '2025-09-12'
visibility: internal
---

# Documentation Quality Agent

**Status:** Active.

**Purpose:** Provides automated markdown validation, Potato.md ignore policy enforcement, and quality scoring for documentation files.

## Framework Features

- Automated markdown validation

- Potato.md ignore policy enforcement

- Quality scoring system

- Remediation recommendations

## Integration Points

- Pre-commit hooks for markdown linting

- CI validation for documentation standards

- PR health assessment integration

## Implementation

This agent leverages:

- `markdownlint-cli2` for markdown validation

- `scripts/check_potato_ignore.sh` for policy enforcement

- `scripts/assess_pr_health.sh` for quality scoring

- `scripts/standards_enforcement_assessment.sh` for quality gates
