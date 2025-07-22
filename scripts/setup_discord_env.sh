#!/usr/bin/env bash
# filepath: scripts/setup_discord_env.sh
# Description: Setup Discord multi-environment routing for DevOnboarder
set -euo pipefail

echo "🎮 DevOnboarder Discord Environment Setup"
echo "========================================="

# Configuration
DEPLOY_ENV="${1:-dev}"
BOT_DIR="bot"

# Discord Server Configuration
DISCORD_DEV_GUILD_ID="1386935663139749998"  # TAGS: DevOnboarder
DISCORD_PROD_GUILD_ID="1065367728992571444" # TAGS: C2C

# Webhook URLs (as provided in the Codex strategy)
DISCORD_DEV_WEBHOOK="https://discord.com/api/webhooks/1364500164127100969/i_drFE3cZypXFW6740J21Ii3dMZnJdgZ8qov5XtKDGTzyBg37s2pXu4fMdxkIcLY2Ej1/slack"
DISCORD_PROD_WEBHOOK="https://discord.com/api/webhooks/1364501968764276779/_y22MC-c8rwyl3Hpox52ylog2UwWAOURuNKapC0Eq1PlV5yIn8GJl89nkPr9J70Cy4UD/slack"

echo "🔧 Environment: $DEPLOY_ENV"
echo ""

# Function to create environment file
create_env_file() {
    local env_name="$1"
    local guild_id="$2"
    local webhook_url="$3"
    local env_file="${BOT_DIR}/.env.${env_name}"
    
    echo "📝 Creating $env_file..."
    
    cat > "$env_file" << EOF
# Discord Bot Configuration - $env_name Environment
# Generated on $(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Bot Authentication
DISCORD_BOT_TOKEN=\${DISCORD_BOT_TOKEN:-changeme}
DISCORD_CLIENT_ID=\${DISCORD_CLIENT_ID:-changeme}

# Environment-specific Discord Server
DISCORD_GUILD_ID=$guild_id
DISCORD_GUILD_IDS=$guild_id
ENVIRONMENT=$env_name

# Webhook Configuration
DISCORD_WEBHOOK_URL=$webhook_url

# API Integration
API_BASE_URL=http://localhost:8001
BOT_API_URL=http://localhost:8002
FRONTEND_URL=http://localhost:8081

# Bot Settings
BOT_JWT=\${BOT_JWT:-}
BOT_PREFIX=!
LOG_LEVEL=info

# Integration Flags
DISCORD_BOT_READY=\${DISCORD_BOT_READY:-false}
LIVE_TRIGGERS_ENABLED=\${LIVE_TRIGGERS_ENABLED:-false}
CODEX_DRY_RUN=\${CODEX_DRY_RUN:-true}

# Multi-environment Support
DISCORD_DEV_GUILD_ID=$DISCORD_DEV_GUILD_ID
DISCORD_PROD_GUILD_ID=$DISCORD_PROD_GUILD_ID
EOF

    echo "✅ Environment file created: $env_file"
}

# Function to setup bot configuration
setup_bot_config() {
    echo "🤖 Setting up bot configuration..."
    
    # Ensure bot directory exists
    if [[ ! -d "$BOT_DIR" ]]; then
        echo "❌ Bot directory not found: $BOT_DIR"
        exit 1
    fi
    
    # Create environment-specific configurations
    if [[ "$DEPLOY_ENV" == "dev" ]]; then
        create_env_file "dev" "$DISCORD_DEV_GUILD_ID" "$DISCORD_DEV_WEBHOOK"
        echo "🔗 Development Discord Server: TAGS: DevOnboarder ($DISCORD_DEV_GUILD_ID)"
    elif [[ "$DEPLOY_ENV" == "prod" ]]; then
        create_env_file "prod" "$DISCORD_PROD_GUILD_ID" "$DISCORD_PROD_WEBHOOK"
        echo "🔗 Production Discord Server: TAGS: C2C ($DISCORD_PROD_GUILD_ID)"
    else
        echo "⚠️  Unknown environment: $DEPLOY_ENV"
        echo "   Supported environments: dev, prod"
        echo "   Creating both configurations..."
        create_env_file "dev" "$DISCORD_DEV_GUILD_ID" "$DISCORD_DEV_WEBHOOK"
        create_env_file "prod" "$DISCORD_PROD_GUILD_ID" "$DISCORD_PROD_WEBHOOK"
    fi
    
    # Create main .env file pointing to current environment
    local main_env_file="${BOT_DIR}/.env"
    if [[ "$DEPLOY_ENV" == "dev" || "$DEPLOY_ENV" == "prod" ]]; then
        echo "🔗 Creating main .env file for $DEPLOY_ENV environment..."
        cp "${BOT_DIR}/.env.${DEPLOY_ENV}" "$main_env_file"
        echo "✅ Main .env file updated for $DEPLOY_ENV environment"
    fi
}

# Function to validate configuration
validate_config() {
    echo "🔍 Validating Discord configuration..."
    
    local env_file="${BOT_DIR}/.env"
    if [[ ! -f "$env_file" ]]; then
        echo "❌ Main .env file not found: $env_file"
        return 1
    fi
    
    # Check required variables
    local required_vars=("DISCORD_GUILD_ID" "ENVIRONMENT" "API_BASE_URL")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$env_file"; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo "❌ Missing required variables: ${missing_vars[*]}"
        return 1
    fi
    
    echo "✅ Configuration validation passed"
    
    # Display current configuration
    echo ""
    echo "📋 Current Configuration:"
    echo "   Environment: $(grep '^ENVIRONMENT=' "$env_file" | cut -d'=' -f2)"
    echo "   Guild ID: $(grep '^DISCORD_GUILD_ID=' "$env_file" | cut -d'=' -f2)"
    echo "   API Base URL: $(grep '^API_BASE_URL=' "$env_file" | cut -d'=' -f2)"
    echo "   Dry-run Mode: $(grep '^CODEX_DRY_RUN=' "$env_file" | cut -d'=' -f2)"
}

# Function to setup Discord role mapping
setup_role_mapping() {
    echo "🎭 Setting up Discord role mapping..."
    
    # Create role mapping configuration
    local roles_config="${BOT_DIR}/config/roles.json"
    mkdir -p "${BOT_DIR}/config"
    
    cat > "$roles_config" << 'EOF'
{
  "environments": {
    "dev": {
      "guild_id": "1386935663139749998",
      "guild_name": "TAGS: DevOnboarder",
      "roles": {
        "admin": ["CTO", "CEO", "Admin"],
        "developer": ["Developer", "Engineer", "Tech Lead"],
        "tester": ["QA", "Tester", "Quality Assurance"],
        "member": ["Member", "User"]
      },
      "permissions": {
        "admin": ["all"],
        "developer": ["deploy", "test", "debug"],
        "tester": ["test", "report"],
        "member": ["view"]
      }
    },
    "prod": {
      "guild_id": "1065367728992571444",
      "guild_name": "TAGS: C2C",
      "roles": {
        "admin": ["CTO", "CEO", "COO", "Admin"],
        "operator": ["Ops", "DevOps", "Site Reliability"],
        "support": ["Support", "Customer Success"],
        "member": ["Member", "User"]
      },
      "permissions": {
        "admin": ["all"],
        "operator": ["deploy", "monitor", "troubleshoot"],
        "support": ["view", "report"],
        "member": ["view"]
      }
    }
  },
  "command_permissions": {
    "deploy": ["admin", "developer"],
    "test": ["admin", "developer", "tester"],
    "status": ["admin", "developer", "tester", "member"],
    "help": ["admin", "developer", "tester", "member"]
  }
}
EOF

    echo "✅ Role mapping configuration created: $roles_config"
}

# Function to create deployment scripts
create_deployment_scripts() {
    echo "🚀 Creating deployment scripts..."
    
    # Bot start script for development
    cat > "${BOT_DIR}/start-dev.sh" << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🤖 Starting Discord Bot - Development Environment"
echo "================================================"

# Load development environment
export NODE_ENV=development
export ENVIRONMENT=dev

# Check if .env.dev exists
if [[ ! -f ".env.dev" ]]; then
    echo "❌ Development environment file not found: .env.dev"
    echo "   Run: bash ../scripts/setup_discord_env.sh dev"
    exit 1
fi

# Copy dev environment to main .env
cp .env.dev .env

# Install dependencies if needed
if [[ ! -d "node_modules" ]]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Build if needed
if [[ ! -d "dist" ]] || [[ "src/" -nt "dist/" ]]; then
    echo "🔨 Building bot..."
    npm run build
fi

echo "🚀 Starting bot in development mode..."
npm start
EOF

    # Bot start script for production
    cat > "${BOT_DIR}/start-prod.sh" << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🤖 Starting Discord Bot - Production Environment"
echo "==============================================="

# Load production environment
export NODE_ENV=production
export ENVIRONMENT=prod

# Check if .env.prod exists
if [[ ! -f ".env.prod" ]]; then
    echo "❌ Production environment file not found: .env.prod"
    echo "   Run: bash ../scripts/setup_discord_env.sh prod"
    exit 1
fi

# Copy prod environment to main .env
cp .env.prod .env

# Ensure dependencies are installed
npm ci --only=production

# Build for production
npm run build

echo "🚀 Starting bot in production mode..."
npm start
EOF

    # Make scripts executable
    chmod +x "${BOT_DIR}/start-dev.sh"
    chmod +x "${BOT_DIR}/start-prod.sh"
    
    echo "✅ Deployment scripts created:"
    echo "   ${BOT_DIR}/start-dev.sh"
    echo "   ${BOT_DIR}/start-prod.sh"
}

# Function to test Discord connection
test_discord_connection() {
    echo "🧪 Testing Discord configuration..."
    
    # Check if bot token is configured
    local env_file="${BOT_DIR}/.env"
    if grep -q "DISCORD_BOT_TOKEN=changeme" "$env_file"; then
        echo "⚠️  Discord bot token not configured"
        echo "   Please set DISCORD_BOT_TOKEN in $env_file"
        echo "   Or set environment variable: export DISCORD_BOT_TOKEN=your_token_here"
    else
        echo "✅ Discord bot token appears to be configured"
    fi
    
    # Check webhook connectivity (if in live mode)
    if [[ "${LIVE_TRIGGERS_ENABLED:-false}" == "true" ]]; then
        local webhook_url
        webhook_url=$(grep '^DISCORD_WEBHOOK_URL=' "$env_file" | cut -d'=' -f2)
        
        if [[ -n "$webhook_url" ]] && [[ "$webhook_url" != "changeme" ]]; then
            echo "🔗 Testing webhook connectivity..."
            if curl -s -o /dev/null -w "%{http_code}" "$webhook_url" | grep -q "2[0-9][0-9]"; then
                echo "✅ Webhook connectivity test passed"
            else
                echo "⚠️  Webhook connectivity test failed (may be expected in dry-run mode)"
            fi
        fi
    else
        echo "🧪 Skipping webhook test (dry-run mode active)"
    fi
}

# Function to display setup summary
display_summary() {
    echo ""
    echo "🎯 Discord Environment Setup Complete!"
    echo "======================================"
    echo ""
    echo "📋 Configuration Summary:"
    echo "   Environment: $DEPLOY_ENV"
    
    if [[ "$DEPLOY_ENV" == "dev" ]]; then
        echo "   Discord Server: TAGS: DevOnboarder"
        echo "   Guild ID: $DISCORD_DEV_GUILD_ID"
        echo "   Start Command: cd bot && ./start-dev.sh"
    elif [[ "$DEPLOY_ENV" == "prod" ]]; then
        echo "   Discord Server: TAGS: C2C"
        echo "   Guild ID: $DISCORD_PROD_GUILD_ID"
        echo "   Start Command: cd bot && ./start-prod.sh"
    else
        echo "   Multiple environments configured"
        echo "   Start Dev: cd bot && ./start-dev.sh"
        echo "   Start Prod: cd bot && ./start-prod.sh"
    fi
    
    echo ""
    echo "🔧 Next Steps:"
    echo "   1. Set your Discord bot token:"
    echo "      export DISCORD_BOT_TOKEN=your_token_here"
    echo ""
    echo "   2. Start the bot:"
    echo "      cd bot && ./start-${DEPLOY_ENV}.sh"
    echo ""
    echo "   3. When ready for live mode:"
    echo "      export DISCORD_BOT_READY=true"
    echo "      export LIVE_TRIGGERS_ENABLED=true"
    echo ""
    echo "🔗 Integration Status:"
    echo "   - Environment Setup: ✅ Complete"
    echo "   - Role Mapping: ✅ Configured"
    echo "   - Deployment Scripts: ✅ Ready"
    echo "   - Bot Connection: ⏸️ Awaiting token configuration"
}

# Main execution
main() {
    echo "🎮 Starting Discord environment setup for: $DEPLOY_ENV"
    echo ""
    
    # Execute setup steps
    setup_bot_config
    setup_role_mapping
    create_deployment_scripts
    validate_config
    test_discord_connection
    display_summary
    
    echo ""
    echo "✅ Discord environment setup completed successfully!"
}

# Execute main function
main "$@"
