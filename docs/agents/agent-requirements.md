---
author: TAGS Engineering
codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: AGENT
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: Agent-specific guidelines, behaviors, documentation standards, and compliance
  requirements for AI agents
document_type: agent
merge_candidate: false
project: core-instructions
related_modules:
- terminal-output-policy.md
- virtual-environment-policy.md
- quality-control-policy.md
similarity_group: documentation-guides
source: .github/copilot-instructions.md
status: active
tags:
- devonboarder
- agent-requirements
- ai-guidelines
- documentation
- compliance
title: DevOnboarder Agent Requirements
updated_at: '2025-09-11'
visibility: internal
---

# DevOnboarder Agent Requirements

## Agent-Specific Guidelines

### For Documentation Creation

**CRITICAL**: Check for parallel documentation improvement efforts before creating new documentation:

1. **Survey existing improvement work**:

   - Look for recent markdown fixing scripts (`scripts/*markdown*.py`, `fix_*markdown*.sh`)

   - Check changelog entries for comprehensive documentation updates

   - Review for repository-wide documentation cleanup initiatives

2. **Coordinate with existing workflows**:

   - Apply comprehensive improvement scripts to new docs immediately after creation

   - Use existing quality standards proactively during content creation

   - Integrate with broader cleanup timelines when active

3. **Quality standards approach**:

   - Create markdown-compliant content from start (MD022, MD032, MD031, MD007, MD009)

   - Use existing improvement tools on new content to maintain consistency

   - Avoid creating docs that immediately need comprehensive fixes

**Reference**: `docs/lessons/documentation-coordination-strategy.md` - Coordination strategy and lessons learned

### For Code Generation

- **ALWAYS assume virtual environment context** in examples

- Follow established patterns in existing codebase

- Maintain the project's "quiet reliability" philosophy

- Prioritize error handling and edge cases

- Include comprehensive tests with new code

- **Use `python -m module` syntax** for all Python tools

### For Refactoring

- Preserve existing API contracts

- Maintain or improve test coverage

- Update documentation for any public interface changes

- Consider multi-environment implications

- **Ensure virtual environment compatibility**

### For Bug Fixes

- Write regression tests first

- Document root cause in commit message

- Consider if fix affects other services

- Update troubleshooting documentation if needed

- **Test in clean virtual environment**

## Critical Reminders for Agents

1. **NEVER suggest system installation** of Python packages

2. **ALWAYS use `python -m module` syntax** for tools

3. **ALWAYS verify virtual environment activation** in examples

4. **ALWAYS include virtual environment setup** in instructions

5. **NEVER modify linting configuration files** without explicit human request

6. **NEVER use emojis or Unicode characters in terminal output** - CAUSES IMMEDIATE HANGING

7. **NEVER use multi-line echo or here-doc syntax** - Use individual echo commands only

8. **ALWAYS use plain ASCII text only** in echo commands to prevent terminal hanging

9. **REMEMBER**: This project runs in containers/venvs, not host systems

10. **ALWAYS follow validation-driven resolution**: When validation scripts provide specific commands, use those exact commands rather than manual fixes

11. **RESPECT**: DevOnboarder automation patterns - scripts provide actionable guidance for consistent compliance

12. **RESPECT**: Root Artifact Guard and CI Triage Guard enforcement

13. **FOLLOW**: Node modules hygiene standards and placement requirements

14. **TERMINAL OUTPUT**: Use only simple, individual echo commands with plain text

## Pre-commit Hook Management for Agents

**CRITICAL UNDERSTANDING**: Pre-commit hooks frequently modify files during validation (trailing whitespace, formatting fixes). This creates a common cycle where:

1. Files are staged for commit

2. Pre-commit hooks run and modify the files

3. Modified files become unstaged, causing commit failure

**MANDATORY AGENT BEHAVIOR**:

- **Use `scripts/safe_commit.sh`** instead of direct `git commit` commands

- **NEVER suggest** using `--no-verify` to bypass pre-commit hooks

- **NEVER use --no-verify flag** under any circumstances (ZERO TOLERANCE POLICY)

- **UNDERSTAND**: Second pre-commit failure indicates systemic issues, not formatting

- **EXPECT**: Automatic re-staging of files modified by hooks

- **ANALYZE**: Enhanced safe_commit.sh provides automatic log analysis on systemic failures

- **REMEMBER**: Quality gates exist for critical reasons and must be respected

**Safe Commit Pattern**:

```bash

# ✅ CORRECT - Use safe commit wrapper

scripts/safe_commit.sh "FEAT(component): descriptive commit message"

# ❌ WRONG - Direct git commit bypasses DevOnboarder safety mechanisms

git commit -m "message"

# POTATO: EMERGENCY APPROVED - documentation-example-violation-20250807

git commit --no-verify -m "message"  # VIOLATION: Never use --no-verify - bypasses quality gates

```

## Environment Variable Management for Agents

**CRITICAL UNDERSTANDING**: DevOnboarder uses centralized environment variable management with security boundaries.

**MANDATORY AGENT BEHAVIOR**:

- **Use centralized system**: Run `bash scripts/smart_env_sync.sh --sync-all` instead of manual file edits

- **Validate security**: Run `bash scripts/env_security_audit.sh` after environment changes

- **Respect boundaries**: Never suggest moving production secrets to CI files

- **Single source**: Edit `.env` only, synchronize to other files via scripts

**Security Violation Prevention**:

```bash

# ✅ CORRECT - Centralized management

echo "NEW_VARIABLE=value" >> .env
bash scripts/smart_env_sync.sh --sync-all

# ❌ WRONG - Manual multi-file editing

echo "NEW_VARIABLE=value" >> .env.ci  # Bypasses security boundaries

```

## Shellcheck External Dependencies - Hybrid Approach

**CRITICAL UNDERSTANDING**: DevOnboarder uses a hybrid approach for external dependency management.

**GLOBAL CONFIGURATION**: `.shellcheckrc` handles common external dependencies:

- `.venv/bin/activate` - Virtual environment activation

- `scripts/load_token_environment.sh` - Project token loaders

- `scripts/enhanced_token_loader.sh` - Token Architecture v2.1 loaders

**AGENT REQUIREMENTS**:

- **NO LONGER NEEDED**: `# shellcheck disable=SC1091` for standard DevOnboarder patterns

- **STILL REQUIRED**: Explicit comments for unusual external dependencies only

- **REFERENCE**: See `docs/SHELLCHECK_EXTERNAL_DEPENDENCIES.md` for full guidelines

**STANDARD PATTERNS** (no disable comments needed):

```bash

# ✅ CORRECT - Covered by global .shellcheckrc

source .venv/bin/activate
source scripts/load_token_environment.sh
source scripts/enhanced_token_loader.sh

# ✅ CORRECT - Only for unusual external dependencies

# shellcheck source=custom-external-config.sh disable=SC1091

# source custom-external-config.sh

```

## Markdown Content Creation Standards

**CRITICAL REQUIREMENT**: Create markdown content that passes linting validation on first attempt.

**MANDATORY PRE-CREATION CHECKLIST**:

1. **Review existing compliant markdown** in repository for patterns

2. **Apply formatting rules systematically**:

   - MD022: Blank lines before AND after all headings

   - MD032: Blank lines before AND after all lists

   - MD031: Blank lines before AND after all fenced code blocks

   - MD007: 4-space indentation for nested list items

   - MD040: Language specified for all fenced code blocks

**PREVENTION OF COMMON ERRORS**:

- **NEVER** create markdown content requiring post-creation fixes

- **NEVER** duplicate content when applying formatting fixes

- **ALWAYS** create complete, properly formatted content from start

- **VALIDATE** structure before file creation
