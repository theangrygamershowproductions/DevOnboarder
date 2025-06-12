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
<!-- PATCHED v0.2.32 docs/Testing-Setup.md — document coverage requirement -->

# Testing & Container Setup Guide

This document outlines the steps required to prepare a local environment,
build the Docker containers and run the test suite.

## Prerequisites

- **Docker** and **Docker Compose** installed
- **Python 3.13** and **Node.js 22** with pnpm 10 (already provided in the
  devcontainer)

## 1. Generate Environment Files

Run the helper script to copy example files:

```bash
./scripts/create-env.sh
```

This creates `.env.development`, `.env.dev` and `infrastructure/.env` if they
do not already exist.
Edit `.env.development` to provide the required values listed below.
The frontend uses `frontend/.env.frontend.dev` with Vite variables.
Update this file if you change the host or port.

## 2. Environment Variables

The application expects these variables (see `.env.example` for sample values):

| Variable | Description |
| -------- | ----------- |
| `DISCORD_CLIENT_ID` | Discord OAuth client ID |
| `DISCORD_CLIENT_SECRET` | Discord OAuth client secret |
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis connection string |
| `JWT_SECRET` | Secret used to sign JWTs |
| `JWT_ALGORITHM` | Algorithm for JWT signing (default `HS256`) |
| `JWT_EXPIRATION` | JWT expiration in seconds (default `3600`) |
| `OWNER_ROLE_ID` | Discord role ID for owners |
| `ADMINISTRATOR_ROLE_ID` | Discord role ID for admins |
| `VERIFIED_USER_ROLE_ID` | Discord role ID for verified users |
| `VERIFIED_MEMBER_ROLE_ID` | Discord role ID for verified members |
| `ALLOWED_ORIGINS` | Allowed CORS origins |
| `FASTAPI_SECRET_KEY` | FastAPI session secret |
| `DEVONBOARDER_ETHEREUM_RPC_URL` | (optional) RPC URL for verification |
| `DEVONBOARDER_ANCHOR_CONTRACT_ADDRESS` | (optional) CodeAnchor address |
| `DEVONBOARDER_REPO_ANCHOR_KEY` | (optional) Repository anchor key |
| `DEVONBOARDER_CODEQL_UPLOAD_TOKEN` | (optional) GitHub token for uploads |

During CI or in the Codex environment, store sensitive values as environment
secrets. Do not commit them.
Place them in `.env.development` when running locally.

## 3. Install Dependencies

Execute the setup script to install Python packages and frontend dependencies.
This also creates a Python virtual environment:

```bash
./scripts/setup-dev.sh
```

Install auth server dependencies from the `auth-server/` directory:

```bash
cd auth-server
pnpm install # required for ts-node tests
cd ..
```

Activate the virtual environment before running tests:

```bash
source venv/bin/activate
```

## 4. Build Containers

To start the minimal development stack (backend and frontend) with live
reload, run:

```bash
make dev-docker
```

For the full stack including Traefik, cloudflared and debug tools,
run:

```bash
make dev-stack
```

Both commands use the variables from `.env.development` and
`frontend/.env.frontend.dev`.

## 5. Run the Test Suite

With the virtual environment active and dependencies installed, execute:

```bash
pytest --cov --cov-fail-under=85
pnpm --dir frontend test:unit
```

Node-based tests rely on **ts-node** and it must be available in your
`$PATH`. Run `pnpm install` inside the `auth-server/` directory to
install the local dev dependency. If the command does not provide a
`ts-node` binary on your system, install it globally with:

```bash
npm install -g ts-node
```

All tests should pass before opening a pull request. Coverage must be at
least 85% or higher to meet the CI requirement.

---

### Last updated: 08 Jul 2025
