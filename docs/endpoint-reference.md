# API Endpoint Reference

This document lists HTTP routes exposed by DevOnboarder services and how Discord commands interact with them.

## XP API

These endpoints provide onboarding and XP details. Most routes accept a
`username` query parameter and do not require authentication. The
`/api/user/contribute` route requires a valid JWT.

- `GET /api/user/onboarding-status?username=<name>` – current onboarding phase.
- `GET /api/user/level?username=<name>` – calculated user level.
- `POST /api/user/contribute` – record a contribution and award XP.

## Auth Service

Requests to these endpoints require a valid JWT unless otherwise noted.

- `POST /api/register` – create a new account and return a token.
- `POST /api/login` – obtain a token for an existing account.
- `GET /login/discord` – redirect to Discord OAuth (no auth required).
- `GET /login/discord/callback` – handle the OAuth code and return a JWT.
- `GET /api/user` – fetch the Discord ID, username, avatar, roles, and admin/verification flags.
- `GET /api/user/onboarding-status` – onboarding status for the authenticated user.
- `GET /api/user/level` – level derived from accumulated XP.
- `POST /api/user/contributions` – record a new contribution and award XP.
- `GET /api/user/contributions` – list contribution descriptions.
- `POST /api/user/promote` – admins only; mark another user as an admin.

## Discord Integration

- `POST /oauth` – exchange an OAuth code and link a Discord account.
- `GET /roles?username=<name>` – return guild role mappings for the user.

## Discord Command Mapping

The bot in `bot/` calls these routes when users run slash commands:

| Command       | Endpoint                          |
| ------------- | --------------------------------- |
| `/verify`     | `GET /api/user/onboarding-status` |
| `/profile`    | `GET /api/user/level`             |
| `/contribute` | `POST /api/user/contributions`    |

For example, typing `/verify` in Discord triggers a request to
`/api/user/onboarding-status` and echoes the resulting status back to the
channel.
