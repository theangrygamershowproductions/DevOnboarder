# DevOnboarder

DevOnboarder demonstrates a trunk‑based workflow with Docker‑based services for rapid onboarding.

See [docs/README.md](docs/README.md) for full setup instructions and workflow guidelines.

## Quickstart

1. Install Docker, Docker Compose, Node.js 22, and Python 3.13.
2. Run `bash scripts/bootstrap.sh` to create `.env.dev` and install dependencies.
3. Copy each `*.env.example` to `.env` inside its service directory.
4. Build the containers with `make deps` and start them with `make up`.
5. Apply database migrations using `bash scripts/run_migrations.sh`.
6. Verify changes with `ruff check .`, `pytest -q`, and `npm test` from `bot/`.

Licensed under the MIT License. See `LICENSE.md` for details.
