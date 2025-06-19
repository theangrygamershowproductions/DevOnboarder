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
  - `docker-compose.dev.yaml` – Compose file for local development using `.env.dev`.
  - `docker-compose.ci.yaml` – Compose file used by the CI pipeline.
  - `docker-compose.prod.yaml` – Compose file for production using `.env.prod`.
  - `docker-compose.yml` – Base compose file for generic deployments.
  - `docker-compose.codex.yml` – Compose file used when running in Codex.
  - `docker-compose.override.yaml` – Overrides for the base compose file.
- `bot/` – Discord bot written in TypeScript.
- `config/devonboarder.config.yml` – Config for the `devonboarder` tool.
- `.env.example` – Sample environment variables for local development.

## Documentation and Onboarding

Workflow documentation lives under the [docs/](docs/) directory. New contributors should:

1. Read [docs/README.md](docs/README.md) for development tips and setup details.
2. Follow [docs/git-guidelines.md](docs/git-guidelines.md) for branch and commit policies.
3. Use [docs/pull_request_template.md](docs/pull_request_template.md) when opening a pull request.
4. Verify merges with [docs/merge-checklist.md](docs/merge-checklist.md).
5. Track community members in [FOUNDERS.md](FOUNDERS.md) and [ALPHA_TESTERS.md](ALPHA_TESTERS.md).
6. Review [docs/alpha/README.md](docs/alpha/README.md) if you are an early tester.
7. See [docs/founders/README.md](docs/founders/README.md) for Founder's Circle guidelines.
8. Follow our [emails/style-guide.md](emails/style-guide.md) when crafting invitations.

These files expand on the steps listed in the Quickstart section.

## Local Development

Build the development container defined in `.devcontainer/devcontainer.json`:

```bash
devcontainer dev --workspace-folder . --config .devcontainer/devcontainer.json
```

Alternatively, you can run the Docker Compose setup directly.
This starts the auth, bot, XP API, frontend, and database services using
environment variables from `.env.dev`:

```bash
docker compose -f docker-compose.dev.yaml --env-file .env.dev up
```

To experiment with the user-facing API outside Docker, run:

```bash
devonboarder-api
```

The API server listens on `http://localhost:8001`.
Test the endpoints with:

```bash
curl http://localhost:8001/api/user/onboarding-status
curl http://localhost:8001/api/user/level
```

For authentication and user management, run:

```bash
devonboarder-auth
```

The auth service listens on `http://localhost:8002`.

The CI pipeline uses `docker-compose.ci.yaml` to start the Postgres database during tests.

## Codex Runs

Codex uses its own compose file. To invoke it manually:

```bash
docker compose -f docker-compose.codex.yml up
```

## Production Deployment

Deploy the production stack with the dedicated compose file and `.env.prod`:

```bash
docker compose -f docker-compose.prod.yaml --env-file .env.prod up -d
```

## Quickstart
1. Run `bash scripts/bootstrap.sh` to copy `.env.example` to `.env.dev` and install dependencies.
2. Install the project with `pip install -e .`.
3. Start the services with `docker compose -f docker-compose.dev.yaml --env-file .env.dev up -d`.
   The services launch using the commands defined in the compose file.
4. Run `alembic upgrade head` to create the initial tables.
5. Execute the tests using `pytest -q`.

## License
This project is licensed under the MIT License. See LICENSE.md.

