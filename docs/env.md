# Environment Variables

This document lists important variables used by DevOnboarder. Copy
`.env.example` to `.env.dev` and fill in values before running the
services. The CI pipeline also copies this file during tests. The auth and
Discord bot services each provide their own examples &ndash; copy
`auth/.env.example` to `auth/.env` and `bot/.env.example` to `bot/.env`
when working with those packages directly.

## Core settings

- `APP_ENV` &ndash; application mode such as `development` or `production`.
- `DATABASE_URL` &ndash; Postgres connection string for the main database.
- `TOKEN_EXPIRE_SECONDS` &ndash; lifetime of auth tokens in seconds (default `3600`).
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

## Discord role-based permissions

The API determines a user's admin and verification status from Discord
roles. Set the guild and role IDs below to match your server
configuration. The bot and API read these values at runtime:

```
ADMIN_SERVER_GUILD_ID=
OWNER_ROLE_ID=
ADMINISTRATOR_ROLE_ID=
MODERATOR_ROLE_ID=
VERIFIED_USER_ROLE_ID=
VERIFIED_MEMBER_ROLE_ID=
GOVERNMENT_ROLE_ID=
MILITARY_ROLE_ID=
EDUCATION_ROLE_ID=
VERIFIED_GOVERNMENT_ROLE_ID=
VERIFIED_MILITARY_ROLE_ID=
VERIFIED_EDUCATION_ROLE_ID=
```

Users are considered admins when they hold the owner, administrator or
moderator role inside the admin guild. Verification types (`government`,
`military`, `education` or `member`) are resolved in the same way. The auth
service filters roles to the guild specified by `ADMIN_SERVER_GUILD_ID` before
resolving these flags, so roles from other guilds do not influence admin or
verification status. These flags appear in the `/api/user` response and control
access to certain commands and pages.

- `VERIFIED_GOVERNMENT_ROLE_ID` &ndash; role granted after confirming a
  government employee's credentials.
- `VERIFIED_MILITARY_ROLE_ID` &ndash; role granted once a user proves active
  duty or veteran status.
- `VERIFIED_EDUCATION_ROLE_ID` &ndash; role assigned when a school or
  university affiliation is verified.

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
- `VITE_DISCORD_CLIENT_ID` &ndash; OAuth client ID for Discord.
- `VITE_SESSION_REFRESH_INTERVAL` &ndash; interval (seconds) between session refreshes.

## Testing utilities

- `AUTH_URL` &ndash; base URL for the auth API used by Playwright tests. Defaults to `http://localhost:8002`.
- `CHECK_HEADERS_URL` &ndash; endpoint queried by `scripts/check_headers.py` to verify headers (default `http://localhost:8002/api/user`).

## Docker development images

`docker-compose.dev.yaml` builds the bot and frontend containers using
`bot/Dockerfile.dev` and `frontend/Dockerfile.dev`. These Dockerfiles install
dependencies with `npm ci` and run the development servers. When running the
frontend outside Docker, follow [../frontend/README.md](../frontend/README.md)
and install packages with `pnpm install` (or `npm ci` for a clean install) before
starting `npm run dev`.

The base `Dockerfile` installs Python packages with `pip install --root-user-action=ignore`
to silence warnings when running as the root user. If you create your own image,
you can activate a virtual environment instead of using this flag.
