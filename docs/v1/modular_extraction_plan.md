---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: v1-v1
status: active
tags:

- documentation

title: Modular Extraction Plan
updated_at: '2025-09-12'
visibility: internal
---

# Phase 2 Modular Extraction Plan

**Date**: 2025-08-03
**Phase**: DevOnboarder Phase 2 Rollout
**Status**: In Progress

## Overview

This document outlines the plan for extracting the Discord bot and frontend components into separate repositories as part of the Phase 2 modularization effort.

## Extraction Targets

### 1. Discord Bot  `tags-discord-bot`

**Source Directory**: `/bot/`
**Target Repository**: `tags-discord-bot`
**Dependencies**:

- Node.js 22

- TypeScript

- Discord.js

- Jest for testing

**Files to Extract**:

- `bot/` (entire directory)

- `bot/package.json` and `package-lock.json`

- `bot/tsconfig.json`

- `bot/eslint.config.js`

- `bot/.prettierrc`

- `bot/README.md`

- Related CI workflows (bot-specific)

**Standalone Requirements**:

- Independent Docker builds

- Standalone CI/CD pipeline

- Environment configuration

- Deployment scripts

### 2. Frontend  `tags-devonboarder-ui`

**Source Directory**: `/frontend/`
**Target Repository**: `tags-devonboarder-ui`
**Dependencies**:

- Node.js 22

- React  Vite

- TypeScript

- Vitest for testing

**Files to Extract**:

- `frontend/` (entire directory)

- `frontend/package.json` and `package-lock.json`

- `frontend/vite.config.ts`

- `frontend/tsconfig.json`

- `frontend/eslint.config.js`

- `frontend/.prettierrc`

- Related CI workflows (frontend-specific)

## Docker Compose Updates Required

### Main Repository (`DevOnboarder`)

- Remove bot and frontend services

- Update service dependencies

- Maintain backend, auth, and database services

### Bot Repository (`tags-discord-bot`)

- Standalone docker-compose.yml

- Bot service with environment configuration

- Optional database connection for development

### Frontend Repository (`tags-devonboarder-ui`)

- Standalone docker-compose.yml

- Frontend service with dev server

- Proxy configuration for backend API

## CI/CD Integration

### Current State

- All services built and tested in single CI pipeline

- Shared environment variables and secrets

- Integrated test coverage reporting

### Target State

- Independent CI pipelines per repository

- Service-specific environment variables

- Cross-repository integration testing

- Coordinated deployment orchestration

## Implementation Steps

### Phase 1: Repository Preparation

1. Create new repositories: `tags-discord-bot` and `tags-devonboarder-ui`

2. Set up basic repository structure and README files

3. Configure repository settings and permissions

### Phase 2: Code Migration

1. Copy bot and frontend directories to new repositories

2. Update package.json files for standalone operation

3. Create standalone Docker configurations

4. Migrate relevant documentation

### Phase 3: CI/CD Setup

1. Create CI pipelines for each repository

2. Configure environment variables and secrets

3. Set up cross-repository integration hooks

4. Test deployment pipelines

### Phase 4: Integration Testing

1. Test standalone builds and deployments

2. Verify cross-service communication

3. Update main repository to remove extracted components

4. Test full system integration

## Dependencies and Considerations

### Shared Dependencies

- Authentication service (backend)

- Database connections

- Environment configurations

- Logging and monitoring

### Breaking Changes

- Repository structure changes

- Build process modifications

- Deployment procedure updates

- Developer workflow changes

## Rollback Plan

If extraction causes issues:

1. Revert main repository changes

2. Keep extracted repositories as experimental

3. Maintain current monorepo structure

4. Document lessons learned for future attempts

## Success Criteria

- [ ] Bot repository builds and deploys independently

- [ ] Frontend repository builds and deploys independently

- [ ] All existing functionality preserved

- [ ] CI/CD pipelines functional for all repositories

- [ ] Integration testing passes

- [ ] Documentation updated across all repositories

---

## LINK: GitHub Issue Tracking

**Phase 2 DevOnboarder Readiness Issues**:

- **Security Token Rotation**: [#1062](https://github.com/theangrygamershowproductions/DevOnboarder/issues/1062)

    - Comprehensive security token rotation infrastructure

    - GitHub, Discord, Database, and JWT credential management

    - Complete validation framework ready for execution

- **Modular Repository Extraction**: [#1063](https://github.com/theangrygamershowproductions/DevOnboarder/issues/1063)

    - Discord bot and frontend component separation

    - Repository creation and standalone deployment

    - Cross-service integration testing

- **Agent Certification System**: [#1064](https://github.com/theangrygamershowproductions/DevOnboarder/issues/1064)

    - Codex agent validation and reindexing

    - Bot permissions verification

    - Automation system certification

**Next Actions**:

1. Execute token rotation (Issue #1062) - **PRIORITY: Complete first**

2. Create target repositories and begin extraction (Issue #1063)

3. Complete agent certification (Issue #1064) - **Can run in parallel**

4. Validate full system integration across all repositories
