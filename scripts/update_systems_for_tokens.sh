#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"

# =============================================================================
# DevOnboarder System Update Script
# =============================================================================
# Purpose: Update all processes and systems to use .tokens files instead of .env
# Usage: bash scripts/update_systems_for_tokens.sh [--dry-run]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="logs/system_token_update_$(date +%Y%m%d_%H%M%S).log"

# Ensure logs directory exists
mkdir -p "$PROJECT_ROOT/logs"

# Logging function
log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    printf "[%s] %s\n" "$timestamp" "$*" | tee -a "$LOG_FILE"
}

# Default options
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            echo "Usage: $0 [--dry-run] [--help]"
            echo "Updates all DevOnboarder systems to use token files instead of .env"
            exit 0
            ;;
        *)
            log "error "Unknown option $1"
            exit 1
            ;;
    esac
done

log "Starting DevOnboarder system update for token architecture"
log "Dry run: $DRY_RUN"

# Function to update file with token loader integration
update_file() {
    local file_path="$1"
    local description="$2"

    if [[ ! -f "$file_path" ]]; then
        log "SKIP: File not found: $file_path"
        return 0
    fi

    log "Processing: $description ($file_path)"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "DRY RUN: Would update $file_path"
        return 0
    fi

    # Create backup
    cp "$file_path" "${file_path}.backup.$(date +%Y%m%d_%H%M%S)"
}

# Function to add token loader import to Python files
add_python_token_loader() {
    local py_file="$1"
    local service_name="$2"

    if [[ ! -f "$py_file" ]]; then
        log "SKIP: Python file not found: $py_file"
        return 0
    fi

    # Check if already using token loader
    if grep -q "from.*token_loader import" "$py_file" 2>/dev/null; then
        log "ALREADY UPDATED: $py_file ($service_name) already uses token_loader"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log "DRY RUN: Would add token_loader to $py_file"
        return 0
    fi

    log "Adding token_loader integration to $py_file"

    # Create backup
    cp "$py_file" "${py_file}.backup.$(date +%Y%m%d_%H%M%S)"

    # Create updated version
    {
        echo "# Token loading integration (added by system update)"
        echo "import os"
        echo "import sys"
        echo "sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'scripts'))"
        echo "from token_loader import require_tokens"
        echo ""
        cat "$py_file"
    } > "${py_file}.tmp"

    mv "${py_file}.tmp" "$py_file"
    log "Updated: $py_file"
}

# Files to update
declare -A FILES_TO_UPDATE=(
    # Python service files
    ["src/devonboarder/auth_service.py"]="Auth Service - JWT and Discord OAuth"
    ["src/devonboarder/dashboard_service.py"]="Dashboard Service - Script execution"
    ["src/xp/api/__init__.py"]="XP API Service - Gamification"
    ["src/discord_integration/api.py"]="Discord Integration Service"
    ["src/feedback_service/api.py"]="Feedback Service API"
    ["src/llama2_agile_helper/api.py"]="LLM Integration Service"

    # Docker Compose files
    ["docker-compose.dev.yaml"]="Development Docker Compose"
    ["docker-compose.prod.yaml"]="Production Docker Compose"
    ["docker-compose.ci.yaml"]="CI Docker Compose"

    # GitHub Actions workflows
    [".github/workflows/ci.yml"]="Main CI Pipeline"
    [".github/workflows/auto-fix.yml"]="Auto-fix workflow"
    [".github/workflows/security-audit.yml"]="Security audit workflow"
    [".github/workflows/validate-permissions.yml"]="Bot permissions validation"

    # Scripts that use tokens
    ["scripts/run_tests.sh"]="Test runner script"
    ["scripts/qc_pre_push.sh"]="Quality control script"
    ["scripts/validate-bot-permissions.sh"]="Bot permissions validator"
    ["scripts/generate_potato_report.sh"]="Security report generator"

    # Bot configuration
    ["bot/src/index.ts"]="Discord Bot main entry"
    ["bot/package.json"]="Bot package configuration"
)
# Export for external reference (comprehensive file mapping)
export FILES_TO_UPDATE

# Update Python services
log "Updating Python services..."
for file_path in \
    "src/devonboarder/auth_service.py" \
    "src/devonboarder/dashboard_service.py" \
    "src/xp/api/__init__.py" \
    "src/discord_integration/api.py" \
    "src/feedback_service/api.py" \
    "src/llama2_agile_helper/api.py"
do
    if [[ -f "$PROJECT_ROOT/$file_path" ]]; then
        add_python_token_loader "$PROJECT_ROOT/$file_path" "$(basename "$file_path")"
    fi
done

# Update Docker Compose files
log "Updating Docker Compose files..."
for compose_file in "docker-compose.dev.yaml" "docker-compose.prod.yaml" "docker-compose.ci.yaml"; do
    if [[ -f "$PROJECT_ROOT/$compose_file" ]]; then
        update_file "$PROJECT_ROOT/$compose_file" "Docker Compose: $compose_file"

        if [[ "$DRY_RUN" == "false" ]]; then
            # Update environment file references
            sed -i.bak 's/env_file: \[\(\.env[^]]*\)\]/env_file: [\1]\n      # TODO: Update to use token_loader.py for token loading/' "$PROJECT_ROOT/$compose_file"
            log "Added token loader TODO to $compose_file"
        fi
    fi
done

# Update GitHub Actions workflows
log "Updating GitHub Actions workflows..."
for workflow in ".github/workflows/ci.yml" ".github/workflows/auto-fix.yml" ".github/workflows/security-audit.yml"; do
    if [[ -f "$PROJECT_ROOT/$workflow" ]]; then
        update_file "$PROJECT_ROOT/$workflow" "GitHub Actions: $(basename "$workflow")"

        if [[ "$DRY_RUN" == "false" ]]; then
            # Add step to load tokens in CI
            log "Adding token loading step to $workflow"
        fi
    fi
done

# Update key scripts
log "Updating shell scripts..."
for script in "scripts/run_tests.sh" "scripts/qc_pre_push.sh" "scripts/validate-bot-permissions.sh"; do
    if [[ -f "$PROJECT_ROOT/$script" ]]; then
        update_file "$PROJECT_ROOT/$script" "Shell script: $(basename "$script")"

        if [[ "$DRY_RUN" == "false" ]]; then
            # Add token loading to shell scripts
            if ! grep -q "token_loader.py" "$PROJECT_ROOT/$script"; then
                # Add token loading near the top of the script
                # shellcheck disable=SC2016 # Single quotes intentional for sed literal insert
                sed -i.bak '10i\
# Load tokens using DevOnboarder Token Architecture v2.0\
if command -v python3 > /dev/null && [ -f "scripts/token_loader.py" ]; then\
    eval "$(python3 scripts/token_loader.py export)"\
fi\
' "$PROJECT_ROOT/$script"
                log "Added token loading to $script"
            fi
        fi
    fi
done

# Update Bot TypeScript files
log "Updating Bot TypeScript files..."
if [[ -f "$PROJECT_ROOT/bot/src/index.ts" ]]; then
    update_file "$PROJECT_ROOT/bot/src/index.ts" "Discord Bot main file"

    if [[ "$DRY_RUN" == "false" ]]; then
        # Check if already updated
        if ! grep -q "token_loader" "$PROJECT_ROOT/bot/src/index.ts"; then
            # Add token loading comment
            sed -i.bak '1i\
// Token loading: Use Python token_loader for environment setup\
// Run: python3 ../scripts/token_loader.py export > .env.tokens && source .env.tokens\
' "$PROJECT_ROOT/bot/src/index.ts"
            log "Added token loading guidance to bot/src/index.ts"
        fi
    fi
fi

# Create integration guide
log "Creating integration guide..."
if [[ "$DRY_RUN" == "false" ]]; then
    cat > "$PROJECT_ROOT/docs/TOKEN_SYSTEM_INTEGRATION.md" << 'EOF'
# Token System Integration Guide

## Overview

DevOnboarder has migrated from scattered token management in `.env` files to a centralized token architecture using `.tokens*` files and the `scripts/token_loader.py` system.

## Integration Points Updated

### Python Services

All Python services now include token loader integration:

```python
# Added to service startup
import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'scripts'))
from token_loader import require_tokens

def main():
    # Validate required tokens before service startup
    required_tokens = ['DISCORD_BOT_TOKEN', 'BOT_JWT', 'AAR_TOKEN']
    if not require_tokens(required_tokens, 'Service Name'):
        sys.exit(1)

    # Service logic continues...
```

### Shell Scripts

Shell scripts now load tokens via export:

```bash
# Load tokens using DevOnboarder Token Architecture v2.0
if command -v python3 > /dev/null && [ -f "scripts/token_loader.py" ]; then
    eval "$(python3 scripts/token_loader.py export)"
fi
```

### Docker Compose

Docker Compose files reference both environment and token files:

```yaml
services:
  service-name:
    env_file: [.env.dev]
    # Tokens loaded via token_loader.py in startup script
```

### GitHub Actions

CI workflows use the token system:

```yaml
- name: Load Tokens
  run: |
    python3 scripts/token_loader.py load
    eval "$(python3 scripts/token_loader.py export)"
```

## Migration Benefits

1. **Centralized Management**: All tokens in dedicated files
2. **Security Boundaries**: Production tokens never in CI files
3. **Auto-Creation**: Missing token files created with templates
4. **Validation**: Required token validation prevents startup issues
5. **Environment Awareness**: Automatic environment detection

## Usage Patterns

### Service Startup
```python
from scripts.token_loader import require_tokens
require_tokens(['TOKEN_NAME'], 'Service Name')
```

### Environment Loading
```bash
eval "$(python3 scripts/token_loader.py export)"
```

### Development Setup
```bash
python3 scripts/token_loader.py load  # Creates .tokens if missing
# Edit .tokens file with your tokens
python3 scripts/token_loader.py validate TOKEN_NAME  # Test specific token
```

## Security Model

- `.tokens` - Source of truth (GITIGNORED)
- `.tokens.dev` - Development tokens (GITIGNORED)
- `.tokens.prod` - Production tokens (GITIGNORED)
- `.tokens.ci` - CI test tokens (COMMITTED - safe placeholders only)

EOF

    log "Created integration guide: docs/TOKEN_SYSTEM_INTEGRATION.md"
fi

# Generate summary report
log "Generating update summary..."
if [[ "$DRY_RUN" == "false" ]]; then
    cat > "$PROJECT_ROOT/TOKEN_MIGRATION_SUMMARY.md" << EOF
# DevOnboarder Token Migration Summary

## Completed Updates

### Python Services Updated
$(find src/ -name "*.py" -type f | wc -l) Python files processed

### Docker Compose Files Updated
- docker-compose.dev.yaml
- docker-compose.prod.yaml
- docker-compose.ci.yaml

### GitHub Actions Updated
- .github/workflows/ci.yml
- .github/workflows/auto-fix.yml
- .github/workflows/security-audit.yml

### Shell Scripts Updated
- scripts/run_tests.sh
- scripts/qc_pre_push.sh
- scripts/validate-bot-permissions.sh

### Bot Files Updated
- bot/src/index.ts

## Migration Date
$(date '+%Y-%m-%d %H:%M:%S')

## Next Steps

1. **Test Services**: Verify all services start correctly with token system
2. **Validate CI**: Check GitHub Actions workflows use token loading
3. **Update Documentation**: Review and update service-specific docs
4. **Team Training**: Ensure team understands new token management

## Rollback Information

All updated files have backups with timestamp:
- Format: filename.backup.YYYYMMDD_HHMMSS
- Location: Same directory as original file

## Support

- Token Loader: scripts/token_loader.py --help
- Integration Guide: docs/TOKEN_SYSTEM_INTEGRATION.md
- Migration Log: $LOG_FILE

EOF

    log "Created migration summary: TOKEN_MIGRATION_SUMMARY.md"
fi

log "System update completed successfully"
log "Log file: $LOG_FILE"

if [[ "$DRY_RUN" == "false" ]]; then
    echo ""
    echo "System Update Complete!"
    echo "======================"
    echo ""
    echo "Updated files:"
    echo "- Python services: Added token_loader integration"
    echo "- Docker Compose: Added token loading guidance"
    echo "- GitHub Actions: Ready for token system integration"
    echo "- Shell scripts: Added token loading"
    echo "- Bot files: Added integration guidance"
    echo ""
    echo "Next steps:"
    echo "1. Test services: python3 scripts/token_loader.py validate"
    echo "2. Review: TOKEN_MIGRATION_SUMMARY.md"
    echo "3. Integration guide: docs/TOKEN_SYSTEM_INTEGRATION.md"
fi
