---
codex-agent:
    name: Agent.DocumentationQuality
    role: Automated markdown validation and quality enforcement
    scope: documentation quality checks
    triggers: documentation changes and PR validation
    output: .codex/logs/documentation-quality.log
permissions:
    - repo:read
    - repo:write
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
