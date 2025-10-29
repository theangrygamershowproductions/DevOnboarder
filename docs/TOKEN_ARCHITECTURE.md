---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-04
description: "Standardized token management system separating authentication from configuration"

document_type: documentation
merge_candidate: false
priority: high
project: DevOnboarder
similarity_group: TOKEN_ARCHITECTURE.md-docs
status: proposed
tags: 
title: "DevOnboarder Token Management Architecture"

updated_at: 2025-10-27
virtual_env_required: true
visibility: internal
---

# DevOnboarder Token Management Architecture

## Overview

DevOnboarder implements **Token Architecture v2.0** - a standardized token management system with **automatic file creation** that separates authentication tokens from configuration variables for improved security, clarity, and maintainability.

### 🆕 **Auto-Creation System**

The system automatically creates missing `.tokens` files with appropriate templates:

- **🤖 Automatic Detection**: Missing files detected on service startup

- **🌍 Environment-Aware**: Creates templates for dev, CI, and production environments

- ** Complete Placeholders**: All standard DevOnboarder tokens included

- **🔔 User Guidance**: Clear instructions for next steps

**See [TOKEN_AUTO_CREATION.md](TOKEN_AUTO_CREATION.md) for complete auto-creation documentation.**

## Architecture Principles

### 1. **Separation of Concerns**

- **Configuration**: `.env*` files contain application settings, URLs, feature flags

- **Authentication**: `.tokens*` files contain ONLY authentication tokens

- **No mixing**: Tokens never appear in .env files, configuration never in .tokens files

### 2. **Environment-Specific Token Files**

```text

.tokens          # Source of truth (GITIGNORED)

.tokens.dev      # Development tokens (GITIGNORED)

.tokens.ci       # CI test tokens (COMMITTED - test values only)

.tokens.prod     # Production tokens (GITIGNORED)

```

### 3. **Security Boundaries**

- **Production tokens**: NEVER committed to repository

- **CI tokens**: Only test/mock values, safe for commit

- **Enhanced Potato Policy**: Protects .tokens files from accidental exposure

## File Structure

### `.tokens` (Source of Truth)

```bash

# =============================================================================

# DevOnboarder Token Management v2.0

# File: .tokens (Source of Truth)

# Security: GITIGNORED - Contains production tokens

# Synchronization: Use scripts/sync_tokens.sh to propagate

# =============================================================================

# GitHub Authentication Tokens

AAR_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
CI_ISSUE_AUTOMATION_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
CI_BOT_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Discord Integration

DISCORD_BOT_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
DISCORD_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Service Authentication

BOT_JWT=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Infrastructure Tokens

TUNNEL_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
CF_DNS_API_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Orchestration Tokens

DEV_ORCHESTRATION_BOT_KEY=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
PROD_ORCHESTRATION_BOT_KEY=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
STAGING_ORCHESTRATION_BOT_KEY=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

```

### `.tokens.ci` (CI Test Values)

```bash

# =============================================================================

# DevOnboarder Token Management v2.0

# File: .tokens.ci (CI Test Environment)

# Security: COMMITTED - Test values only, no production secrets

# =============================================================================

# GitHub Authentication Tokens (Test Values)

AAR_TOKEN=ci_test_aar_token_placeholder
CI_ISSUE_AUTOMATION_TOKEN=ci_test_issue_automation_token_placeholder
CI_BOT_TOKEN=ci_test_bot_token_placeholder

# Discord Integration (Test Values)

DISCORD_BOT_TOKEN=ci_test_discord_bot_token_placeholder
DISCORD_CLIENT_SECRET=ci_test_discord_client_secret_placeholder

# Service Authentication (Test Values)

BOT_JWT=ci_test_bot_jwt_placeholder

# Infrastructure Tokens (Test Values)

TUNNEL_TOKEN=ci_test_tunnel_token_placeholder
CF_DNS_API_TOKEN=ci_test_cloudflare_token_placeholder

# Orchestration Tokens (Test Values)

DEV_ORCHESTRATION_BOT_KEY=ci_test_dev_orchestration_placeholder
PROD_ORCHESTRATION_BOT_KEY=ci_test_prod_orchestration_placeholder
STAGING_ORCHESTRATION_BOT_KEY=ci_test_staging_orchestration_placeholder

```

## Token Loading System

### 1. **Centralized Token Loader**

All services use standardized token loading:

```python

# Standard pattern for all Python services

from scripts.token_loader import load_tokens

def create_app():
    load_tokens()  # Automatically loads appropriate .tokens file

    # ... rest of app initialization

```

### 2. **Environment Detection**

```python

def get_tokens_file():
    """Determine which tokens file to load based on environment."""
    if os.getenv("CI"):
        return ".tokens.ci"
    elif os.getenv("APP_ENV") == "production":
        return ".tokens.prod"
    elif os.getenv("APP_ENV") == "development":
        return ".tokens.dev"
    else:
        return ".tokens"  # Default/source of truth

```

## Integration Points

### 1. **Docker Compose Integration**

```yaml

# docker-compose.dev.yaml

services:
  backend:
    env_file:
      - .env.dev        # Configuration variables

      - .tokens.dev     # Authentication tokens

```

### 2. **GitHub Actions Integration**

```yaml

# .github/workflows/ci.yml

- name: Setup CI Tokens

  run: cp .tokens.ci .tokens

- name: Load Environment

  run: |
    source .env.ci      # Configuration

    source .tokens.ci   # Authentication

```

### 3. **Script Integration**

All DevOnboarder scripts use standardized token loading:

```bash
#!/bin/bash

# Standard token loading pattern

source scripts/load_tokens.sh

```

## Security Features

### 1. **Enhanced Potato Policy Integration**

- `.gitignore`, `.dockerignore`, `.codespell-ignore` include `.tokens*` patterns

- Pre-commit hooks validate token file security

- CI workflows enforce token isolation

### 2. **Token Validation System**

```bash

# Validate token permissions and availability

python scripts/token_manager.py validate

# Audit token security boundaries

bash scripts/audit_token_security.sh

```

### 3. **Automatic Synchronization**

```bash

# Synchronize tokens across environment files

bash scripts/sync_tokens.sh --sync-all

# Validate synchronization

bash scripts/sync_tokens.sh --validate-only

```

## Migration Strategy

### Phase 1: Implementation (Immediate)

1. Create `.tokens` file structure

2. Implement `scripts/token_loader.py`

3. Update `scripts/token_manager.py` for new system

4. Create `scripts/sync_tokens.sh` for synchronization

### Phase 2: Service Integration (Week 1)

1. Update all Python services to use token loader

2. Update Docker Compose files

3. Update GitHub Actions workflows

4. Update all shell scripts

### Phase 3: Security Hardening (Week 2)

1. Enhanced Potato Policy updates

2. CI validation for token isolation

3. Comprehensive testing

4. Documentation updates

## Benefits

### 1. **Clear Separation of Concerns**

- Configuration in `.env*` files

- Authentication in `.tokens*` files

- No confusion about where tokens belong

### 2. **Enhanced Security**

- Tokens isolated from configuration

- Environment-specific security boundaries

- Clear audit trails

### 3. **Improved Developer Experience**

- Single place for all tokens

- Standardized loading across services

- Clear token hierarchy and usage

### 4. **DevOnboarder Compliance**

- Aligns with "quiet reliability" philosophy

- Follows existing centralized management patterns

- Integrates with Enhanced Potato Policy

## Implementation Checklist

- [ ] Create `.tokens` file structure

- [ ] Implement `scripts/token_loader.py`

- [ ] Update `scripts/token_manager.py`

- [ ] Create `scripts/sync_tokens.sh`

- [ ] Update all service integrations

- [ ] Update Docker Compose files

- [ ] Update GitHub Actions workflows

- [ ] Update Enhanced Potato Policy

- [ ] Create comprehensive tests

- [ ] Update documentation

---

**Status**: Proposed Architecture

**Next Step**: Implement Phase 1 (token file structure and loader)
**Integration**: Seamless with existing DevOnboarder systems
