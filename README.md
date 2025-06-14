# DevOnboarder

This repository showcases a **trunk-based** workflow and a minimal
container setup used by Codex.

## Trunk-Based Workflow

- All stable code lives in the `main` branch.
- Short-lived branches are created off `main` for each change.
- Changes are merged back into `main` via pull requests after review.
- Feature branches are deleted after they are merged to keep history clean.

## Directory Overview

- `config/` – Configuration files, including `devonboarder.config.yml`.
- `scripts/` – Helper scripts for bootstrapping and environment setup.
- `.devcontainer/` – Dev container configuration (tracked with `.gitkeep`).
- `docker-compose.yml` – Base compose file for production deployments.
- `docker-compose.dev.yaml` – Compose file for local development.
  Includes a Redis service exposed on port `6379`.
- `docker-compose.codex.yml` – Compose file used when running in Codex.
- `docker-compose.override.yaml` – Overrides for the base compose file.
- `config/devonboarder.config.yml` – Config for the `devonboarder` tool.

## Local Development

Build the development container defined in `.devcontainer/devcontainer.json`:

```bash
devcontainer dev --workspace-folder . --config .devcontainer/devcontainer.json
```

Alternatively, you can run the Docker Compose setup directly.
This will start the
application along with a Redis container on port `6379`:

```bash
docker compose -f docker-compose.dev.yaml up
```

The CI pipeline also relies on this compose file to start Redis during tests.

## Codex Runs

Codex uses its own compose file. To invoke it manually:

```bash
docker compose -f docker-compose.codex.yml up
```

## Production Deployment

Use the main compose file (with overrides) to deploy the application:

```bash
docker compose -f docker-compose.yml -f docker-compose.override.yaml up -d
```

## Quickstart
1. cp .env.example .env.dev
2. bash scripts/setup-env.sh
3. docker-compose -f docker-compose.dev.yaml up -d
4. pytest -q

## License
This project is licensed under the MIT License. See LICENSE.md.

