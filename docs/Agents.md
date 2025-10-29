---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Documentation description needed"

document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: Agents.md-docs
status: active
tags: 
title: Agents

updated_at: 2025-10-27
visibility: internal
---

# Agent Service and Integration Roles

> **Note**: The up-to-date agent documentation now lives at
> [agents/index.md](../agents/index.md). The remainder of this file is kept for
> legacy reference only.

This document defines all agents (services, bots, integrations, and guards) in the TAGS ecosystem.
Each entry describes the agent's purpose, configuration, and typical workflow so contributors
and Codex automation can keep the platform healthy.

<!-- This file is derived from the master merged draft provided during onboarding. -

## Table of Contents

- [Agent Service and Integration Roles](#agent-service-and-integration-roles)
    - [Table of Contents](#table-of-contents)
    - [Agent Service Map](#agent-service-map)
    - [Auth Server (Backend Agent)](#auth-server-backend-agent)
        - [Auth Server Endpoints](#auth-server-endpoints)
    - [XP API](#xp-api)
        - [XP API Endpoints](#xp-api-endpoints)
    - [Frontend Session Agent](#frontend-session-agent)
        - [Routes](#routes)
    - [Role Guard (RBAC Agent)](#role-guard-rbac-agent)
    - [Discord Integration Agent](#discord-integration-agent)
        - [Discord Integration Endpoints](#discord-integration-endpoints)
    - [Verification Agent](#verification-agent)
    - [Session/JWT Agent](#sessionjwt-agent)
    - [Database Service (Postgres)](#database-service-postgres)
    - [DevOps/Infrastructure Agents](#devopsinfrastructure-agents)
    - [Planned Agents and Stubs](#planned-agents-and-stubs)
    - [Startup Healthcheck (Autocheck Agent)](#startup-healthcheck-autocheck-agent)
    - [Healthcheck Implementation Guide](#healthcheck-implementation-guide)
    - [CI Wait Example](#ci-wait-example)
    - [Agent Task Checklist](#agent-task-checklist)
    - [Next Steps and Remediation Timeline](#next-steps-and-remediation-timeline)
    - [Agent Health/Liveness Matrix](#agent-healthliveness-matrix)
    - [Environment Variable Reference](#environment-variable-reference)
    - [Codex Observability](#codex-observability)
    - [Security Policy for Tooling and Dependencies](#security-policy-for-tooling-and-dependencies)
    - [How to Extend/Contribute](#how-to-extendcontribute)
    - [Deprecation and Retirement](#deprecation-and-retirement)
    - [Glossary](#glossary)
    - [Related Docs](#related-docs)
    - [Revision History](#revision-history)
    - [Last Updated](#last-updated)

---

## Agent Service Map

| Agent Name          | Port | Healthcheck | Depends On | Status   |
| ------------------- | ---- | ----------- | ---------- | -------- |
| Auth Server         | 8002 | `/health`   | db         | updating |
| Discord Integration | 8081 | `/health`   | Auth, db   | verify   |
| Frontend Agent      | 3000 | N/A         | Auth       | stable   |
| XP API              | 8001 | `/health`   | db         | verify   |
| Database (Postgres) | 5432 | docker      | N/A        | stable   |

---

## Auth Server (Backend Agent)

**Purpose:** Provides Discord OAuth, role checks, JWT issuance, and user session endpoints.

### Auth Server Endpoints

- `GET /health` - Service health check
- `POST /api/discord/exchange` - Exchange Discord code for JWT
- `GET /api/auth/user` - Get current user session
- `GET /api/verification/status` - Check user verification status

**Environment:** Discord client credentials, role IDs, JWT secret and config.

**Typical Workflow:**

1. Receive code from frontend.

2. Exchange it for a Discord token and fetch roles.

3. Issue a JWT and session payload to the frontend.

## XP API

**Purpose:** Provides onboarding and XP routes backed by the auth service database.

### XP API Endpoints

- `GET /health` - Service health check
- `GET /api/user/onboarding-status` - Get user onboarding progress
- `GET /api/user/level` - Get user XP level and statistics
- `POST /api/user/contribute` - Record user contribution for XP

**Environment:** Shares database connection via `DATABASE_URL`.

---

## Frontend Session Agent

**Purpose:** Stores and refreshes JWTs, restores sessions, and applies RBAC checks client-side.

### Routes

- `GET /` - Main application interface
- `GET /session` - Session management interface
- `GET /*` - Protected routes with RBAC checks

**Key Files:** `src/hooks/useSession.ts`, `src/lib/auth/discord.ts`

**Environment:** Role IDs as `VITE_*`, session refresh interval.

---

## Role Guard (RBAC Agent)

**Purpose:** Restricts pages/components based on Discord roles in the current session.

**Key Files:** `src/components/auth/ProtectedRoute.tsx`, `src/components/auth/OwnerRoute.tsx`

---

## Discord Integration Agent

**Status:** Verify – exposes `/oauth` and `/roles` for account linking and role lookups.

**Purpose:** Handles Discord OAuth flows and role lookups.

### Discord Integration Endpoints

- `GET /health` - Service health check
- `POST /oauth` - Handle Discord OAuth callback
- `GET /roles` - Lookup user Discord roles

**Key Files:** `src/discord_integration/api.py`

---

## Verification Agent

**Purpose:** Determines user verification status based on Discord roles or API lookup.

**Key Files:** `src/routes/verification/status.ts`, `src/utils/resolveUserRoles.ts`

---

## Session/JWT Agent

**Purpose:** Issues, validates, and rehydrates JWT sessions for the frontend.

**Key Files:** Backend utilities in `src/utils/jwt.ts`, session logic in `src/routes/auth/user.ts`

---

## Database Service (Postgres)

**Purpose:** Provides persistent storage for the auth and XP services.

**Key Files:** schema models in `src/devonboarder/auth_service.py` and migrations in `migrations/`.

**Environment:** Connection string defined by `DATABASE_URL`.

---

## DevOps/Infrastructure Agents

Examples include Traefik or Nginx for routing, Docker Compose for orchestration, and monitoring agents.

---

## Planned Agents and Stubs

Examples include a Discord bot/webhook agent and ID.me integration.

---

## Startup Healthcheck (Autocheck Agent)

**Purpose:** Exposes `/health` endpoints so CI/CD and Docker Compose can verify service readiness before running tests.

**Example Docker Compose Healthcheck:**

```yaml
healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
    interval: 5s
    timeout: 2s
    retries: 10
```

## Healthcheck Implementation Guide

Add a simple `/health` route in each service so CI and Compose can poll for readiness.

**Express:**

    app.get("/health", (req, res) => res.status(200).send("OK"));

**FastAPI:**

    @app.get("/health")
    def healthcheck():
        return {"status": "ok"}

## CI Wait Example

Use a small loop in your workflow to wait for the auth service before running tests:

    - name: Wait for Auth service
      run: |
          for i in {1..20}; do
            if curl -sf http://localhost:8002/health; then
              echo "Auth is up"
              exit 0
            fi
            sleep 3
          done
          exit 1

---

## Agent Task Checklist

- [x] Document each agent's purpose, key files, environment, and workflow.

- [x] Update this file and the changelog when an agent changes.

- [x] Ensure healthchecks pass for required services.

- [x] Run `python -m diagnostics` to verify packages, service health, and env vars.

---

## Next Steps and Remediation Timeline

- [x] Implement `/health` in Auth

- [x] Add Docker healthcheck to compose

- [x] CI workflow update to poll `/health`

- [x] Env var audit/cleanup in `.env.dev`

- [x] Doc/Agents.md/Changelog update

- [x] Retire obsolete scripts

---

## Agent Health/Liveness Matrix

| Agent               | Healthcheck | Required in CI | Required in Prod |
| ------------------- | ----------- | -------------- | ---------------- |

| Auth Server         | Yes         | Yes            | Yes              |
| Frontend            | Yes         | Yes            | Yes              |
| Discord Integration | Yes         | No             | No               |
| XP API              | Yes         | Yes            | Yes              |
| Webhook/Bot Agent   | Optional    | No             | Optional         |
| Database (Postgres) | Yes         | Yes            | Yes              |

---

## Environment Variable Reference

| Variable                      | Description                                                                  |
| ----------------------------- | ---------------------------------------------------------------------------- |

| APP_ENV                       | Application mode (`development`, etc.)                                       |
| DATABASE_URL                  | Postgres connection string                                                   |
| TOKEN_EXPIRE_SECONDS          | JWT expiration in seconds                                                    |
| CORS_ALLOW_ORIGINS            | Comma-separated list of allowed CORS origins                                 |
| IS_ALPHA_USER                 | Enable alpha-only routes                                                     |
| IS_FOUNDER                    | Enable founder-only routes                                                   |
| ADMIN_SERVER_GUILD_ID         | Discord guild ID used for admin checks                                       |
| OWNER_ROLE_ID                 | Discord role for system owner                                                |
| ADMINISTRATOR_ROLE_ID         | Discord role for administrators                                              |
| MODERATOR_ROLE_ID             | Discord role for moderators                                                  |
| VERIFIED_USER_ROLE_ID         | Role granted to verified community members                                   |
| VERIFIED_MEMBER_ROLE_ID       | Alias role for verified members                                              |
| GOVERNMENT_ROLE_ID            | Role for government employees                                                |
| MILITARY_ROLE_ID              | Role for military members                                                    |
| EDUCATION_ROLE_ID             | Role for school or university affiliation                                    |
| DISCORD_CLIENT_ID             | Discord application client ID                                                |
| DISCORD_CLIENT_SECRET         | Discord application client secret                                            |
| DISCORD_REDIRECT_URI          | OAuth callback URL for Discord                                               |
| DISCORD_API_TIMEOUT           | HTTP timeout in seconds for Discord API calls                                |
| JWT_SECRET_KEY                | Secret key for JWT signing (errors if empty or "secret" outside development) |
| JWT_ALGORITHM                 | Algorithm for JWT signing (default `HS256`)                                  |
| DISCORD_BOT_TOKEN             | Token for the Discord bot                                                    |
| DISCORD_GUILD_IDS             | Guilds where the bot operates                                                |
| BOT_JWT                       | JWT used by the bot for API calls                                            |
| API_BASE_URL                  | XP API URL for the bot                                                       |
| AUTH_URL                      | Auth service URL for Playwright tests                                        |
| CHECK_HEADERS_URL             | Endpoint used by header checks (default `http://localhost:8002/api/user`)    |
| VITE_AUTH_URL                 | Auth service URL for the frontend                                            |
| VITE_API_URL                  | XP API URL for the frontend                                                  |
| VITE_DISCORD_CLIENT_ID        | Discord client ID for the frontend                                           |
| VITE_SESSION_REFRESH_INTERVAL | How often the frontend refreshes sessions                                    |
| INIT_DB_ON_STARTUP            | Auto-run migrations when the auth service starts                             |

---

## Codex Observability

CI health and failure events are monitored by Codex. Future outages will trigger
an automated notification and suggested fix via Codex's reporting channel.

## Security Policy for Tooling and Dependencies

To reduce the attack surface in CI/CD workflows:

- **Do not use Codecov** or any third-party coverage uploaders that execute

  remote scripts in CI.

- Avoid integrations that rely on `bash <curl | sh>` style commands.

- Vet all external tools for prior security incidents before adoption.

---

## How to Extend/Contribute

1. Add a new section following the same structure: purpose, key files, environment, typical workflow.

2. Update the environment table and health matrix if needed.

3. Record your changes in the revision history below and in `docs/CHANGELOG.md`.

---

## Deprecation and Retirement

When retiring an agent, mark the section as deprecated with the date and reason.
Update the health matrix and remove references from code and docs.

---

## Glossary

- **Agent:** Any service, bot, or integration that manages part of the TAGS platform.

- **RBAC:** Role-Based Access Control.

- **Codex:** The automation system that verifies docs and code quality.

---

## Related Docs

- [Project README](../README.md)

- [Security Policy](../SECURITY.md)

- [Onboarding Guide](ONBOARDING.md)

- [.env.example](../.env.example)

---

## Revision History

| Date        | Version | Author    | Summary                                        |
| ----------- | ------- | --------- | ---------------------------------------------- |

| 3 Jul 2025  | v0.3.3  | Codex     | Added tests for ci_failure_diagnoser script    |
| 22 Jun 2025 | v0.3.0  | Codex     | Added service map and healthcheck guide        |
| 23 Jun 2025 | v0.3.1  | Codex     | Documented `/health` endpoints                 |
| 2 Jul 2025  | v0.3.2  | Codex     | Archived languagetool script and updated tasks |
| 21 Jun 2025 | v0.2.1  | Codex     | Added database agent and updated env vars      |
| 21 Jun 2025 | v0.2.0  | C. Reesey | Master merged, health matrix, glossary         |
| 21 Jun 2025 | v0.1.0  | C. Reesey | Initial draft                                  |

## Last Updated

Last updated: 3 July 2025
