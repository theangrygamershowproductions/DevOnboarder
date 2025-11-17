#!/bin/bash
# =============================================================================
# File: scripts/setup_tunnel.sh
# Purpose: Setup and validate Cloudflare tunnel configuration
# Usage: bash scripts/setup_tunnel.sh [--validate|--start|--stop]
# =============================================================================

# Source project wrapper for error handling
# shellcheck source=scripts/project_root_wrapper.sh disable=SC1091
source scripts/project_root_wrapper.sh

# Initialize logging
mkdir -p logs
LOG_FILE="logs/setup_tunnel_$(date %Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting Cloudflare tunnel setup"

# Configuration
TUNNEL_ID="ac65c0eb-6e16-4444-b340-feb89e45d991"
CONFIG_DIR="config/cloudflare"
CREDENTIALS_DIR="cloudflared"

# Detect available Docker Compose command
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null && docker-compose version &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo "Error: No working Docker Compose command found"
    echo "Please ensure Docker Desktop is running with proper WSL integration"
    exit 1
fi

echo "Using Docker Compose command: $COMPOSE_CMD"

# Validate configuration files exist
validate_config() {
    echo "Validating tunnel configuration"

    local missing_files=()

    if [ ! -f "$CONFIG_DIR/tunnel-config.yml" ]; then
        missing_files=("$CONFIG_DIR/tunnel-config.yml")
    fi

    if [ ! -f "$CREDENTIALS_DIR/$TUNNEL_ID.json" ]; then
        missing_files=("$CREDENTIALS_DIR/$TUNNEL_ID.json")
    fi

    if [ ! -f "docker-compose.dev.yaml" ]; then
        missing_files=("docker-compose.dev.yaml")
    fi

    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "Error: Missing required files:"
        printf " - %s\n" "${missing_files[@]}"
        return 1
    fi

    echo "Configuration validation passed"
    return 0
}

# Test tunnel connectivity
test_tunnel() {
    echo "Testing tunnel connectivity"

    # Check if cloudflared is available
    if ! command -v cloudflared >/dev/null 2>&1; then
        echo "Warning: cloudflared CLI not available for direct testing"
        echo "Will test via Docker container"
        return 0
    fi

    # Test tunnel info
    echo "Checking tunnel info"
    if cloudflared tunnel info "$TUNNEL_ID"; then
        echo "Tunnel info retrieved successfully"
    else
        echo "Warning: Could not retrieve tunnel info"
    fi

    return 0
}

# Start services with tunnel
start_tunnel() {
    echo "Starting services with Cloudflare tunnel"

    # Validate first
    if ! validate_config; then
        echo "Configuration validation failed"
        return 1
    fi

    # Start services with tunnel profile
    echo "Starting Docker services with tunnel profile"
    $COMPOSE_CMD -f docker-compose.dev.yaml --profile tunnel up -d

    echo "Services started. Checking health status"

    # Wait for services to become healthy
    local max_wait=120
    local wait_time=0

    while [ "$wait_time" -lt "$max_wait" ]; do
        if $COMPOSE_CMD -f docker-compose.dev.yaml ps --filter "health=healthy" | grep -q "healthy"; then
            echo "Services are becoming healthy"
            break
        fi
        echo "Waiting for services to start (${wait_time}s/${max_wait}s)"
        sleep 10
        wait_time=$((wait_time  10))
    done

    # Show final status
    echo "Final service status:"
    $COMPOSE_CMD -f docker-compose.dev.yaml ps

    echo "Tunnel setup complete"
    echo "Access URLs:"
    echo "  - Main App: https://dev.theangrygamershow.com"
    echo "  - Auth Service: https://auth.dev.theangrygamershow.com"
    echo "  - API Service: https://api.dev.theangrygamershow.com"
    echo "  - Discord Integration: https://discord.dev.theangrygamershow.com"
    echo "  - Dashboard: https://dashboard.dev.theangrygamershow.com"

    return 0
}

# Stop tunnel services
stop_tunnel() {
    echo "Stopping Cloudflare tunnel services"

    $COMPOSE_CMD -f docker-compose.dev.yaml --profile tunnel down

    echo "Tunnel services stopped"
    return 0
}

# Show help
show_help() {
    echo "Usage: bash scripts/setup_tunnel.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  --validate    Validate tunnel configuration files"
    echo "  --start       Start services with tunnel"
    echo "  --stop        Stop tunnel services"
    echo "  --test        Test tunnel connectivity"
    echo "  --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  bash scripts/setup_tunnel.sh --validate"
    echo "  bash scripts/setup_tunnel.sh --start"
    echo "  bash scripts/setup_tunnel.sh --stop"
}

# Main execution
main() {
    case "${1:-}" in
        --validate)
            validate_config
            ;;
        --start)
            start_tunnel
            ;;
        --stop)
            stop_tunnel
            ;;
        --test)
            test_tunnel
            ;;
        --help)
            show_help
            ;;
        "")
            echo "Starting default tunnel setup"
            validate_config && start_tunnel
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
