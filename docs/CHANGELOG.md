# Changelog

All notable changes to this project will be recorded in this file.

## [Unreleased]

- `scripts/check_docstrings.py` now accepts an optional directory argument and
  CI passes `src/devonboarder` explicitly.

- Dropped unused `user_id` argument from `utils.discord.get_user_roles`.
- Docstring check now detects FastAPI route decorators instead of relying on function name prefixes.
- Added missing docstrings to auth service endpoints.
- Pinned Prettier pre-commit hook to `v3.1.0`.
- Verified Prettier hook installation with `pre-commit autoupdate`.
- Added `pytest-cov` to development requirements.
- Added CORS and security middleware to the auth and XP services and updated the
  header smoke test.
- Synced docs pull request template with `.github` to include OpenAPI and
  migration checks, docstring enforcement, header validation, and coverage
  requirements.
- Header smoke test now queries `CHECK_HEADERS_URL` (defaults to
  `http://localhost:8002/api/user`).
- CI compose now includes the auth service and the workflow waits for it to start.
- Auth service wait step now retries the port check up to 30 times and fails if the service isn't reachable.
- Bot Dockerfile installs dev dependencies for the TypeScript build and prunes them for runtime.
- CI compose now includes the auth service and waits for it before tests and header checks.
- Enabled OpenAPI format validation in the CI workflow.
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
- Added a "Secrets" section in `docs/env.md` covering Discord OAuth and bot tokens, with matching placeholders in `.env.example` and `.env.bot.example`.
- Added `tests/test_roles.py` verifying admin and verified role flags.

## [0.1.0] - 2025-06-14

- Added `src/app.py` with `greet` function and updated smoke tests. [#21](https://github.com/theangrygamershowproductions/DevOnboarder/pull/21)
- Added `requirements-dev.txt` and `pyproject.toml` with ruff configuration. Updated CI to run the linter. [#22](https://github.com/theangrygamershowproductions/DevOnboarder/pull/22)
- Added `.env.example` and documented setup steps in the README. [#23](https://github.com/theangrygamershowproductions/DevOnboarder/pull/23)
- Documented branch naming, commit messages, and rebase policy in the Git guidelines. [#24](https://github.com/theangrygamershowproductions/DevOnboarder/pull/24)
- Expanded `docs/pull_request_template.md` with sections for summary, linked issues, screenshots, testing steps, and a checklist referencing documentation and changelog updates. [#25](https://github.com/theangrygamershowproductions/DevOnboarder/pull/25)
- Documented the requirement to pass lint and tests, update documentation and the changelog, and added a reviewer sign-off section to the pull request template. [#26](https://github.com/theangrygamershowproductions/DevOnboarder/pull/26)
