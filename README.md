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
<!-- PATCHED v0.2.35 README.md — reference new blueprints and diagram -->
<!-- markdownlint-disable MD025 -->

# DevOnboarder

[![CI](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/ci.yaml/badge.svg)](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/ci.yaml)
[![License](https://img.shields.io/github/license/theangrygamershowproductions/DevOnboarder?color=blue)](./LICENSE)
[![Python](https://img.shields.io/badge/python-3.13-blue)](./scripts/versions.sh)

DevOnboarder is an internal onboarding and training platform designed
to accelerate the ramp-up of contributors to TAG Projects, ASoS Gaming,
and associated branches.
It delivers real-world coding challenges, interactive tutorials,
and role-based progression using Codex AI assistance and GitHub integration.

## Documentation

- [TAGS Operation Alignment Plan](./docs/TAGS-Operation-Alignment-Plan.md)
- [Git Standards](./docs/Git.md)
- Commit messages use `<type>(<scope>): <subject>` format
- [PR Template](./docs/TAGS-PR-Template.md)
- [Change Log](./docs/CHANGELOG.md)
- [Archive Guide](./docs/Archive-Guide.md)
- [Submodule Integration Guide](./docs/integration/submodule.md)
- [Codex Coding Guidelines](./docs/Codex%20Coding%20Guidelines.md)
- 🤖 [Automation & Agents Overview](./docs/AGENTS.md)
- [Security Policy](./.github/SECURITY.md)
- [Code of Conduct](./CODE_OF_CONDUCT.md)
- [Stack Overview](./docs/Stack.md)
- [Project Structure](./docs/Structure.md)
- [Roadmap](./docs/TAG-Roadmap.v1.2.md)
- [Project Scope and Timeline](./docs/Project_Scope_and_Timeline.md)
- [Aurora Blueprint](docs/infrastructure/blueprints/Aurora-Blueprint.md)
- [Laramie Blueprint](docs/infrastructure/blueprints/Laramie-Blueprint.md)
- [Contributing Guide](./docs/CONTRIBUTING.md)
- [Development Setup](./docs/Development-Setup.md)
- [Frontend Auth Flow](./docs/frontend/frontend-auth-flow.md)
- [User Role Matrix](./docs/auth/User_Role_Matrix.md)
- [Session Role Guide](./docs/frontend/frontend-session-role-guide.md)
- [Security Policies](./docs/internal/TAGS-Secrets-Security-Policy.md)
- [Threat Model](./docs/auth/security/threat-model.md)
- [Penetration Test Plan](./docs/auth/security/penetration-test-plan.md)
- [TAGS Auth Pivot Diagram](docs/case-studies/TAGS-Auth-Pivot.drawio.svg)
- [Codex Challenges](./challenges/)
- [Codex Rubrics](./rubrics/)
- [Codex Submissions](./submissions/)
- [Codex Evaluation Script](./codex/evaluate.py)
  — includes rubric scoring summary
- [Codex Journal](./codex/journal/) — CLI and automation logs.
- [Environment Setup Script](./scripts/setup-env.sh)
- [Developer Setup Script](./scripts/setup-dev.sh)
- [VS Code Integrations](./.vscode-integrations/README.md)
- [Security Scan Script](./scripts/run-all-scans.sh)

See docs/Codex Coding Guidelines.md for mandatory style rules.

## Environment Setup

Run the CI or Codex environment bootstrap script:

```bash
bash scripts/setup-env.sh
```

For local development use:

```bash
bash scripts/setup-dev.sh
```

Both scripts source the same runtime versions from `scripts/versions.sh`.

### VS Code Devcontainer

A `.devcontainer/Dockerfile` extends the **Node.js 22** image and installs
`python3.11-venv`. `devcontainer.json` builds from this file and runs
`scripts/setup-dev.sh`
automatically. Install the Dev Containers
extension and choose **Reopen in Container** to launch this setup.

## Quick Start

Ensure **Node.js 22** and **Python 3.13** are installed or use the provided
devcontainer.

Generate a development environment file and update values for local testing:

```bash
./scripts/create-env.sh
# edit .env.development to match your local settings
```

Both services read from `.env.development`.

`CODEX_JOURNAL_DIR=codex/journal` in this file controls where the CLI writes
journal logs.
Automation steps also append entries to this folder.

Bootstrap the development environment by running:

```bash
./scripts/setup-dev.sh
```

The script now installs `pre-commit` automatically and cleans up stale
virtual environments if needed. Automated Codex environments might not
include these dependencies, so always run the script before executing
hooks.
source venv/bin/activate  # activate before running tests
pre-commit install        # ensure hooks run with the environment prepared
pre-commit run --all-files # run hooks manually once

Before installing frontend dependencies, enable Corepack and activate pnpm 10:

```bash
corepack enable
corepack prepare pnpm@10 --activate
```

Alternatively, create a Python virtual environment and install the Python
dependencies manually:

```bash
python3 -m venv venv
source venv/bin/activate
python -m pip install --requirement requirements-dev.txt
```

`requirements-dev.txt` bundles backend and auth dependencies.

Start both services with Docker Compose via the Makefile target:

```bash
make dev-docker
```

This command loads `docker-compose.override.yaml`
for live-reload volume mounts.

For the full development stack including Traefik and debug utilities:

```bash
make dev-stack
```

This uses `docker-compose.dev.yaml` to start all services in detached mode.

Run security scans locally:

```bash
bash scripts/run-all-scans.sh
```

## DevOnboarder ⇢ OpenAI rollout

The Codex OpenAI workflow is optional but provides automated code generation
for supported modules.
Populate your `.env.development` file before enabling the workflow.
This file is the single source of truth for all environment values.

| Step | Action | Result |
| ---- | ------ | ------ |
| 1 | Run `./scripts/create-env.sh` | Generates env file from example |
| 2 | Edit `.env.development` | Add `OPENAI_API_KEY` and verify values |
| 3 | Execute `./scripts/setup-dev.sh` | Installs deps and loads the env |

### Running Tests

Ensure dependencies are installed via `./scripts/setup-dev.sh`
before running tests. If you skip the script, install them manually:

```bash
python -m pip install --requirement requirements-dev.txt
```

```bash
pytest -q
pnpm --dir frontend test:unit
```

## CI/CD Workflow

The repository uses GitHub Actions to automate linting, testing, and security
checks. The primary workflow (`ci.yaml`) runs on pushes and pull requests and:

1. Sets up pnpm 10.11.1 via `pnpm/action-setup` before Node.js for caching.
2. Installs Python 3.13 dependencies for the backend and auth services.
3. Executes `pnpm lint` and `pnpm test:unit` for frontend code.
4. Runs `pytest` for backend code.

Separate workflows perform security scans (`security-scan.yml`), weekly pnpm
upgrades, and CodeQL analysis with on-chain verification.

## Project Structure

- `auth/` — FastAPI authentication service
- `frontend/` — React application
- `infrastructure/` — Deployment configuration
- `docker/` — Container definitions
- `shared/` — Shared utilities and components
- `api1/` — Placeholder for future API
- `api2/` — Placeholder for future API
- `challenges/` — Codex challenges
- `rubrics/` — Scoring guides
- `submissions/` — User submissions
- `tests/` — Automated tests

## Funding

Support the project via GitHub Sponsors. Donations are accepted on
**EVM-compatible networks only**: Ethereum, Base, Polygon, Avalanche,
Arbitrum, and BNB Smart Chain. See `.github/FUNDING.yml` for the current
sponsor handle and wallet address.
