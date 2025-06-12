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
<!-- PATCHED v0.1.60 docs/CHANGELOG.md — add infrastructure blueprints entry -->
<!-- markdownlint-disable MD022 MD032 MD024 MD025 -->

<!--
Project: DevOnboarder
File: CHANGELOG.md
Purpose: Record notable changes to the project
Updated: 08 Jun 2025 00:00 (EST)
Version: v0.1.12
-->

# Changelog

All notable changes to this project will be documented in this file.
## [v0.1.9] - 2025-06-05
### Added
- Implemented JWT login and user endpoints

## [v0.1.8] - 2025-06-05
### Added
- Shared pre-commit hook to run formatters and tests
## [v0.1.7] - 2025-06-04
### Added
- Initial CI workflow using Node 22 and pnpm 10
## [v0.1.5] - 2025-06-04
### Added
- Documented Node and pnpm version requirements

## [v0.1.6] - 2025-06-04
### Changed
- Updated pnpm instructions to use version 10

## [v0.1.4] - 2025-06-04
### Added
- Expanded CONTRIBUTING and MERGE_CHECKLIST guides

## [v0.1.3] - 2025-06-04
### Added
- Quick Start notes on `scripts/codex_setup.sh` in README.

## [v0.1.1] - 2025-06-03
### Added
- ESLint configuration for frontend

## [v0.1.2] - 2025-06-03
### Added
- Archive guide for creating tar and zip packages

## [v0.1.0] - 2025-05-30
### Added
- Initial TAGS operation alignment plan and supporting documentation
## [v0.1.10] - 2025-06-07
### Added
- Database model and endpoints for verification tracking
- Documentation for verification schema

## [v0.1.11] - 2025-06-08
### Added
- Admin routes for user and verification management
- React admin components for role and verification tools

## [v0.1.12] - 2025-06-08
### Added
- Pydantic-based environment validation loaded on app startup
- Documentation for required environment variables
- Tests ensuring missing variables raise validation errors

## [v0.1.13] - 2025-06-08
### Added
- Discord bot skeleton under `discord-bot/` with Docker support
- Updated commander README with build and run instructions

## [v0.1.14] - 2025-06-08
### Changed
- CONTRIBUTING guide notes running `scripts/codex_setup.sh` before `pytest`

## [v0.1.15] - 2025-06-08
### Changed
- codex_setup.sh instructs to activate venv
- README notes to source venv before tests

## [v0.1.16] - 2025-06-08
### Changed
- create-env generates `.env.development`
## [v0.1.17] - 2025-06-08
### Added
- docker-compose.dev.yaml development stack

## [v0.1.18] - 2025-06-15
### Added
- .env.development defaults; create-env now generates it

## [v0.1.19] - 2025-07-21
### Added
- setup-dev.sh installs pre-commit automatically
- README and Development-Setup mention the automatic install

## [v0.1.20] - 2025-07-22
### Removed
- Potato.md symlink and snapshot entry

## [v0.1.21] - 2025-07-23
### Added
- .gitignore rule for stray Potato files

## [v0.1.22] - 2025-07-24
### Added
- README notes commit message format

## [v0.1.23] - 2025-08-14
### Changed
- Git standards document includes a patch header example

## [v0.1.24] - 2025-08-15
### Changed
- Development-Setup and backend README note SQLAlchemy in requirements

## [v0.1.25] - 2025-08-18
### Added
- CODEX_JOURNAL_DIR variable documented and included in env templates

## [v0.1.26] - 2025-08-20
### Added
- Manifest listing key modules with architecture and integration links

## [v0.1.27] - 2025-08-25
### Changed
- Development-Setup and README mention `pip install -r requirements-dev.txt`

## [v0.1.28] - 2025-08-25
### Added
- GitHub funding file with EVM-only wallet disclaimer

## [v0.1.29] - 2025-08-26
### Changed
- Manifest refreshed with module summary and integration links

## [v0.1.30] - 2025-08-26
### Added
- Documentation for Snyk token configuration and CI security scan notes

## [v0.1.31] - 2025-08-30
### Added
- Traefik section on acme.json, DNS records, and health checks

## [v0.1.32] - 2025-09-03
### Changed
- Development and testing docs instruct running `pnpm install` in `auth-server/`
  and note that **ts-node** is required for Node-based tests

## [v0.1.33] - 2025-09-05
### Changed
- `.gitignore` now excludes `acme.json`; remove tracked file and update docs

## [v0.1.34] - 2025-09-07
### Changed
- Testing and development docs clarify `ts-node` must be in `$PATH` and
  describe installing it globally when a local install is not detected

## [v0.1.35] - 2025-09-08
### Changed
- Pre-commit and CI now enforce 85% test coverage

## [v0.1.36] - 2025-09-10
### Added
- Instructions for starting Redis in Development-Setup

## [v0.1.37] - 2025-09-15
### Added
- Initial Aurora and Laramie blueprints under infrastructure
- TAGS Auth pivot diagram in case studies
