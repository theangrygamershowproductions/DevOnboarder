# DevOnboarder

![Coverage](coverage.svg)
[![CI](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/ci.yml/badge.svg)](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/ci.yml)
[![Auto Fix](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/auto-fix.yml/badge.svg)](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/auto-fix.yml)

DevOnboarder demonstrates a trunk‑based workflow with Docker‑based services for rapid onboarding.

See [docs/README.md](docs/README.md) for full setup instructions and workflow guidelines.

## 🔧 **Project Statement**

> _"This project wasn’t built to impress — it was built to work. Quietly.
> Reliably. And in service of those who need it."_

_Designed to automate onboarding, reduce friction, and support developers building from the ground up._

## Why This Project Exists

The short version: everything broke, then got rebuilt.
The full recovery story lives in [docs/origin.md](docs/origin.md).

## Trunk-Based Workflow

-   All stable code lives in the `main` branch.
-   Short-lived branches are created off `main` for each change.
-   Changes are merged back into `main` via pull requests after review.
-   Feature branches are deleted after they are merged to keep history clean.

## Directory Overview

- `config/` – Configuration files, including `devonboarder.config.yml`.
- `scripts/` – Helper scripts for bootstrapping and environment setup.
- `.devcontainer/` – Contains `devcontainer.json` which builds the VS Code development container,
  forwards port `3000`, and runs `scripts/setup-env.sh`.
- `archive/docker-compose.dev.yaml` – Archived compose file for local development using `.env.dev`.
- `docker-compose.ci.yaml` – Compose file used by the CI pipeline.
- `archive/docker-compose.prod.yaml` – Archived compose file for production using `.env.prod`.
- `archive/docker-compose.yml` – Archived base compose file for generic deployments.
- `archive/docker-compose.codex.yml` – Archived compose file for Codex runs.
- `archive/docker-compose.override.yaml` – Archived overrides for the base compose file.
- `bot/` – Discord bot written in TypeScript. Provides slash commands like `/verify`, `/dependency_inventory`, and `/qa_checklist`. This bot runs on its own and is not tied to Codex agents or CI workflows.
- `frontend/` – Vite-based React application.
- `auth/` – Environment files for the authentication service.
- `plugins/` – Optional Python packages that extend functionality.
- `config/devonboarder.config.yml` – Config for the `devonboarder` tool.
- `.env.example` – Sample variables shared across services.
- `docs/CHANGELOG.md` – Project history and notable updates.
<!-- markdownlint-disable MD030 -->
<!-- prettier-ignore-start -->

-   `config/` - Configuration files, including `devonboarder.config.yml`.
-   `scripts/` - Helper scripts for bootstrapping and environment setup.
-   `.devcontainer/` - Contains `devcontainer.json` which builds the VS Code development container,
    forwards port `3000`, and runs `scripts/setup-env.sh`.
-   `archive/docker-compose.dev.yaml` - Archived compose file for local development using `.env.dev`.
-   `docker-compose.ci.yaml` - Compose file used by the CI pipeline.
-   `archive/docker-compose.prod.yaml` - Archived compose file for production using `.env.prod`.
-   `archive/docker-compose.yml` - Archived base compose file for generic deployments.
-   `archive/docker-compose.codex.yml` - Archived compose file for Codex runs.
-   `archive/docker-compose.override.yaml` - Archived overrides for the base compose file.
-   `bot/` - Discord bot written in TypeScript. Run `/dependency_inventory` to export dependencies.
-   `frontend/` - Vite-based React application.
-   `auth/` - Environment files for the authentication service.
-   `plugins/` - Optional Python packages that extend functionality.
-   `config/devonboarder.config.yml` - Config for the `devonboarder` tool.
-   `.env.example` - Sample variables shared across services.
-   `docs/CHANGELOG.md` - Project history and notable updates.
    <!-- prettier-ignore-end -->
    <!-- markdownlint-restore -->

## Language Versions

`scripts/setup-env.sh` pulls the `ghcr.io/openai/codex-universal` image to provide a unified runtime.
When Docker isn't available, the script installs Python 3.12 using `mise` or `asdf` before creating a virtual environment.

| Language | Version |
| -------- | ------- |
| Python   | 3.12    |
| Node.js  | 20      |
| Ruby     | 3.4.4   |
| Rust     | 1.87.0  |
| Go       | 1.24.3  |
| Bun      | 1.2.14  |
| Java     | 21      |
| Swift    | 6.1     |

Install the required runtimes with `mise install` (or `asdf install`) to match the versions defined in `.tool-versions`.

## Documentation and Onboarding

Workflow documentation lives under the [docs/](docs/) directory. New contributors should:

1. Read [docs/README.md](docs/README.md) for development tips and setup details.
2. Follow [docs/git-guidelines.md](docs/git-guidelines.md) for branch and commit policies.
3. Use [.github/pull_request_template.md](.github/pull_request_template.md) when opening a pull request.
4. Run `bash scripts/install_commit_msg_hook.sh`
   or see [CONTRIBUTING.md](CONTRIBUTING.md) to install the commit-msg hook.
5. Verify merges with [docs/merge-checklist.md](docs/merge-checklist.md).
6. Track community members in [FOUNDERS.md](FOUNDERS.md) and [ALPHA_TESTERS.md](ALPHA_TESTERS.md).
7. Update all relevant READMEs when new roles are added to the GitHub organization.
8. Review [docs/alpha/README.md](docs/alpha/README.md) if you are an early tester.
9. See [docs/founders/README.md](docs/founders/README.md) for Founder's Circle guidelines.
10. Follow our [emails/style-guide.md](emails/style-guide.md) when crafting invitations.
11. Review our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) to learn our community expectations.
12. Check [docs/sample-pr.md](docs/sample-pr.md) for a small example update.
13. Review [docs/first-pr-guide.md](docs/first-pr-guide.md) for a full pull request walkthrough.
14. View the [docs/architecture.svg](docs/architecture.svg) diagram for an overview of our services.
15. Run `./scripts/check_docs.sh` to lint documentation with **Vale**.
    - The script automatically downloads Vale if it isn’t installed and
      prints a warning if the download fails. See
      [docs/README.md#documentation-quality-checks](docs/README.md#documentation-quality-checks)
      for more details.
    - LanguageTool checks are optional; start a local server and set
      `LANGUAGETOOL_URL` to enable them.
16. Install the Vale CLI (version 3.12.0+) with `brew install vale` on macOS or
    `choco install vale` on Windows. You can also download it from the
    [Vale releases page](https://github.com/errata-ai/vale/releases).
    If the binary isn't in your `PATH`, set the `VALE_BINARY` environment variable
    and install Python dependencies from `requirements-dev.txt` so the
    documentation checks work locally.
17. Browse the [agents overview](agents/index.md) for individual service specs.
    Codex reads the machine‑readable list in `codex/agents/index.json` to
    coordinate automation across these agents.
18. Review [.codex/Agents.md](.codex/Agents.md) for agent YAML header requirements and centralized notifications.
19. See [docs/ONBOARDING.md#sending-notifications](docs/ONBOARDING.md#sending-notifications) for how to send human updates.
20. Keep the sentinel word `Potato` and the file `Potato.md` listed in `.gitignore`,
    `.dockerignore`, and `.codespell-ignore`.
    See [AGENTS.md](AGENTS.md) for the full policy. Both pre-commit and CI run `scripts/check_potato_ignore.sh`
    to confirm the entries exist. Do not remove them without approval.
21. Review the [builder ethics dossier](docs/builder_ethics_dossier.md)
    outlining contributor ethics and a simple template.
22. Prefix a commit message with `[no-ci]` to skip the CI workflow on direct pushes. Pull requests always run CI. See
    [AGENTS.md](AGENTS.md) for details.
23. See [docs/network-exception-list.md](docs/network-exception-list.md)
    for required firewall domains. Run
    `scripts/show_network_exceptions.sh` to print them.
24. See [docs/ci-failure-issues.md](docs/ci-failure-issues.md)
    if CI automation fails to create or close `ci-failure` issues.
25. Review [docs/assessments/engineer_assessment_work_items.md](docs/assessments/engineer_assessment_work_items.md)
    and open an issue with the
    [Engineer Assessment template](.github/ISSUE_TEMPLATE/assessment.md)
    during onboarding reviews to ensure new features meet the checklist.
26. Read [docs/ecosystem.md](docs/ecosystem.md) for an overview of how the
    services interact inside the TAGS stack.
27. See [docs/tags_integration.md](docs/tags_integration.md) for TAGS setup
    steps and feature flag usage.

28. Review [docs/checklists/continuous-improvement.md](docs/checklists/continuous-improvement.md) for periodic retrospective tasks.

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
The `frontend/` directory hosts a Vite-based React app.
Run `npm install` (or `pnpm install`) in that folder to install dependencies,
commit the generated lockfile, and then start the development server with `npm run dev`:

```bash
docker compose -f archive/docker-compose.dev.yaml --env-file .env.dev up
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

To link Discord accounts and fetch roles separately, run:

```bash
devonboarder-integration
```

This service listens on `http://localhost:8081`.

The CI pipeline uses `docker-compose.ci.yaml` to start the Postgres database during tests.
Workflows rely on the preinstalled GitHub CLI or the `ksivamuthu/actions-setup-gh-cli` action.

## Codex Runs

Codex uses its own compose file. Export your credentials and start the runner:

```bash
GITHUB_TOKEN=<token> OPENAI_API_KEY=<key> \
  docker compose -f archive/docker-compose.codex.yml up
```

The container reads `codex.ci.yml` and `codex.automation.bundle.json` from the
project root.

## Plugins

The package automatically loads modules found under the top-level `plugins/`
directory. Each plugin lives in its own subfolder with an `__init__.py` file.
Importing :mod:`devonboarder` populates `devonboarder.PLUGINS` with the
discovered modules. Enable a plugin by adding a new package under
`plugins/` and providing any initialization logic in its `register`
function.

## Production Deployment

Deploy the production stack with the dedicated compose file and `.env.prod`:

```bash
docker compose -f archive/docker-compose.prod.yaml --env-file .env.prod up -d
```

## Quickstart

1. Install Docker and Docker Compose. Run `mise install` to install the Python and Node.js versions defined in `.tool-versions`.
2. Run `bash scripts/bootstrap.sh` to create `.env.dev` and install dependencies.
   The script installs the frontend and bot packages so `npm ci --prefix bot` and
   `npm ci --prefix frontend` are only needed if you skip this step.
   For a manual setup, run `bash scripts/dev_setup.sh` to install Python and Node
   dependencies and set up pre-commit hooks.
3. Run `bash scripts/generate-secrets.sh` so `.env.dev` matches the secrets CI uses.
4. Copy each `*.env.example` to `.env` inside its service directory.
5. Build the containers with `make deps` and start them with `make up`.
6. Apply database migrations using `bash scripts/run_migrations.sh`.
7. Run `python -m diagnostics` to verify required packages load, services are
   healthy, and environment variables match the examples.
8. Install the project **before** running tests. Use editable mode so `pytest` can import the `devonboarder` package.
   Install Node.js packages with `npm ci` in each subdirectory:

    ```bash
    pip install -e .  # or `pip install -r requirements.txt` if present
    pip install -r requirements-dev.txt
    ruff check .
    pytest --cov=src --cov-fail-under=95
    npm ci --prefix bot && npm run coverage --prefix bot
    npm ci --prefix frontend && npm run coverage --prefix frontend
    ```

    Set `OFFLINE_BADGE=1` if `img.shields.io` is unreachable to skip the badge
    update.
    **Note:** both installs must finish before running `pytest` or the tests may
    fail with `ModuleNotFoundError`. See
    [tests/README.md](tests/README.md) for details.

9. Run `./scripts/run_tests.sh` to install dependencies and execute all tests.
   This wrapper prints helpful hints when packages are missing. See
   [docs/troubleshooting.md](docs/troubleshooting.md) if any failures occur.
10. Install git hooks with `pre-commit install` so lint checks run automatically.
11. The CI workflow enforces a minimum of **95% code coverage** for all projects
    (frontend, bot, and backend). Pull requests will fail if any test suite drops
    below this threshold.

Licensed under the MIT License. See `LICENSE.md` for details.

## Found DevOnboarder useful?

If this project helped speed up onboarding, save time, or avoid headaches,
please [⭐ star the repo](https://github.com/theangrygamershowproductions/DevOnboarder)
or [open an issue](https://github.com/theangrygamershowproductions/DevOnboarder/issues)
with your feedback. Your input directly shapes future improvements.

## License

This project is licensed under the MIT License. See LICENSE.md.
