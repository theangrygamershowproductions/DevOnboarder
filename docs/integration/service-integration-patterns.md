---
author: TAGS Engineering

codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: API conventions, Discord bot patterns, database integration, and multi-service
  communication standards
document_type: standards
merge_candidate: false
project: core-instructions
related_modules:

- architecture-overview.md

- common-integration-points.md

similarity_group: integration-standards
source: .github/copilot-instructions.md
status: active
tags:

- devonboarder

- service-integration

- api-patterns

- discord-bot

- database

title: DevOnboarder Service Integration Patterns
updated_at: '2025-09-11'
visibility: internal
---

# DevOnboarder Service Integration Patterns

## Service Integration Patterns

### 1. API Conventions

- **Health checks**: All services expose `/health` endpoint

- **Authentication**: JWT tokens issued by auth service

- **CORS**: Properly configured for frontend integration

- **Documentation**: FastAPI auto-generated docs required

### 2. Discord Bot Patterns

- **Multi-guild support**: Automatic environment routing

- **Commands**: `/verify`, `/dependency_inventory`, `/qa_checklist`, `/onboard`

- **Role-based access**: Comprehensive permission model

- **Management**: Use `npm run invite|status|test-guilds|dev`

- **Environment detection**: Guild ID-based routing in bot code

```typescript
// Multi-environment routing example
const guildId = interaction.guild?.id;
const isDevEnvironment = guildId === "1386935663139749998";
const isProdEnvironment = guildId === "1065367728992571444";

```

- **Startup logging**: Bot provides detailed environment info on startup

- **ESLint v9 flat config**: Use `eslint.config.js` format, not legacy `.eslintrc`

### 3. Database Patterns

- **Migrations**: Alembic for schema changes

- **Models**: SQLAlchemy with proper relationships

- **Connection**: Environment-specific (SQLite dev, PostgreSQL prod)
