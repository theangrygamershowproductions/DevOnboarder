# Environment Variables

This document lists important variables used by DevOnboarder. Copy
`.env.example` to `.env.dev` and fill in values before running the
services. The CI pipeline also copies this file during tests. The auth and
Discord bot services each provide their own examples &ndash; copy
`auth/.env.example` to `auth/.env` and `bot/.env.example` to `bot/.env`
when working with those packages directly.

## Core settings

- `APP_ENV` &ndash; application mode such as `development` or `production`.
- `REDIS_URL` &ndash; connection string for the Redis cache.
- `DATABASE_URL` &ndash; Postgres connection string for the main database.
- `LOG_LEVEL` &ndash; Python logging level (`INFO`, `DEBUG`, etc.).

## Feature flags

- `IS_ALPHA_USER` &ndash; enable routes restricted to early testers.
- `IS_FOUNDER` &ndash; enable routes and perks for Founder's Circle members.

## Secrets

The following tokens and keys are required but **must not** be committed to
the repository. Provide them through your build or deployment secret store:

- `DISCORD_CLIENT_ID` and `DISCORD_CLIENT_SECRET` &ndash; OAuth credentials for
  authenticating with Discord.
- `AUTH_SECRET_KEY` &ndash; signing key used by the auth service (sometimes
  referred to as `JWT_SECRET`).
- `DISCORD_TOKEN` &ndash; bot token used when running the Discord bot.
- `DISCORD_BOT_TOKEN` &ndash; alternative variable name for the bot token.
- `DISCORD_GUILD_IDS` &ndash; comma-separated guilds where the bot operates.

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
`military`, `education` or `member`) are resolved in the same way. These
flags appear in the `/api/user` response and control access to certain
commands and pages.

- `VERIFIED_GOVERNMENT_ROLE_ID` &ndash; role granted after confirming a
  government employee's credentials.
- `VERIFIED_MILITARY_ROLE_ID` &ndash; role granted once a user proves active
  duty or veteran status.
- `VERIFIED_EDUCATION_ROLE_ID` &ndash; role assigned when a school or
  university affiliation is verified.
