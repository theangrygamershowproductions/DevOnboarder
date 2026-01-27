---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Guide for contributing to DevOnboarder including setup, commit hooks, and quality standards
document_type: guide
merge_candidate: false
project: DevOnboarder
similarity_group: docs-
status: active

tags:

- guide

- contributing

- development

title: DevOnboarder Contributing Guide
updated_at: '2025-09-12'
visibility: internal
---

# Contributing

## Quick Start (No Local Tooling Required)

**CI is the source of truth.** You don't need to install any local tooling to contribute:

1. Fork and clone the repository
2. Make your changes
3. Push and open a PR
4. CI will validate your code — fix any failures

That's it. See [docs/governance/COMPATIBILITY.md](docs/governance/COMPATIBILITY.md) for our full governance contract.

## Optional: Local Development Tooling

For faster feedback during development, you can optionally install local hooks:

### Commit Message Hook (Recommended)

Validates commit message format before pushing:

```bash
bash scripts/install_commit_msg_hook.sh
```

### Pre-commit Hooks (Optional)

Runs linting locally for faster feedback. **Not required** — CI runs the same checks:

```bash
pip install pre-commit
pre-commit install
```

> **Note**: Pre-commit hooks are a convenience, not a gate. CI is authoritative.

### Full Development Setup

Install dependencies for running tests locally:

```bash
pip install -e .[test]
npm ci --prefix bot
npm ci --prefix frontend
```

## Centralized Logging Policy

**CRITICAL**: ALL logging must use the centralized `logs/` directory. This is enforced by CI/CD:

- Scripts: `mkdir -p logs && exec > >(tee -a "logs/script_$(date +%Y%m%d_%H%M%S).log") 2>&1`

- Workflows: `command 2>&1 | tee logs/step-name.log`

- Policy: `docs/standards/centralized-logging-policy.md`

- Validation: `scripts/validate_log_centralization.sh`

Violations block all commits and CI runs. No exceptions.

## Terminal Output Policy

**ZERO TOLERANCE**: GitHub Actions workflows must use only plain ASCII text in echo statements:

- **FORBIDDEN**: Emojis, Unicode characters, command substitution, variable expansion

- **REQUIRED**: Individual echo commands with static text only

- **VALIDATION**: `bash scripts/validate_terminal_output.sh`

- **DOCUMENTATION**: `docs/TERMINAL_OUTPUT_VIOLATIONS.md`

Violations cause immediate terminal hanging and are blocked by pre-commit hooks.

**Markdown Standards**: All documentation must follow markdownlint rules including MD032 (lists surrounded by blank lines).
Check compliance with: `npx markdownlint *.md docs/**/*.md`

You can run `scripts/dev_setup.sh` to perform these steps automatically, or
`scripts/setup_tests.sh` to install only the Python requirements.
See [docs/dependencies.md](docs/dependencies.md) for the Dependabot update workflow.

See [.codex/Agents.md](.codex/Agents.md) for agent YAML guidelines and notification rules.
Agent files are automatically validated against the schema in `schema/agent-schema.json` during pre-commit and CI.
Run `python scripts/validate_agents.py` to manually validate all agent files.
Refer to [docs/checklists/continuous-improvement.md](docs/checklists/continuous-improvement.md) during each retrospective.

## Issue Management

DevOnboarder uses a comprehensive labeling system for issue organization and project planning.
See [docs/contributing/issue-labeling-guide.md](docs/contributing/issue-labeling-guide.md) for:

- **Priority and effort estimation** (`priority-high`, `effort-medium`, etc.)

- **Component categorization** (`testing-infrastructure`, `developer-experience`, etc.)

- **Strategic planning guidelines** and implementation sequences

- **Label usage examples** and filter combinations

- **Integration with CI/CD workflows** and automation

## Continuous Improvement Checklist

Pull requests must include the block from
[`.github/pull_request_template.md`](.github/pull_request_template.md) with the
heading **## Continuous Improvement Checklist**. The CI workflow fails when this

heading is missing. See
[docs/checklists/continuous-improvement.md](docs/checklists/continuous-improvement.md)
for details.
