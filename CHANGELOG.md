---
project: "TAGS"
module: "Documentation Tools"
phase: "Maintenance Automation"
tags: ["metadata", "markdown", "indexing", "automation"]
updated: "12 June 2025 09:33 (EST)"
version: "v1.2.6"
author: "Chad Allan Reesey (Mr. Potato)"
email: "education@thenagrygamershow.com"
description: "Manages indexing and metadata injection for project documentation."
---

# Documentation Tools – Maintenance Automation
## <!-- markdownlint-disable-file -->

project: "DevOnboarder Codex"
module: "Root Changelog"
phase: "MVP"
tags: ["changelog", "versioning"]
updated: "15 August 2025 00:00 (EST)"
version: "v0.5.52"

---

# Changelog

## [v0.5.87] - 2025-09-13
### Added
- Default metadata headers inserted across documentation

## [v0.5.88] - 2025-09-15
### Added
- Aurora and Laramie infrastructure blueprints
- Auth pivot diagram referenced in README

## [v0.5.86] - 2025-09-12
### Added
- Initial Code of Conduct referencing TAGS community standards

## [v0.5.62] - 2025-08-25
### Added
- PATCHED header for docs/frontend/RBAC-Migration.md
## [v0.5.63] - 2025-08-25
### Changed
- ts-node installed locally via pnpm install
- setup-dev.sh uses pnpm install for frontend and drops global ts-node
## [v0.5.64] - 2025-08-25
### Fixed
- NODE_PATH in tests includes frontend node_modules

## [v0.5.65] - 2025-08-26
### Changed
- docs manifest refreshed with new architecture and integration links
## [v0.5.66] - 2025-08-26
### Added
- Express auth server with JWT claim validation middleware
## [v0.5.67] - 2025-08-27
### Added
- Cloudflare token placeholders in env templates
- Docs mention new Cloudflare variables
## [v0.5.68] - 2025-08-28
### Added
- VS Code integrations module
## [v0.5.69] - 2025-08-29
### Added
- JWT issuer and audience defaults in env and docs
## [v0.5.70] - 2025-08-30
### Added
- Traefik setup instructions for local HTTPS testing
## [v0.5.71] - 2025-08-31
### Changed
- ts-node added to auth-server devDependencies with start/test scripts
## [v0.5.72] - 2025-08-31
### Changed
- CI and pre-commit run auth-server tests
## [v0.5.73] - 2025-09-01
### Changed
- Bump ts-node in auth-server devDependencies and retain scripts
## [v0.5.74] - 2025-09-02
### Changed
- setup-dev.sh installs auth-server packages after frontend
## [v0.5.75] - 2025-09-03
### Changed
- Development and testing docs mention running `pnpm install` inside `auth-server/`
  and note that **ts-node** is required for Node-based tests
## [v0.5.76] - 2025-09-04
### Changed
- Auth spec runner test skips when ts-node is missing
## [v0.5.77] - 2025-09-05
### Changed
- CI installs auth-server dependencies before running tests
## [v0.5.78] - 2025-09-05
### Changed
- `.gitignore` excludes `acme.json` and documentation notes the rule
## [v0.5.79] - 2025-09-06
### Changed
- auth-server tests migrated to vitest and ESM imports

## [v0.5.80] - 2025-09-07
### Changed
- Verification DB URL configurable via `VERIFICATION_DB_URL`
- Development setup docs mention the new variable

## [v0.5.81] - 2025-09-08
### Added
- CI starts Redis container before tests and waits for readiness

## [v0.5.82] - 2025-09-09
### Added
- Node auth logout test and in-memory revocation fallback

## [v0.5.83] - 2025-09-10
### Changed
- Devcontainer installs Python venv tooling for Python 3.13

## [v0.5.84] - 2025-09-11
### Added
- In-memory Redis mock for logout tests
### Fixed
- Removed header comment from auth-server/package.json

## [v0.5.85] - 2025-09-11
### Changed
- Setup scripts and docs now use `python -m pip` for reliability


## [v0.5.61] - 2025-08-24
### Added
- requirements-dev.txt for unified dev dependencies
- README instructions to install from requirements-dev.txt

## [v0.5.57] - 2025-08-20
### Added
- copyPolicies script updates owner injection and summary

## [v0.5.60] - 2025-08-23
### Added
- README patch header referencing CLI journal logs

## [v0.5.55] - 2025-08-18
### Added
- Journal folder entry `codex/journal/2025-06-10.md` summarizing feature rollup

## [v0.5.56] - 2025-08-19
### Added
- Document `CODEX_JOURNAL_DIR` variable controlling CLI journal logs

## [v0.5.57] - 2025-08-20
### Fixed
- updateOwner placeholder replacement handles special characters

## [v0.5.58] - 2025-08-21
### Added
- Shared policy templates for CLA, LICENSE, and NOTICE

## [v0.5.59] - 2025-08-22
### Added
- TypeScript test verifying policy copy summary counts

## [v0.5.54] - 2025-08-17
### Added
- Discord bot command to sync modules via repository dispatch

## [v0.5.55] - 2025-08-18
### Added
- CODEX_JOURNAL_DIR environment variable and documentation

## [v0.5.53] - 2025-08-16
### Added
- Submodule integration guide and README link

## [v0.5.52] - 2025-08-15
### Added
- Architecture, platform support, and quickstart docs


## [v0.5.51] - 2025-08-14

### Changed

- Ignore node_modules in dev Docker build

## [v0.5.50] - 2025-08-13

### Added

- Patch headers for auth Dockerfile and .dockerignore

## [v0.5.42] - 2025-08-05

### Changed

- markdownlint pre-commit hook uses system Node to avoid downloads

## [v0.5.43] - 2025-08-06

### Changed

- verify-on-chain script reads DEVONBOARDER\_ environment variables

## [v0.5.44] - 2025-08-07

### Changed

- updated CODEOWNERS patterns and owners

## [v0.5.45] - 2025-08-08

### Added

- scaffold logs errors and hints at setup steps

## [v0.5.46] - 2025-08-09

### Fixed

- ci workflow uses maintained branchlint action

## [v0.5.49] - 2025-08-12

### Changed

- Disable CodeQL workflow until infrastructure is ready

## [v0.5.48] - 2025-08-11

### Fixed

- Dockerfile installs packages in frontend directory

## [v0.5.47] - 2025-08-10

### Fixed

- Makefile indentation uses tabs for docker targets

## [v0.5.40] - 2025-08-03

### Added

- Patch headers for Git docs

## [v0.5.36] - 2025-07-30

### Fixed

- Use `datetime.now(UTC)` instead of deprecated `utcnow`

## [v0.5.37] - 2025-07-31

### Changed

- Devcontainer builds from a Dockerfile that installs `python3.11-venv`

## [v0.5.38] - 2025-08-01

### Added

- Ignore `verification.db` SQLite file

## [v0.5.39] - 2025-08-02

### Changed

- setup-dev.sh respects $HOME when creating Corepack directory

## [v0.5.23] - 2025-07-18

### Changed

- Normalize blank lines after PATCHED headers across the repo

## [v0.5.24] - 2025-07-19

### Changed

- Wrap code lines to stay within 79 characters

## [v0.5.25] - 2025-07-20

### Changed

- Split whitelist path assignment in `check_plugins.py`
- Wrapped secret lines in workflow files
- Broke pnpm upgrade commit message across lines

## [v0.5.26] - 2025-07-21

### Added

- Use Git LFS for binary assets via `.gitattributes`
- Document LFS setup instructions

## [v0.5.27] - 2025-07-22

### Added

- `.python-version` file pins Python 3.13

## [v0.5.28] - 2025-07-23

### Changed

- codex CI workflow uses Python 3.13

## [v0.5.29] - 2025-07-24

### Added

- .editorconfig defines charset and indent defaults

## [v0.5.30] - 2025-07-25

### Added

- Discord bot requires Node.js 22

## [v0.5.31] - 2025-07-26

### Changed

- Add patch headers for commitlint config and security docs

## [v0.5.32] - 2025-07-27

### Changed

- Refactor long lines for flake8 compliance

## [v0.5.33] - 2025-07-27

### Fixed

- Install corepack in setup-dev.sh if missing

## [v0.5.34] - 2025-07-28

### Changed

- Devcontainer image now uses Node.js 22
- Document devcontainer usage in setup guides

## [v0.5.35] - 2025-07-29

### Fixed

- Setup script ensures writable `venv` before creation

## [v0.5.22] - 2025-07-17

### Changed

- CI workflow now uses Python 3.13 and pnpm 10

## [v0.5.21] - 2025-07-16

### Added

- Codex guard rails config and CI workflow

## [v0.5.20] - 2025-07-15

### Fixed

- README security policy link path

## [v0.5.19] - 2025-07-14

### Added

- Dev container runs setup script automatically

## [v0.5.18] - 2025-07-13

### Changed

- CI installs dependencies via setup-dev.sh

## [v0.5.17] - 2025-07-12

### Added

- Abort tests early if required Python packages are missing

## [v0.5.15] - 2025-07-10

### Fixed

- CI installs Node and Python deps before running hooks

## [v0.5.16] - 2025-07-11

### Changed

- CI uses a virtualenv to run pre-commit and tests

## [v0.5.14] - 2025-07-09

### Fixed

- Remove default env placeholders to avoid hardcoded secrets

## [v0.5.13] - 2025-07-08

### Fixed

- Insert blank line after patch headers

## [v0.5.11] - 2025-07-06

### Added

- OPENAI_API_KEY placeholder and loader for Codex automation

## [v0.5.12] - 2025-07-07

### Added

- Document OpenAI rollout steps in README

## [v0.5.10] - 2025-07-05

### Added

- Codex CI workflow, Dockerfile, and agent documentation

## [v0.5.9] - 2025-07-04

### Changed

- Bump Python runtime to 3.13 and upgrade Pydantic dependencies

## [v0.5.8] - 2025-07-02

### Fixed

- Update universal container path in setup scripts

## [v0.5.7] - 2025-07-01

### Changed

- CI installs pnpm via pnpm/action-setup before Node.js for better caching

## [v0.5.5] - 2025-06-30

### Fixed

- CI workflow installs pnpm so pnpm commands run

## [v0.5.4] - 2025-06-29

### Changed

- `setup-env.sh` runs the universal container when Docker is present and exports
  CODEX_ENV variables.

## [v0.5.3] - 2025-06-28

### Changed

- Clarify patch header and script documentation in `codex_setup.sh`.

## [v0.5.2] - 2025-06-28

### Changed

- `codex_setup.sh` now runs the Codex universal container when Docker is available.

## [v0.2.16] - 2025-06-27

### Added

- Split codex_setup.sh into setup-env.sh and setup-dev.sh with shared versions

## [v0.2.17] - 2025-06-27

### Fixed

- Include python-multipart in auth requirements to satisfy FastAPI form parsing

## [v0.2.18] - 2025-06-27

### Fixed

- Also list python-multipart in backend requirements for tests that only install backend deps

## [v0.2.19] - 2025-06-27

### Added

- Document `setup-env.sh` usage in README

## [v0.2.20] - 2025-06-27

### Changed

- CI workflow uses setup-env.sh for environment setup

## [v0.2.15] - 2025-06-26

### Changed

- `codex_setup.sh` exports PYTHONPATH and installs auth dependencies

## [v0.2.14] - 2025-06-24

### Changed

- Removed duplicate `setup/codex_setup.sh`; use `scripts/codex_setup.sh` instead

## [v0.2.13] - 2025-06-23

### Changed

- `codex_setup.sh` uses Corepack to manage pnpm

### Added

- Cluster budget template for Minisforum AI X1 Pro nodes

## [v0.2.12] - 2025-06-23

### Added

- Testing & container setup guide

## [v0.2.11] - 2025-06-22

### Added

- Placeholder directories `api1/`, `api2/`, and `shared/` with README files
- Updated project README to reference these folders

## [v0.2.10] - 2025-06-21

### Fixed

- Removed duplicate `DATABASE_URL` line from environment examples
  so Postgres is the default connection string.

## [v0.2.9] - 2025-06-20

### Changed

- Docs use `.env.development` consistently
- Added `make dev-stack` target and compose instructions

## [v0.2.8] - 2025-06-14

### Added

- Full development compose stack with Traefik, cloudflared, and debug tools

## [v0.2.7] - 2025-06-13

### Added

- README section summarizing CI/CD workflow

## [v0.2.6] - 2025-06-05

### Changed

- `auth.app` now exports the FastAPI instance from `app.main`

## [v0.2.5] - 2025-06-05

### Changed

- Updated auth service patch header and imports

## [v0.2.4] - 2025-06-05

### Changed

- Documented create-env script copies `.env.example` to `.env.development` and infrastructure `.env`

## [v0.2.3] - 2025-06-05

### Changed

- CI/CD Build Agent uses Node.js 22

## [v0.2.2] - 2025-06-05

### Changed

- CI/CD Build Agent uses Node.js 22

## [v0.1.22] - 2025-06-05

### Added

- JWT-based auth with login and user endpoints

## [v0.1.21] - 2025-06-05

### Added

- create-env utility script and env file ignore rules

## [v0.2.1] - 2025-06-05

### Changed

- Updated `run-all-scans.sh` to build the CodeQL container and log steps

## [v0.2.0] - 2025-06-08

### Added

- Project directory scaffolding for auth, frontend, infrastructure, agents, setup, and security
- Stubbed auth health endpoint with tests and Dockerfile
- Added CodeQL artifact ignores and example environment variables
- Created agent descriptions in `Agents.md`

## [v0.1.43] - 2025-06-13

### Added

- Dockerfile and compose service for CodeQL scanning
- Smart contract `CodeAnchor.sol` and on-chain verification script
- GitHub Actions workflow for scanning and verification
- Cron wrapper script and setup documentation

## [v0.1.42] - 2025-06-13

### Added

- Unified `run-all-scans.sh` script to run pytest, pnpm checks and CodeQL
- Documented new script path in security guides
- Added `pytest-asyncio` to backend requirements

## [v0.1.41] - 2025-06-12

### Added

- README updates for security scans and rubric scoring summary

## [v0.1.40] - 2025-06-12

### Changed

- Security scan workflow now runs `scripts/run-all-scans.sh` and installs Node.js/pnpm.

## [v0.1.39] - 2025-06-12

### Added

- Rubric-based evaluation with scoring summary

## [v0.1.38] - 2025-06-12

### Changed

- Auth service now loads allowed CORS origins from `ALLOWED_ORIGINS`.
- Secrets for Discord OAuth and JWT are pulled from Docker secrets.
- Updated compose template and docs to reflect new deployment settings.

## [v0.1.37] - 2025-06-11

### Added

- `docker-compose.override.yaml` with volume mounts for live reload
- `make dev-docker` target to start the Docker stack
- README instructions covering the new workflow

## [v0.1.34] - 2025-06-11

### Changed

- Disabled CodeQL security scan workflow; requires GitHub Advanced Security

## [v0.1.35] - 2025-06-11

### Added

- Token revocation for the auth service

## [v0.1.36] - 2025-06-11

### Added

- Example Vite environment file and config
- Local frontend setup instructions

## [v0.1.33] - 2025-06-11

### Added

- Weekly workflow to upgrade pnpm and regenerate lockfile

### Changed

- `codex_setup.sh` installs pnpm 10.11.1

## [v0.1.32] - 2025-06-10

### Changed

- Security scan workflow now includes `actions: read` permission

## [v0.1.30] - 2025-06-10

### Added

- Security scan workflow with CodeQL permissions

## [v0.1.31] - 2025-06-10

### Changed

- Updated security scan workflow permissions

## [v0.1.29] - 2025-06-10

### Changed

- Quick Start instructions now mention copying `.env.example` to `.env`
  before running setup scripts

## [v0.1.30] - 2025-06-10

### Added

- GitHub CodeQL workflow for scheduled security scanning

## [v0.1.28] - 2025-06-09

### Added

- Login challenge and scoring rubric

## [v0.1.27] - 2025-06-08

### Added

- Auth service requirements file for FastAPI dependencies

## [v0.1.26] - 2025-06-08

### Added

- Dockerfiles for backend and frontend under docker/
- Local docker-compose.yml for development

### Changed

- README instructions referencing docker compose

## [v0.1.25] - 2025-06-07

### Added

- Tailwind CSS configuration and build instructions for the frontend

## [v0.1.24] - 2025-06-07

### Added

- Black formatter requirement for backend

### Changed

- Setup script upgrades pip and installs updated backend dependencies

## [v0.1.23] - 2025-06-06

### Changed

- `codex_setup.sh` now installs auth dependencies if present

## [v0.1.22] - 2025-06-05

### Added

- Python multipart library requirement for form handling

## [v0.1.21] - 2025-06-05

### Added

- Backend README with install and usage instructions

## [v0.1.19] - 2025-06-05

### Changed

- Updated docker-compose to reference infrastructure Dockerfiles and use port 5173 for the frontend

## [v0.1.20] - 2025-06-05

### Changed

- Backend container now uses `python:3.12-slim`

## [v0.1.18] - 2025-06-05

### Added

- Placeholder values for OAuth and database env vars

## [v0.1.17] - 2025-06-05

### Fixed

- Updated documentation links to reflect new file locations

## [v0.1.16] - 2025-06-04

### Added

- React plugin lockfile regenerated and lint passes

## [v0.1.15] - 2025-06-04

### Added

- Add Vite React plugin to devDependencies

## [v0.1.14] - 2025-06-04

### Changed

- Enable JSX parsing in ESLint config

## [v0.1.13] - 2025-06-04

### Changed

- Security scan scripts now install dependencies with pnpm and run ESLint via pnpm exec

## [v0.1.12] - 2025-06-04

### Changed

- Added missing newlines to documentation files

## [v0.1.11] - 2025-06-04

### Added

- Base TypeScript configuration for the frontend

## [v0.1.10] - 2025-06-04

### Added

- ESLint parser and plugin for TypeScript support in the frontend

## [v0.1.4] - 2025-06-04

### Added

- Quick Start instructions for `codex_setup.sh` in README

## [v0.1.8] - 2025-06-04

### Added

- Frontend Vitest sanity test and npm test script

## [v0.1.9] - 2025-06-04

### Changed

- Relaxed pnpm engine requirement to allow version 10

## [v0.1.7] - 2025-06-04

### Changed

- Emphasized semantic commit message format in contribution docs

## [v0.1.6] - 2025-06-04

### Added

- CONTRIBUTING and merge checklist documentation

## [v0.1.3] - 2025-06-04

### Added

- Initial project scaffold with auth service and frontend boilerplate

## [v0.1.4] - 2025-06-04

### Changed

- Corrected variable name to `ADMINISTRATOR_ROLE_ID` in `.env.example`.

## [v0.1.5] - 2025-06-04

### Added

- Quick Start section in `README.md` for streamlined setup.

All notable changes to this project will be documented in this file.

## [v0.1.1] - 2025-06-03

### Added

- ESLint configuration for frontend

## [v0.1.2] - 2025-06-03

### Added

- Archive guide for creating tar and zip packages

## [v0.1.0] - 2025-05-30

### Added

- Initial TAGS operation alignment plan and supporting documentation
