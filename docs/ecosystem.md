---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Overview of DevOnboarder's integration with the TAGS platform stack and service architecture
document_type: overview
merge_candidate: false
project: DevOnboarder
similarity_group: ecosystem.md-docs
status: active
tags:
- overview
- architecture
- tags-platform
- ecosystem
title: DevOnboarder Ecosystem and TAGS Stack
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder and the TAGS Stack

DevOnboarder is one of several services that make up the TAGS platform. The stack relies on
Docker Compose to orchestrate each component. Shared authentication allows users to move
between services seamlessly. The table below lists the default interfaces and ports.

| Service             | Description                               | Port |
| ------------------- | ----------------------------------------- | ---- |

| Auth Server         | Provides Discord OAuth and JWT issuance   | 8002 |
| XP API              | Tracks onboarding progress and experience | 8001 |
| Integration Service | Handles Discord role syncing              | 8081 |
| DevOnboarder Server | Greeting and status endpoints             | 8000 |

All services depend on the same Postgres database container exposed on port 5432. The auth

service issues tokens consumed by the other agents. Each agent exposes a `/health` endpoint so
Docker Compose can verify readiness.

TAGS deployments typically run behind a reverse proxy. Local development exposes the ports
directly on `localhost` as shown above.
