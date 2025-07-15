# CI Enforcement Tasks

This document outlines the automation checks Codex uses to keep the CI workflow consistent.

## Language Versions

- The main workflow tests Python **3.12** only.
- Node.js **20** is also validated.
- `scripts/check_versions.sh` verifies the versions match the ones used locally.

## Workflow Linting

- Every run starts with `validate-yaml` which lints `.github/workflows/**/*.yml` using the shared config.
- The YAML log uploads as `yamllint.log` for troubleshooting.

## Dependency Checks

- `pip check` runs after installing requirements and again once the package is installed.
- `pip-audit`, `bandit`, and `npm audit --audit-level=high` fail the build on high severity issues.
- `scripts/check_dependencies.sh` and `scripts/security_audit.sh` provide local equivalents.

## Coverage Gate

- Both Python and JavaScript tests must keep **95%** coverage.
- `pytest --cov=src --cov-fail-under=95` enforces this for Python.
- The bot and frontend run `npm run coverage` with the same threshold.
- Coverage summaries are posted on pull requests and saved as artifacts.

## CI Failure Handling

- `codex.ci.yml` monitors `ci.yml` for failures.
- When lint errors occur, Codex attempts `ruff --fix` and `pre-commit run --files`.
- If the build still fails, the bot opens a `ci-failure` issue with logs and summaries.
- Subsequent successful runs automatically close these issues.
