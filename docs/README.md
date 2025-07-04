# Developer Onboarding

Welcome to **DevOnboarder**. This page explains how to get your environment running and where to find documentation about our workflow.

If you're setting up a fresh Ubuntu machine, follow [ubuntu-setup.md](ubuntu-setup.md) for the commands that install Docker, Docker Compose, Node.js 20, and Python 3.12.

After cloning the repository, run `bash scripts/install_commit_msg_hook.sh` to install a `commit-msg` hook. This ensures your commit messages pass the lint check in CI.

## Local Development

1. Run `bash scripts/bootstrap.sh` to create `.env.dev` and install dependencies
   (including `httpx` and `uvicorn`).
   Update `DATABASE_URL` in `.env.dev` if you are not using the default
   Postgres credentials.
2. Generate throwaway secrets with `./scripts/generate-secrets.sh`.
   This script overwrites `.env.dev` with fresh random values. The CI
   workflow runs the same script before building containers so your
   environment matches the pipeline.
3. Build the service containers with `make deps`.
4. Install the project in editable mode with `pip install -e .`.
   Install the dev requirements with `pip install -r requirements-dev.txt`.
5. Start services with `make up` or run
   `docker compose -f docker-compose.dev.yaml --env-file .env.dev up -d`.
   This launches the auth, bot, XP API, frontend, and Postgres services.
   The `frontend/` folder now hosts a React app built with Vite.
6. Run `bash scripts/run_migrations.sh` to apply the initial database migration.
7. Alternatively, run `devonboarder-server` to start the app without Docker. Stop the server with Ctrl+C.
8. Visit `http://localhost:8000` to see the greeting server.
9. Run `devonboarder-api` to start the user API at `http://localhost:8001`.
   This command requires `uvicorn`.
10. Run `devonboarder-auth` to start the auth service at `http://localhost:8002`.
    It stores data in a local SQLite database.
11. Test the XP API with:
    `curl http://localhost:8001/api/user/onboarding-status`
    and `curl http://localhost:8001/api/user/level`.
12. Stop services with `docker compose -f docker-compose.dev.yaml --env-file .env.dev down`.
13. Verify changes with `ruff check .`, `pytest --cov=src --cov-fail-under=95`, and `npm run coverage` from the `bot/` directory before committing.
    After installing dependencies, run `npm run coverage` in the `frontend/` directory as well
    (see [../frontend/README.md](../frontend/README.md) for details).
    Install the project and dev requirements **before running the tests**:

    ```bash
    pip install -e .  # or `pip install -r requirements.txt` if you have one
    pip install -r requirements-dev.txt
    ```

14. Run `npm run coverage` in both the `bot/` and `frontend/` directories to collect test coverage.
    The CI workflow fails if coverage drops below **95%**.
15. Install git hooks with `pre-commit install` so these checks run automatically.
16. Lint all Markdown docs with `./scripts/check_docs.sh` before pushing.
    This script uses **Vale** for style and **LanguageTool** for grammar.
    LanguageTool requires network access to `api.languagetool.org` unless you
    provide a custom server URL in the `LANGUAGETOOL_URL` environment variable.
    If your environment blocks outbound requests, run your own instance with:

    ```bash
    docker run -d --name languagetool -p 8010:8010 silviof/docker-languagetool
    ```

Then set `LANGUAGETOOL_URL=http://localhost:8010/v2`.

17. Run `bash scripts/check_dependencies.sh` to verify Jest, Vitest, and Vale are installed.

18. CI posts a coverage summary on pull requests. Run
    `python scripts/post_coverage_comment.py` to generate the table locally.
19. Append the coverage numbers to a Markdown file with
    `bash scripts/append_coverage_summary.sh`. Set the following
    environment variables before running the script:
    `COVERED_LINES`, `TOTAL_LINES`, `COVERAGE_PERCENT`,
    `COVERED_BRANCHES`, `TOTAL_BRANCHES`, and `BRANCH_PERCENT`.
    Pass an optional output filename as the first argument
    (defaults to `summary.md`).
20. Install the GitHub CLI with `./scripts/install_gh_cli.sh` if you plan to run
    scripts that use `gh` locally.

The compose files define common service settings using YAML anchors. Each
environment file overrides differences like `env_file` or exposed ports below the
`<<` merge key.

### Platform Verification

These instructions were tested on Windows 11 (with WSL&nbsp;2), macOS Ventura,
and Ubuntu&nbsp;22.04. The Docker and Python versions match across
platforms. Please report any issues you encounter on your operating system.

## Key Documentation

- [Git guidelines](git-guidelines.md) &ndash; branch naming, commit messages and the pre‑PR checklist.
- [Pull request template](pull_request_template.md) &ndash; describe your changes and verify the checklist.
- [Sample pull request](sample-pr.md) &ndash; walkthrough of a minimal docs update.
- [About Potato](about-potato.md) &ndash; the playful backstory of our root vegetable mascot.
- [Merge checklist](merge-checklist.md) &ndash; steps maintainers use before merging.
- [Changelog](CHANGELOG.md) &ndash; record notable updates for each release.
- [Task management](task-management.md) &ndash; archive completed items in `codex.tasks.json`.
- [Doc QA onboarding](doc-quality-onboarding.md) &ndash; quickstart for documentation checks.
- [Network troubleshooting](network-troubleshooting.md#pre-commit-nodeenv-ssl-errors)
  &ndash; work around pre-commit `nodeenv` SSL errors and other network restrictions.
- [Troubleshooting guide](troubleshooting.md)
  &ndash; quick fixes for setup problems and failing CI jobs.
- [CI failure issue management](ci-failure-issues.md)
  &ndash; how automatic cleanup works and how to close old issues.
- [Automatic Codex issue closing](codex-issue-autoclose.md)
  &ndash; merged PRs with `Fixes #<issue>` close the linked Codex ticket.
- [CI workflow](ci-workflow.md)
  &ndash; overview of job steps, caching, concurrency, and coverage requirements.
- [Offline setup](offline-setup.md) &ndash; download Python wheels and npm packages on another machine.
- [Security audit](security-audit-2025-07-01.md) &ndash; latest dependency check results.
- [Environment variables](env.md) &ndash; explanation of `.env` settings and the role-based permission system.
- [Alpha tester onboarding](alpha/README.md) &ndash; guide for early testers.
- [Alpha wave rollout guide](alpha/alpha-wave-rollout-guide.md) &ndash; steps to prepare each invite wave.
- [Founder's Circle onboarding](founders/README.md) &ndash; roles and perks for core supporters.
- [Alpha phase roadmap](roadmap/alpha-phase.md) &ndash; pre- and post-launch milestones.
- [Feedback dashboard PRD](prd/feedback-dashboard.md) &ndash; objectives and features for the feedback tool.
- [Discord message templates](discord/discord-message-templates.md) &ndash; sample posts for the community.
- [Discord server configuration](discord/configuration.md) &ndash; enable the widget for status display.
- [Endpoint reference](endpoint-reference.md) &ndash; list of API routes and Discord command mappings.
- [Alpha testers log](../ALPHA_TESTERS.md) &ndash; track invitations and feedback status.
- [Founders log](../FOUNDERS.md) &ndash; record core contributors and how they help.
- [Frontend README](../frontend/README.md) &ndash; instructions for running the React app.
- [Marketing site home](../frontend/index.html) &ndash; early look at the public landing page.
- [E2E test guide](e2e-tests.md) &ndash; run the Playwright suite.

## Onboarding Phases

Our rollout begins with invite-only [alpha testing](alpha/README.md) followed by
the **Founder's Circle** outlined in [founders/README.md](founders/README.md).
These groups provide early feedback before the project opens to the public.

## XP Milestones

Each contribution grants experience points (XP). Every 100 XP increases your
level, which you can check through the `/profile` command or the
`/api/user/level` endpoint.

## Contributor Logging

Add yourself to [../ALPHA_TESTERS.md](../ALPHA_TESTERS.md) or
[../FOUNDERS.md](../FOUNDERS.md) when you participate. These logs help us track
who has contributed and when.

## Configuration Helpers

- `.pre-commit-config.yaml` &ndash; run `pre-commit install` to set up git hooks that execute the linter and tests.
- `.editorconfig` &ndash; ensures consistent indentation and line endings across editors.
- `.python-version` &ndash; indicates the Python version for pyenv.
- `.nvmrc` &ndash; defines the Node.js version for nvm.

## Documentation Quality Checks

All Markdown files must pass Vale and LanguageTool checks.
See [doc-quality-onboarding.md](doc-quality-onboarding.md) for a step-by-step guide.

- Run `bash scripts/check_docs.sh` before pushing any changes.
- Install Vale (version 3.12.0) with `brew install vale` or download it from the
  [Vale releases page](https://github.com/errata-ai/vale/releases).
- If your network blocks direct downloads, fetch version 3.12.0 from
  `https://github.com/errata-ai/vale/releases` on another machine and copy the
  `vale` binary to a directory in your `PATH`.
- Install Python dev dependencies with `pip install -r requirements-dev.txt`.
- Set `LANGUAGETOOL_URL` if you use a self-hosted LanguageTool server. See the [LanguageTool HTTP server guide](https://dev.languagetool.org/http-server).

## Issues and Pull Requests

1. Search existing issues to avoid duplicates and provide clear reproduction steps.
2. Start branches from the latest `main` and follow the git guidelines.
3. Use the pull request template and ensure the checklist passes.
4. Review [sample-pr.md](sample-pr.md) for an end-to-end example.
5. See the Codex CI Monitoring Policy in [../AGENTS.md](../AGENTS.md) for how failed CI jobs automatically create tasks.
6. When CI fails, an issue titled `CI Failures for <sha>` is opened or updated with a summary of the failing tests and links to the artifacts.
7. The CI workflow uses the built-in `GITHUB_TOKEN` with `issues: write` permission. When the pipeline succeeds, it closes every open `ci-failure` issue.
8. A nightly job (`cleanup-ci-failure.yml`) closes any open `ci-failure` issues so the board stays tidy.

9. A weekly job (`security-audit.yml`) runs dependency audits and uploads the report as an artifact.
10. CODEOWNERS automatically requests reviews from the maintainer team.
