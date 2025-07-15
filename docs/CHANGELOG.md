# Changelog

All notable changes to this project will be recorded in this file.

## [Unreleased]
- docs(ci): outline CI enforcement tasks in `.codex/automation-tasks.md`

- fix(ci): correct YAML indentation in Verify gh version step
- chore(ci): reuse saved ci-failure issue number across runs
- chore(ci): validate `.codex/bot-permissions.yaml` via new script

- chore(codex): record bot secrets and permissions in `.codex/bot-permissions.yaml`

- chore(docs): regenerate env variable docs from `.env.example` via new script
  and run it in CI before validation

- Linked `docs/CHANGELOG.md` from `README.md` for easier navigation.
- Mentioned `codex/agents/index.json` alongside `agents/index.md` and
  documented the agent index requirement in `AGENTS.md`.
- Documented that the `validate-yaml` step always runs even when `[no-ci]` skips
  the test job and clarified the `[no-ci]` marker in `docs/ci-workflow.md`.
- Added `.github/.yamllint-config` to centralize workflow lint rules, disabling
  `document-start` and `truthy` and warning on lines over 200 characters.
- Aligned yamllint invocation across scripts and CI with
  `yamllint -c .github/.yamllint-config .github/workflows/**/*.yml`.
- fix(ci): correct YAML indentation in `Python dependency audit` step
- Fixed indentation of Python blocks in `auto-fix.yml` to resolve YAML linting errors.
- Added `src/diagnostics.py` with a `python -m diagnostics` entry for package
  and service health checks. CI runs the script and uploads its log.
- Expanded QA checklist with TAGS-specific deployment and diagnostics items.
- Added `docs/diagnostics-sample.log` and referenced it from onboarding docs to
  show expected output from `python -m diagnostics`.
- Added `prompts/devonboarder_integration_task.md` and referenced it from
  `codex.tasks.json` so Codex can generate integration steps automatically.

- CI matrix now tests only Python 3.12 and Node 20.

- Improved `ci-monitor.yml` to detect additional rate-limit phrases and fall back
  to `${{ secrets.GITHUB_TOKEN }}` when `CI_ISSUE_TOKEN` is unavailable.
- Broadened `ci-monitor.yml` detection patterns, captures the matched log line,
  and falls back to `${{ secrets.GITHUB_TOKEN }}` when `CI_ISSUE_TOKEN` is
  missing.

- Documented additional pre-PR checklist steps in `docs/sample-pr.md`.
- Added `docs/codex-e2e-report.md` to track E2E run results and linked it from
  `docs/README.md`.
- Archived unused Dockerfiles and compose files under `archive/`.

- Replaced `.python-version` and `.nvmrc` with `.tool-versions` and added
  `.mise.yml`.
- Updated README to instruct running `mise install` using `.tool-versions` for Python and Node.js.

- Added `docs/ecosystem.md` and `docs/tags_integration.md` describing the TAGS
  stack and integration steps. Linked them from both READMEs.

- Linked TAGS stack docs from `docs/ONBOARDING.md` and mentioned `IS_ALPHA_USER`
  and `IS_FOUNDER` for running in TAGS.
- Added `TAGS_MODE` variable to `.env.example`, diagnostics, and integration docs
  so TAGS deployments check all services.

- Added `LLAMA2_API_TIMEOUT` variable with default `10` and documented it.
- Replaced the Node.js installation command to download the NodeSource script
  before running it, referencing the security policy.
- Enhanced `scripts/validate.sh` to enforce `.tool-versions`, lint workflows and
  Markdown files, validate front matter with `ajv`, and list unused Docker
  artifacts.
- Replaced the JSON block in `Codex_Contributor_Dashboard.md` with YAML front
  matter and validated the file using `yamllint`.

- Added weekly `ci-health.yml` workflow that tests active branches and opens an issue on failures.
- Introduced `auto-fix.yml` workflow that downloads CI logs, asks OpenAI for a YAML
  patch using `yamllint` output, applies it, then requests a broader fix and opens
  a pull request with `peter-evans/create-pull-request`.

- Implemented feedback submission and analytics API.
- Added a QA checklist bullet to the GitHub PR template.

- Documented health-check curl commands for local and production use and cross-linked from onboarding guide.

- Wrapped HTTP requests in scripts with try/except to exit on connection errors.
- Added unit tests for `resolve_verification_type` and `resolve_user_flags`.
- Expanded docs/QA_CHECKLIST.md with sections for architecture, CI/CD, Codex, Discord, ethics, and community.
- Added `scripts/generate_openapi.py` and a `make openapi` target for regenerating the FastAPI spec.
- Documented `pip-audit` failure behavior and offline steps in `docs/ci-workflow.md` per task docs-qa-101.
- Documented offline markdownlint usage in `docs/doc-quality-onboarding.md` per task docs-qa-102.
- Fixed ordered list formatting in `AGENTS.md` and updated outreach links.
- Added `/qa_checklist` bot command and the QA checklist document.
- Documented `/qa_checklist` usage in `docs/README.md`.
- Documented `/qa_checklist` usage in `docs/discord/configuration.md`.

- Added a Python shebang to `scripts/check_docstrings.py` and made the file executable.

- Added a Python shebang to `scripts/check_headers.py` and made the file executable.

- Added SECURITY.md outlining supported versions, reporting instructions, and a
  30-day response timeframe.
- Implemented the Discord Integration service with `/oauth` and `/roles` endpoints.

- Added CODE_OF_CONDUCT.md using the Contributor Covenant and linked it from the README and onboarding docs.
- Documented troubleshooting steps for CI failure issues.
- Removed pnpm lockfile commit instructions from `frontend/README.md`.
- Added mdformat to pre-commit with `--wrap 120` and documented running `pre-commit install` in CONTRIBUTING.
- Documented CI environment variables used in the workflows.
- Added a plugin registry that loads modules from `plugins/` and documented the
  structure in the READMEs.
- Documented `./scripts/run_tests.sh` as the preferred way to run tests.
- Warns when the CI failure issue search fails and logs the message in `gh_cli.log`.
- Searches the CI failure issue title and body for the commit SHA and logs the search exit code.
- Added a first PR guide and service architecture diagram with links from the docs overview. The screencast is now linked externally instead of embedded.
- Documented how maintainers can provide a personal access token for workflows on forked pull requests.
- Added a reminder in `docs/README.md` that forked pull requests require a personal access token or
  `pull_request_target` workflow to update CI failure issues.
- Expanded `docs/ci-failure-issues.md` with a note linking back to this reminder.
- Wrapped long documentation lines to satisfy markdownlint rule MD013.
- Additional documentation line wrapping for MD013.
- Clarified that `pip install -e .` and `pip install -r requirements-dev.txt` must run before executing tests.
- Updated AGENTS and the first PR guide to use uppercase commit types.

- Updated ESLint and TypeScript versions across bot and frontend packages and
  regenerated the lock files.

- Removed the Codecov badge from the README and deleted the upload step.
- Fixed indentation in `cleanup-ci-failure.yml` so the closing step runs as a
  separate action and prints `Closed N ci-failure issues` on success.
- Updated README star and issue links to point to the repository.
- Mentioned `docs/ci-failure-issues.md` in the README for troubleshooting CI
  automation.
- CI now commits a coverage.svg badge using coverage-summary.md.

- CI workflow caches Playwright browsers to reuse ~/.cache/ms-playwright.
- Skip Codex container setup when running in CI.
- Added `markdownlint-cli2` to documentation checks and pre-commit.
- `check_docs.sh` now runs `markdownlint-cli2 "**/*.md"` before Vale and the
  doc-quality guide notes this dependency.
- CI installs markdownlint dependencies before running documentation checks and
  uses `npx -y` with an offline hint on failure.
- Documented how to cache `markdownlint-cli2` for offline runs and clarified that
  `scripts/check_docs.sh` invokes `npx -y markdownlint-cli2`.
- Codex now attempts `ruff --fix` and `pre-commit run --files` when linting fails
  and commits the patch automatically if safe. Otherwise it opens a "chore:
  auto-fix lint errors via Codex" pull request.
- Added Bandit and npm audit checks to fail CI when high severity issues are found.
- `scripts/security_audit.sh` now exits with code 1 when `pip-audit` reports vulnerabilities, and CI runs `pip-audit` after installing Python requirements with offline guidance on failures.
- Install the GitHub CLI in CI using the preinstalled binary or
  `scripts/install_gh_cli.sh`.
- `scripts/trivy_scan.sh` now downloads the pinned Trivy release tarball instead
  of piping the install script. Offline instructions updated accordingly.
- Added `ghcr.io` to the network exception list with references to `scripts/setup-env.sh` and `docker-
  compose.codex.yml`.
- Linked the network exception list from the docs overview and added `scripts/check_network_access.sh` for preflight
  checks.
- Added `scripts/show_network_exceptions.sh` to print the firewall domain list.
- Mentioned `scripts/check_network_access.sh` in `docs/README.md` for connectivity checks.
- `scripts/check_network_access.sh` now parses `docs/network-exception-list.md` instead of using a hard-coded domain
  array.
- Documented Bandit and npm audit steps in `docs/ci-workflow.md`.
- Documented the pip-audit step in `docs/ci-workflow.md` with a note about
  offline failures linking to `docs/offline-setup.md`.
- Updated `scripts/security_audit.sh` to run Bandit and high severity `npm audit`
  checks for both `frontend/` and `bot/`.
- `monitor-ci` now runs `ruff --fix` and `pre-commit run --files` on lint
  failures and commits the patch when safe.
- Detects documentation-only pushes and sets `steps.filter.outputs.code` to `false`.
- Skips the `test` job when only docs or Markdown files change using
  `dorny/paths-filter`.
- Disabled the `pytest` pre-commit hook by default and documented how to enable it.
- Added `scripts/check_env_docs.py` to validate environment variable docs and
  referenced it in `docs/merge-checklist.md`.
- CI workflow now runs `python scripts/check_env_docs.py` after the Black step
  to fail when environment docs are out of sync.
- Documented commit-msg hook setup in CONTRIBUTING.md and docs.
- Offline install instructions now appear in CI logs when package installs fail.
- Clarified README step 7 to run `pip install -e .` and
  `pip install -r requirements-dev.txt` before `pytest` and linked to
  `tests/README.md`.
- CI now checks compose service status early and prints logs on failure.
- Added `docs/fips-golang.md` summarizing FIPS compliance rules for Go projects.
- `wait_for_service.sh` prints `docker compose ps` when a service fails.
- CI workflow uploads the full job log as the `ci-logs` artifact.
- Documented offline header check in `tests/test_check_headers.py`.
- Reminded contributors to run `pip install -r requirements-dev.txt` and
  `pip install -e .` before running `pytest`. `scripts/check_dependencies.sh`
  now verifies these packages are installed.
- Documented running `pip install -e .` before `pytest` in docs/README.md and
  docs/ONBOARDING.md to avoid `ModuleNotFoundError: No module named 'devonboarder'`.
- Documented Teams and Llama2 environment variables in `docs/env.md`.
- Added a Tests section to `bot/README.md` with `npm run coverage` instructions and noted the **95%** coverage
  requirement.
- Added `scripts/audit_env_vars.sh` to report missing or extra environment variables and documented usage in
  `docs/env.md`.
- CI now audits `.env.dev` in CI using `scripts/audit_env_vars.sh` and fails when variables are missing or extra.
- Added `secret-alignment.md` issue template and referenced it from `docs/merge-checklist.md`.
- Added `secrets-alignment.yml` workflow to open an issue when environment
  variables are misaligned.
- Added `env-doc-alignment.yml` workflow that opens a Secret Alignment issue
  when `check_env_docs.py` reports missing variables.
- Added `pytest.ini` to load modules from `src` without installing the package.
- Linked `builder_ethics_dossier.md` from the README and docs overview.
- Added `scripts/ci_log_audit.py` and documented using it to summarize CI logs in `docs/ci-failure-issues.md`.
- Split `docs/Agents.md` into `agents/` pages and updated references.
- CI workflow now runs `ci_log_audit.py` on failures and appends the `audit.md` summary to CI failure issues.
- Added tests for `ci_log_audit.py`.
- Added a test for `scripts/check_headers.py` using FastAPI's TestClient.
- Expanded `docs/ci-failure-issues.md` with an explanation of the automated audit step and how to interpret `audit.md`.
- Replaced deprecated `actions/setup-gh-cli` with a direct
  installation approach.
- Verified GitHub CLI availability across all workflows.
- Updated README to document the new GitHub CLI installation method.
- Documented GitHub CLI installation and version output in `docs/ci-workflow.md`.
- `audit_env_vars.sh` now writes a JSON summary when `JSON_OUTPUT` is set and CI
  uploads the file for the secrets-alignment workflow.
- Added CODEOWNERS to automatically request maintainer reviews on pull requests.
- Added stub agent specs for ID.me verification and AI mentor.
- CI workflow cancels in-progress runs when new commits push.
- Added a 60-minute timeout to the `test` job in `ci.yml`.
- Added `close-codex-issues.yml` workflow to automatically close Codex-created issues referenced by `Fixes #<issue>`
  after a pull request merges and documented it in `docs/README.md`.
- Clarified auth_service test revisions in commit e541dd5.
- Added empty commit referencing e541dd5 for additional context.
- Removed obsolete `xp/.env.example`; the XP API now reads from the main `.env` file.
- Archived `languagetool_check.py` to `archive/` and removed its invocation from `scripts/check_docs.sh`.
- `scripts/check_docs.sh` now downloads Vale automatically and prints a notice when a LanguageTool server is required.
  Updated docs to make LanguageTool optional.
- Added `scripts/install_gh_cli.sh` for local GitHub CLI installation and referenced it in the docs.
- Added `scripts/commit-msg` and `scripts/install_commit_msg_hook.sh` to help contributors set up a local `commit-msg`
  hook.
- Replaced `docs/origin.md` with a full recovery story and updated README links.
- Added `tests/README.md` describing how to install project requirements before running `pytest` so modules like
  `fastapi` are available.
- `install_gh_cli.sh` now checks `GITHUB_PATH` before appending to prevent local failures.
- Added `scripts/wait_for_service.sh` and updated the CI workflow to reuse it when waiting for the auth service to
  start.
- `scripts/wait_for_service.sh` now prints auth container logs when startup fails.
- `wait_for_service.sh` accepts an optional service name and prints that container's logs when provided.
- Documented the 95% coverage requirement and how to run Python and JavaScript coverage tests in `tests/README.md`.
- Documented manual cleanup of `ci-failure` issues in `docs/ci-failure-issues.md`.
- CI workflow now closes every open `ci-failure` issue once the pipeline succeeds.
- Pytest failure annotations run only when the results file exists to avoid grep errors.
- Added a reusable `.github/actions/setup-gh-cli` action for installing the GitHub CLI.
- Workflows log the install path with `which gh` and no longer modify `$GITHUB_PATH`.
- Steps that invoke the GitHub CLI now call the path from `which gh` to ensure the latest version is used.
- Updated `setup-gh-cli` to remove the old `/usr/bin/gh` binary and export `/usr/local/bin` through `$GITHUB_PATH` so
  the new CLI is always found.
- Added `scripts/cache_precommit_hooks.sh` and offline instructions for caching
  pre-commit hooks.
- CI now lints commit messages with `scripts/check_commit_messages.sh`.
- `setup-gh-cli` now installs the GitHub CLI with the `actions/setup-gh` action to avoid apt repository outages.
- CI workflow fetches the full git history so commit message linting can compare against `origin/main`.
- Added `mypy` type checking and a configuration file. CI now runs `mypy`.
- Updated `scripts/run_tests.sh` to run `pytest --cov=src --cov-fail-under=95`
  and invoke `npm run coverage` for the bot and frontend packages.
- Documented policy against rewriting commit history or force-pushing after commits are pushed.
- Extracted CORS helper to `utils.cors` and reused in auth and XP services.
- Renamed `_get_cors_origins` to `get_cors_origins` and exported it via
  `utils.__all__`.

- Updated `docker-compose.codex.yml` with the Codex runner image and documented manual invocation under "Codex Runs".

- Clarified README instructions to stop the server with Ctrl+C.
- Updated README quickstart to run `npm run coverage --prefix frontend`.
- Quickstart now instructs running `bash scripts/generate-secrets.sh` after
  `bootstrap.sh` so local secrets match CI.
- Removed unused `REDIS_URL`, `LOG_LEVEL`, and `API_KEY` from `.env.example` and
  documented `CORS_ALLOW_ORIGINS` and `DISCORD_REDIRECT_URI` in `docs/Agents.md`
  and `docs/env.md`.
- Added `CORS_ALLOW_ORIGINS` environment variable for configuring CORS.
- Replaced `node-fetch` with the global `fetch` in the Discord bot and updated tests.
- Prettier now runs only via the pre-commit mirror. Removed duplicate `npm run format` hooks from `.pre-commit-
  config.yaml`.
- Replaced the outdated TODO section in `docs/git/Git.md` with a "Maintenance Notes" summary.
- Upgraded React packages to 19.1.0 and `dotenv` to 17.0.1.
- Removed the `API_KEY` generation step from `scripts/generate-secrets.sh`.

- Added `scripts/check_dependencies.sh` and documented running it from `docs/README.md` and `docs/doc-quality-
  onboarding.md`.

- Checked off completed tasks in `docs/Agents.md` for `/health` endpoints, Docker healthchecks, and CI polling.
- Added outreach templates and a feedback log scaffold for community engagement.
- Added `pip-audit` and `npm audit --production` security checks run via `scripts/security_audit.sh` and invoked in CI.
  Results are stored in `docs/security-audit-2025-07-01.md`.
- Marked the Discord Integration agent as deferred and added a tracking task.

- Added Lighthouse CI performance audits using `npm run perf`. CI uploads the
  generated HTML reports as artifacts and `docs/e2e-tests.md` explains how to
  download them.

- Added `scripts/trivy_scan.sh` and a CI step that scans Docker images with
  Trivy, failing on high or critical vulnerabilities. Documented offline
  installation steps in `docs/offline-setup.md`.

- Moved XP API code into a dedicated `xp/api` package and updated tests and the
  `devonboarder-api` entrypoint.

- CI failures now trigger an issue summarizing failing tests with links to the run artifacts.
- CI workflow now uploads `playwright.log` and summarizes failing Playwright tests in the CI failure issue.
- CI now posts a coverage summary on pull requests using `scripts/post_coverage_comment.py` and uploads the full reports
  as an artifact.
- Fixed newline formatting in the coverage summary by quoting the `printf` command with double quotes.
- Added `scripts/append_coverage_summary.sh` to append the coverage link with proper newline handling.
- Added ESLint and Prettier configurations for the frontend and bot with new `npm run lint` and `npm run format`
  scripts.
- CI workflow now uses this script so the coverage link appears on its own line.
- CI workflow now exports GitHub variables when generating the coverage summary.
- CI workflow now comments on the CI failure issue and closes it once a build succeeds.

- Updated Login component test to stub `import.meta.env.VITE_AUTH_URL` with `vi.stubEnv`.
- Added `data-testid` attributes to user info in `Login.tsx` and updated
  the Playwright tests and documentation.
- Updated the OAuth Playwright test to wait for the dev server and added
  troubleshooting tips to `docs/e2e-tests.md`.
- The base Dockerfile now runs `pip install --root-user-action=ignore` to
  suppress warnings when installing packages as root. Documented this
  behavior in `docs/env.md`.
- Set the Vite dev server to listen on port `3000` and ensured all documentation
  and compose files reference the same port.
- Added coverage scripts for the bot and frontend packages. CI now runs `npm run coverage` and fails if coverage drops
  below 80%.
- Increased required code coverage threshold to 95% for all test suites.
- Added tests for the React entrypoint and `Login` component to improve frontend
  coverage.

- Documented running `npm test` from the `frontend/` directory after installing dependencies and linked
  `frontend/README.md` for details.
- Clarified `frontend/README.md` to install dependencies with `pnpm` or `npm`, commit the lockfile, and run `npm run
  dev`.
- Added `docs/offline-setup.md` explaining how to install dependencies without internet access and linked it from the
  onboarding docs.
- Extended the offline setup guide with steps for caching and installing npm packages in `bot/`.
- Added `docs/troubleshooting.md` summarizing setup and CI problems and linked it from the docs README.
- Added a module-level docstring to `src/devonboarder/cli.py` describing CLI usage.
- Added a "Project Statement" section to the README highlighting the project's purpose.
- Added `scripts/run_migrations.sh` for running `alembic upgrade head` and
  updated onboarding docs to reference it.
- Documented installing the project with `pip install -e .` before running tests and updated setup scripts.
- Added `completedTasks` to `codex.tasks.json` and documented the archiving process.
- Added Playwright E2E tests and documented how to run them.
- Clarified Playwright install instructions in `docs/e2e-tests.md` to run
  `npx playwright install --with-deps` inside the `frontend/` directory.
- Added `docs/about-potato.md` describing the Potato origin story and Easter egg.
- Linked `docs/about-potato.md` from the documentation README.
- Documented how to request a full QA sweep with Codex using `@codex run full-qa` in `docs/ONBOARDING.md`.
- Added `"license": "MIT"` to `bot/package.json` and `frontend/package.json`.
- Expanded the Codex QA instructions with troubleshooting tips and a Potato-themed Easter egg in `docs/ONBOARDING.md`.
- Added a `Login` React component that redirects to Discord OAuth and handles
  the `/login/discord/callback` flow. Updated `frontend/README.md` and
  `docs/env.md` with usage instructions.
- Removed the `version:` field from all Docker compose files since Compose v2 no longer requires it.
- Updated the frontend dependencies to `vite@7`, `vitest@3`, and the latest React and testing packages.
- Documented a sample QA response, randomized Easter egg reply, and the Vale/LanguageTool fallback policy.
- Refactored `auth_service.create_app()` to instantiate a new `FastAPI` app and
  moved endpoints to an `APIRouter`.
- Clarified where Codex posts QA results, added a "What happens next?" section, and noted that "⚠️ Docs: Lint skipped"
  doesn't block merges.
- Refined the onboarding snippet to show a sample Codex QA response and referenced network troubleshooting and the Codex
  FAQ.
- Documented how `docker-compose.dev.yaml` builds the bot and frontend from
  `Dockerfile.dev`, noting the `pnpm install`/`npm ci` steps from
  `frontend/README.md`.

- Added Dockerfiles for the bot and frontend and updated `docker-compose.dev.yaml` to build them.
- Documented Ubuntu commands for installing Docker, Docker Compose, Node.js 20, and Python 3.12. Linked the setup guide
  from the README quickstart.
- CI workflow now builds service containers before starting Compose.
- CI workflow installs Vale automatically before documentation checks.
- Added `codespell` pre-commit hook for Markdown and text files.
- Codespell ignore list covers `DevOnboarder`, `nodeenv`, and `pyenv`.
- Enforced "Potato" and `Potato.md` entries in ignore files with a pre-commit check.
- CI now enforces the Potato policy with `scripts/check_potato_ignore.sh`.
- CI workflow now runs `./scripts/generate-secrets.sh` instead of copying `.env.example` to `.env.dev`.
- Expanded nodeenv troubleshooting with certificate verification failure tips and
  linked the section from the onboarding docs.
- Documented the `NODEJS_MIRROR` environment variable and linked the troubleshooting guide from the PR template.
- Pinned Vale version to 3.12.0 in CI, documentation, and scripts.
- Added `/health` endpoints for auth and XP services with compose and CI healthchecks.
- Confirmed all Docker healthchecks and CI wait steps use `/health` instead of the deprecated `/healthz` path.
- Generated `frontend/package-lock.json` to pin npm dependencies.
- Added Vale and LanguageTool documentation linting in CI.
- CI now saves Vale results as `vale-results.json` and uploads them as an artifact.
- Linter step now uses `ruff check --output-format=github .`.
- Improved LanguageTool script with line/column output and graceful connection error handling.
- CI workflow now records pytest results and uploads them as an artifact.
- CI workflow now uses `actions/upload-artifact@v4`.
- Documented where to download the `pytest-results.xml` artifact in the doc-quality onboarding guide.
- Pytest results now save to `test-results/pytest-results.xml` and documentation references this path.
- Added Playwright accessibility tests using `@axe-core/playwright` with a new `npm run test:a11y` script.
- Added a `make test` target that installs dev requirements before running tests.
- Documented installing `requirements-dev.txt` prior to running `pytest`.
- LanguageTool checks now skip files that exceed the request size limit instead of failing.
- LanguageTool script now emits GitHub error annotations and exits with a non-zero code when issues are found.
- `scripts/check_docs.sh` now skips the Vale check with a warning when the binary cannot be downloaded or executed.
- Documented how to install Vale manually when network access is restricted.
- Added offline instructions for manual Vale installation and running LanguageTool locally.
- Improved the Vale download logic in `scripts/check_docs.sh` to extract the tarball in a temporary directory and move
  only the binary.
- Added a cleanup trap to remove the temporary Vale directory automatically.
- `scripts/check_docs.sh` now verifies that the Vale binary was extracted
  successfully before moving it, exiting with a warning if missing.
- CI now prints auth container logs if the service fails to start before header checks.
- Added a Known Limitations section to `doc-quality-onboarding.md` explaining that large files may skip LanguageTool
  checks.
- Documented that grammar and style issues only produce CI warnings.
- `scripts/check_docs.sh` now reports Vale and LanguageTool issues as warnings instead of failing CI.
- `docker-compose.ci.yaml` exposes the auth service on port 8002 and drops the deprecated `version` key so CI health
  checks succeed.
- Added `docs/network-troubleshooting.md` with tips for working behind restricted networks.
- CI workflow now waits for the auth service before running the header check to avoid connection errors.
- The initial auth wait step now fails and prints logs if the service never starts, avoiding test timeouts.
- Documented committing the lockfile in the README and frontend README.
- Documented starting the frontend with `npm install` (or `pnpm install`) and `npm run dev`.
- Added `scripts/generate-secrets.sh` and a Makefile for generating throwaway secrets before starting Compose.
- Documented `make deps` and `make up` targets in the onboarding guide for a simpler workflow.
- Added `docs/Agents.md` with a consolidated overview of service agents and healthchecks.
- Cleaned up README and AGENTS docs to reduce documentation lint warnings.
- Auth service now errors at startup when `JWT_SECRET_KEY` is unset or "secret" outside development mode.
- Replaced `AUTH_SECRET_KEY` with `JWT_SECRET_KEY` and added `JWT_ALGORITHM` with dotenv support.
- Documented database agent and synced environment variables with `.env.example`.
- `setup-env.sh` now falls back to `npm install` when `pnpm` is unavailable.
- `setup-env.sh` skips the Codex Docker image when `CI` is set and uses the local virtualenv.
- `setup-env.sh` installs bot packages when `bot/` exists and the README quickstart mentions
  running `npm ci --prefix bot`.
- Added documentation & QA checklist to `docs/pull_request_template.md` and `.github/pull_request_template.md`.
- Added `doc-quality-onboarding.md` with a quickstart for running documentation checks.
- Replaced marketing preview links with the frontend README and React demo.
- Updated `frontend/README.md` with DevOnboarder branding and removed outdated badge references.
- Updated `docker-compose.dev.yaml` to run `npm run dev` for the frontend service.
- Completed alpha onboarding guide and linked a simple marketing site preview.
- Checked off roadmap tasks for documentation, feedback integration, security audit, marketing preview, and cross-
  platform verification.
- Documented that setup instructions were validated on Windows, macOS, and Linux.
- Recorded npm audit results showing zero vulnerabilities and noted pip-audit could not run in the sandbox environment.
- Removed outdated reference to `bot/npm-audit.json` in the security audit doc.
- Updated Codex dashboard and plan to mark auth, XP, and bot modules complete.
- Added `/api/user/contribute` endpoint to the XP API requiring a JWT.
- Updated README to describe the Vite-based React frontend.
- Added a standard Vite `index.html` with a `<div id="root"></div>` mount point in the `frontend/` directory.
- Documented new frontend environment variables in `docs/env.md` and `docs/Agents.md`.
- Replaced marketing preview links with `frontend/index.html`.

- `scripts/check_docstrings.py` now accepts an optional directory argument and CI passes `src/devonboarder` explicitly.
- Added `docs/sample-pr.md` with an example pull request.
- Documented Vale installation steps and improved `scripts/check_docs.sh` to
  verify the command is available before running.

- Updated `scripts/check_docs.sh` to output GitHub error annotations when
  Vale or LanguageTool find issues.

- Dropped unused `user_id` argument from `utils.discord.get_user_roles`.
- Docstring check now detects FastAPI route decorators instead of relying on function name prefixes.
- Added missing docstrings to auth service endpoints.
- Docstring check now emits GitHub error annotations for missing docstrings.
- Pinned Prettier pre-commit hook to `v3.6.2`.
- Verified Prettier hook installation with `pre-commit autoupdate`.
- Added `pytest-cov` to development requirements.
- Added CORS and security middleware to the auth and XP services and updated the
  header smoke test.
- Synced docs pull request template with `.github` to include OpenAPI and
  migration checks, docstring enforcement, header validation, and coverage
  requirements.
- Expanded the pull request template with environment variable and coverage checks and noted the template in the Git
  guidelines.
- Header smoke test now queries `CHECK_HEADERS_URL` (defaults to
  `http://localhost:8002/api/user`).
- Updated CI and container configs to Node 20 and Python 3.12.
- CI compose now includes the auth service and the workflow waits for it to start.
- Auth service wait step now retries the port check up to 30 times and fails if the service isn't reachable.
- Bot Dockerfile installs dev dependencies for the TypeScript build and prunes them for runtime.
- CI compose now includes the auth service and waits for it before tests and header checks.
- Enabled OpenAPI format validation in the CI workflow.
- Updated CI to run `openapi-spec-validator` without the
  `--enable-format-check` flag.
- `init_db()` no longer drops existing tables. Tests now clean up the database
  themselves.
- Introduced `utils/roles.py` and expanded `/api/user` to return role flags;
  documented `GOVERNMENT_ROLE_ID`, `MILITARY_ROLE_ID`, and `EDUCATION_ROLE_ID`.
- Added tests for Discord role resolution and `/api/user` flags.
- Bot API helpers now validate `resp.ok` before parsing JSON and throw errors on
  failure responses.
- API request helper now logs network errors and throws a descriptive
  "Network error" exception when `fetch` fails.
- Auth service now filters Discord roles to the admin guild when resolving
  user flags. Updated docs to clarify guild-based role filtering.
- Auth tokens now include `iat` and `exp` claims. Set `TOKEN_EXPIRE_SECONDS` to configure expiry.
- Auth tokens now use integer timestamps for `iat` and `exp` to avoid race
  conditions when checking expiry.
- Bot API helpers now accept a `username` argument and bot commands send the
  caller's name in each request.
- XP API now reads `Contribution` and `XPEvent` data to return onboarding
  status and level for the requested user.
- Moved role flag logic to `utils.roles` and added `resolve_verification_type`.
- Introduced Discord role resolution in the auth service and expanded `/api/user`
  to return Discord profile fields and resolved role flags.
- Auth service now stores Discord OAuth tokens and uses them for Discord API
  calls during authentication.
- Added `src/routes/user.py` router for `/api/user` and included it in the auth service.
- Added Discord bot scaffolding with dynamic command loading and a `/ping` command.
- Added `POST /api/user/contributions` endpoint and updated the `/contribute` bot command to record contributions.
- Added `/verify`, `/profile`, and `/contribute` command modules to the bot and tests loading them via `loadCommands`.

- Added `.env.example` files for individual services and documented how to copy
  them during setup.
- Renamed `AUTH_DATABASE_URL` to `DATABASE_URL` for the auth service.

- Added `docker-compose.dev.yaml` and `docker-compose.prod.yaml` with auth,
  bot, XP API, frontend, and Postgres services loading variables from
  `.env.dev` and `.env.prod`.
- Documented commit message style with an example summarizing change purpose.
- Added `docker-compose.ci.yaml` for the CI pipeline.
- Added Postgres `db` service in the compose files and initial Alembic
  migrations for `users`, `contributions`, and `xp_events` tables.
- Added placeholder `frontend/README.md` to reserve the upcoming UI directory.
- Added React/Vite frontend with OAuth session component.
- Corrected `ADMINISTRATOR_ROLE_ID` variable name in docs, code and tests.
- Added authentication service with SQLAlchemy models and JWT-protected routes.
- Documented running `devonboarder-auth` in the onboarding guide.
- Added test ensuring the CLI prints the default greeting when no name is provided.
- Authentication middleware now resolves Discord roles after JWT validation and
  `/api/user` includes `isAdmin`, `isVerified`, `verificationType`, and `roles`.
- `/api/user` now returns the Discord ID, username, avatar, and guild roles.
- Documented how to propose issues and pull requests in `docs/README.md`.
- Added an alpha phase roadmap under `docs/roadmap/` and linked it from the docs README.
- Added a README section pointing to workflow docs under `docs/`.
- Documented the alpha wave rollout process in `docs/alpha/alpha-wave-rollout-guide.md` and linked it from the docs.
- Added `DATABASE_URL` placeholder to `.env.example`.
- Expanded `scripts/bootstrap.sh` to create `.env.dev` and run the environment setup script.
- CI workflow copies `.env.example` to `.env.dev` before launching Docker Compose.
- Added `httpx` as a project dependency and documented it in the README.
- Added `uvicorn` as a project dependency and documented its usage in the
  API server instructions.
- Consolidated compose service configuration using YAML anchors and explained
  how to override environment-specific settings.
- Documented running `devonboarder-api` on `http://localhost:8001` under Local Development in the README.
- Linked `docs/founders/charter.md` from the founders README.
- Added `.dockerignore` to reduce the Docker build context by excluding caches and tests.
- Ignored `.pytest_cache/` and `.ruff_cache/` in `.gitignore` and `.dockerignore`.
- Added FastAPI user API with `/api/user/onboarding-status` and `/api/user/level` routes.
- Expanded infrastructure blueprints with usage notes.
- Expanded `infra/README.md` and blueprint docs with compose examples and
  environment variable instructions.
- Clarified dev container usage in the README.
- Replaced `docs/README.md` placeholder with onboarding instructions and local development steps.
- Added tests for the greeting function and Docker Compose configuration.
- Added configuration helper files and documented their usage.
- Added test for the bootstrap script and removed the unused Postgres
  service from CI.
- Added test for `setup-env.sh` that verifies virtual environment creation when Docker is unavailable.
- Replaced the placeholder Docker image with a Python-based image and updated
  `docker-compose.yml` and tests accordingly.
- Added a minimal HTTP server and configured the app service to run it.
- CI workflow now installs the package before running tests.
- Defined project metadata in `pyproject.toml` and added a console script entry point.
- Restructured source into a `devonboarder` package and updated tests to import modules by package path.
- Dockerfile installs the package and uses the CLI entrypoint.
- Added test that runs the CLI and verifies the greeting output.
- Compose files start the server via `devonboarder-server`.
- Added onboarding templates for invite-only alpha testers and the founder's circle.
- Moved onboarding docs into `docs/alpha/` and `docs/founders/` with new feedback and charter files.
- Added invitation email templates under the `emails/` directory.
- Added `FOUNDERS.md` and `ALPHA_TESTERS.md` to track community members.
- Added `IS_ALPHA_USER` and `IS_FOUNDER` flags to `.env.example` with server routes and documentation.
- Added `docs/alpha/feedback-template.md` and linked it from the alpha README.
- Added feedback dashboard PRD under `docs/prd/` and linked it from the docs README.
- Refined email templates and added a style guide under `emails/`.
- Added test ensuring the `/founder` route returns `403` unless `IS_FOUNDER` is set.
- Documented when to use the feedback form versus filing issues in
  `docs/alpha/README.md` and linked the form.
- Added README links to `docs/alpha/README.md`, `docs/founders/README.md`, and the email style guide for easier
  navigation.
- Removed `Potato.md` from `.gitignore`.
- Added Discord message templates and linked them from the docs README.
- Added example feedback row with notes column in `ALPHA_TESTERS.md` and noted
  that new rows should be appended below it.
- Added tests verifying that `/alpha` and `/founder` routes allow mixed-case
  feature flags.
- Added `devonboarder-server` console script and updated compose files and docs.
- Documented how to stop running services in `docs/README.md`.
- Added XP API with `/api/user/onboarding-status` and `/api/user/level` routes
  exposed via the `devonboarder-api` command.
- Added Discord bot under `bot/` with verify, profile, and contribute commands.
- CI workflow now installs bot dependencies and runs `npm test`.
- Documented onboarding phases, XP milestones and contributor logs in `docs/README.md`.
- Added `docs/endpoint-reference.md` with API routes and Discord command examples.
- Added Discord utilities for fetching user roles and resolving admin flags.
- Documented role and guild ID placeholders in `.env.example` and created `docs/env.md` with details on the role-based
  permission system.
- Added verified role ID placeholders to `.env.example` and documented them in `docs/env.md`.
- Added a "Secrets" section in `docs/env.md` covering Discord OAuth and bot tokens, with matching placeholders in
  `.env.example` and `bot/.env.example`.
- Added `tests/test_roles.py` verifying admin and verified role flags.
- Documented outdated packages and vulnerability scan results. `pip list` showed
  updates for mypy, pyright, pytest, ruff and typing extensions; `npm outdated`
  flagged missing React packages in the frontend and outdated `node-fetch` in
  the bot. `pip-audit` reported no issues while `npm audit` found moderate
  vulnerabilities in `esbuild` for the frontend with none in the bot.
- Expanded `docs/Agents.md` with a service map, healthcheck code samples and a
  remediation checklist.
- Added `INIT_DB_ON_STARTUP` placeholder to `.env.example` and documented its purpose.
- Removed duplicate auth wait step from CI workflow.
- Added Vitest setup and a basic React test.
- Added Discord server configuration guide noting that the Widget must be enabled.
- Replaced `VITE_AUTH_API_BASE_URL` with `VITE_AUTH_URL` and documented `VITE_API_URL`.
- Added placeholders for `VITE_AUTH_URL`, `VITE_API_URL`, and `VITE_SESSION_REFRESH_INTERVAL` in `.env.example`.
- Added `VITE_SESSION_REFRESH_INTERVAL` to `frontend/src/.env.example` with a default value and synced `docs/env.md`.
- Added `VITE_DISCORD_CLIENT_ID` placeholders to `.env.example` and `frontend/src/.env.example` and documented the
  variable.
- Corrected README quickstart path to `frontend/src/.env.example`.

- Updated development tooling to stable versions and pinned the Vale download
  tag in CI for reproducibility.
- Updated Node to 20 and Python to 3.12 across Dockerfiles, compose files, CI, and documentation.
- Required Python 3.12 in `pyproject.toml` and ruff configuration.
- Fixed the Vale download path in CI to resolve a 404 error.
- Documented batch doc fixes with `codespell` and Prettier in the doc-quality onboarding guide.
- Added a reminder in `docs/merge-checklist.md` to keep `scripts/check_docs.sh` passing.
- Added `docs/tasks/doc_lint_debt.md` as a template issue for documentation lint backlog.
- Ensured tests set `APP_ENV` and `JWT_SECRET_KEY` before importing modules from
  `devonboarder`.
- Documented Codex CI Monitoring Policy and linked it from the onboarding guide.
- Added ignore patterns and token filters to `.vale.ini` to skip code blocks and frontmatter.
- Documented the new Vale ignore patterns and Codespell hook in
  `docs/doc-quality-onboarding.md`, including how to disable Vale with
  `<!-- vale off -->` / `<!-- vale on -->` and a reference to `.pre-commit-config.yaml`.
- Documented how to add words to `.codespell-ignore`.
- Added nodeenv SSL troubleshooting steps to `docs/network-troubleshooting.md`.
- Rewrote the repository README with a concise introduction and quickstart linking to `docs/README.md` and removed Vale
  instructions.
- Added a package docstring to `src/routes/__init__.py` summarizing the routes module.
- `scripts/run_tests.sh` now always installs development requirements before running tests to ensure packages like
  PyYAML are available.
- `scripts/run_tests.sh` installs bot dependencies with `npm ci --prefix bot` before running Jest and
  installs frontend dependencies with `npm ci --prefix frontend` when frontend tests exist.
- Added `DISCORD_REDIRECT_URI` placeholder to `.env.example` and documented it under Secrets.
- Playwright tests now read `AUTH_URL` to locate the auth service. Documented the
  variable in `docs/e2e-tests.md` and set it in CI.

- Fixed bullet formatting in `docs/pull_request_template.md`.

- Fixed spacing in the Git guidelines pre-PR checklist.
- Updated `Codex_Contributor_Dashboard.md` to mark the frontend module in progress.
- Planned feedback dashboard with backend API and React UI as described in `docs/prd/feedback-dashboard.md`.

- CI workflow now uses the GitHub CLI for issue automation tasks instead of third-party actions.
- Improved CI failure issue detection to search titles for the current commit SHA.
- CI workflow now closes any open CI failure issue for the current commit by searching titles rather than using
  artifacts.
- Added `DISCORD_API_TIMEOUT` environment variable and enforced HTTP timeouts when contacting Discord APIs.
- Added `license = {text = "MIT"}` to `pyproject.toml`.
- Dependabot now monitors `/frontend` and `/bot` for npm updates.
- Upgraded React to v19 and dotenv to v17.
- Aligned Prettier version 3.6.2 across configuration and docs.
- Documented the 95% coverage policy in `docs/doc-quality-onboarding.md`.
- Documented that CI failure issues use the built-in `GITHUB_TOKEN`; no personal token is required unless `permissions:`
  removes `issues: write`.
- Added `cleanup-ci-failure.yml` workflow to close stale `ci-failure` issues nightly and documented the job in
  `docs/README.md`.
- Granted `issues: write` permission in `ci.yml` so forks can open and close CI failure issues with the built-in token.
- Noted that new GitHub organization roles require updates to all README files.
- Verified `.env.dev` matches `.env.example` and added a warning in
  `scripts/bootstrap.sh` when variables are missing. Marked the env var audit
  task complete in `docs/Agents.md`.
- Updated `.nvmrc` and CI workflow to use Node 20.
- Ignored `.coverage` in `.gitignore` and `.dockerignore`.

- Documented module descriptions for the auth service, XP API, roles, and CORS utilities.
- CI now stops docker compose containers even when earlier steps fail.
- Added `openapi-spec-validator` and `requests` to `requirements-dev.txt` and
  removed their manual installation from the CI workflow.
- CI workflow caches pip downloads and Node dependencies for faster installs.
- Cache keys include Python and Node versions to avoid mismatches.

- JS test scripts now run coverage and fail if coverage drops below 95%.
  CI uses `npm test` for the bot and frontend packages.
- Documented the CI job's caching, concurrency, and coverage requirements in
  `docs/ci-workflow.md`.
- Documented `AUTH_URL`, `DISCORD_API_TIMEOUT`, and `CHECK_HEADERS_URL` environment variables.
- Documented running `scripts/install_commit_msg_hook.sh` after cloning so commit messages pass CI linting.
- Added `docs/origin.md` with the project's backstory and linked it from the README.
- Expanded `docs/origin.md` with more detail on the 2017–2021 collapse,
  recovery steps, and disclaimers.
- Added `docs/builder_ethics_dossier.md` documenting project values and a reusable template. Removed the outdated
  `docs/builder-ethics-dossier.md`.
- Added a journal log section in `docs/builder_ethics_dossier.md` summarizing the removal of
  `docs/builder-ethics-dossier.md` and noting the Quickstart coverage command.
- Added environment variable summary to `agents/index.md`.
- Added MS Teams integration variables (`TEAMS_APP_ID`, `TEAMS_APP_PASSWORD`, `TEAMS_TENANT_ID`,
  `TEAMS_CHANNEL_ID_ONBOARD`) to `.env.example` and documentation.
- Documented running `pre-commit install` in README Quickstart.
- Added a legacy note in `docs/Agents.md` directing readers to `agents/index.md`.
- Documented `API_BASE_URL` in `.env.example` and environment docs.
- Added Llama2 Agile Helper agent doc and `LLAMA2_API_KEY` variable.
- Documented planned status for Llama2 Agile Helper agent.
- Documented running `npm run coverage` in `frontend/README.md` and noted the
  95% coverage requirement.
- Added feature expansion plan for Llama2 Agile Helper agent with prompts and integration points.
- Cleaned up outdated verification role ID references across the docs.
- Added prompts, metrics log, and Codex tasks scaffolding for the Llama2 Agile Helper agent.
- Documented configuring `VALE_BINARY` when the Vale binary is not in `PATH`.
- Verified builder ethics dossier links, journal log, and coverage doc alignment
  (`codex/tasks/confirm_doc_alignment.md`)
- Documented Llama2 Agile Helper integration step in `codex.plan.md` and updated automation bundle.
- Added `agile-001` task for Llama2 Agile Helper integration in `codex.tasks.json` and verified `codex.plan.md`
  reference.
- CI workflow skips push runs when commit messages start with `[no-ci]`; documented the marker in `AGENTS.md`.
- Added optional `pytest` pre-commit hook so tests can run locally before each commit.
- Documented running `env -i PATH="$PATH" bash scripts/audit_env_vars.sh` in `docs/env.md` and explained the
  `JSON_OUTPUT` option for machine-readable results.
- Clarified that `scripts/check_docs.sh` uses Vale only and that running
  LanguageTool checks requires a local server.
- Updated README to note that `scripts/check_docs.sh` relies on Vale and that
  LanguageTool is optional.
- Documented that `scripts/check_docs.sh` attempts to download Vale when it is
  missing and prints a warning without failing if the download fails.
- Summarized the download fallback in `README.md` and linked to
  `docs/README.md#documentation-quality-checks` for full details.
- Updated ONBOARDING.md to display "Vale warnings" and noted that
  LanguageTool runs only when `LANGUAGETOOL_URL` is set.

- Added governance checklist for bot permissions in `docs/governance/bot_access_governance.md`.
- Added an **Owner** column to that checklist and assigned responsible teams to each task.
- Documented token requirements for forked pull requests in `docs/ci-failure-issues.md` and referenced it from the
  documentation README.
- Added a debug step to `cleanup-ci-failure.yml` to print token status and open issue numbers before closing them.
- Linked the network exception list from the docs overview so newcomers can find firewall rules.
- Reminded contributors to add new domains to this list when scripts or docs reference them.
- The cleanup workflow now exits with an error when any `gh` command fails and opens a follow-up issue.
- The cleanup workflow prints `Closed N ci-failure issues` on success or `::error::Cleanup failed` in the job log.
- Added tests for `scripts/show_network_exceptions.sh` validating the domain list matches the documentation.
- Required Node.js 20+ via the `engines` field in all package.json files.
- Documented the Node.js 20 requirement in the bot and frontend READMEs and referenced `.nvmrc`.
- Added `docs/service-status.md` summarizing core service health and linked it from the documentation overview.
- Re-added `"milestone": "v0.5.0"` for `feedback-002` in `codex.tasks.json`.
- Documented Codex agent index and YAML headers for agent docs.
- Simplified CI failure issue parsing to use `gh` output directly and verified the CLI version in CI workflows.
- Removed `--json` and `--jq` flags from CI failure issue commands. Workflows now
  check the GitHub CLI version and fall back to `awk` parsing when searches fail.
- Fixed YAML indentation in `ci.yml` for the Python dependency audit step.

## [0.1.0] - 2025-06-14

- Added `src/app.py` with `greet` function and updated smoke tests.
  [#21](https://github.com/theangrygamershowproductions/DevOnboarder/pull/21)
- Added `requirements-dev.txt` and `pyproject.toml` with ruff configuration. Updated CI to run the linter.
  [#22](https://github.com/theangrygamershowproductions/DevOnboarder/pull/22)
- Added `.env.example` and documented setup steps in the README.
  [#23](https://github.com/theangrygamershowproductions/DevOnboarder/pull/23)
- Documented branch naming, commit messages, and rebase policy in the Git guidelines.
  [#24](https://github.com/theangrygamershowproductions/DevOnboarder/pull/24)
- Expanded `docs/pull_request_template.md` with sections for summary, linked issues, screenshots, testing steps, and a
  checklist referencing documentation and changelog updates.
  [#25](https://github.com/theangrygamershowproductions/DevOnboarder/pull/25)
- Documented the requirement to pass lint and tests, update documentation and the changelog, and added a reviewer sign-
  off section to the pull request template.
  [#26](https://github.com/theangrygamershowproductions/DevOnboarder/pull/26)
- Added `codex.ci.yml` to automate CI monitoring and fix failing builds.

- Updated bot and frontend lock files and added tests so `scripts/run_tests.sh` passes
- Updated pytest artifact path in CI workflow to `artifacts/pytest-results.xml`
- Added `security-audit.yml` workflow to run dependency audits weekly and upload the report as an artifact. Documented
  the job in `docs/README.md`.
- Added Black formatting checks in CI. The workflow runs `black --check .` after installing dev dependencies.
- Logged `gh auth status` before creating CI failure issues and stopped the job
  when the GitHub CLI exits with an error.
- Noted the Node.js 20 requirement in the bot and frontend READMEs and
  referenced the `.nvmrc` setup.
- Documented Dependabot PR review steps in docs/dependencies.md and linked the page from CONTRIBUTING.
- `scripts/alembic_migration_check.sh` now sets `set -euo pipefail` and quotes `$DATABASE_URL`.
- Added a Quickstart bullet recommending `bash scripts/run_tests.sh` with a link
  to `docs/troubleshooting.md` for troubleshooting help.
- Documented the language versions provided by `ghcr.io/openai/codex-universal`
  and noted that `scripts/setup-env.sh` pulls this image.
- Invited contributors to share onboarding feedback by linking a short survey in docs/pull_request_template.md.
- Added `VITE_FEEDBACK_URL` configuration and implemented React components for the feedback form, status board, and analytics snapshot.
- Implemented Llama2 Agile Helper service exposing `/sprint-summary` and `/groom-backlog` endpoints.
- Validated feedback components handle failed requests and show error messages.
- Ensured the feedback status board uses functional state updates so concurrent changes aren't lost.
- Added CI failure issue troubleshooting guide to `AGENTS.md` and a typedoc docs build script.
- Added engineer assessment work items checklist in `docs/assessments/engineer_assessment_work_items.md`.
- Linked the checklist from `docs/README.md` and the project README for onboarding reviews.
- Created `assessment.md` issue template and referenced it from the merge checklist and README.
- Updated engineer assessment checklist with Codex-compatible work items.
- Added CI and Auto Fix badges to `README.md`.
- Added `ci-monitor.yml` to open an issue when CI fails due to API rate limits and documented the secret in `docs/ci-env-vars.md`.
- Updated docs/README local setup to run `python -m diagnostics` after bootstrap. The script checks package imports, service health, and environment variables.
- Updated `docs/ONBOARDING.md` to run `python -m diagnostics` once services are
  running and link to `docs/troubleshooting.md` for interpreting failures.
- Clarified how to obtain the TAGS compose files in `docs/tags_integration.md`.
- Added example TAGS compose templates under `archive/` and documented how to
  customize them in `docs/tags_integration.md`.
- Copied the TAGS compose templates to the repository root and clarified the
  path in `docs/tags_integration.md`.
- Added a yamllint log upload step to `cleanup-ci-failure.yml` and corrected
  indentation of `GH_TOKEN` lines.
- Replaced `--json` and `--jq` examples in `docs/ci-failure-issues.md` with
  awk-based parsing so the commands work on older GitHub CLI versions.

- Verified GitHub CLI version and piped issue author JSON to jq in `close-codex-issues.yml`.
- Added `httpx`, `requests`, and `yaml` checks to `scripts/check_dependencies.sh` and now exit non-zero when any are missing.
- `scripts/run_tests.sh` validates dependencies with `pip check` after installing dev requirements and again after installing the project.
- Replaced custom GitHub CLI script with the `ksivamuthu/actions-setup-gh-cli` action and updated documentation.
