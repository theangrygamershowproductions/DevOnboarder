# Environment Variables

This document lists important variables used by DevOnboarder. Copy
`.env.example` to `.env.dev` and fill in values before running the
services. The CI pipeline also copies this file during tests. The auth and
Discord bot services each provide their own examples &ndash; copy
`auth/.env.example` to `auth/.env` and `bot/.env.example` to `bot/.env`
when working with those packages directly.

## Environment Configuration System

DevOnboarder supports comprehensive environment configuration with 5 distinct modes. Each environment provides optimized defaults for different use cases.

### Available Environments

Set `APP_ENV` in your `.env` file to switch between environments:

- **`testing`** &ndash; Unit tests and automated testing
    - Fast token expiration (60s), SQLite database, minimal logging
    - Optimized for rapid test cycles
- **`ci`** &ndash; Continuous integration pipelines
    - SQLite database, detailed logging, 6 localhost CORS origins
    - Comprehensive testing environment
- **`debug`** &ndash; Development with verbose logging
    - DEBUG level logging, extended token timeout (1h), SQLite database
    - Maximum verbosity for troubleshooting
- **`development`** &ndash; Local development (default)
    - PostgreSQL database, wildcard CORS, balanced logging
    - Developer-friendly defaults
- **`production`** &ndash; Production deployment
    - PostgreSQL database, restricted CORS, error-only logging
    - Security-first configuration

### Switching Environments

#### Method 1: Edit .env file (Recommended)

```bash
# Edit .env file and change:
APP_ENV=development  # Change to: testing, ci, debug, development, or production

# Sync to other environment files (optional)
bash scripts/smart_env_sync.sh --sync-all
```

#### Method 2: Temporary override

```bash
# For current terminal session only
export APP_ENV=testing
```

### Environment-Specific Defaults

Each environment automatically configures:

- **Database URLs**: SQLite for testing/CI/debug, PostgreSQL for dev/prod
- **CORS Origins**: Appropriate security boundaries per environment
- **Logging Levels**: From WARNING (testing) to DEBUG (debug) to ERROR (production)
- **Token Expiration**: From 60s (testing) to 30min (production)
- **Redis URLs**: Isolated database numbers per environment
- **Initialization**: Auto-setup enabled for dev environments, manual for production

### Programming Usage

Use the environment system in your code:

```python
from utils.environment import (
    get_environment,
    is_testing,
    is_debug,
    get_database_url,
    get_cors_origins,
    get_config_value
)

# Check current environment
env = get_environment()
print(f"Running in {env} mode")

# Environment-specific logic
if is_testing():
    # Fast test setup
    timeout = 5
elif is_debug():
    # Verbose debugging
    timeout = 300
else:
    # Normal operation
    timeout = 30

# Get environment-appropriate configuration
db_url = get_database_url()
cors_origins = get_cors_origins()
token_expire = get_config_value("TOKEN_EXPIRE_SECONDS")
```

#### Enhanced Conditional Helpers

For the environments we control (testing, CI, debug), use enhanced conditionals:

```python
from utils.environment import (
    is_controlled_environment,      # testing, ci, debug
    is_fast_environment,           # testing, ci (speed optimized)
    allows_dangerous_operations,   # testing, ci, debug (safe to reset)
    requires_production_safety     # development, production (conservative)
)

# Database operations
if allows_dangerous_operations():
    # Safe to reset database in controlled environments
    reset_database()
    clear_all_caches()

# Performance optimizations  
if is_fast_environment():
    # Aggressive caching for testing/CI
    enable_fast_mode()

# Safety measures
if requires_production_safety():
    # Conservative settings for dev/prod
    enable_rate_limiting()
    enable_audit_logging()
```

### Quick Reference

| Environment  | Database | CORS      | Log Level | Token Exp | Use Case              |
|-------------|----------|-----------|-----------|-----------|----------------------|
| `testing`   | SQLite   | Wildcard  | WARNING   | 60s       | Unit tests           |
| `ci`        | SQLite   | 6 origins | INFO      | 5min      | CI pipelines         |
| `debug`     | SQLite   | Wildcard  | DEBUG     | 1h        | Troubleshooting      |
| `development` | PostgreSQL | Wildcard | INFO    | 1h        | Local development    |
| `production` | PostgreSQL | Restricted | ERROR  | 30min     | Production deployment |

## Core settings

- `APP_ENV` &ndash; Environment mode: `testing`, `ci`, `debug`, `development`, or `production`.
- `DATABASE_URL` &ndash; Postgres connection string for the main database.
- `TOKEN_EXPIRE_SECONDS` &ndash; lifetime of auth tokens in seconds (default `3600`).
- `TAGS_MODE` &ndash; set to `true` when running within the TAGS stack so
  diagnostics expect all services.
- `CORS_ALLOW_ORIGINS` &ndash; comma-separated list of allowed CORS origins. Defaults to `*` in development.
- `INIT_DB_ON_STARTUP` &ndash; run database migrations automatically when the auth service starts.

## Feature flags

- `IS_ALPHA_USER` &ndash; enable routes restricted to early testers.
- `IS_FOUNDER` &ndash; enable routes and perks for Founder's Circle members.

## Secrets

The following tokens and keys are required but **must not** be committed to
the repository. Provide them through your build or deployment secret store:

- `DISCORD_CLIENT_ID` and `DISCORD_CLIENT_SECRET` &ndash; OAuth credentials for
  authenticating with Discord.
- `JWT_SECRET_KEY` &ndash; signing key used by the auth service.
- `JWT_ALGORITHM` &ndash; signing algorithm for JWTs (default `HS256`).
- `DISCORD_BOT_TOKEN` &ndash; bot token used when running the Discord bot.
- `DISCORD_GUILD_IDS` &ndash; comma-separated guilds where the bot operates.
- `DISCORD_REDIRECT_URI` &ndash; callback URL for Discord OAuth. Defaults to
  `http://localhost:8002/login/discord/callback`.
- `DISCORD_API_TIMEOUT` &ndash; HTTP timeout in seconds when contacting Discord APIs (default `10`).
- `BOT_JWT` &ndash; fallback token used by the bot when calling the API. Bot
  API helpers send this JWT when no other token is provided.
- `API_BASE_URL` &ndash; base URL for the XP API used by the bot.

## Discord role-based permissions

The API determines a user's admin and verification status from Discord
roles. Set the guild and role IDs below to match your server
configuration. The bot and API read these values at runtime:

```bash
ADMIN_SERVER_GUILD_ID=
OWNER_ROLE_ID=
ADMINISTRATOR_ROLE_ID=
MODERATOR_ROLE_ID=
VERIFIED_USER_ROLE_ID=
VERIFIED_MEMBER_ROLE_ID=
GOVERNMENT_ROLE_ID=
MILITARY_ROLE_ID=
EDUCATION_ROLE_ID=
```

Users are considered admins when they hold the owner, administrator or
moderator role inside the admin guild. Verification types (`government`,
`military`, `education` or `member`) are resolved in the same way. The auth
service filters roles to the guild specified by `ADMIN_SERVER_GUILD_ID` before
resolving these flags, so roles from other guilds do not influence admin or
verification status. These flags appear in the `/api/user` response and control
access to certain commands and pages.

### Discord OAuth login

Users sign in by visiting `/login/discord`, which redirects to Discord's consent
screen. After granting permissions, Discord redirects back to
`DISCORD_REDIRECT_URI`. The auth service exchanges the provided code for an
access token, creates or looks up the user, then returns a JWT from
`/login/discord/callback`.

The React `Login` component in `frontend/` handles this callback route. It
stores the returned token in the browser and displays the user's onboarding
status and level.

## Frontend

- `VITE_AUTH_URL` &ndash; base URL for the auth API.
- `VITE_API_URL` &ndash; base URL for the XP API.
- `VITE_FEEDBACK_URL` &ndash; base URL for the feedback service.
- `VITE_DISCORD_CLIENT_ID` &ndash; OAuth client ID for Discord.
- `VITE_SESSION_REFRESH_INTERVAL` &ndash; interval (seconds) between session refreshes.

## Testing utilities

- `AUTH_URL` &ndash; base URL for the auth API used by Playwright tests. Defaults to `http://localhost:8002`.
- `CHECK_HEADERS_URL` &ndash; endpoint queried by `scripts/check_headers.py` to
  verify headers (default `http://localhost:8002/api/user`).

## Integrations

- `TEAMS_APP_ID` &ndash; Azure app ID for the MS Teams integration.
- `TEAMS_APP_PASSWORD` &ndash; secret used to authenticate the Teams app.
- `TEAMS_TENANT_ID` &ndash; Azure tenant hosting the Teams app.
- `TEAMS_CHANNEL_ID_ONBOARD` &ndash; Teams channel ID for onboarding updates.
- `LLAMA2_API_KEY` &ndash; API key for accessing the Llama2 service.
- `LLAMA2_API_TIMEOUT` &ndash; HTTP timeout in seconds when calling the Llama2 API (default `10`).

## Docker development images

`../archive/docker-compose.dev.yaml` builds the bot and frontend containers using
`bot/Dockerfile.dev` and `frontend/Dockerfile.dev`. These Dockerfiles install
dependencies with `npm ci` and run the development servers. When running the
frontend outside Docker, follow [../frontend/README.md](../frontend/README.md)
and install packages with `pnpm install` (or `npm ci` for a clean install) before
starting `npm run dev`.

The base `Dockerfile` installs Python packages with `pip install --root-user-action=ignore`
to silence warnings when running as the root user. If you create your own image,
you can activate a virtual environment instead of using this flag.

## Auditing environment variables

Run `env -i PATH="$PATH" bash scripts/audit_env_vars.sh` to compare only the
variables loaded from `.env.dev` with those listed in `.env.example`,
`frontend/src/.env.example`, `bot/.env.example`, and `auth/.env.example`. The
script prints any required variables that are missing and any extras found in
the environment. Set `JSON_OUTPUT` to a file path for machine-readable results.
