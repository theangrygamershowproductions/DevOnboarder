# Developer Onboarding

Welcome to **DevOnboarder**. This page explains how to get your environment running and where to find documentation about our workflow.

## Local Development

1. Run `bash scripts/bootstrap.sh` to create `.env.dev` and install dependencies
   (including `httpx` and `uvicorn`).
2. Install the project in editable mode with `pip install -e .`.
3. Start services with `docker compose -f docker-compose.dev.yaml up -d`.
4. Alternatively, run `devonboarder-server` to start the app without Docker. Stop it with Ctrl+C.
5. Visit `http://localhost:8000` to see the greeting server.
6. Run `devonboarder-api` to start the user API at `http://localhost:8001`.
   This command requires `uvicorn`.
7. Run `devonboarder-auth` to start the auth service at `http://localhost:8002`.
   It stores data in a local SQLite database.
8. Test the XP API with:
   `curl http://localhost:8001/api/user/onboarding-status`
   and `curl http://localhost:8001/api/user/level`.
9. Stop services with `docker compose -f docker-compose.dev.yaml down`.
10. Verify changes with `ruff check .` and `pytest -q` before committing.
11. Install git hooks with `pre-commit install` so these checks run automatically.

## Key Documentation

- [Git guidelines](git-guidelines.md) &ndash; branch naming, commit messages and the pre‑PR checklist.
- [Pull request template](pull_request_template.md) &ndash; describe your changes and verify the checklist.
- [Merge checklist](merge-checklist.md) &ndash; steps maintainers use before merging.
- [Changelog](CHANGELOG.md) &ndash; record notable updates for each release.
- [Alpha tester onboarding](alpha/README.md) &ndash; guide for early testers.
- [Alpha wave rollout guide](alpha/alpha-wave-rollout-guide.md) &ndash; steps to prepare each invite wave.
- [Founder's Circle onboarding](founders/README.md) &ndash; roles and perks for core supporters.
- [Alpha phase roadmap](roadmap/alpha-phase.md) &ndash; pre- and post-launch milestones.
- [Feedback dashboard PRD](prd/feedback-dashboard.md) &ndash; objectives and features for the feedback tool.
- [Discord message templates](discord/discord-message-templates.md) &ndash; sample posts for the community.
- [Alpha testers log](../ALPHA_TESTERS.md) &ndash; track invitations and feedback status.
- [Founders log](../FOUNDERS.md) &ndash; record core contributors and how they help.

## Configuration Helpers

- `.pre-commit-config.yaml` &ndash; run `pre-commit install` to set up git hooks that execute the linter and tests.
- `.editorconfig` &ndash; ensures consistent indentation and line endings across editors.
- `.python-version` &ndash; indicates the Python version for pyenv.
- `.nvmrc` &ndash; defines the Node.js version for nvm.

## Issues and Pull Requests

1. Search existing issues to avoid duplicates and provide clear reproduction steps.
2. Start branches from the latest `main` and follow the git guidelines.
3. Use the pull request template and ensure the checklist passes.

