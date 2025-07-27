# Multi-Bot Orchestration Guide

This document explains how the Discord bot, Codex automation, and other
service accounts coordinate within DevOnboarder. It also covers API key
management and how to escalate problems when automation fails.

## Multi-Bot Setup

Several bots operate together:

-   **Codex** – monitors CI jobs, opens issues, and proposes YAML fixes.
-   **Discord bot** – provides slash commands and onboarding checks.
-   **Orchestrator workflows** – scheduled jobs that manage bot permissions
    using `.codex/bot-permissions.yaml`.

Each bot uses a dedicated token stored in GitHub Actions secrets. The
`check-bot-permissions.sh` script verifies that permissions match the policy
before workflows run.

## Orchestrator URL

The orchestration scripts reference an `ORCHESTRATOR_URL` environment variable.
Workflows set this variable when invoking the scripts. If not provided, the
scripts default to `https://orchestrator.example.com`.
The workflows also supply an `ORCHESTRATION_KEY` secret token used for
authentication.

## API Key Management

1. Store each bot token as a separate secret in GitHub.
2. Limit the scopes to only the required operations (issue write, pull
   requests, etc.).
3. Rotate tokens every quarter and record the rotation date in
   `docs/governance/bot_access_governance.md`.
4. Reference tokens in workflows via `${{ secrets.<TOKEN_NAME> }}` so they are
   not hard coded in repository files.

## Escalation Paths

If automation breaks or a bot is unresponsive:

1. Check workflow run logs for errors and consult
   `docs/troubleshooting.md` for common fixes.
2. If the issue persists, mention @project-maintainers in the failing pull
   request or issue.
3. For credential problems, escalate to the security team listed in
   `docs/governance/bot_access_governance.md`.
4. Document the incident in `docs/CHANGELOG.md` if manual recovery steps were
   required.
