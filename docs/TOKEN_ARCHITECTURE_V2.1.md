---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: TOKEN_ARCHITECTURE_V2.1.md-docs
status: active
tags:

- documentation

title: Token Architecture V2.1
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder Token Architecture v2.1 - Separation of Concerns

## Overview

This document defines the **corrected** DevOnboarder token architecture that properly separates CI/CD automation tokens from application runtime tokens.

## Token Classification

###  CI/CD Automation Tokens (`.tokens*` files)

**Purpose**: Build, deployment, and automation processes
**Lifecycle**: Managed by DevOps/Infrastructure team
**Usage**: GitHub Actions, CI/CD pipelines, automated scripts

```bash

# These tokens go in .tokens files

AAR_TOKEN=                          # GitHub PAT for After Action Reports

CI_BOT_TOKEN=                       # GitHub PAT for CI automation

CI_ISSUE_AUTOMATION_TOKEN=          # GitHub PAT for issue management

DEV_ORCHESTRATION_BOT_KEY=          # GitHub PAT for dev orchestration

PROD_ORCHESTRATION_BOT_KEY=         # GitHub PAT for prod orchestration

STAGING_ORCHESTRATION_BOT_KEY=      # GitHub PAT for staging orchestration

```

###  Application Runtime Tokens (`.env*` files)

**Purpose**: Service runtime authentication and integration
**Lifecycle**: Managed by Development team
**Usage**: Discord bot, service-to-service auth, external APIs

```bash

# These tokens STAY in .env files

DISCORD_BOT_TOKEN=                  # Discord bot authentication

DISCORD_CLIENT_SECRET=              # Discord OAuth

BOT_JWT=                           # Internal service authentication

CF_DNS_API_TOKEN=                  # Cloudflare infrastructure

TUNNEL_TOKEN=                      # Cloudflare tunnel

```

## Architecture Benefits

###  **Separation of Concerns**

- **CI/CD tokens**: Used only for automation and deployment

- **Runtime tokens**: Used only for application services

###  **Security Boundaries**

- Different rotation schedules and access patterns

- Clear ownership (DevOps vs Development teams)

- Reduced blast radius for token compromise

###  **Operational Clarity**

- CI/CD failures don't affect runtime services

- Runtime issues don't affect CI/CD processes

- Clear troubleshooting paths

## File Structure

```text
DevOnboarder/
── .tokens              # CI/CD automation tokens (GITIGNORED)

── .tokens.dev          # Development CI tokens (GITIGNORED)

── .tokens.prod         # Production CI tokens (GITIGNORED)

── .tokens.ci           # CI test tokens (COMMITTED - safe values)

── .env                 # App config  runtime tokens (GITIGNORED)

── .env.dev             # Development app config (GITIGNORED)

── .env.prod            # Production app config (GITIGNORED)

── .env.ci              # CI app config  test tokens (COMMITTED)

```

## Usage Patterns

### CI/CD Scripts

```bash

# Load CI/CD automation tokens

eval "$(python3 scripts/token_loader.py export --type=cicd)"

```

### Application Services

```python

# Runtime services use standard environment loading

import os
DISCORD_BOT_TOKEN = os.getenv('DISCORD_BOT_TOKEN')

```

### Development Setup

```bash

# Developers need both types

python3 scripts/token_loader.py load --type=cicd    # Creates .tokens

# Edit .tokens with CI/CD tokens

# Edit .env with runtime tokens (as usual)

DISCORD_BOT_TOKEN=your_bot_token

```

## Migration Strategy

### Phase 1: Extract CI/CD Tokens Only

```bash
bash scripts/migrate_cicd_tokens.sh

# Moves only CI/CD tokens from .env to .tokens files

```

### Phase 2: Keep Runtime Tokens in .env

```bash

# No migration needed - runtime tokens stay in .env files

# Existing DevOnboarder services continue working unchanged

```

## Enhanced Token Loader

The `token_loader.py` script will be enhanced to support token types:

```python

# Load only CI/CD tokens

python3 scripts/token_loader.py load --type=cicd

# Load only runtime tokens (from .env)

python3 scripts/token_loader.py load --type=runtime

# Load all tokens (default behavior)

python3 scripts/token_loader.py load --type=all

```

## Security Model

### CI/CD Tokens (.tokens files)

- **Production**: `.tokens.prod` (GITIGNORED)

- **Development**: `.tokens.dev` (GITIGNORED)

- **CI Testing**: `.tokens.ci` (COMMITTED - test values only)

### Runtime Tokens (.env files)

- **Production**: `.env.prod` (GITIGNORED)

- **Development**: `.env.dev` (GITIGNORED)

- **CI Testing**: `.env.ci` (COMMITTED - test values only)

## DevOnboarder Integration

This architecture aligns with DevOnboarder's philosophy:

- **"Works quietly and reliably"**: Clear separation prevents confusion

- **Zero tolerance for hanging**: Proper token loading prevents auth failures

- **Enhanced Potato Policy**: Both token types protected appropriately

## Implementation Status

-  **Current State**: All tokens mixed in `.env` files

-  **Target State**: CI/CD tokens in `.tokens`, runtime tokens in `.env`

- SYNC: **Migration**: Create selective migration script for CI/CD tokens only

---

**Last Updated**: September 4, 2025

**Architecture Version**: v2.1 (Separation of Concerns)
