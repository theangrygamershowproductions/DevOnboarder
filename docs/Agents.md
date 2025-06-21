# Agents — Service and Integration Roles (Codex-Driven Reference)

This document defines all agents (services, bots, integrations, and guards) in the TAGS ecosystem. Each entry describes the agent's purpose, configuration, and typical workflow so contributors and Codex automation can keep the platform healthy.

<!-- This file is derived from the master merged draft provided during onboarding. -->

## Table of Contents
1. [Auth Server (Backend Agent)](#auth-server-backend-agent)
2. [Frontend Session Agent](#frontend-session-agent)
3. [Role Guard (RBAC Agent)](#role-guard-rbac-agent)
4. [Discord Integration Agent](#discord-integration-agent)
5. [Verification Agent](#verification-agent)
6. [Session/JWT Agent](#sessionjwt-agent)
7. [Database Service (Postgres)](#database-service-postgres)
8. [DevOps/Infrastructure Agents](#devopsinfrastructure-agents)
9. [Planned Agents / Stubs](#planned-agents--stubs)
10. [Startup Healthcheck (Autocheck Agent)](#startup-healthcheck-autocheck-agent)
11. [Agent Task Checklist](#agent-task-checklist)
12. [Agent Health/Liveness Matrix](#agent-healthliveness-matrix)
13. [Environment Variable Reference](#environment-variable-reference)
14. [How to Extend/Contribute](#how-to-extendcontribute)
15. [Deprecation & Retirement](#deprecation--retirement)
16. [Glossary](#glossary)
17. [Related Docs](#related-docs)
18. [Revision History](#revision-history)

---

## Auth Server (Backend Agent)

**Purpose:** Provides Discord OAuth, role checks, JWT issuance, and user session endpoints.

**Key Endpoints:** `POST /api/discord/exchange`, `GET /api/auth/user`, `GET /api/verification/status`

**Environment:** Discord client credentials, role IDs, JWT secret and config.

**Typical Workflow:**
1. Receive code from frontend.
2. Exchange it for a Discord token and fetch roles.
3. Issue a JWT and session payload to the frontend.

---

## Frontend Session Agent

**Purpose:** Stores and refreshes JWTs, restores sessions, and applies RBAC checks client side.

**Key Files:** `src/hooks/useSession.ts`, `src/lib/auth/discord.ts`

**Environment:** Role IDs as `VITE_*`, session refresh interval.

---

## Role Guard (RBAC Agent)

**Purpose:** Restricts pages/components based on Discord roles in the current session.

**Key Files:** `src/components/auth/ProtectedRoute.tsx`, `src/components/auth/OwnerRoute.tsx`

---

## Discord Integration Agent

**Purpose:** Handles all Discord-specific OAuth flows and role lookups.

**Key Files:** Backend utilities in `src/utils/discord.ts`, frontend helpers in `src/lib/auth/discord.ts`

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

---

## Agent Task Checklist

- [ ] Document each agent's purpose, key files, environment, and workflow.
- [ ] Update this file and the changelog when an agent changes.
- [ ] Ensure healthchecks pass for required services.

---

## Agent Health/Liveness Matrix

| Agent               | Healthcheck | Required in CI | Required in Prod |
| ------------------- | ----------- | -------------- | ---------------- |
| Auth Server         | Yes         | Yes            | Yes              |
| Frontend            | Yes         | Yes            | Yes              |
| Discord Integration | Partial     | No             | No               |
| XP API              | Yes         | Yes            | Yes              |
| Webhook/Bot Agent   | Optional    | No             | Optional         |
| Database (Postgres) | Yes         | Yes            | Yes              |

---

## Environment Variable Reference

| Variable                     | Description                                |
| ---------------------------- | ------------------------------------------ |
| APP_ENV                      | Application mode (`development`, etc.)     |
| REDIS_URL                    | Redis connection string                    |
| DATABASE_URL                 | Postgres connection string                 |
| LOG_LEVEL                    | Python log level                           |
| TOKEN_EXPIRE_SECONDS         | JWT expiration in seconds                  |
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
| AUTH_SECRET_KEY              | Secret key for JWT signing                 |
| DISCORD_BOT_TOKEN            | Token for the Discord bot                  |
| DISCORD_GUILD_IDS            | Guilds where the bot operates              |
| BOT_JWT                      | JWT used by the bot for API calls          |
| API_BASE_URL                 | XP API URL for the bot                     |
| VITE_API_URL                 | XP API URL for the frontend                |
| VITE_AUTH_URL                | Auth service URL for the frontend          |
| INIT_DB_ON_STARTUP           | Auto-run migrations when the auth service starts |

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
| 21 Jun 2025 | v0.2.1  | Codex     | Added database agent and updated env vars |
| 21 Jun 2025 | v0.2.0  | C. Reesey | Master merged, health matrix, glossary |
| 21 Jun 2025 | v0.1.0  | C. Reesey | Initial draft                          |

*Last updated: 21 June 2025*

