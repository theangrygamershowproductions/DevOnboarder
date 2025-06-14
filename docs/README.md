# Developer Onboarding

Welcome to **DevOnboarder**. This page explains how to get your environment running and where to find documentation about our workflow.

## Local Development

1. Run `bash scripts/bootstrap.sh` to create `.env.dev` and install dependencies.
2. Start services with `docker compose -f docker-compose.dev.yaml up -d`.
3. Verify changes with `ruff check .` and `pytest -q` before committing.

## Key Documentation

- [Git guidelines](git-guidelines.md) &ndash; branch naming, commit messages and the pre‑PR checklist.
- [Pull request template](pull_request_template.md) &ndash; describe your changes and verify the checklist.
- [Merge checklist](merge-checklist.md) &ndash; steps maintainers use before merging.
- [Changelog](CHANGELOG.md) &ndash; record notable updates for each release.

## Issues and Pull Requests

1. Search existing issues to avoid duplicates and provide clear reproduction steps.
2. Start branches from the latest `main` and follow the git guidelines.
3. Use the pull request template and ensure the checklist passes.

