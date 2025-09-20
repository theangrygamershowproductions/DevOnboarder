---
author: DevOnboarder Team

codex-agent:
  name: Agent.MsTeamsIntegration
  output: Teams channel messages
  role: Sends DevOnboarder updates to Microsoft Teams
  scope: infrastructure notifications
  triggers: Project events requiring team alerts
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: core-agents
similarity_group: documentation-documentation
status: active
tags:

- documentation

title: Ms Teams Integration
updated_at: '2025-09-12'
visibility: internal
---

# MS Teams Integration Agent

**Status:** Planned.

**Purpose:** Provides Microsoft Teams notifications and channel integrations for project updates.

**Key Files:** To be determined when work begins.

## Environment Variables

- `TEAMS_APP_ID` – Azure application (client) ID for the integration.

- `TEAMS_APP_PASSWORD` – application secret used to obtain access tokens.

- `TEAMS_TENANT_ID` – Azure tenant that hosts the Teams app.

- `TEAMS_CHANNEL_ID_ONBOARD` – channel ID for onboarding notifications.
