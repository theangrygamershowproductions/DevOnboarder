#!/bin/bash
# =============================================================================
# File: scripts/validate_tunnel_setup.sh
# Purpose: Comprehensive validation of Cloudflare tunnel configuration
# Usage: bash scripts/validate_tunnel_setup.sh
# =============================================================================

# Source project wrapper for error handling
# shellcheck source=scripts/project_root_wrapper.sh disable=SC1091
source scripts/project_root_wrapper.sh

# Initialize logging
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting Cloudflare tunnel configuration validation"

# Configuration
TUNNEL_ID="ac65c0eb-6e16-4444-b340-feb89e45d991"
CONFIG_FILE="config/cloudflare/tunnel-config.yml"
CREDENTIALS_FILE="cloudflared/$TUNNEL_ID.json"
DOCKER_COMPOSE_FILE="docker-compose.dev.yaml"
ENV_FILE=".env"  # Check main .env file which has the correct variables

# Track validation results
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0

# Helper function to log errors
log_error() {
    echo "ERROR: $1"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
}

# Helper function to log warnings
log_warning() {
    echo "WARNING: $1"
    VALIDATION_WARNINGS=$((VALIDATION_WARNINGS + 1))
}

# Helper function to log success
log_success() {
    echo "SUCCESS: $1"
}

# Validate file existence
validate_files() {
    echo ""
    echo "=== File Existence Validation ==="

    local required_files=(
        "$CONFIG_FILE:Tunnel configuration"
        "$CREDENTIALS_FILE:Tunnel credentials"
        "$DOCKER_COMPOSE_FILE:Docker Compose configuration"
        "$ENV_FILE:Environment configuration"
    )

    for file_info in "${required_files[@]}"; do
        local file_path="${file_info%%:*}"
        local file_desc="${file_info##*:}"

        if [ -f "$file_path" ]; then
            log_success "$file_desc exists at $file_path"
        else
            log_error "$file_desc missing at $file_path"
        fi
    done
}

# Validate tunnel configuration
validate_tunnel_config() {
    echo ""
    echo "=== Tunnel Configuration Validation ==="

    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "Tunnel configuration file not found"
        return 1
    fi

    # Check tunnel ID
    if grep -q "tunnel: $TUNNEL_ID" "$CONFIG_FILE"; then
        log_success "Tunnel ID matches expected value"
    else
        log_error "Tunnel ID mismatch in configuration"
    fi

    # Check credentials path
    if grep -q "credentials-file: /etc/cloudflared/$TUNNEL_ID.json" "$CONFIG_FILE"; then
        log_success "Credentials file path is correct"
    else
        log_error "Credentials file path is incorrect"
    fi

    # Check required hostnames
    local required_hostnames=(
        "auth.theangrygamershow.com"
        "api.theangrygamershow.com"
        "discord.theangrygamershow.com"
        "dashboard.theangrygamershow.com"
        "dev.theangrygamershow.com"
    )

    for hostname in "${required_hostnames[@]}"; do
        if grep -q "hostname: $hostname" "$CONFIG_FILE"; then
            log_success "Hostname $hostname configured"
        else
            log_error "Hostname $hostname not found in configuration"
        fi
    done

    # Check service mappings (using Traefik reverse proxy)
    local traefik_services
    traefik_services=$(grep -c "service: http://traefik:80" "$CONFIG_FILE" 2>/dev/null || echo "0")

    if [ "$traefik_services" -ge 5 ]; then
        log_success "Traefik reverse proxy routing configured ($traefik_services services)"
        log_success "Service mapping http://traefik:80 configured for all subdomains"
    else
        log_error "Traefik reverse proxy routing incomplete (found $traefik_services/5 services)"
        log_error "All subdomains should route through http://traefik:80"
    fi

    # Check catch-all rule
    if grep -q "service: http_status:404" "$CONFIG_FILE"; then
        log_success "Catch-all 404 rule configured"
    else
        log_error "Catch-all 404 rule missing"
    fi
}

# Validate Docker Compose configuration
validate_docker_compose() {
    echo ""
    echo "=== Docker Compose Configuration Validation ==="

    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
        log_error "Docker Compose file not found"
        return 1
    fi

    # Check service names match tunnel configuration
    local required_services=(
        "auth-service"
        "backend"
        "discord-integration"
        "dashboard-service"
        "frontend"
        "cloudflare-tunnel"
    )

    for service in "${required_services[@]}"; do
        if grep -q "^  $service:" "$DOCKER_COMPOSE_FILE"; then
            log_success "Service $service defined in Docker Compose"
        else
            log_error "Service $service not found in Docker Compose"
        fi
    done

    # Check tunnel service configuration
    if grep -q "image: cloudflare/cloudflared:latest" "$DOCKER_COMPOSE_FILE"; then
        log_success "Cloudflare tunnel image specified"
    else
        log_error "Cloudflare tunnel image not found"
    fi

    if grep -q "tunnel --config /etc/cloudflared/config.yml run" "$DOCKER_COMPOSE_FILE"; then
        log_success "Tunnel command configured correctly"
    else
        log_error "Tunnel command not configured correctly"
    fi

    # Check volume mounts
    if grep -q "./config/cloudflare/tunnel-config.yml:/etc/cloudflared/config.yml:ro" "$DOCKER_COMPOSE_FILE"; then
        log_success "Tunnel config volume mount configured"
    else
        log_error "Tunnel config volume mount missing"
    fi

    if grep -q "./cloudflared/$TUNNEL_ID.json:/etc/cloudflared/$TUNNEL_ID.json:ro" "$DOCKER_COMPOSE_FILE"; then
        log_success "Tunnel credentials volume mount configured"
    else
        log_error "Tunnel credentials volume mount missing"
    fi
}

# Validate environment configuration
validate_environment() {
    echo ""
    echo "=== Environment Configuration Validation ==="

    if [ ! -f "$ENV_FILE" ]; then
        log_error "Environment file not found"
        return 1
    fi

    # Check tunnel URLs
    local required_env_vars=(
        "DEV_TUNNEL_AUTH_URL=https://auth.theangrygamershow.com"
        "DEV_TUNNEL_API_URL=https://api.theangrygamershow.com"
        "DEV_TUNNEL_DISCORD_URL=https://discord.theangrygamershow.com"
        "DEV_TUNNEL_DASHBOARD_URL=https://dashboard.theangrygamershow.com"
        "DEV_TUNNEL_FRONTEND_URL=https://dev.theangrygamershow.com"
        "VITE_AUTH_URL=https://auth.theangrygamershow.com"
        "VITE_API_URL=https://api.theangrygamershow.com"
    )

    for env_var in "${required_env_vars[@]}"; do
        if grep -q "^$env_var" "$ENV_FILE"; then
            log_success "Environment variable $env_var configured"
        else
            log_error "Environment variable $env_var not found or incorrect"
        fi
    done

    # Check CORS configuration
    if grep -q "CORS_ALLOW_ORIGINS=.*dev.theangrygamershow.com" "$ENV_FILE"; then
        log_success "CORS origins include tunnel domains"
    else
        log_warning "CORS origins may not include all tunnel domains"
    fi
}

# Validate network connectivity prerequisites
validate_network() {
    echo ""
    echo "=== Network Prerequisites Validation ==="

    # Check if Docker is running
    if docker info >/dev/null 2>&1; then
        log_success "Docker daemon is running"
    else
        log_error "Docker daemon is not running"
    fi

    # Check if Docker Compose is available
    if command -v docker-compose >/dev/null 2>&1; then
        log_success "Docker Compose is available"
    else
        log_error "Docker Compose is not available"
    fi

    # Check if required ports are available (optional)
    local required_ports=(8001 8002 8003 8081 3000)

    for port in "${required_ports[@]}"; do
        if ! netstat -tln 2>/dev/null | grep -q ":$port "; then
            log_success "Port $port is available"
        else
            log_warning "Port $port is already in use"
        fi
    done
}

# Generate validation report
generate_report() {
    echo ""
    echo "=== Validation Summary ==="
    echo "Errors: $VALIDATION_ERRORS"
    echo "Warnings: $VALIDATION_WARNINGS"

    if [ $VALIDATION_ERRORS -eq 0 ]; then
        if [ $VALIDATION_WARNINGS -eq 0 ]; then
            echo ""
            echo "SUCCESS: All validations passed!"
            echo "You can now start the tunnel with:"
            echo "  bash scripts/setup_tunnel.sh --start"
        else
            echo ""
            echo "READY WITH WARNINGS: Configuration is valid but has warnings"
            echo "You can start the tunnel, but consider addressing warnings"
        fi
        return 0
    else
        echo ""
        echo "FAILED: Configuration has errors that must be fixed"
        echo "Please address the errors above before starting the tunnel"
        return 1
    fi
}

# Main execution
main() {
    echo "Cloudflare Tunnel Configuration Validation"
    echo "Tunnel ID: $TUNNEL_ID"
    echo "Log file: $LOG_FILE"

    validate_files
    validate_tunnel_config
    validate_docker_compose
    validate_environment
    validate_network

    generate_report
}

main "$@"
