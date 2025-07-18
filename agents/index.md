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
- [Prod Orchestrator](prod-orchestrator.md)
- [Dev Orchestrator](dev-orchestrator.md)
- [Staging Orchestrator](staging-orchestrator.md)
- [Onboarding Agent](onboarding-agent.md)
- [CI Helper Agent](ci-helper-agent.md)
- [CI Bot](ci-bot.md)
- [Diagnostics Bot](diagnostics-bot.md)
- [EnvVar Manager](envvar-manager.md)
- [Branch Cleanup](branch-cleanup.md)

Use the [template](templates/agent-spec-template.md) when documenting a new agent.
## Required Environment Variables

The table below lists environment variables used across DevOnboarder agents. Keep `.env.example` in sync with this list.

| Variable                      | Description |
| ----------------------------- | ----------- |
| ADMINISTRATOR_ROLE_ID         | Discord role for administrators |
| ADMIN_SERVER_GUILD_ID         | Discord guild ID used for admin checks |
| API_BASE_URL                  | XP API URL for the bot |
| APP_ENV                       | Application mode (`development`, etc.) |
| AUTH_URL                      | Auth service URL for Playwright tests |
| BOT_JWT                       | JWT used by the bot for API calls |
| CHECK_HEADERS_URL             | Endpoint used by header checks (default `http://localhost:8002/api/user`) |
| CI_BOT_TOKEN                  | GitHub token used by the CI bot |
| CI_BOT_USERNAME               | GitHub username used to assign CI failure issues |
| CI_ISSUE_TOKEN                | Token used to open CI failure issues |
| CORS_ALLOW_ORIGINS            | Comma-separated list of allowed CORS origins |
| DATABASE_URL                  | Postgres connection string |
| DEV_ORCHESTRATION_BOT_KEY     | Secret token for development orchestrator |
| DISCORD_API_TIMEOUT           | HTTP timeout in seconds for Discord API calls |
| DISCORD_BOT_TOKEN             | Token for the Discord bot |
| DISCORD_CLIENT_ID             | Discord application client ID |
| DISCORD_CLIENT_SECRET         | Discord application client secret |
| DISCORD_GUILD_IDS             | Guilds where the bot operates |
| DISCORD_REDIRECT_URI          | OAuth callback URL for Discord |
| EDUCATION_ROLE_ID             | Role for school or university affiliation |
| GH_TOKEN                      | GitHub CLI token for automation |
| GOVERNMENT_ROLE_ID            | Role for government employees |
| INIT_DB_ON_STARTUP            | Auto-run migrations when the auth service starts |
| IS_ALPHA_USER                 | Enable alpha-only routes |
| IS_FOUNDER                    | Enable founder-only routes |
| JSON_OUTPUT                   | Path to write audit_env_vars JSON summary |
| JWT_ALGORITHM                 | Algorithm for JWT signing (default `HS256`) |
| JWT_SECRET_KEY                | Secret key for JWT signing (required; service errors if empty or "secret" outside `development`) |
| LANGUAGETOOL_URL              | Base URL for a local LanguageTool server (optional) |
| LLAMA2_API_KEY                | API key for accessing the Llama2 service |
| LLAMA2_API_TIMEOUT            | HTTP timeout in seconds for Llama2 API calls |
| LLAMA2_URL                    | Base URL for the Llama2 API |
| MILITARY_ROLE_ID              | Role for military members |
| MODERATOR_ROLE_ID             | Discord role for moderators |
| NPM_TOKEN                     | Authenticate `npm publish` |
| OFFLINE_BADGE                 | Set to `1` to skip coverage badge generation |
| OPENAI_API_KEY                | Token for OpenAI requests |
| ORCHESTRATION_KEY             | Secret used by orchestration scripts |
| ORCHESTRATOR_URL              | Base URL for orchestration service |
| OWNER_ROLE_ID                 | Discord role for system owner |
| PROD_ORCHESTRATION_BOT_KEY    | Secret token for production orchestrator |
| STAGING_ORCHESTRATION_BOT_KEY | Secret token for staging orchestrator |
| TAGS_MODE                     | Expect TAGS services when `true` |
| TEAMS_APP_ID                  | Azure app ID for the Teams integration |
| TEAMS_APP_PASSWORD            | Secret used to authenticate the Teams app |
| TEAMS_CHANNEL_ID_ONBOARD      | Teams channel ID for onboarding updates |
| TEAMS_TENANT_ID               | Azure tenant hosting the Teams app |
| TOKEN_EXPIRE_SECONDS          | JWT expiration in seconds |
| TRIVY_VERSION                 | Selects the Trivy release for scanning |
| VALE_VERSION                  | Selects the Vale version for docs checks |
| VERIFIED_MEMBER_ROLE_ID       | Alias role for verified members |
| VERIFIED_USER_ROLE_ID         | Role granted to verified community members |
| VITE_API_URL                  | XP API URL for the frontend |
| VITE_AUTH_URL                 | Auth service URL for the frontend |
| VITE_DISCORD_CLIENT_ID        | Discord client ID for the frontend |
| VITE_FEEDBACK_URL             | Base URL for the feedback service |
| VITE_SESSION_REFRESH_INTERVAL | How often the frontend refreshes sessions |
