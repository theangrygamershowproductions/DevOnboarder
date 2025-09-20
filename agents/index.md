---
similarity_group: index.md-agents

content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---

# Agents Overview

---
title: "Agents Overview"

description: "Index and documentation overview for all DevOnboarder agents with service descriptions and workflow integration details"
document_type: "documentation"
tags: ["agents", "index", "overview", "documentation", "services"]
project: "core-agents"
agent: documentation_index
authentication_required: false
author: DevOnboarder Team
codex_dry_run: false
codex_runtime: false
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
updated_at: '2025-09-13'
discord_role_required: ''
environment: any
integration_log: Agent index and documentation overview
merge_candidate: false
output: .codex/logs/documentation.log
permissions:

- repo:read

purpose: Documentation index and overview for all DevOnboarder agents
similarity_group: index.md-agents
status: active
trigger: documentation updates and agent additions

visibility: internal

---

This directory documents the services and integrations that make up the

DevOnboarder platform. Each agent has its own page describing the purpose and
how it fits into the workflow.
See [../.codex/Agents.md](../.codex/Agents.md) for header guidelines; every agent file must start with a `codex-agent` YAML header.

## Available Agents

- [Discord Integration](discord-integration.md)

- [MS Teams Integration](ms-teams-integration.md)

- [ID.me Verification](idme-verification.md)

- [AI Mentor](ai-mentor.md)

- [Llama2 Agile Helper](llama2-agile-helper.md)

- [Prod Orchestrator](prod-orchestrator.md)

- [Documentation Quality Enforcer](documentation-quality-enforcer.md)

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
| AUTH_PORT                     | Port for the authentication service |
| AUTH_SECRET_KEY               |  |
| AUTH_URL                      | Auth service URL for Playwright tests |
| BACKEND_PORT                  | Port for the backend API service |
| BOT_API_URL                   | API URL for bot-to-backend communication |
| BOT_JWT                       | JWT used by the bot for API calls |
| BOT_PORT                      | Port for the Discord bot service |
| BOT_PREFIX                    | Command prefix for Discord bot commands |
| CF_DNS_API_TOKEN              |  |
| CHECK_HEADERS_URL             | Endpoint used by header checks (default `http://localhost:8002/api/user`) |
| CI                            | Continuous Integration environment flag |
| CI_BOT_TOKEN                  | GitHub token used by the CI bot |
| CI_BOT_USERNAME               | GitHub username used to assign CI failure issues |
| CI_ISSUE_AUTOMATION_TOKEN     | Fine-grained GitHub token for CI issue/PR automation (primary token) |
| CI_ISSUE_TOKEN                | Token used to open CI failure issues |
| CODEX_DRY_RUN                 | Enable dry-run mode for Codex operations |
| CORS_ALLOW_ORIGINS            | Comma-separated list of allowed CORS origins |
| DATABASE_URL                  | Postgres connection string |
| DEBUG                         | Enable debug logging and features |
| DEV_ORCHESTRATION_BOT_KEY     | Secret token for development orchestrator |
| DEV_TUNNEL_API_URL            |  |
| DEV_TUNNEL_APP_URL            |  |
| DEV_TUNNEL_AUTH_URL           |  |
| DEV_TUNNEL_DASHBOARD_URL      |  |
| DEV_TUNNEL_DISCORD_URL        |  |
| DEV_TUNNEL_FRONTEND_URL       |  |
| DISCORD_API_TIMEOUT           |  |
| DISCORD_BOT_READY             | Flag indicating Discord bot readiness state |
| DISCORD_BOT_TOKEN             | Token for the Discord bot |
| DISCORD_C2C_GUILD_ID          |  |
| DISCORD_CLIENT_ID             | Discord application client ID |
| DISCORD_CLIENT_SECRET         | Discord application client secret |
| DISCORD_DEV_GUILD_ID          | Discord guild ID for development environment |
| DISCORD_GAMING_GUILD_ID       |  |
| DISCORD_GUILD_ID              | Primary Discord guild ID for bot operations |
| DISCORD_GUILD_IDS             | Guilds where the bot operates |
| DISCORD_PROD_GUILD_ID         | Discord guild ID for production environment |
| DISCORD_PUBLIC_KEY            |  |
| DISCORD_REDIRECT_URI          | OAuth callback URL for Discord |
| DISCORD_TOKEN                 | Primary Discord authentication token |
| DISCORD_WEBHOOK_URL           | Webhook URL for Discord notifications |
| EDUCATION_ROLE_ID             | Role for school or university affiliation |
| ENVIRONMENT                   | Current deployment environment (dev/staging/prod) |
| FRONTEND_PORT                 | Port for the frontend development server |
| FRONTEND_URL                  | Base URL for the frontend application |
| GH_TOKEN                      | GitHub CLI token for automation |
| GOVERNMENT_ROLE_ID            | Role for government employees |
| INIT_DB_ON_STARTUP            | Auto-run migrations when the auth service starts |
| IS_ALPHA_USER                 | Enable alpha-only routes |
| IS_FOUNDER                    | Enable founder-only routes |
| JSON_OUTPUT                   | Path to write audit_env_vars JSON summary |
| JWT_ALGORITHM                 | Algorithm for JWT signing (default `HS256`) |
| JWT_SECRET_KEY                | Secret key for JWT signing (required; service errors if empty or "secret" outside `development`) |
| LANGUAGETOOL_URL              | Base URL for a local LanguageTool server (optional) |
| LIVE_TRIGGERS_ENABLED         | Enable live trigger functionality |
| LLAMA2_API_KEY                | API key for accessing the Llama2 service |
| LLAMA2_API_TIMEOUT            | HTTP timeout in seconds for Llama2 API calls |
| LLAMA2_URL                    | Base URL for the Llama2 API |
| LOG_LEVEL                     | Logging level (debug/info/warn/error) |
| MILITARY_ROLE_ID              | Role for military members |
| MODERATOR_ROLE_ID             | Discord role for moderators |
| NODE_ENV                      | Node.js environment (development/production) |
| NPM_TOKEN                     | Authenticate `npm publish` |
| OFFLINE_BADGE                 | Set to `1` to skip coverage badge generation |
| OPENAI_API_KEY                | Token for OpenAI requests |
| ORCHESTRATION_KEY             | Secret used by orchestration scripts |
| ORCHESTRATOR_URL              | Base URL for orchestration service |
| OWNER_ROLE_ID                 | Discord role for system owner |
| PROD_ORCHESTRATION_BOT_KEY    | Secret token for production orchestrator |
| PYTHON_ENV                    | Python environment configuration |
| REDIS_URL                     |  |
| STAGING_ORCHESTRATION_BOT_KEY | Secret token for staging orchestrator |
| TAGS_MODE                     | Expect TAGS services when `true` |
| TEAMS_APP_ID                  | Azure app ID for the Teams integration |
| TEAMS_APP_PASSWORD            | Secret used to authenticate the Teams app |
| TEAMS_CHANNEL_ID_ONBOARD      | Teams channel ID for onboarding updates |
| TEAMS_TENANT_ID               | Azure tenant hosting the Teams app |
| TOKEN_EXPIRE_SECONDS          | JWT expiration in seconds |
| TRIVY_VERSION                 | Selects the Trivy release for scanning |
| TUNNEL_ID                     |  |
| TUNNEL_TOKEN                  |  |
| VALE_VERSION                  | Selects the Vale version for docs checks |
| VERIFIED_MEMBER_ROLE_ID       | Alias role for verified members |
| VERIFIED_USER_ROLE_ID         | Role granted to verified community members |
| VITE_ALLOWED_HOST_DEV         |  |
| VITE_ALLOWED_HOST_PROD        |  |
| VITE_API_URL                  | XP API URL for the frontend |
| VITE_AUTH_URL                 | Auth service URL for the frontend |
| VITE_DASHBOARD_URL            |  |
| VITE_DISCORD_CLIENT_ID        | Discord client ID for the frontend |
| VITE_DISCORD_INTEGRATION_URL  |  |
| VITE_FEEDBACK_URL             | Base URL for the feedback service |
| VITE_SESSION_REFRESH_INTERVAL | How often the frontend refreshes sessions |
