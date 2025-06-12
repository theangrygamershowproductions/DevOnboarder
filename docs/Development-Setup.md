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
<!-- PATCHED v0.2.33 docs/Development-Setup.md — local Redis note -->
<!-- markdownlint-disable MD013 MD031 -->

<!--
Project: DevOnboarder
File: Development-Setup.md
Purpose: Basic environment setup instructions
Updated: 21 Jul 2025
Version: v1.1.0
-->

# Development Setup

Follow these steps to prepare a local development environment.

## Node.js and pnpm

This project requires **Node.js 22** and pnpm **10**.
Use Corepack to install and activate the correct pnpm version:

```bash
corepack enable
corepack prepare pnpm@10 --activate
```

## VS Code Devcontainer

A preconfigured devcontainer provides **Node.js 22** with **Python 3.13**.
It runs `scripts/setup-dev.sh` automatically to install dependencies.
Open the repository in VS Code, press **F1**, and choose
**Dev Containers: Reopen in Container** to build the environment.

Install frontend dependencies from the `frontend/` directory:

```bash
cd frontend
pnpm install
cd ..
```

Install auth server dependencies from the `auth-server/` directory:

```bash
cd auth-server
pnpm install # installs ts-node for Node-based tests
cd ..
```

`ts-node` must be available in your `$PATH` for the Node-based tests.
The `pnpm install` command above installs it locally. If no `ts-node`
binary is found after installation, add it globally:

```bash
npm install -g ts-node
```

## Backend Python Environment

Create and activate a virtual environment, then install the Python
dependencies:

```bash
python3 -m venv venv
source venv/bin/activate
python -m pip install --requirement requirements-dev.txt
```

`requirements-dev.txt` includes backend and auth packages such as
**SQLAlchemy**.

You can also run `./scripts/setup-dev.sh` to automate the above steps.
Run `./scripts/create-env.sh` to copy `.env.example` to `.env.development`.
The same script also creates `.env.development` for the Node auth service.

## Environment Variables

Create `.env.development` in the project root with these variables.
The `utils.env.Settings` class loads and validates them at startup.

| Variable | Description | Validation |
| -------- | ----------- | ---------- |
| `DISCORD_CLIENT_ID` | Discord OAuth client ID | required string |
| `DISCORD_CLIENT_SECRET` | Discord OAuth client secret | required string |
| `DATABASE_URL` | PostgreSQL connection string | required URL |
| `VERIFICATION_DB_URL` | SQLite DB URL | default `sqlite:///verification.db` |
| `REDIS_URL` | Redis connection string | required URL |
| `REDIS_MOCK` | Use in-memory Redis for tests | bool, default `0` |
| `JWT_SECRET` | Secret used to sign JWTs | required string |
| `JWT_ALGORITHM` | Algorithm for JWT signing | string, default `HS256` |
| `JWT_EXPIRATION` | JWT expiration in seconds | int, default `3600` |
| `JWT_ISSUER` | Expected `iss` claim in JWTs | required string |
| `JWT_AUDIENCE` | Expected `aud` claim in JWTs | required string |
| `JWT_PUBLIC_KEY` | Optional RSA public key for verifying tokens | optional string |
| `OWNER_ROLE_ID` | Discord role ID for owners | required string |
| `ADMINISTRATOR_ROLE_ID` | Discord role ID for admins | required string |
| `VERIFIED_USER_ROLE_ID` | ID for verified users | required string |
| `VERIFIED_MEMBER_ROLE_ID` | ID for verified members | required string |
| `ALLOWED_ORIGINS` | Comma-separated CORS origins | required string |
| `OPENAI_API_KEY` | OpenAI API key for Codex automation | required string |
| `CODEX_JOURNAL_DIR` | Path for CLI logs | string, default `codex/journal` |
| `CF_DNS_API_TOKEN` | Cloudflare DNS API token | optional string |
| `TUNNEL_TOKEN` | Cloudflare tunnel auth token | optional string |
| `TUNNEL_ID` | Cloudflare tunnel ID | optional string |

Example values are provided in `.env.example`. `CODEX_JOURNAL_DIR` controls
where the CLI writes journal logs. Missing required variables will cause the
application and test suite to fail at startup. Node tests verify JWT claims,
so set `JWT_ISSUER` and `JWT_AUDIENCE` to match your auth server.
The cloudflared container uses --token with `TUNNEL_TOKEN` to authenticate.

Start Redis for local development:

```bash
docker compose up redis -d
```

Tests use a fake Redis instance when `REDIS_MOCK=1`. Otherwise a server must be running on `REDIS_URL`.

### Running Tests

Before tests, run `./scripts/setup-dev.sh` to install dependencies.
The script installs `pre-commit` and removes stale virtual environments.
Automated Codex environments may not include these tools, so always
execute the script before any hooks run.
Run `pre-commit install` so the hook sets up the env and runs tests.

```bash
pytest -q
pnpm --dir frontend test:unit
```

Node-based tests rely on **ts-node** and it must be in your `$PATH`.
Run `pnpm install` inside `auth-server/` to install the required dev
dependencies. If this does not make the `ts-node` command available,
install it globally with `npm install -g ts-node`.

### Docker Compose

Start the full development stack with Traefik and related services:

```bash
make dev-stack
```
This uses `docker-compose.dev.yaml` to run containers in detached mode.

### Git LFS

Binary assets such as images and PDFs are tracked with **Git LFS**. After
cloning the repository, install the extension and fetch LFS files:

```bash
git lfs install
git lfs pull
```

The `.gitattributes` file lists the patterns managed by LFS, including
`*.png` and `*.pdf`.

### Traefik Local TLS

Create `acme.json` in the project root and restrict its permissions:

```bash
sudo touch acme.json
sudo chmod 600 acme.json
```

`acme.json` is ignored in version control via `.gitignore` so Traefik can
store certificates locally.

Add DNS A records pointing to your host:

- `auth.thenagrygamershow.com`
- `test.thenagrygamershow.com`

Start the services and confirm the health endpoint:

```bash
docker compose up -d
curl -k https://auth.<domain>/healthz
```
