# Agents Overview

This directory documents the services and integrations that make up the
DevOnboarder platform. Each agent has its own page describing the purpose and
how it fits into the workflow.

## Available Agents

- [Discord Integration](discord-integration.md)
- [MS Teams Integration](ms-teams-integration.md)
- [ID.me Verification](idme-verification.md)
- [AI Mentor](ai-mentor.md)
- [Llama2 Agile Helper](llama2-agile-helper.md)

Use the [template](templates/agent-spec-template.md) when documenting a new agent.
## Required Environment Variables

The table below lists environment variables used across DevOnboarder agents. Keep `.env.example` in sync with this list.

| Variable                     | Description                                |
| ---------------------------- | ------------------------------------------ |
| APP_ENV                      | Application mode (`development`, etc.)     |
| DATABASE_URL                 | Postgres connection string                 |
| TOKEN_EXPIRE_SECONDS         | JWT expiration in seconds                  |
| TAGS_MODE                    | Expect TAGS services when `true`           |
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
| DISCORD_CLIENT_ID            | Discord application client ID              |
| DISCORD_CLIENT_SECRET        | Discord application client secret          |
| DISCORD_REDIRECT_URI         | OAuth callback URL for Discord             |
| DISCORD_API_TIMEOUT          | HTTP timeout in seconds for Discord API calls |
| JWT_SECRET_KEY               | Secret key for JWT signing (required; service
errors if empty or "secret" outside `development`) |
| JWT_ALGORITHM                | Algorithm for JWT signing (default `HS256`) |
| DISCORD_BOT_TOKEN            | Token for the Discord bot                  |
| DISCORD_GUILD_IDS            | Guilds where the bot operates              |
| BOT_JWT                      | JWT used by the bot for API calls          |
| API_BASE_URL                 | XP API URL for the bot                     |
| AUTH_URL                     | Auth service URL for Playwright tests      |
| CHECK_HEADERS_URL            | Endpoint used by header checks (default `http://localhost:8002/api/user`) |
| VITE_AUTH_URL                | Auth service URL for the frontend          |
| VITE_API_URL                 | XP API URL for the frontend                |
| VITE_FEEDBACK_URL            | Base URL for the feedback service          |
| VITE_DISCORD_CLIENT_ID       | Discord client ID for the frontend         |
| VITE_SESSION_REFRESH_INTERVAL| How often the frontend refreshes sessions  |
| INIT_DB_ON_STARTUP           | Auto-run migrations when the auth service starts |
| TEAMS_APP_ID                 | Azure app ID for the Teams integration      |
| TEAMS_APP_PASSWORD           | Secret used to authenticate the Teams app   |
| TEAMS_TENANT_ID              | Azure tenant hosting the Teams app          |
| TEAMS_CHANNEL_ID_ONBOARD     | Teams channel ID for onboarding updates     |
| LLAMA2_API_KEY               | API key for accessing the Llama2 service    |
| LLAMA2_API_TIMEOUT           | HTTP timeout in seconds for Llama2 API calls |

