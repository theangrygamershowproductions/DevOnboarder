# Changelog

All notable changes to this project will be recorded in this file.

## [Unreleased]
- Added test ensuring the CLI prints the default greeting when no name is provided.
- Documented how to propose issues and pull requests in `docs/README.md`.
- Added an alpha phase roadmap under `docs/roadmap/` and linked it from the docs README.
- Added a README section pointing to workflow docs under `docs/`.
- Documented the alpha wave rollout process in `docs/alpha/alpha-wave-rollout-guide.md` and linked it from the docs.
- Added `DATABASE_URL` placeholder to `.env.example`.
- Expanded `scripts/bootstrap.sh` to create `.env.dev` and run the environment setup script.
- Added `httpx` as a project dependency and documented it in the README.
- Linked `docs/founders/charter.md` from the founders README.
- Added `.dockerignore` to reduce the Docker build context by excluding caches and tests.
- Ignored `.pytest_cache/` and `.ruff_cache/` in `.gitignore` and `.dockerignore`.
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

## [0.1.0] - 2025-06-14
- Added `src/app.py` with `greet` function and updated smoke tests. [#21](https://github.com/theangrygamershowproductions/DevOnboarder/pull/21)
- Added `requirements-dev.txt` and `pyproject.toml` with ruff configuration. Updated CI to run the linter. [#22](https://github.com/theangrygamershowproductions/DevOnboarder/pull/22)
- Added `.env.example` and documented setup steps in the README. [#23](https://github.com/theangrygamershowproductions/DevOnboarder/pull/23)
- Documented branch naming, commit messages, and rebase policy in the Git guidelines. [#24](https://github.com/theangrygamershowproductions/DevOnboarder/pull/24)
- Expanded `docs/pull_request_template.md` with sections for summary, linked issues, screenshots, testing steps, and a checklist referencing documentation and changelog updates. [#25](https://github.com/theangrygamershowproductions/DevOnboarder/pull/25)
- Documented the requirement to pass lint and tests, update documentation and the changelog, and added a reviewer sign-off section to the pull request template. [#26](https://github.com/theangrygamershowproductions/DevOnboarder/pull/26)
