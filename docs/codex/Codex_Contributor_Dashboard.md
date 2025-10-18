---
author: Chad Reesey

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Dashboard summarizing Codex task progress and module status for contributors.
document_type: documentation
email: reesey275@thenagrygamershow.com
merge_candidate: false
module: Codex Integration
phase: MVP
project: DevOnboarder
similarity_group: ci-automation
status: active
tags:

- dashboard

- codex

- contributors

- roadmap

- automation

title: Codex Contributor Dashboard
updated: 21 June 2025 08:25 (EST)
updated_at: '2025-09-12'
version: v1.0.0
visibility: internal
---

# 🧩 Codex Contributor Dashboard – MVP

This dashboard provides a live snapshot of module status and responsibilities.
It also tracks onboarding readiness for Codex contributors.

| Module           | Path                    | Description                                                     | Status         |
| ---------------- | ----------------------- | --------------------------------------------------------------- | -------------- |

| **auth_service** | `services/auth_service` | Implement Discord OAuth2 login and session issuance.            |  Complete    |

| **xp_api**       | `services/xp_api`       | Fix XP endpoint logic and add contribution POST route.          |  Complete    |

| **discord_bot**  | `bot`                   | Modularize commands and integrate token-based API calls.        |  Complete    |

| **frontend**     | `frontend`              | Scaffold OAuth callback, onboarding UI, and XP dashboard.       | WORK: In Progress |

| **infra_docs**   | `infra`                 | Environment templates, Docker Compose, CI/CD scripts.           |  Complete    |

| **codex_docs**   | `codex`                 | Codex plan, tasks, and automation metadata files.               |  Complete    |

| **project_docs** | `docs`                  | General docs, merge guides, changelog, and onboarding markdown. |  Complete    |

##  Summary

- Use this table to assign, track, and verify Codex contributor progress across all modules.

- Keep this dashboard updated with each commit or milestone push to ensure alignment.
