---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-04
description: "Step-by-step migration from .env token management to dedicated .tokens"

document_type: guide
merge_candidate: false
priority: high
project: DevOnboarder
similarity_group: TOKEN_MIGRATION_GUIDE.md-docs
status: implementation
tags: 
title: "Token Architecture v2.0 Migration Guide"

updated_at: 2025-10-27
visibility: internal
---

# Token Architecture v2.0 Migration Guide

## Overview

This guide walks through migrating DevOnboarder from mixed `.env` token management to the new **Token Architecture v2.0** with **automatic file creation**.

### 🆕 **Auto-Creation Feature**

The new system includes automatic `.tokens` file creation - missing files are created with appropriate templates automatically. See [TOKEN_AUTO_CREATION.md](TOKEN_AUTO_CREATION.md) for complete details.

## 🎯 Migration Benefits

### Before (Mixed System)

- Tokens scattered across `.env*` files

- Complex exclusion rules for security

- Configuration and authentication mixed

- Agent confusion about token placement

### After (Token Architecture v2.0)

- **Clear separation**: Configuration (`.env*`) vs Authentication (`.tokens*`)

- **Enhanced security**: Environment-specific token boundaries

- **Standardized loading**: All services use same token loader

- **DevOnboarder compliance**: Aligns with "quiet reliability" philosophy

##  Migration Steps

### Phase 1: Setup Token Architecture (30 minutes)

#### Step 1.1: Create Token Files Structure

```bash

# Create token templates

bash scripts/sync_tokens.sh --create-templates

# This creates

# .tokens.dev (gitignored)

# .tokens.ci (committed with test values)

# .tokens.prod (gitignored)

```bash

## Step 1.2: Verify Enhanced Potato Policy Protection

```bash

# Verify .tokens files are protected

git status --short

# Should NOT show .tokens.dev or .tokens.prod as untracked

# Should show .tokens.ci as ready to commit

```bash

## Phase 2: Migrate Existing Tokens (45 minutes)

### Step 2.1: Extract Tokens from Current .env

```bash

# Create source .tokens file from existing tokens

# MANUAL STEP: Extract these tokens from your .env

cat > .tokens << 'EOF'

# GitHub Authentication Tokens

AAR_TOKEN=your_actual_aar_token_here
CI_ISSUE_AUTOMATION_TOKEN=your_actual_ci_issue_token_here
CI_BOT_TOKEN=your_actual_ci_bot_token_here

# Discord Integration

DISCORD_BOT_TOKEN=your_actual_discord_bot_token_here
DISCORD_CLIENT_SECRET=your_actual_discord_client_secret_here

# Service Authentication

BOT_JWT=your_actual_bot_jwt_here

# Infrastructure Tokens

TUNNEL_TOKEN=your_actual_tunnel_token_here
CF_DNS_API_TOKEN=your_actual_cloudflare_token_here

# Orchestration Tokens

DEV_ORCHESTRATION_BOT_KEY=your_actual_dev_orchestration_token_here
PROD_ORCHESTRATION_BOT_KEY=your_actual_prod_orchestration_token_here
STAGING_ORCHESTRATION_BOT_KEY=your_actual_staging_orchestration_token_here
EOF

```bash

## Step 2.2: Synchronize to Environment Files

```bash

# Synchronize .tokens to all environment-specific files

bash scripts/sync_tokens.sh --sync-all

# Validate synchronization

bash scripts/sync_tokens.sh --validate-only

```bash

## Step 2.3: Remove Tokens from .env Files

```bash

# MANUAL STEP: Remove these lines from .env files

# - AAR_TOKEN=*

# - CI_ISSUE_AUTOMATION_TOKEN=*

# - CI_BOT_TOKEN=*

# - DISCORD_BOT_TOKEN=*

# - DISCORD_CLIENT_SECRET=*

# - BOT_JWT=*

# - TUNNEL_TOKEN=*

# - CF_DNS_API_TOKEN=*

# - DEV_ORCHESTRATION_BOT_KEY=*

# - PROD_ORCHESTRATION_BOT_KEY=*

# - STAGING_ORCHESTRATION_BOT_KEY=*

# Keep only configuration variables in .env files

# - DATABASE_URL

# - CORS_ALLOW_ORIGINS

# - APP_ENV

# - DISCORD_CLIENT_ID

# - API_BASE_URL

# etc

```bash

## Phase 3: Update Service Integration (60 minutes)

### Step 3.1: Update Python Services

```python

# OLD: Manual environment loading

from dotenv import load_dotenv
load_dotenv()

# NEW: Use centralized token loader

from scripts.token_loader import load_tokens
load_tokens()

```bash

## Files to update

- `src/devonboarder/api.py`

- `src/xp/api/__init__.py`

- `src/discord_integration/api.py`

- `scripts/generate_aar.py`

- `scripts/aar_security.py`

### Step 3.2: Update Docker Compose Files

```yaml

# OLD: Single .env file

services:
  backend:
    env_file: [.env.dev]

# NEW: Separate configuration and tokens

services:
  backend:
    env_file:

      - .env.dev      # Configuration

      - .tokens.dev   # Authentication

```bash

## Files to update (2)

- `docker-compose.dev.yaml`

- `docker-compose.prod.yaml`

- `docker-compose.ci.yaml`

### Step 3.3: Update GitHub Actions Workflows

```yaml

# OLD: Mixed environment loading

- name: Setup Environment

  run: source .env.ci

# NEW: Explicit token and config loading

- name: Setup CI Tokens

  run: cp .tokens.ci .tokens

- name: Load Environment

  run: |
    source .env.ci      # Configuration

    source .tokens.ci   # Authentication

```bash

## Files to update (3)

- `.github/workflows/ci.yml`

- `.github/workflows/auto-fix.yml`

- `.github/workflows/codex.ci.yml`

### Step 3.4: Update Shell Scripts

```bash

# OLD: Manual environment loading (2)

source .env

# NEW: Use token loading function

source scripts/load_tokens.sh

```bash

## Files to update (4)

- `scripts/generate_aar.py` (already uses Python loader)

- `scripts/fix_aar_tokens.sh` (update to use new system)

- Any scripts that need tokens

### Phase 4: Testing & Validation (30 minutes)

#### Step 4.1: Test Token Loading

```bash

# Test token loader

python scripts/token_loader.py info
python scripts/token_loader.py validate AAR_TOKEN CI_ISSUE_AUTOMATION_TOKEN

# Test token manager

python scripts/token_manager.py

```bash

## Step 4.2: Test Service Integration

```bash

# Test services can load tokens

cd src/devonboarder && python -c "from scripts.token_loader import load_tokens; load_tokens(); import os; print('' if os.environ.get('AAR_TOKEN') else '')"

# Test Docker Compose

docker compose -f docker-compose.dev.yaml config

```bash

## Step 4.3: Test CI Integration

```bash

# Test CI token loading

CI=true python scripts/token_loader.py info

# Should show tokens_file: ".tokens.ci"

# Validate CI has test values only

grep -E "(placeholder|test)" .tokens.ci

```bash

## Phase 5: Documentation Updates (15 minutes)

### Update Project Documentation

- Update `docs/env.md` to document new separation

- Update `README.md` setup instructions

- Update `.github/copilot-instructions.md` with new patterns

##  Implementation Checklist

### Core Infrastructure

- [x] Created `scripts/token_loader.py` - Centralized token loading

- [x] Created `scripts/sync_tokens.sh` - Token synchronization system

- [x] Created `.tokens.ci` - CI test tokens (committed)

- [x] Updated Enhanced Potato Policy - Protection for `.tokens*` files

- [ ] Create `.tokens` - Source of truth (manual step)

- [ ] Create `.tokens.dev` - Development tokens (manual step)

### Service Integration

- [ ] Update Python services to use `token_loader`

- [ ] Update Docker Compose files for dual env_file loading

- [ ] Update GitHub Actions workflows for token/config separation

- [ ] Update shell scripts to use new token loading

### Testing & Validation

- [x] Test token loader functionality

- [ ] Test service integration

- [ ] Test CI integration

- [ ] Validate security boundaries

### Documentation

- [x] Created migration guide

- [x] Created architecture documentation

- [ ] Update existing docs

- [ ] Update setup instructions

## 🚨 Critical Security Notes

### During Migration

1. **NEVER commit actual tokens** during migration

2. **Test with CI tokens first** before using real tokens

3. **Validate .tokens files are gitignored** before adding real tokens

4. **Double-check CI files only have test values**

### Post-Migration

1. **Audit token permissions** regularly with `python scripts/token_manager.py`

2. **Keep .tokens synchronized** with `bash scripts/sync_tokens.sh --sync-all`

3. **Monitor for token leaks** in committed files

## 🎯 Success Criteria

### Technical Validation

- [ ] All tokens loaded from `.tokens*` files, not `.env*` files

- [ ] CI uses only test token values

- [ ] Production/development tokens properly gitignored

- [ ] All services use standardized token loading

### Security Validation

- [ ] No production tokens in committed files

- [ ] Enhanced Potato Policy protects all `.tokens*` files

- [ ] Token synchronization respects security boundaries

- [ ] Regular token permission audits working

### DevOnboarder Compliance

- [ ] "Quiet reliability" - system works without manual intervention

- [ ] Clear separation of concerns - config vs authentication

- [ ] Standardized patterns across all services

- [ ] Comprehensive documentation and error handling

---

## 🆘 Troubleshooting

### Common Issues

**Issue**: `Token file not found: .tokens`
**Solution**: Create source `.tokens` file with your actual tokens

**Issue**: `AAR_TOKEN missing required permissions`
**Solution**: Update GitHub token permissions as per `docs/token-setup-guide.md`

**Issue**: CI failing after migration
**Solution**: Verify `.tokens.ci` committed and contains test values only

### Rollback Plan

If migration fails, rollback by:

1. Restore tokens to `.env` files from backup

2. Remove `.tokens*` files

3. Revert service integration changes

4. Continue with old mixed system until issues resolved

---

**Status**: Ready for Implementation

**Estimated Time**: 3-4 hours for complete migration
**Risk Level**: Medium (requires careful token handling)
**Next Step**: Begin Phase 1 - Setup Token Architecture
