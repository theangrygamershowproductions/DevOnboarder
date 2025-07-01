# Agents — Service and Integration Roles (Codex-Driven Reference)

This document defines all agents (services, bots, integrations, and guards) in the TAGS ecosystem. Each entry describes the agent's purpose, configuration, and typical workflow so contributors and Codex automation can keep the platform healthy.

<!-- This file is derived from the master merged draft provided during onboarding. -->

## Table of Contents
1. [Agent Service Map](#agent-service-map)
2. [Auth Server (Backend Agent)](#auth-server-backend-agent)
3. [XP API](#xp-api)
4. [Frontend Session Agent](#frontend-session-agent)
5. [Role Guard (RBAC Agent)](#role-guard-rbac-agent)
6. [Discord Integration Agent](#discord-integration-agent)
7. [Verification Agent](#verification-agent)
8. [Session/JWT Agent](#sessionjwt-agent)
9. [Database Service (Postgres)](#database-service-postgres)
10. [DevOps/Infrastructure Agents](#devopsinfrastructure-agents)
11. [Planned Agents / Stubs](#planned-agents--stubs)
12. [Startup Healthcheck (Autocheck Agent)](#startup-healthcheck-autocheck-agent)
13. [Healthcheck Implementation Guide](#healthcheck-implementation-guide)
14. [CI Wait Example](#ci-wait-example)
15. [Agent Task Checklist](#agent-task-checklist)
16. [Next Steps / Remediation Timeline](#next-steps--remediation-timeline)
17. [Agent Health/Liveness Matrix](#agent-healthliveness-matrix)
18. [Environment Variable Reference](#environment-variable-reference)
19. [Codex Observability](#codex-observability)
20. [How to Extend/Contribute](#how-to-extendcontribute)
21. [Deprecation & Retirement](#deprecation--retirement)
22. [Glossary](#glossary)
23. [Related Docs](#related-docs)
24. [Revision History](#revision-history)

---

## Agent Service Map

| Agent Name          | Endpoint(s)                      | Port | Healthcheck | Depends On | Status   |
| ------------------- | -------------------------------- | ---- | ----------- | ---------- | -------- |
| Auth Server         | `/api/*`, `/health`              | 8002 | `/health`   | db         | updating |
| Discord Integration | `/oauth`, `/roles`               | 8081 | `TBD`       | Auth, db   | deferred |
| Frontend Agent      | `/`, `/session`                  | 3000 | N/A         | Auth       | stable   |
| XP API              | `/xp`, `/health`                 | 8001 | `/health`   | db         | verify   |
| Database (Postgres) | N/A                              | 5432 | docker      | N/A        | stable   |

---

## Auth Server (Backend Agent)

**Purpose:** Provides Discord OAuth, role checks, JWT issuance, and user session endpoints.

**Key Endpoints:** `POST /api/discord/exchange`, `GET /api/auth/user`, `GET /api/verification/status`, `GET /health`

**Environment:** Discord client credentials, role IDs, JWT secret and config.

**Typical Workflow:**
1. Receive code from frontend.
2. Exchange it for a Discord token and fetch roles.
3. Issue a JWT and session payload to the frontend.

## XP API

**Purpose:** Provides onboarding and XP routes backed by the auth service database.

**Key Endpoints:** `GET /api/user/onboarding-status`, `GET /api/user/level`, `POST /api/user/contribute`, `GET /health`

**Environment:** Shares database connection via `DATABASE_URL`.

---

## Frontend Session Agent

**Purpose:** Stores and refreshes JWTs, restores sessions, and applies RBAC checks client-side.

**Key Files:** `src/hooks/useSession.ts`, `src/lib/auth/discord.ts`

**Environment:** Role IDs as `VITE_*`, session refresh interval.

---

## Role Guard (RBAC Agent)

**Purpose:** Restricts pages/components based on Discord roles in the current session.

**Key Files:** `src/components/auth/ProtectedRoute.tsx`, `src/components/auth/OwnerRoute.tsx`

---

## Discord Integration Agent

**Status:** Deferred – planned endpoints `/oauth` and `/roles` are not yet implemented.

**Purpose:** Handles Discord OAuth flows and role lookups once the service is built.

**Key Files:** To be determined when development resumes.

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

## Planned Agents / Stubs

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

```js
app.get('/health', (req, res) => res.status(200).send('OK'));
```

**FastAPI:**

```python
@app.get("/health")
def healthcheck():
    return {"status": "ok"}
```

## CI Wait Example

Use a small loop in your workflow to wait for the auth service before running tests:

```yaml
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
```

---

## Agent Task Checklist

- [x] Document each agent's purpose, key files, environment, and workflow.
- [x] Update this file and the changelog when an agent changes.
- [x] Ensure healthchecks pass for required services.

---

## Next Steps / Remediation Timeline

- [x] Implement `/health` in Auth
- [x] Add Docker healthcheck to compose
- [x] CI workflow update to poll `/health`
- [ ] Env var audit/cleanup in `.env.dev`
- [ ] Doc/Agents.md/Changelog update
- [ ] Retire obsolete scripts

---

## Agent Health/Liveness Matrix

| Agent               | Healthcheck | Required in CI | Required in Prod |
| ------------------- | ----------- | -------------- | ---------------- |
| Auth Server         | Yes         | Yes            | Yes              |
| Frontend            | Yes         | Yes            | Yes              |
| Discord Integration | N/A         | No             | No               |
| XP API              | Yes         | Yes            | Yes              |
| Webhook/Bot Agent   | Optional    | No             | Optional         |
| Database (Postgres) | Yes         | Yes            | Yes              |

---

## Environment Variable Reference

| Variable                     | Description                                |
| ---------------------------- | ------------------------------------------ |
| APP_ENV                      | Application mode (`development`, etc.)     |
| DATABASE_URL                 | Postgres connection string                 |
| TOKEN_EXPIRE_SECONDS         | JWT expiration in seconds                  |
| CORS_ALLOW_ORIGINS           | Comma-separated list of allowed CORS origins |
| IS_ALPHA_USER                | Enable alpha-only routes                   |
| IS_FOUNDER                   | Enable founder-only routes                 |
| ADMIN_SERVER_GUILD_ID        | Discord guild ID used for admin checks     |
| OWNER_ROLE_ID                | Discord role for system owner              |
| ADMINISTRATOR_ROLE_ID        | Discord role for administrators            |
| MODERATOR_ROLE_ID            | Discord role for moderators                |
| VERIFIED_USER_ROLE_ID        | Role granted to verified community members |
| VERIFIED_MEMBER_ROLE_ID      | Alias role for verified members            |
| GOVERNMENT_ROLE_ID           | Role for government employees              |
| MILITARY_ROLE_ID             | Role for military members                  |
| EDUCATION_ROLE_ID            | Role for school or university affiliation  |
| VERIFIED_GOVERNMENT_ROLE_ID  | Role assigned after government verification|
| VERIFIED_MILITARY_ROLE_ID    | Role assigned after military verification  |
| VERIFIED_EDUCATION_ROLE_ID   | Role assigned after education verification |
| DISCORD_CLIENT_ID            | Discord application client ID              |
| DISCORD_CLIENT_SECRET        | Discord application client secret          |
| DISCORD_REDIRECT_URI         | OAuth callback URL for Discord             |
| DISCORD_API_TIMEOUT          | HTTP timeout in seconds for Discord API calls |
| JWT_SECRET_KEY               | Secret key for JWT signing (required; service errors if empty or "secret" outside `development`) |
| JWT_ALGORITHM                | Algorithm for JWT signing (default `HS256`) |
| DISCORD_BOT_TOKEN            | Token for the Discord bot                  |
| DISCORD_GUILD_IDS            | Guilds where the bot operates              |
| BOT_JWT                      | JWT used by the bot for API calls          |
| API_BASE_URL                 | XP API URL for the bot                     |
| AUTH_URL                     | Auth service URL for Playwright tests      |
| VITE_AUTH_URL                | Auth service URL for the frontend          |
| VITE_API_URL                 | XP API URL for the frontend                |
| VITE_DISCORD_CLIENT_ID       | Discord client ID for the frontend         |
| VITE_SESSION_REFRESH_INTERVAL| How often the frontend refreshes sessions  |
| INIT_DB_ON_STARTUP           | Auto-run migrations when the auth service starts |

---

## Codex Observability

CI health and failure events are monitored by Codex. Future outages will trigger
an automated notification and suggested fix via Codex's reporting channel.

---

## How to Extend/Contribute

1. Add a new section following the same structure: purpose, key files, environment, typical workflow.
2. Update the environment table and health matrix if needed.
3. Record your changes in the revision history below and in `docs/CHANGELOG.md`.

---

## Deprecation & Retirement

When retiring an agent, mark the section as deprecated with the date and reason. Update the health matrix and remove references from code and docs.

---

## Glossary

- **Agent:** Any service, bot, or integration that manages part of the TAGS platform.
- **RBAC:** Role-Based Access Control.
- **Codex:** The automation system that verifies docs and code quality.

---

## Related Docs

- [Project README](../README.md)
- [Security Policy](../SECURITY.md)
- [Onboarding Guide](../ONBOARDING.md)
- [.env.example](../.env.example)

---

## Revision History

| Date        | Version | Author    | Summary                                |
| ----------- | ------- | --------- | -------------------------------------- |
| 22 Jun 2025 | v0.3.0  | Codex     | Added service map and healthcheck guide |
| 23 Jun 2025 | v0.3.1  | Codex     | Documented `/health` endpoints |
| 21 Jun 2025 | v0.2.1  | Codex     | Added database agent and updated env vars |
| 21 Jun 2025 | v0.2.0  | C. Reesey | Master merged, health matrix, glossary |
| 21 Jun 2025 | v0.1.0  | C. Reesey | Initial draft                          |

*Last updated: 23 June 2025*

