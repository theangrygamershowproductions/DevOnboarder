# Developer Onboarding

Welcome to **DevOnboarder**. This page explains how to get your environment running and where to find documentation about our workflow.

## Local Development

1. Run `bash scripts/bootstrap.sh` to create `.env.dev` and install dependencies.
2. Start services with `docker compose -f docker-compose.dev.yaml up -d`.
3. Visit `http://localhost:8000` to see the greeting server.
4. Verify changes with `ruff check .` and `pytest -q` before committing.
5. Install git hooks with `pre-commit install` so these checks run automatically.

## Key Documentation

- [Git guidelines](git-guidelines.md) &ndash; branch naming, commit messages and the pre‑PR checklist.
- [Pull request template](pull_request_template.md) &ndash; describe your changes and verify the checklist.
- [Merge checklist](merge-checklist.md) &ndash; steps maintainers use before merging.
- [Changelog](CHANGELOG.md) &ndash; record notable updates for each release.

## Configuration Helpers

- `.pre-commit-config.yaml` &ndash; run `pre-commit install` to set up git hooks that execute the linter and tests.
- `.editorconfig` &ndash; ensures consistent indentation and line endings across editors.
- `.python-version` &ndash; indicates the Python version for pyenv.
- `.nvmrc` &ndash; defines the Node.js version for nvm.

## Issues and Pull Requests

1. Search existing issues to avoid duplicates and provide clear reproduction steps.
2. Start branches from the latest `main` and follow the git guidelines.
3. Use the pull request template and ensure the checklist passes.

