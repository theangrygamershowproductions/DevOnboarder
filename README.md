# DevOnboarder

This repository showcases a **trunk‑based** workflow and a minimal container setup used by Codex.

## Trunk-Based Workflow

- All stable code lives in the `main` branch.
- Short-lived branches are created off `main` for each change.
- Changes are merged back into `main` via pull requests after review.
- Feature branches are deleted after they are merged to keep history clean.

## Directory Overview

- `config/` – Optional configuration files. Empty by default.
- `scripts/` – Helper scripts for bootstrapping and environment setup.
- `.devcontainer/` – Holds dev container configuration (tracked with `.gitkeep`).
- `docker-compose.yml` – Base compose file for production deployments.
- `docker-compose.dev.yaml` – Compose file used for local development.
- `docker-compose.codex.yml` – Compose file used when running in Codex.
- `docker-compose.override.yaml` – Overrides applied on top of the base compose file.
- `devonboarder.config.yml` – Configuration file consumed by the `devonboarder` tool.

## Local Development

Build and start the development container defined in `devcontainer.dev.json`:

```bash
devcontainer dev --workspace-folder . --config devcontainer.dev.json
```

Alternatively, you can run the Docker Compose setup directly:

```bash
docker compose -f docker-compose.dev.yaml up
```

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
