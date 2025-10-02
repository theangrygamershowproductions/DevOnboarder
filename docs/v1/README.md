---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: v1-v1
status: active
tags:

- documentation

title: Readme
updated_at: '2025-09-12'
visibility: internal
---

# Developer Onboarding

Welcome to **DevOnboarder**. This page explains how to get your environment
running and where to find documentation about our workflow.

If you're setting up a fresh Ubuntu machine, follow
[ubuntu-setup.md](../ubuntu-setup.md) for the commands that install Docker, Docker
Compose, Node.js 22, and Python 3.12. Running tests requires Python **3.12**.

After cloning the repository, run `bash scripts/install_commit_msg_hook.sh` to
install a `commit-msg` hook. This ensures your commit messages pass the lint
check in CI. See [CONTRIBUTING.md](../../CONTRIBUTING.md) for details.

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

4. Install the project in editable mode with `pip install -e .[test]` so the

   `devonboarder` package and its test dependencies are available.
   This command **must run before** you execute `pytest`. Run

   `scripts/setup_tests.sh` to automate this step.

    Tests run only on **Python 3.12**. Use `mise use -g python 3.12`
    (or `asdf install python 3.12`) before running `pip install -e .[test]`.
    Verify with `python3 --version`.

5. Start services with `make up` or run

   `docker compose -f ../archive/docker-compose.dev.yaml --env-file .env.dev up -d`.
   This launches the auth, bot, XP API, frontend, and Postgres services.
   The `frontend/` folder now hosts a React app built with Vite.

6. Run `bash scripts/run_migrations.sh` to apply the initial database migration.

7. Run `python -m diagnostics` to confirm required packages import, all services are healthy, and environment variables match the examples. See

   diagnostics-sample.log (legacy reference) for the expected output.

8. Alternatively, run `devonboarder-server` to start the app without Docker. Stop the server with Ctrl+C.

9. Visit `http://localhost:8000` to see the greeting server.

10. Run `devonboarder-api` to start the user API at `http://localhost:8001`.

    This command requires `uvicorn`.

11. Run `devonboarder-auth` to start the auth service at `http://localhost:8002`.

    It stores data in a local SQLite database and automatically loads
    environment variables from `auth/.env` when that file exists.

12. Test the XP API with:

    `curl http://localhost:8001/api/user/onboarding-status`
    and `curl http://localhost:8001/api/user/level`.

13. Stop services with `docker compose -f ../archive/docker-compose.dev.yaml --env-file .env.dev down`.

14. Verify changes with `ruff check .`, `pytest --cov=src --cov-fail-under=95`,

    and `npm run coverage` from the `bot/` directory before committing.
    After installing dependencies, run `npm run coverage` in the `frontend/`
    directory as well (see [../bot/README.md](../../bot/README.md) for
    details).
    Install the project and test requirements with
    `pip install -e .[test]` **before running `pytest`**. The helper
    script `scripts/setup_tests.sh` runs this command. Skipping
    `pip install -e .[test]` often leads to `ModuleNotFoundError` when
    `pytest` imports the `devonboarder` package:

    ```bash
    pip install -e .[test]  # or `pip install -r requirements.txt` if you have one

    ```

    `pytest.ini` sets `pythonpath=src` so tests can locate the
    `devonboarder` package. Installing the project still ensures
    dependencies like **FastAPI** are available. The test suite only runs on

    Python **3.12**.

15. Run `npm run coverage` in both the `bot/` and `frontend/` directories to collect test coverage.

    The CI workflow fails if coverage drops below **95%**.

16. Install git hooks with `pre-commit install` so these checks run automatically.

17. `pre-commit` also verifies environment variable docs with

    `python scripts/check_env_docs.py`.

18. Lint all Markdown docs with `./scripts/check_docs.sh` before pushing.

    The script downloads **Vale** automatically when it is missing and prints a

    notice if grammar checks require **LanguageTool**.
    To run LanguageTool locally, start your own instance with:

    ```bash
    docker run -d --name languagetool -p 8010:8010 silviof/docker-languagetool
    ```

    Then optionally set `LANGUAGETOOL_URL=http://localhost:8010/v2`.

19. Lint shell scripts with `shellcheck scripts/*.sh`.

20. Run `bash scripts/check_dependencies.sh` to verify Jest, Vitest, and Vale are installed.

21. CI posts a coverage summary on pull requests. Run

    `python scripts/post_coverage_comment.py` to generate the table locally.

22. Append the coverage numbers to a Markdown file with

    `bash scripts/append_coverage_summary.sh`. Set the following
    environment variables before running the script:
    `COVERED_LINES`, `TOTAL_LINES`, `COVERAGE_PERCENT`,
    `COVERED_BRANCHES`, `TOTAL_BRANCHES`, and `BRANCH_PERCENT`.
    Pass an optional output filename as the first argument
    (defaults to `summary.md`).

23. Install the GitHub CLI from <https://cli.github.com/> if you plan to run

    scripts that use `gh` locally.

The compose files define common service settings using YAML anchors. Each
environment file overrides differences like `env_file` or exposed ports below the
`<<` merge key.

### Service Health Checks

After starting the services with `make up`, confirm each one is running:

```bash
curl http://localhost:8002/health
curl http://localhost:8001/health

```

Production environments expose the same endpoints for monitoring.

### Platform Verification

These instructions were tested on Windows 11 (with WSL&nbsp;2), macOS Ventura,
and Ubuntu&nbsp;22.04. The Docker and Python versions match across

platforms. Please report any issues you encounter on your operating system.

## Key Documentation

- [About Potato](../about-potato.md) &ndash; the playful backstory of our root vegetable mascot.

- [Alpha phase roadmap](../roadmap/alpha-phase.md) &ndash; pre- and post-launch milestones.

- [Alpha tester onboarding](../alpha/README.md) &ndash; guide for early testers.

- [Alpha testers log](../contributing/ALPHA_TESTERS.md) &ndash; track invitations and feedback status.

- [Alpha wave rollout guide](../alpha/alpha-wave-rollout-guide.md) &ndash; steps to prepare each invite wave.

- [Automatic Codex issue closing](../codex-issue-autoclose.md)

  &ndash; merged PRs with `Fixes #<issue>` close the linked Codex ticket.

- [Changelog](CHANGELOG.md) &ndash; record notable updates for each release.

- [Code of Conduct](../../CODE_OF_CONDUCT.md) &ndash; expected behavior in our community.

- [CI failure issue management](../ci-failure-issues.md)

  &ndash; how automatic cleanup works and how to close old issues.

- [CI workflow](../ci-workflow.md)

  &ndash; overview of job steps, caching, concurrency, and coverage requirements.

- [CI environment variables](../ci-env-vars.md)

  &ndash; summary of tokens and other variables used by the workflows.

- [CI-first OpenAI API key policy](../ci-first-policy.md)

  &ndash; explains why the OpenAI key only exists in CI.

- [CI resilience hardening steps](../../codex/prompts/ci_resilience_hardening.md)

  &ndash; quick checklist for analyzing failing runs.

- [Discord message templates](../discord/discord-message-templates.md) &ndash; sample posts for the community.

- [Discord server configuration](../discord/configuration.md) &ndash; enable the widget for status display.

- [Doc QA onboarding](../doc-quality-onboarding.md) &ndash; quickstart for documentation checks.

- [E2E test guide](../e2e-tests.md) &ndash; run the Playwright suite.

- [Codex E2E report](../codex-e2e-report.md) &ndash; record outcomes of each run.

- [Engineer assessment work items](../assessments/engineer_assessment_work_items.md)

  &ndash; checklist for onboarding reviews of new features.

- [Endpoint reference](../endpoint-reference.md) &ndash; list of API routes and Discord command mappings.

- [Environment variables](../env.md) &ndash; explanation of `.env` settings and the role-based permission system.

- [Agents overview](../../agents/index.md) &ndash; service and integration specs.

  Codex also reads `.codex/agents/index.json` to map these agents for automation.

- [Multi-bot orchestration](../orchestration.md) – token management and escalation paths.

- [DevOnboarder in TAGS](../ecosystem.md) &ndash; how the services fit together.

- [TAGS integration guide](../tags_integration.md) &ndash; compose files and feature flags.

- [Feedback dashboard PRD](../prd/feedback-dashboard.md) &ndash; objectives and features for the feedback tool.

- [Founder's Circle onboarding](../founders/README.md) &ndash; roles and perks for core supporters.

- [Founders log](../contributing/FOUNDERS.md) &ndash; record core contributors and how they help.

- [Frontend README](../../frontend/README.md) &ndash; instructions for running the React app.

- [Git guidelines](../git-guidelines.md) &ndash; branch naming, commit messages and the pre‑PR checklist.

- [Branch cleanup workflow](../git-guidelines.md) &ndash; nightly script for removing old branches.

- [Issue labeling guide](../contributing/issue-labeling-guide.md) &ndash; comprehensive labeling system for strategic issue management.

- [Issue labels quick reference](../contributing/labels-quick-reference.md) &ndash; essential labels and common filtering examples.

- [Marketing site home](../../frontend/index.html) &ndash; early look at the public landing page.

- [Merge checklist](../merge-checklist.md) &ndash; steps maintainers use before merging.

- [Network troubleshooting](../network-troubleshooting.md)

  &ndash; work around pre-commit `nodeenv` SSL errors and other network restrictions.

- [Network exception list](../network-exception-list.md)

  &ndash; domains that must be reachable for setup and CI tasks.
  &ndash; required external domains and firewall exceptions.
  &ndash; required firewall exceptions for setup and CI tasks.
  &ndash; run `scripts/show_network_exceptions.sh` to print the list.
  &ndash; run `scripts/check_network_access.sh` to verify connectivity.

- [Offline setup](../offline-setup.md) &ndash; download Python wheels and npm packages on another machine.

- [Project origin & recovery story](../origin.md) &ndash; why DevOnboarder exists.

- [Pull request template](../../.github/pull_request_template.md) &ndash; describe your changes and verify the checklist.

- [Sample pull request](../sample-pr.md) &ndash; walkthrough of a minimal docs update.

- [First PR walkthrough](../first-pr-guide.md) &ndash; clone, install hooks and open your first pull request.

- Service architecture diagram (legacy reference) &ndash; high-level view of the auth, XP API, frontend and bot.

- [Service status dashboard](../service-status.md) &ndash; checkbox view of core service health.

- [Tools dashboard](../tools-dashboard.md) &ndash; comprehensive maintenance, cleanup, and diagnostic tools reference.

- [Security audit](../security-audit-2025-07-01.md) &ndash; latest dependency check results.

- [Dependency update policy](../dependencies.md) &ndash; how Dependabot PRs are reviewed and merged.

- [FIPS compliance for Go services](../fips-golang.md) &ndash; guidelines for running a Go project in FIPS mode.

- [Builder ethics dossier](../builder_ethics_dossier.md) &ndash; outlines contributor ethics and provides a template.

- [Task management](../task-management.md) &ndash; archive completed items in `codex.tasks.json`.

- [Troubleshooting guide](../troubleshooting.md)

  &ndash; quick fixes for setup problems and failing CI jobs.

## Onboarding Phases

Our rollout begins with invite-only [alpha testing](../alpha/README.md) followed by
the **Founder's Circle** outlined in [founders/README.md](../founders/README.md).

These groups provide early feedback before the project opens to the public.

## XP Milestones

Each contribution grants experience points (XP). Every 100 XP increases your
level, which you can check through the `/profile` command or the
`/api/user/level` endpoint.

## Contributor Logging

Add yourself to [../ALPHA_TESTERS.md](../contributing/ALPHA_TESTERS.md) or
[../FOUNDERS.md](../contributing/FOUNDERS.md) when you participate. These logs help us track
who has contributed and when.

## Retrospectives

Run `scripts/create-retro-file.sh` whenever you start a new retrospective. It
copies `docs/checklists/retrospective-template.md` into
`docs/checklists/retros/` using today's date for the filename.

```bash
bash scripts/create-retro-file.sh

```

If a file with the same date already exists, the script prints an error and
exits so duplicates are not created.

## Configuration Helpers

- `.pre-commit-config.yaml` &ndash; run `pre-commit install` to set up git hooks that execute the linter and tests.

- `.editorconfig` &ndash; ensures consistent indentation and line endings across editors.

- `.tool-versions` &ndash; defines the Python and Node.js versions for mise.

## Plugin Development

Place optional extensions under the repository's `plugins/` directory. Each
plugin lives in its own folder with an `__init__.py` file and a `register`
function. Importing :mod:`devonboarder` loads these modules into the global
`devonboarder.PLUGINS` dictionary.

## Available Bot Commands

The Discord bot exposes several slash commands documented in
[bot/README.md](../../bot/README.md). Use `/qa_checklist` to display the QA
checklist from `docs/QA_CHECKLIST.md`; the command sends it back in ephemeral
messages. Run `/dependency_inventory` to upload `dependency_inventory.xlsx` as a
file for maintainers. The exported spreadsheet now lives at `docs/dependency_inventory.xlsx`.

## Documentation Quality Checks

All Markdown files are checked with **Vale** for style. The docs script prints a

notice if grammar checks need **LanguageTool**.
See [doc-quality-onboarding.md](../doc-quality-onboarding.md) for a step-by-step guide.

- Run `bash scripts/check_docs.sh` before pushing any changes.

- The script automatically downloads Vale when it is missing. CI issues a

  warning (not a failure) if the download fails. Set `VALE_BINARY` to
  use a custom path.

- Install Vale (version 3.12.0) with `brew install vale` on macOS or

  `choco install vale` on Windows. You can also download it from the
  [Vale releases page](https://github.com/errata-ai/vale/releases).

- If your network blocks direct downloads, fetch version 3.12.0 from

  `https://github.com/errata-ai/vale/releases` on another machine and copy the
  `vale` binary to a directory in your `PATH`.

- If the binary lives outside `PATH`, set the `VALE_BINARY` environment variable

  to its location so `scripts/check_docs.sh` can find it.

- Install Python dev dependencies with `pip install .[test]`.

- Optionally set `LANGUAGETOOL_URL` when running your own LanguageTool server

  for local grammar checks. See the [LanguageTool HTTP server guide](https://dev.languagetool.org/http-server).

- Markdown files must not exceed 120 characters per line (MD013). See

  [doc-quality-onboarding.md](../doc-quality-onboarding.md) for details.

## Issues and Pull Requests

1. Search existing issues to avoid duplicates and provide clear reproduction steps.

2. Start branches from the latest `main` and follow the git guidelines.

3. Use the pull request template and ensure the checklist passes.

4. Review our [issue labeling guide](../contributing/issue-labeling-guide.md) for proper categorization and prioritization.

5. Use the [labels quick reference](../contributing/labels-quick-reference.md) for common labeling scenarios.

### Continuous Improvement Checklist

Pull requests must include the block from
[`../.github/pull_request_template.md`](../../.github/pull_request_template.md)
labeled **## Continuous Improvement Checklist**. The CI workflow fails when this

heading is missing. See
[`checklists/continuous-improvement.md`](../checklists/continuous-improvement.md)
for the items. If the GitHub UI does not preload the template, copy the snippet
from [`checklists/ci-checklist-snippet.md`](../checklists/ci-checklist-snippet.md).

1. Review [sample-pr.md](../sample-pr.md) for an end-to-end example.

2. See the Codex CI Monitoring Policy in [../Agents.md](../Agents.md) for how failed CI jobs automatically create tasks.

3. When CI fails on a pull request, an issue titled `CI Failure: PR #<number>`

   is opened or updated with a summary of the failing tests. The commit SHA is
   stored in the issue body as a comment for reference.

4. The CI workflow uses the built-in `GITHUB_TOKEN` with `issues: write`

   permission. When the pipeline succeeds, it closes every open `ci-failure`
   issue.

5. `${{ secrets.GITHUB_TOKEN }}` is read-only on pull requests from forks. Use a

   token with `issues: write` permission or a `pull_request_target` workflow as
   explained in [ci-failure-issues.md](../ci-failure-issues.md).
   Maintainers can supply a personal access token as described in
   [ci-failure-issues.md#maintainer-token-setup].

6. Maintainers must provide a personal access token or use a

   `pull_request_target` workflow for forked pull requests so CI can update the
   failure issue. See
   [ci-failure-issues.md](../ci-failure-issues.md).

7. A nightly job (`cleanup-ci-failure.yml`) logs token details, closes any open

   `ci-failure` issues, and opens a follow-up ticket if cleanup fails.

8. Failing jobs run `scripts/ci_failure_diagnoser.py` to create an `audit.md` summary. The file uploads with the CI logs and is appended to any failure issue.

9. A weekly job (`security-audit.yml`) runs dependency audits and uploads the report as an artifact.

10. CODEOWNERS automatically requests reviews from the maintainer team.

11. The `auto-fix.yml` workflow runs when CI fails. It downloads the `logs` artifact,

    asks OpenAI for a YAML patch using `yamllint` output, applies it, then requests a
    broader fix and opens a pull request with `peter-evans/create-pull-request`.
    Add a `CI_BUILD_OPENAPI` secret under **Settings → Secrets and variables → Actions** (or `OPENAI_API_KEY` if unavailable)

    so the workflow can request a patch from OpenAI.

12. The `ci-monitor.yml` workflow scans CI logs for several rate-limit phrases.

    It quotes the first match and opens an issue using
    `${{ secrets.CI_ISSUE_TOKEN }}` or `${{ secrets.GITHUB_TOKEN }}` when that
    secret isn’t set. See [ci-env-vars.md](../ci-env-vars.md) for details.

13. Workflows share `.github/.yamllint-config` to disable `document-start` and

    `truthy` checks and raise the line-length limit to 200 so linting focuses on
    real YAML syntax errors.

## \U0001F6E1\uFE0F Coverage and Security

We track coverage locally using `pytest --cov=src` and `npm run coverage`. This
project does **not** use external uploaders like Codecov because remote scripts

pose a supply chain risk. Only local, inspectable tools are permitted.

Run the same security checks locally before pushing:

```bash
bash scripts/security_audit.sh

```

The script runs `pip-audit`, `bandit -r src -ll`, and `npm audit --audit-level=high`
in both `frontend/` and `bot/`. Each command fails when vulnerabilities are
detected.
CI also runs `pip-audit` immediately after installing Python requirements. If this step fails to reach the vulnerability database, see [docs/offline-setup.md](../offline-setup.md).
