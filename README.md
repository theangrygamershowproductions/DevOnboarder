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
- `.devcontainer/` – Contains `devcontainer.json` which builds the VS Code
  development container, forwards port `3000`, and runs `scripts/setup-env.sh`.
- `docker-compose.yml` – Base compose file for production deployments.
- `docker-compose.dev.yaml` – Compose file for local development.
  Includes a Redis service exposed on port `6379`.
- `docker-compose.codex.yml` – Compose file used when running in Codex.
- `docker-compose.override.yaml` – Overrides for the base compose file.
- `config/devonboarder.config.yml` – Config for the `devonboarder` tool.
- `.env.example` – Sample environment variables for local development.

## Documentation and Onboarding

Workflow documentation lives under the [docs/](docs/) directory. New contributors should:

1. Read [docs/README.md](docs/README.md) for development tips and setup details.
2. Follow [docs/git-guidelines.md](docs/git-guidelines.md) for branch and commit policies.
3. Use [docs/pull_request_template.md](docs/pull_request_template.md) when opening a pull request.
4. Verify merges with [docs/merge-checklist.md](docs/merge-checklist.md).
5. Track community members in [FOUNDERS.md](FOUNDERS.md) and [ALPHA_TESTERS.md](ALPHA_TESTERS.md).

These files expand on the steps listed in the Quickstart section.

## Local Development

Build the development container defined in `.devcontainer/devcontainer.json`:

```bash
devcontainer dev --workspace-folder . --config .devcontainer/devcontainer.json
```

Alternatively, you can run the Docker Compose setup directly.
This will start the application (executed via `python -m devonboarder.server`)
along with a Redis container on port `6379`:

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
1. Run `bash scripts/bootstrap.sh` to copy `.env.example` to `.env.dev` and install dependencies.
2. Install the project with `pip install -e .`.
3. Start the services with `docker compose -f docker-compose.dev.yaml up -d`.
   The app container launches via `python -m devonboarder.server`.
4. Execute the tests using `pytest -q`.

## License
This project is licensed under the MIT License. See LICENSE.md.

