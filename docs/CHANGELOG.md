# Changelog

All notable changes to this project will be recorded in this file.

## [Unreleased]
- Added `close-codex-issues.yml` workflow to automatically close Codex-created issues referenced by `Fixes #<issue>` after a pull request merges and documented it in `docs/README.md`.
- Archived `languagetool_check.py` to `archive/` and removed its invocation from `scripts/check_docs.sh`.
- Added `scripts/install_gh_cli.sh` for local GitHub CLI installation and referenced it in the docs.
- Added `tests/README.md` describing how to install project requirements before running `pytest` so modules like `fastapi` are available.
- Documented the 95% coverage requirement and how to run Python and JavaScript coverage tests in `tests/README.md`.
- Documented manual cleanup of `ci-failure` issues in `docs/ci-failure-issues.md`.
- CI workflow now closes every open `ci-failure` issue once the pipeline succeeds.
- Added a reusable `.github/actions/setup-gh-cli` action for installing the GitHub CLI.
- Workflows log the install path with `which gh` and no longer modify `$GITHUB_PATH`.
- Steps that invoke the GitHub CLI now call the path from `which gh` to ensure the latest version is used.
- Updated `setup-gh-cli` to remove the old `/usr/bin/gh` binary and export `/usr/local/bin` through `$GITHUB_PATH` so the new CLI is always found.
- CI now lints commit messages with `scripts/check_commit_messages.sh`.
- Updated `scripts/run_tests.sh` to run `pytest --cov=src --cov-fail-under=95`
  and invoke `npm run coverage` for the bot and frontend packages.
- Documented policy against rewriting commit history or force-pushing after commits are pushed.
- Extracted CORS helper to `utils.cors` and reused in auth and XP services.

- Updated `docker-compose.codex.yml` with the Codex runner image and documented manual invocation under "Codex Runs".

- Clarified README instructions to stop the server with Ctrl+C.
- Removed unused `REDIS_URL`, `LOG_LEVEL`, and `API_KEY` from `.env.example` and
  documented `CORS_ALLOW_ORIGINS` and `DISCORD_REDIRECT_URI` in `docs/Agents.md`
  and `docs/env.md`.
- Added `CORS_ALLOW_ORIGINS` environment variable for configuring CORS.
- Replaced `node-fetch` with the global `fetch` in the Discord bot and updated tests.
- Prettier now runs only via the pre-commit mirror. Removed duplicate `npm run format` hooks from `.pre-commit-config.yaml`.
- Replaced the outdated TODO section in `docs/git/Git.md` with a "Maintenance Notes" summary.
- Upgraded React packages to 19.1.0 and `dotenv` to 17.0.1.
- Removed the `API_KEY` generation step from `scripts/generate-secrets.sh`.

- Added `scripts/check_dependencies.sh` and documented running it from `docs/README.md` and `docs/doc-quality-onboarding.md`.

- Checked off completed tasks in `docs/Agents.md` for `/health` endpoints, Docker healthchecks, and CI polling.
- Added outreach templates and a feedback log scaffold for community engagement.
- Added `pip-audit` and `npm audit --production` security checks run via `scripts/security_audit.sh` and invoked in CI. Results are stored in `docs/security-audit-2025-07-01.md`.
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
- CI now posts a coverage summary on pull requests using `scripts/post_coverage_comment.py` and uploads the full reports as an artifact.
- Fixed newline formatting in the coverage summary by quoting the `printf` command with double quotes.
- Added `scripts/append_coverage_summary.sh` to append the coverage link with proper newline handling.
- Added ESLint and Prettier configurations for the frontend and bot with new `npm run lint` and `npm run format` scripts.
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
- Added coverage scripts for the bot and frontend packages. CI now runs `npm run coverage` and fails if coverage drops below 80%.
- Increased required code coverage threshold to 95% for all test suites.
- Added tests for the React entrypoint and `Login` component to improve frontend
  coverage.

- Documented running `npm test` from the `frontend/` directory after installing dependencies and linked
  `frontend/README.md` for details.
- Clarified `frontend/README.md` to install dependencies with `pnpm` or `npm`, commit the lockfile, and run `npm run dev`.
- Added `docs/offline-setup.md` explaining how to install dependencies without internet access and linked it from the onboarding docs.
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
- Clarified where Codex posts QA results, added a "What happens next?" section, and noted that "⚠️ Docs: Lint skipped" doesn't block merges.
- Refined the onboarding snippet to show a sample Codex QA response and referenced network troubleshooting and the Codex FAQ.
- Documented how `docker-compose.dev.yaml` builds the bot and frontend from
  `Dockerfile.dev`, noting the `pnpm install`/`npm ci` steps from
  `frontend/README.md`.

- Added Dockerfiles for the bot and frontend and updated `docker-compose.dev.yaml` to build them.
- Documented Ubuntu commands for installing Docker, Docker Compose, Node.js 20, and Python 3.12. Linked the setup guide from the README quickstart.
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
- Added Playwright accessibility tests using `@axe-core/playwright` with a new `npm run test:a11y` script.
- Added a `make test` target that installs dev requirements before running tests.
- Documented installing `requirements-dev.txt` prior to running `pytest`.
- LanguageTool checks now skip files that exceed the request size limit instead of failing.
- LanguageTool script now emits GitHub error annotations and exits with a non-zero code when issues are found.
- `scripts/check_docs.sh` now skips the Vale check with a warning when the binary cannot be downloaded or executed.
- Documented how to install Vale manually when network access is restricted.
- Added offline instructions for manual Vale installation and running LanguageTool locally.
- Improved the Vale download logic in `scripts/check_docs.sh` to extract the tarball in a temporary directory and move only the binary.
- Added a cleanup trap to remove the temporary Vale directory automatically.
- `scripts/check_docs.sh` now verifies that the Vale binary was extracted
  successfully before moving it, exiting with a warning if missing.
- CI now prints auth container logs if the service fails to start before header checks.
- Added a Known Limitations section to `doc-quality-onboarding.md` explaining that large files may skip LanguageTool checks.
- Documented that grammar and style issues only produce CI warnings.
- `scripts/check_docs.sh` now reports Vale and LanguageTool issues as warnings instead of failing CI.
- `docker-compose.ci.yaml` exposes the auth service on port 8002 and drops the deprecated `version` key so CI health checks succeed.
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
- Added documentation & QA checklist to `docs/pull_request_template.md` and `.github/pull_request_template.md`.
- Added `doc-quality-onboarding.md` with a quickstart for running documentation checks.
- Replaced marketing preview links with the frontend README and React demo.
- Updated `frontend/README.md` with DevOnboarder branding and removed outdated badge references.
- Updated `docker-compose.dev.yaml` to run `npm run dev` for the frontend service.
- Completed alpha onboarding guide and linked a simple marketing site preview.
- Checked off roadmap tasks for documentation, feedback integration, security audit, marketing preview, and cross-platform verification.
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
- Expanded the pull request template with environment variable and coverage checks and noted the template in the Git guidelines.
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
- Clarified the purpose of `VERIFIED_GOVERNMENT_ROLE_ID`,
  `VERIFIED_MILITARY_ROLE_ID`, and `VERIFIED_EDUCATION_ROLE_ID` in
  `docs/env.md`.
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
- Added README links to `docs/alpha/README.md`, `docs/founders/README.md`, and the email style guide for easier navigation.
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
- Documented role and guild ID placeholders in `.env.example` and created `docs/env.md` with details on the role-based permission system.
- Added verified role ID placeholders to `.env.example` and documented them in `docs/env.md`.
- Added a "Secrets" section in `docs/env.md` covering Discord OAuth and bot tokens, with matching placeholders in `.env.example` and `bot/.env.example`.
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
- Added `VITE_DISCORD_CLIENT_ID` placeholders to `.env.example` and `frontend/src/.env.example` and documented the variable.
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
- Rewrote the repository README with a concise introduction and quickstart linking to `docs/README.md` and removed Vale instructions.
- Added a package docstring to `src/routes/__init__.py` summarizing the routes module.
- `scripts/run_tests.sh` now always installs development requirements before running tests to ensure packages like PyYAML are available.
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
- CI workflow now closes any open CI failure issue for the current commit by searching titles rather than using artifacts.
- Added `DISCORD_API_TIMEOUT` environment variable and enforced HTTP timeouts when contacting Discord APIs.
- Added `license = {text = "MIT"}` to `pyproject.toml`.
- Dependabot now monitors `/frontend` and `/bot` for npm updates.
- Upgraded React to v19 and dotenv to v17.
- Aligned Prettier version 3.6.2 across configuration and docs.
- Documented the 95% coverage policy in `docs/doc-quality-onboarding.md`.
- Documented that CI failure issues use the built-in `GITHUB_TOKEN`; no personal token is required unless `permissions:` removes `issues: write`.
- Added `cleanup-ci-failure.yml` workflow to close stale `ci-failure` issues nightly and documented the job in `docs/README.md`.
- Granted `issues: write` permission in `ci.yml` so forks can open and close CI failure issues with the built-in token.
- Noted that new GitHub organization roles require updates to all README files.
- Verified `.env.dev` matches `.env.example` and added a warning in
  `scripts/bootstrap.sh` when variables are missing. Marked the env var audit
  task complete in `docs/Agents.md`.
- Updated `.nvmrc` and CI workflow to use Node 20.
- Ignored `.coverage` in `.gitignore` and `.dockerignore`.

- Documented module descriptions for the auth service, XP API, roles, and CORS utilities.

## [0.1.0] - 2025-06-14

- Added `src/app.py` with `greet` function and updated smoke tests. [#21](https://github.com/theangrygamershowproductions/DevOnboarder/pull/21)
- Added `requirements-dev.txt` and `pyproject.toml` with ruff configuration. Updated CI to run the linter. [#22](https://github.com/theangrygamershowproductions/DevOnboarder/pull/22)
- Added `.env.example` and documented setup steps in the README. [#23](https://github.com/theangrygamershowproductions/DevOnboarder/pull/23)
- Documented branch naming, commit messages, and rebase policy in the Git guidelines. [#24](https://github.com/theangrygamershowproductions/DevOnboarder/pull/24)
- Expanded `docs/pull_request_template.md` with sections for summary, linked issues, screenshots, testing steps, and a checklist referencing documentation and changelog updates. [#25](https://github.com/theangrygamershowproductions/DevOnboarder/pull/25)
- Documented the requirement to pass lint and tests, update documentation and the changelog, and added a reviewer sign-off section to the pull request template. [#26](https://github.com/theangrygamershowproductions/DevOnboarder/pull/26)
- Added `codex.ci.yml` to automate CI monitoring and fix failing builds.

- Updated bot and frontend lock files and added tests so `scripts/run_tests.sh` passes
