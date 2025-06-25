# DevOnboarder

This repository showcases a **trunk-based** workflow and a minimal
container setup used by Codex.

### 🔧 **Project Statement**

> *"This project wasn’t built to impress — it was built to work. Quietly. Reliably. And in service of those who need it."*

*Designed to automate onboarding, reduce friction, and support developers building from the ground up.*


## Trunk-Based Workflow

- All stable code lives in the `main` branch.
- Short-lived branches are created off `main` for each change.
- Changes are merged back into `main` via pull requests after review.
- Feature branches are deleted after they are merged to keep history clean.

## Directory Overview

- `config/` – Configuration files, including `devonboarder.config.yml`.
- `scripts/` – Helper scripts for bootstrapping and environment setup.
- `.devcontainer/` – Contains `devcontainer.json` which builds the VS Code development container, forwards port `3000`, and runs `scripts/setup-env.sh`.
- `docker-compose.dev.yaml` – Compose file for local development using `.env.dev`.
- `docker-compose.ci.yaml` – Compose file used by the CI pipeline.
- `docker-compose.prod.yaml` – Compose file for production using `.env.prod`.
- `docker-compose.yml` – Base compose file for generic deployments.
- `docker-compose.codex.yml` – Compose file used when running in Codex.
- `docker-compose.override.yaml` – Overrides for the base compose file.
- `bot/` – Discord bot written in TypeScript.
- `frontend/` – Vite-based React application.
- `auth/` – Environment files for the authentication service.
- `xp/` – Environment files for the XP API.
- `config/devonboarder.config.yml` – Config for the `devonboarder` tool.
- `.env.example` – Sample variables shared across services.

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
9. Check [docs/sample-pr.md](docs/sample-pr.md) for a small example update.
10. Run `./scripts/check_docs.sh` to lint documentation with Vale and
    LanguageTool. Set `LANGUAGETOOL_URL` if you use a local LanguageTool
    server.
11. Install Vale with `brew install vale` (or see the [Vale installation docs](https://vale.sh/docs/installation/))
    and install Python dependencies from `requirements-dev.txt` so the
    documentation checks work locally.

These files expand on the steps listed in the Quickstart section.

## Local Development

Build the development container defined in `.devcontainer/devcontainer.json`:

```bash
devcontainer dev --workspace-folder . --config .devcontainer/devcontainer.json
```

Alternatively, you can run the Docker Compose setup directly.
This starts the auth, bot, XP API, frontend, and database services using
environment variables from `.env.dev`.
Copy each `*.env.example` to `.env` inside its service directory before starting.
The `frontend/` directory hosts a Vite-based React app. Run `npm install` (or `pnpm install`) in that folder to install dependencies, commit the generated lockfile, and then start the development server with `npm run dev`:

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
First install Docker, Docker Compose, Node.js 22, and Python 3.13. See [docs/ubuntu-setup.md](docs/ubuntu-setup.md) for the Ubuntu commands.
1. Run `bash scripts/bootstrap.sh` to copy `.env.example` to `.env.dev` and install dependencies.
2. Copy each service example file to `.env`:
   `cp auth/.env.example auth/.env`
   `cp bot/.env.example bot/.env`
   `cp xp/.env.example xp/.env`
   `cp frontend/src/.env.example frontend/.env`
3. Install the project with `pip install -e .`.
   Install development tools with `pip install -r requirements-dev.txt`.
4. Build the containers with `make deps`.
5. Start the services with `make up` or run
   `docker compose -f docker-compose.dev.yaml --env-file .env.dev up -d`.
   The services launch using the commands defined in the compose file.
6. Run `bash scripts/run_migrations.sh` to create the initial tables.
7. Execute the tests using `pytest -q`.
   If `pytest` is not available, first run `pip install -r requirements-dev.txt`.
   You can also run `make test` to install missing dependencies automatically.

## License
This project is licensed under the MIT License. See LICENSE.md.

