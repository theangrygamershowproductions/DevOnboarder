---
codex-agent:
    name: Agent.MsTeamsIntegration
    role: Sends DevOnboarder updates to Microsoft Teams
    scope: infrastructure notifications
    triggers: Project events requiring team alerts
    output: Teams channel messages
---

# MS Teams Integration Agent

**Status:** Planned.

**Purpose:** Provides Microsoft Teams notifications and channel integrations for project updates.

**Key Files:** To be determined when work begins.

## Environment Variables

-   `TEAMS_APP_ID` – Azure application (client) ID for the integration.
-   `TEAMS_APP_PASSWORD` – application secret used to obtain access tokens.
-   `TEAMS_TENANT_ID` – Azure tenant that hosts the Teams app.
-   `TEAMS_CHANNEL_ID_ONBOARD` – channel ID for onboarding notifications.
