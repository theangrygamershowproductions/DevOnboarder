---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: TOKEN_AUTO_CREATION.md-docs
status: active
tags:

- documentation

title: Token Auto Creation
updated_at: '2025-09-12'
visibility: internal
---

# Token Auto-Creation System

## Overview

DevOnboarder's Token Architecture v2.0 includes automatic `.tokens` file creation when files don't exist. This eliminates setup friction and ensures developers have all necessary token placeholders configured correctly.

## How It Works

### Automatic Detection

When the token loader tries to load a `.tokens` file that doesn't exist:

1. **Detection**: System detects missing file

2. **Environment Analysis**: Determines environment (CI, dev, prod, default)

3. **Template Creation**: Creates appropriate template with environment-specific placeholders

4. **User Notification**: Provides clear guidance on next steps

### Environment-Specific Templates

The system creates different templates based on detected environment:

#### Default Environment (`.tokens`)

```bash

# Example usage

python scripts/token_loader.py load

```

**Template Features:**

- **Placeholders**: `CHANGE_ME_*_here` format

- **Security Note**: "GITIGNORED - Source of truth, never commit"

- **Purpose**: Main configuration file for local development

#### Development Environment (`.tokens.dev`)

```bash

# Example usage

APP_ENV=development python scripts/token_loader.py load

```

**Template Features:**

- **Placeholders**: `CHANGE_ME_DEV_*_here` format

- **Security Note**: "GITIGNORED - Development secrets, never commit"

- **Purpose**: Development-specific token values

#### Production Environment (`.tokens.prod`)

```bash

# Example usage

APP_ENV=production python scripts/token_loader.py load

```

**Template Features:**

- **Placeholders**: `CHANGE_ME_PROD_*_here` format

- **Security Note**: "GITIGNORED - Production secrets, never commit"

- **Purpose**: Production token values (highest security)

#### CI Environment (`.tokens.ci` or CI=true)

```bash

# Example usage

CI=true python scripts/token_loader.py load

```

**Template Features:**

- **Placeholders**: `ci_test_*_placeholder` format

- **Security Note**: "COMMITTED - Test values only, no production secrets"

- **Purpose**: Safe test values for continuous integration

### Standard Token Fields

All generated templates include the complete set of DevOnboarder tokens:

```plaintext

# GitHub Authentication Tokens

AAR_TOKEN=<placeholder>
CI_ISSUE_AUTOMATION_TOKEN=<placeholder>
CI_BOT_TOKEN=<placeholder>

# Discord Integration Tokens

DISCORD_BOT_TOKEN=<placeholder>
DISCORD_CLIENT_SECRET=<placeholder>

# Service Authentication Tokens

BOT_JWT=<placeholder>

# Infrastructure Tokens

TUNNEL_TOKEN=<placeholder>
CF_DNS_API_TOKEN=<placeholder>

# Orchestration Tokens

DEV_ORCHESTRATION_BOT_KEY=<placeholder>
PROD_ORCHESTRATION_BOT_KEY=<placeholder>
STAGING_ORCHESTRATION_BOT_KEY=<placeholder>

```

## Enhanced Placeholder Detection

The validation system now detects placeholder values as invalid:

### Placeholder Patterns Detected

- `CHANGE_ME_*` - Standard placeholder format

- `ci_test_*` - CI test placeholder format

- `*_here` - Template suffix indicating incomplete setup

- `*_placeholder` - Explicit placeholder marker

### Example Validation

```python

# This will show tokens as invalid even though they exist in file

from scripts.token_loader import require_tokens

success = require_tokens(['AAR_TOKEN', 'DISCORD_BOT_TOKEN'], 'My Service')

# Output: ❌ My Service: CANNOT START - Missing required tokens

```

## User Experience

### First-Time Setup Flow

1. **Service Startup**: Service tries to load tokens

2. **Missing File Detection**: System detects no `.tokens` file exists

3. **Automatic Creation**: Template file created with all necessary fields

4. **Clear Guidance**: User gets specific instructions on next steps

### Sample Output

```plaintext
⚠️  Token file not found: /path/to/.tokens
💡 Creating template: .tokens
✅ Created template token file: /path/to/.tokens
📝 Please fill in your actual token values!

```

### Follow-Up Instructions

The created template includes comprehensive setup instructions:

```plaintext

# =============================================================================

# SETUP INSTRUCTIONS

# 1. Replace all 'CHANGE_ME_*_here' values with actual tokens

# 2. Run: bash scripts/sync_tokens.sh --sync-all

# 3. Test: python scripts/token_loader.py validate <TOKEN_NAMES>

#

# For token acquisition guidance, see

# - docs/token-setup-guide.md

# - docs/TOKEN_ARCHITECTURE.md

# =============================================================================

```

## Integration Examples

### Service Integration

```python
#!/usr/bin/env python3
"""Service with automatic token setup."""

from scripts.token_loader import require_tokens

def main():
    # This will auto-create .tokens file if missing

    if not require_tokens(['AAR_TOKEN', 'DISCORD_BOT_TOKEN'], 'My Service'):
        return 1

    # Service logic here

    print("Service starting with valid tokens...")
    return 0

if __name__ == "__main__":
    exit(main())

```

### Shell Script Integration

```bash
#!/bin/bash

# Service startup with token validation

source scripts/require_tokens.sh

# This will auto-create and validate tokens

if ! require_tokens "AAR_TOKEN DISCORD_BOT_TOKEN" "My Shell Service"; then
    echo "Cannot start service without tokens"
    exit 1
fi

echo "Service starting with valid tokens..."

```

## Security Features

### Environment-Appropriate Security

- **CI Files**: Safe test values, can be committed

- **Development Files**: Gitignored, local development only

- **Production Files**: Gitignored, highest security

- **Default Files**: Gitignored, source of truth

### Enhanced Potato Policy Integration

All `.tokens*` files are automatically protected by Enhanced Potato Policy:

- **Git Protection**: Added to `.gitignore` (except CI files)

- **Docker Protection**: Added to `.dockerignore`

- **Documentation Protection**: Added to `.codespell-ignore`

## Benefits

### Developer Experience

- **Zero Manual Setup**: Templates created automatically

- **Complete Coverage**: All DevOnboarder tokens included

- **Clear Instructions**: Step-by-step guidance provided

- **Environment Awareness**: Appropriate placeholders for context

### Operational Benefits

- **Consistent Structure**: All environments use same token format

- **Security Boundaries**: Appropriate security levels per environment

- **Validation Integration**: Placeholder detection prevents invalid configurations

- **Synchronization Ready**: Templates work with sync system out of box

## Troubleshooting

### Common Issues

#### Template Creation Fails

```bash

# Check permissions

ls -la /path/to/project/

# Verify directory exists and is writable

```

#### Wrong Environment Detected

```bash

# Check environment variables

echo "APP_ENV: $APP_ENV"
echo "CI: $CI"

# Force specific environment

APP_ENV=development python scripts/token_loader.py load

```

#### Placeholder Values Not Detected

```bash

# Validate specific tokens

python scripts/token_loader.py validate AAR_TOKEN

# Should show ❌ for placeholder values

```

### Recovery Commands

```bash

# Recreate template (removes existing file)

rm .tokens && python scripts/token_loader.py load

# Test validation after filling tokens

python scripts/token_loader.py validate AAR_TOKEN DISCORD_BOT_TOKEN

# Synchronize after template creation

bash scripts/sync_tokens.sh --sync-all

```

## File Locations

- **Templates**: Auto-created in project root

- **Documentation**: `docs/TOKEN_ARCHITECTURE.md`

- **Scripts**: `scripts/token_loader.py`, `scripts/sync_tokens.sh`

- **Examples**: `examples/service_with_token_validation.py`

## Related Documentation

- [Token Architecture v2.0](TOKEN_ARCHITECTURE.md)

- [Token Migration Guide](TOKEN_MIGRATION_GUIDE.md)

- [Token Notification System](TOKEN_NOTIFICATION_SYSTEM.md)

- [Enhanced Potato Policy](enhanced-potato-policy.md)
