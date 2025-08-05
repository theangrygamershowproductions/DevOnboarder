#!/bin/bash
# =============================================================================
# File: scripts/manage_cloudflare_tunnel.sh
# Version: 1.0.0
# Author: DevOnboarder Project
# Created: 2025-08-05
# Purpose: Cloudflare tunnel management for DevOnboarder
# Usage: ./scripts/manage_cloudflare_tunnel.sh [command] [environment]
# DevOnboarder Project Standards: Compliant with copilot-instructions.md
# =============================================================================

set -euo pipefail

# Source environment
if [ -f .env ]; then
    # shellcheck source=.env disable=SC1091
    source .env
fi

# Logging
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/cloudflare_tunnel_$(date +%Y%m%d_%H%M%S).log"

log_info() {
    echo "INFO: $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "ERROR: $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo "SUCCESS: $1" | tee -a "$LOG_FILE"
}

# Show usage
show_usage() {
    echo "Cloudflare Tunnel Management for DevOnboarder"
    echo ""
    echo "Usage: $0 <command> [environment]"
    echo ""
    echo "Commands:"
    echo "  status     - Check tunnel status"
    echo "  start      - Start tunnel (development with --profile tunnel)"
    echo "  stop       - Stop tunnel"
    echo "  logs       - Show tunnel logs"
    echo "  test       - Test tunnel connectivity"
    echo "  validate   - Validate tunnel configuration"
    echo "  dns        - Show required DNS records"
    echo ""
    echo "Environment:"
    echo "  dev        - Development environment (optional, profile-gated)"
    echo "  prod       - Production environment (always-on)"
    echo ""
    echo "Examples:"
    echo "  $0 status dev"
    echo "  $0 start dev"
    echo "  $0 test prod"
    echo "  $0 dns"
}

# Validate environment
validate_environment() {
    local env=${1:-dev}

    if [ -z "${TUNNEL_TOKEN:-}" ]; then
        log_error "TUNNEL_TOKEN not set in environment"
        return 1
    fi

    if [ -z "${TUNNEL_ID:-}" ]; then
        log_error "TUNNEL_ID not set in environment"
        return 1
    fi

    if [ ! -f "cloudflared/config.yml" ]; then
        log_error "Tunnel configuration file not found: cloudflared/config.yml"
        return 1
    fi

    if [ ! -f "cloudflared/${TUNNEL_ID}.json" ]; then
        log_error "Tunnel credentials file not found: cloudflared/${TUNNEL_ID}.json"
        return 1
    fi

    log_success "Environment validation passed for $env"
    return 0
}

# Check tunnel status
check_status() {
    local env=${1:-dev}
    local container_name="devonboarder-cloudflared-${env}"

    log_info "Checking tunnel status for $env environment"

    if docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -q "$container_name"; then
        echo "Container Status:"
        docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep "$container_name"
        echo ""

        echo "Health Check:"
        if docker exec "$container_name" cloudflared tunnel info "${TUNNEL_ID}" 2>/dev/null; then
            log_success "Tunnel is healthy and connected"
        else
            log_error "Tunnel health check failed"
        fi
    else
        log_info "Tunnel container not running for $env environment"

        if [ "$env" = "dev" ]; then
            echo "To start development tunnel: docker compose -f docker-compose.dev.yaml --profile tunnel up -d"
        else
            echo "To start production tunnel: docker compose -f docker-compose.tags.prod.yaml up -d"
        fi
    fi
}

# Start tunnel
start_tunnel() {
    local env=${1:-dev}

    log_info "Starting tunnel for $env environment"

    if ! validate_environment "$env"; then
        return 1
    fi

    if [ "$env" = "dev" ]; then
        log_info "Starting development tunnel (profile-gated)"
        docker compose -f docker-compose.dev.yaml --profile tunnel up -d cloudflared
    elif [ "$env" = "prod" ]; then
        log_info "Starting production tunnel (always-on)"
        docker compose -f docker-compose.tags.prod.yaml up -d cloudflared
    else
        log_error "Invalid environment: $env (use 'dev' or 'prod')"
        return 1
    fi

    # Wait for startup
    sleep 10
    check_status "$env"
}

# Stop tunnel
stop_tunnel() {
    local env=${1:-dev}
    local container_name="devonboarder-cloudflared-${env}"

    log_info "Stopping tunnel for $env environment"

    if docker ps -q --filter "name=$container_name" | grep -q .; then
        docker stop "$container_name"
        docker rm "$container_name"
        log_success "Tunnel stopped for $env environment"
    else
        log_info "Tunnel not running for $env environment"
    fi
}

# Show tunnel logs
show_logs() {
    local env=${1:-dev}
    local container_name="devonboarder-cloudflared-${env}"

    log_info "Showing tunnel logs for $env environment"

    if docker ps -q --filter "name=$container_name" | grep -q .; then
        docker logs -f "$container_name"
    else
        log_error "Tunnel container not running for $env environment"
        return 1
    fi
}

# Test tunnel connectivity
test_connectivity() {
    local env=${1:-dev}

    log_info "Testing tunnel connectivity for $env environment"

    if [ "$env" = "prod" ]; then
        local domains=(
            "auth.dev.theangrygamershow.com"
            "api.dev.theangrygamershow.com"
            "dev.theangrygamershow.com"
            "discord.dev.theangrygamershow.com"
            "dashboard.dev.theangrygamershow.com"
        )

        for domain in "${domains[@]}"; do
            echo "Testing $domain..."
            if curl -s -o /dev/null -w "%{http_code}" "https://$domain/health" | grep -q "200"; then
                log_success "$domain is accessible"
            else
                log_error "$domain is not accessible"
            fi
        done
    else
        log_info "Development tunnel testing requires manual verification"
        echo "Development tunnel routes traffic through Cloudflare to localhost services"
    fi
}

# Show required DNS records
show_dns_records() {
    log_info "Required DNS records for Cloudflare tunnel"

    echo ""
    echo "Add these CNAME records in your Cloudflare dashboard for theangrygamershow.com:"
    echo "----------------------------------------"
    echo "Type  | Name                              | Content"
    echo "------|-----------------------------------|----------------------------------"
    echo "CNAME | auth.dev                          | ${TUNNEL_ID}.cfargotunnel.com"
    echo "CNAME | api.dev                           | ${TUNNEL_ID}.cfargotunnel.com"
    echo "CNAME | dev                               | ${TUNNEL_ID}.cfargotunnel.com"
    echo "CNAME | discord.dev                       | ${TUNNEL_ID}.cfargotunnel.com"
    echo "CNAME | dashboard.dev                     | ${TUNNEL_ID}.cfargotunnel.com"
    echo "----------------------------------------"
    echo ""
    echo "Full URLs will be:"
    echo "- Main App: https://dev.theangrygamershow.com"
    echo "- Auth API: https://auth.dev.theangrygamershow.com"
    echo "- Main API: https://api.dev.theangrygamershow.com"
    echo "- Discord:  https://discord.dev.theangrygamershow.com"
    echo "- Dashboard: https://dashboard.dev.theangrygamershow.com"
    echo ""
    echo "Tunnel ID: ${TUNNEL_ID}"
    echo "Dashboard: https://dash.cloudflare.com"
}

# Validate configuration
validate_config() {
    local env=${1:-dev}

    log_info "Validating tunnel configuration"

    # Check environment variables
    if ! validate_environment "$env"; then
        return 1
    fi

    # Check configuration file syntax
    log_info "Validating config.yml syntax"
    if ! python -c "import yaml; yaml.safe_load(open('cloudflared/config.yml'))" 2>/dev/null; then
        log_error "Invalid YAML syntax in cloudflared/config.yml"
        return 1
    fi

    # Check credentials file
    log_info "Validating credentials file"
    if ! python -c "import json; json.load(open('cloudflared/${TUNNEL_ID}.json'))" 2>/dev/null; then
        log_error "Invalid JSON syntax in credentials file"
        return 1
    fi

    log_success "Configuration validation passed"
    return 0
}

# Main function
main() {
    local command=${1:-}
    local environment=${2:-dev}

    # Ensure logs directory exists
    mkdir -p logs

    log_info "Starting Cloudflare tunnel management"
    log_info "Command: $command, Environment: $environment"

    case "$command" in
        "status")
            check_status "$environment"
            ;;
        "start")
            start_tunnel "$environment"
            ;;
        "stop")
            stop_tunnel "$environment"
            ;;
        "logs")
            show_logs "$environment"
            ;;
        "test")
            test_connectivity "$environment"
            ;;
        "validate")
            validate_config "$environment"
            ;;
        "dns")
            show_dns_records
            ;;
        "")
            show_usage
            ;;
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
