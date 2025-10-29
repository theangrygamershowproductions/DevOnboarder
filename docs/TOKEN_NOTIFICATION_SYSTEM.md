---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-04
description: "Comprehensive notification capabilities for missing tokens in DevOnboarder"

document_type: documentation
merge_candidate: false
priority: high
project: DevOnboarder
similarity_group: TOKEN_NOTIFICATION_SYSTEM.md-docs
status: implemented
tags: 
title: "Token Missing Notification System"

updated_at: 2025-10-27
visibility: internal
---

# Token Missing Notification System

## Overview

DevOnboarder's **Token Architecture v2.0** includes comprehensive notification capabilities that automatically alert users when required tokens are missing from the environment. This integrates seamlessly with the **Auto-Creation System** - see [TOKEN_AUTO_CREATION.md](TOKEN_AUTO_CREATION.md) for automatic file creation features.

## 🔔 **Notification Methods**

### 1. **Python Service Integration**

#### Automatic Service Startup Validation

```python
from scripts.token_loader import require_tokens

# Define required tokens for your service

REQUIRED_TOKENS = ["AAR_TOKEN", "CI_ISSUE_AUTOMATION_TOKEN"]

# Validate on startup with automatic notifications

if not require_tokens(REQUIRED_TOKENS, "My Service"):
    sys.exit(1)  # Service won't start if tokens missing

```bash

## Manual Token Validation

```python
from scripts.token_loader import validate_required_tokens

# Check tokens with notifications

status = validate_required_tokens(["AAR_TOKEN", "CI_ISSUE_AUTOMATION_TOKEN"])

# Shows missing token notifications automatically

```bash

## 2. **Shell Script Integration**

### Service Startup Validation

```bash

# Source the token requirement functions

source scripts/require_tokens.sh

# Validate tokens for your service

if ! require_tokens "My Service" AAR_TOKEN CI_ISSUE_AUTOMATION_TOKEN; then
    exit 1  # Service won't start if tokens missing

fi

```bash

## Direct Command Usage

```bash

# Test token requirements directly

./scripts/require_tokens.sh "AAR Service" AAR_TOKEN CI_ISSUE_AUTOMATION_TOKEN

```bash

## 3. **CLI Validation Commands**

### Interactive Token Validation

```bash

# Validate specific tokens with notifications

python scripts/token_loader.py validate AAR_TOKEN CI_ISSUE_AUTOMATION_TOKEN

# Load tokens and show info

python scripts/token_loader.py info

# Comprehensive token analysis

python scripts/token_manager.py

```bash

##  **Notification Features**

###  **What Gets Notified**

1. **Missing Token Detection** - Clear visual indicators for each missing token

2. **Environment-Specific Guidance** - Different instructions for CI vs development

3. **Fix Instructions** - Step-by-step commands to resolve issues

4. **Documentation References** - Links to setup guides and architecture docs

5. **Environment Debugging** - Current configuration and file locations

6. **Service Impact** - Which services are affected by missing tokens

### 🎯 **Notification Examples**

#### Development Environment

```bash
  MISSING TOKENS DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AAR_TOKEN
 CI_ISSUE_AUTOMATION_TOKEN

 TO FIX MISSING TOKENS:
   1. Add missing tokens to: /home/user/DevOnboarder/.tokens

   2. Run: bash scripts/sync_tokens.sh --sync-all

   3. Test: python scripts/token_loader.py validate AAR_TOKEN CI_ISSUE_AUTOMATION_TOKEN

📚 For token setup guidance:
   See: docs/token-setup-guide.md
   Architecture: docs/TOKEN_ARCHITECTURE.md

 ENVIRONMENT CHECK:
   Current tokens file: .tokens
   Project root: /home/user/DevOnboarder
   APP_ENV: not set
   CI: not set

```bash

#### CI Environment

```bash
  MISSING TOKENS DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 NONEXISTENT_TOKEN

 TO FIX MISSING TOKENS:
   CI Environment: Check .tokens.ci file has test values
   File: /home/user/DevOnboarder/.tokens.ci

 ENVIRONMENT CHECK:
   Current tokens file: .tokens.ci
   Project root: /home/user/DevOnboarder
   APP_ENV: not set
   CI: true

```bash

##  **Integration Patterns**

### 1. **FastAPI Service Integration**

```python

# src/myservice/api.py

from scripts.token_loader import require_tokens

def create_app():
    # Validate required tokens before starting service

    REQUIRED_TOKENS = ["AAR_TOKEN", "CI_ISSUE_AUTOMATION_TOKEN"]

    if not require_tokens(REQUIRED_TOKENS, "MyService API"):
        raise RuntimeError("Cannot start service - missing required tokens")

    app = FastAPI()
    # ... rest of app initialization

    return app

```bash

## 2. **Discord Bot Integration**

```python

# bot/main.py

from scripts.token_loader import require_tokens

def main():
    REQUIRED_TOKENS = ["DISCORD_BOT_TOKEN", "BOT_JWT"]

    if not require_tokens(REQUIRED_TOKENS, "Discord Bot"):
        sys.exit(1)

    # Bot initialization continues...

```bash

## 3. **Shell Script Integration**

```bash

#!/bin/bash

# scripts/my_script.sh

# Source token requirements

source "$(dirname "$0")/require_tokens.sh"

# Validate required tokens

if ! require_tokens "My Script" AAR_TOKEN CI_ISSUE_AUTOMATION_TOKEN; then
    echo "Script cannot continue without required tokens"
    exit 1
fi

# Script logic continues

```bash

## 4. **Docker Compose Health Checks**

```yaml

# docker-compose.dev.yaml

services:
  backend:
    environment:

      - REQUIRED_TOKENS=AAR_TOKEN,CI_ISSUE_AUTOMATION_TOKEN

    healthcheck:
      test: ["CMD", "python", "scripts/token_loader.py", "validate", "AAR_TOKEN", "CI_ISSUE_AUTOMATION_TOKEN"]
      interval: 30s
      retries: 3

```bash

## 🎛️ **Configuration Options**

### Notification Control

```python

# Disable notifications for silent validation

status = validate_required_tokens(tokens, notify_missing=False)

# Enable notifications (default)

status = validate_required_tokens(tokens, notify_missing=True)

```bash

## Environment Detection

- **Automatic**: System detects CI vs development environment

- **Manual Override**: Set `APP_ENV` or `CI` environment variables

- **File Selection**: Automatically uses appropriate `.tokens.*` file

##  **Monitoring & Debugging**

### Token Status Monitoring

```bash

# Comprehensive token analysis (2)

python scripts/token_manager.py

# Quick token file status

python scripts/token_loader.py info

# Token synchronization validation

bash scripts/sync_tokens.sh --validate-only

```bash

## Integration Testing

```bash

# Test service integration

python examples/service_with_token_validation.py

# Test shell integration

./scripts/require_tokens.sh "Test Service" AAR_TOKEN

```bash

## 🚦 **Usage Guidelines**

### When to Use Notifications

 **DO Use For**:

- Service startup validation

- Critical operation token checks

- Development environment setup

- CI/CD pipeline validation

 **DON'T Use For**:

- High-frequency token checks

- Background processes (use `notify_missing=False`)

- Optional token validation

### Best Practices

1. **Define token requirements early** in service initialization

2. **Use descriptive service names** for clear error messages

3. **Test notification flow** during development

4. **Document token requirements** in service documentation

5. **Include token validation** in health checks

## 🎯 **Answer to Original Question**

**YES** - The Token Architecture v2.0 provides comprehensive notification methods for missing tokens:

1. **Proactive Notifications**: Services automatically check required tokens on startup

2. **Environment-Aware Guidance**: Different instructions for CI vs development

3. **Clear Visual Indicators**: Emojis and formatting for easy identification

4. **Actionable Instructions**: Specific commands to fix token issues

5. **Multiple Integration Methods**: Python, shell, CLI, and Docker support

6. **Silent Mode Available**: Can disable notifications when needed

The system ensures users are immediately notified when tokens are missing and provides clear guidance on how to resolve the issues.

---

**Status**: Fully Implemented

**Integration**: Ready for all DevOnboarder services
**Testing**: Validated across Python and shell environments
