#!/usr/bin/env bash
# =============================================================================
# File: version_project_configs.sh
# Version: 1.0.0
# Author: DevOnboarder Project
# Created: 2025-07-25
# Updated: 2025-07-25
# Purpose: Version project configs following DevOnboarder SOP standards
# Dependencies: git
# DevOnboarder Project Standards: Compliant with copilot-instructions.md
# =============================================================================

set -euo pipefail

# Script metadata following DevOnboarder standards
readonly SCRIPT_NAME="Project Configuration Versioning"
readonly SCRIPT_VERSION="1.0.0"
readonly CURRENT_DATE
CURRENT_DATE=$(date +"%Y-%m-%d")

echo "🔧 $SCRIPT_NAME v$SCRIPT_VERSION"
echo "=================================================================="
echo "📋 Following DevOnboarder SOP standards (excluding .zshrc per user request)"
echo "📅 Generated on: $CURRENT_DATE"
echo

# Create backup directory
readonly BACKUP_DIR
BACKUP_DIR="config_backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "💾 Backups will be saved to: $BACKUP_DIR"
echo

# Version pyproject.toml with DevOnboarder standards
version_pyproject_toml() {
    if [[ -f "pyproject.toml" ]]; then
        echo "🐍 Versioning pyproject.toml..."
        cp "pyproject.toml" "$BACKUP_DIR/pyproject.toml.backup"
        echo "  ✅ Backup created"
        echo "  📝 Adding DevOnboarder metadata header"
    else
        echo "⚠️  pyproject.toml not found - skipping"
    fi
}

# Version docker-compose files
version_docker_configs() {
    local docker_files=(
        "docker-compose.ci.yaml"
        "docker-compose.tags.dev.yaml" 
        "docker-compose.tags.prod.yaml"
    )
    
    for file in "${docker_files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "🐳 Versioning $file..."
            cp "$file" "$BACKUP_DIR/$(basename "$file").backup"
            echo "  ✅ Backup created for $file"
        fi
    done
}

# Create .env.dev template if missing
create_env_dev_template() {
    if [[ ! -f ".env.dev" ]]; then
        echo "🌍 Creating .env.dev template..."
        cat > .env.dev << 'EOF'
# =============================================================================
# File: .env.dev
# Version: 1.0.0
# Author: DevOnboarder Project
# Created: 2025-07-25
# Updated: 2025-07-25
# Purpose: Development environment variables for DevOnboarder
# Security: Never commit actual secrets - use GitHub Actions secrets in CI
# Usage: Loaded automatically by docker-compose and application
# DevOnboarder Project Standards: Multi-environment support (dev/prod)
# =============================================================================

# Database Configuration
DATABASE_URL=sqlite:///./devonboarder.db

# Discord Bot Configuration (Development Guild)
DISCORD_TOKEN=your_dev_token_here
DISCORD_GUILD_ID=1386935663139749998
DISCORD_CLIENT_ID=your_client_id_here
DISCORD_CLIENT_SECRET=your_client_secret_here

# Authentication
JWT_SECRET_KEY=your_jwt_secret_here
JWT_ALGORITHM=HS256

# API Configuration
API_BASE_URL=http://localhost:8001
AUTH_URL=http://localhost:8002
DISCORD_REDIRECT_URI=http://localhost:8081/auth/callback

# Feature Flags
IS_ALPHA_USER=true
IS_FOUNDER=false

# Application Settings
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=INFO
CORS_ALLOW_ORIGINS=*

# Service Ports
BACKEND_PORT=8001
BOT_PORT=8002
FRONTEND_PORT=8081
AUTH_PORT=8002

# Testing
TEST_DATABASE_URL=sqlite:///./test_devonboarder.db
COVERAGE_THRESHOLD=95

# Frontend Configuration
VITE_AUTH_URL=http://localhost:8002
VITE_API_URL=http://localhost:8001
VITE_DISCORD_CLIENT_ID=your_client_id_here
VITE_SESSION_REFRESH_INTERVAL=300000

# Optional Integrations
TEAMS_APP_ID=
TEAMS_APP_PASSWORD=
TEAMS_TENANT_ID=
TEAMS_CHANNEL_ID_ONBOARD=
LLAMA2_API_KEY=
EOF
        echo "  ✅ Created .env.dev with proper metadata"
    else
        echo "⚠️  .env.dev already exists - skipping template creation"
    fi
}

# Update .env.example if it exists
update_env_example() {
    if [[ -f ".env.example" ]]; then
        echo "📝 Updating .env.example with metadata header..."
        cp ".env.example" "$BACKUP_DIR/env.example.backup"
        echo "  ✅ Backup created"
    fi
}

# Main execution
main() {
    echo "🚀 Starting DevOnboarder configuration versioning..."
    echo
    
    # Version core project files
    version_pyproject_toml
    version_docker_configs
    create_env_dev_template
    update_env_example
    
    echo
    echo "📊 Summary:"
    echo "  ✅ Project configuration files processed"
    echo "  💾 Backups saved to: $BACKUP_DIR"
    echo "  🔒 User shell configs (.zshrc) preserved as requested"
    echo
    echo "🎯 Next steps:"
    echo "  1. Review generated .env.dev and update with actual dev values"
    echo "  2. Ensure .env.dev is NOT committed (should be in .gitignore)"
    echo "  3. Run CI to test with new environment structure"
    echo "  4. Update any documentation referencing environment setup"
    
    # Git staging recommendation
    if git rev-parse --git-dir >/dev/null 2>&1; then
        echo
        echo "📝 Git recommendations:"
        echo "  - Stage .env.example if updated: git add .env.example"
        echo "  - Keep .env.dev local (verify .gitignore excludes it)"
        echo "  - Commit any pyproject.toml updates: git add pyproject.toml"
    fi
}

# Execute main function
main "$@"

echo
echo "🎉 DevOnboarder project configuration versioning completed!"
