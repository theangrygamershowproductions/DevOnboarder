# DevOnboarder

DevOnboarder demonstrates a trunk‑based workflow with Docker‑based services for rapid onboarding.

See [docs/README.md](docs/README.md) for full setup instructions and workflow guidelines.

## 🔧 **Project Statement**

> *"This project wasn’t built to impress — it was built to work. Quietly. Reliably. And in service of those who need it."*

*Designed to automate onboarding, reduce friction, and support developers building from the ground up.*

## Why This Project Exists

The short version: everything broke, then got rebuilt. The full recovery story lives in [docs/origin.md](docs/origin.md).

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
- `config/devonboarder.config.yml` – Config for the `devonboarder` tool.
- `.env.example` – Sample variables shared across services.

## Documentation and Onboarding

Workflow documentation lives under the [docs/](docs/) directory. New contributors should:

1. Read [docs/README.md](docs/README.md) for development tips and setup details.
2. Follow [docs/git-guidelines.md](docs/git-guidelines.md) for branch and commit policies.
3. Use [docs/pull_request_template.md](docs/pull_request_template.md) when opening a pull request.
4. Run `bash scripts/install_commit_msg_hook.sh` or see [CONTRIBUTING.md](CONTRIBUTING.md) to install the commit-msg hook.
5. Verify merges with [docs/merge-checklist.md](docs/merge-checklist.md).
6. Track community members in [FOUNDERS.md](FOUNDERS.md) and [ALPHA_TESTERS.md](ALPHA_TESTERS.md).
7. Update all relevant READMEs when new roles are added to the GitHub organization.
8. Review [docs/alpha/README.md](docs/alpha/README.md) if you are an early tester.
9. See [docs/founders/README.md](docs/founders/README.md) for Founder's Circle guidelines.
10. Follow our [emails/style-guide.md](emails/style-guide.md) when crafting invitations.
11. Check [docs/sample-pr.md](docs/sample-pr.md) for a small example update.
12. Run `./scripts/check_docs.sh` to lint documentation with **Vale**.
    The script tries to download Vale automatically when it isn't
    available in your `PATH`. If that download fails, it prints a
    warning and exits without failing.
    LanguageTool checks are optional; start a local server and set
    `LANGUAGETOOL_URL` to enable them.
13. Install the Vale CLI (version 3.12.0+) with `brew install vale` on macOS or
    `choco install vale` on Windows. You can also download it from the
    [Vale releases page](https://github.com/errata-ai/vale/releases).
    If the binary isn't in your `PATH`, set the `VALE_BINARY` environment variable
    and install Python dependencies from `requirements-dev.txt` so the
    documentation checks work locally.
14. Browse the [agents overview](agents/index.md) for individual service specs.
15. Keep the sentinel word `Potato` and the file `Potato.md` listed in `.gitignore`, `.dockerignore`, and `.codespell-ignore`.
    See [AGENTS.md](AGENTS.md) for the full policy. Both pre-commit and CI run `scripts/check_potato_ignore.sh`
    to confirm the entries exist. Do not remove them without approval.
16. Review the [builder ethics dossier](docs/builder_ethics_dossier.md) outlining contributor ethics and a simple template.

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
Workflows rely on the preinstalled GitHub CLI or run `./scripts/install_gh_cli.sh`.

## Codex Runs

Codex uses its own compose file. Export your credentials and start the runner:

```bash
GITHUB_TOKEN=<token> OPENAI_API_KEY=<key> \
  docker compose -f docker-compose.codex.yml up
```

The container reads `codex.ci.yml` and `codex.automation.bundle.json` from the
project root.

## Production Deployment

Deploy the production stack with the dedicated compose file and `.env.prod`:

```bash
docker compose -f docker-compose.prod.yaml --env-file .env.prod up -d
```

## Quickstart

1. Install Docker, Docker Compose, Node.js 20, and Python 3.12.
2. Run `bash scripts/bootstrap.sh` to create `.env.dev` and install dependencies.
   The script installs the frontend and bot packages so `npm ci --prefix bot` is
   only needed if you skip this step.
3. Run `bash scripts/generate-secrets.sh` so `.env.dev` matches the secrets CI uses.
4. Copy each `*.env.example` to `.env` inside its service directory.
5. Build the containers with `make deps` and start them with `make up`.
6. Apply database migrations using `bash scripts/run_migrations.sh`.
7. Install the project and dev requirements, then run the tests:

   ```bash
   pip install -e .  # or `pip install -r requirements.txt` if present
   pip install -r requirements-dev.txt
   ruff check .
   pytest --cov=src --cov-fail-under=95
   npm run coverage --prefix bot
   npm run coverage --prefix frontend
   ```
8. Install git hooks with `pre-commit install` so lint checks run automatically.
9. The CI workflow enforces a minimum of **95% code coverage** for all projects (frontend, bot, and backend). Pull requests will fail if any test suite drops below this threshold.

Licensed under the MIT License. See `LICENSE.md` for details.

## Found DevOnboarder useful?
If this project helped speed up onboarding, save time, or avoid headaches, please [⭐ star the repo](#) or [open an issue](#) with your feedback. Your input directly shapes future improvements.

## License

This project is licensed under the MIT License. See LICENSE.md.
