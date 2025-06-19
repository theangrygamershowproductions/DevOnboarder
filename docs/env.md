# Environment Variables

This document lists important variables used by DevOnboarder. Copy
`.env.example` to `.env.dev` and fill in values before running the
services. The CI pipeline also copies this file during tests.

## Core settings

- `APP_ENV` &ndash; application mode such as `development` or `production`.
- `REDIS_URL` &ndash; connection string for the Redis cache.
- `DATABASE_URL` &ndash; Postgres connection string for the main database.
- `LOG_LEVEL` &ndash; Python logging level (`INFO`, `DEBUG`, etc.).

## Feature flags

- `IS_ALPHA_USER` &ndash; enable routes restricted to early testers.
- `IS_FOUNDER` &ndash; enable routes and perks for Founder's Circle members.

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
```

Users are considered admins when they hold the owner, administrator or
moderator role inside the admin guild. Verification types (`government`,
`military`, `education` or `member`) are resolved in the same way. These
flags appear in the `/api/user` response and control access to certain
commands and pages.
