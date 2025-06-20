# API Endpoint Reference

This document lists HTTP routes exposed by DevOnboarder services and how Discord commands interact with them.

## XP API

These endpoints provide onboarding and XP details without authentication. Pass a
`username` query parameter to look up records for that user.

- `GET /api/user/onboarding-status?username=<name>` – current onboarding phase.
- `GET /api/user/level?username=<name>` – calculated user level.

## Auth Service

Requests to these endpoints require a valid JWT unless otherwise noted.

- `POST /api/register` – create a new account and return a token.
- `POST /api/login` – obtain a token for an existing account.
- `GET /api/user` – fetch the Discord ID, username, avatar, roles, and admin/verification flags.
- `GET /api/user/onboarding-status` – onboarding status for the authenticated user.
- `GET /api/user/level` – level derived from accumulated XP.
- `GET /api/user/contributions` – list contribution descriptions.
- `POST /api/user/promote` – admins only; mark another user as an admin.

## Discord Command Mapping

The bot in `bot/` calls these routes when users run slash commands:

| Command | Endpoint |
| ------- | -------- |
| `/verify` | `GET /api/user/onboarding-status` |
| `/profile` | `GET /api/user/level` |
| `/contribute` | `GET /api/user/contributions` |

For example, typing `/verify` in Discord triggers a request to `/api/user/onboarding-status` and echoes the resulting status back to the channel.
