#!/bin/bash
# =============================================================================
# File: scripts/validate_cors_configuration.sh
# Purpose: Validate CORS configuration for multi-subdomain architecture
# Usage: bash scripts/validate_cors_configuration.sh
# =============================================================================

# Source project wrapper for error handling
# shellcheck source=scripts/project_root_wrapper.sh disable=SC1091
source scripts/project_root_wrapper.sh

# Initialize logging
mkdir -p logs
LOG_FILE="logs/cors_validation_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting CORS Configuration Validation"

# Track validation results
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0

# Helper functions
log_error() {
    echo "ERROR: $1"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
}

log_warning() {
    echo "WARNING: $1"
    VALIDATION_WARNINGS=$((VALIDATION_WARNINGS + 1))
}

log_success() {
    echo "SUCCESS: $1"
}

# Validate environment CORS settings
validate_env_cors() {
    echo ""
    echo "=== Environment CORS Configuration ==="

    if [ ! -f ".env.dev" ]; then
        log_error "Environment file .env.dev not found"
        return 1
    fi

    # Check CORS_ALLOW_ORIGINS
    local cors_origins
    cors_origins=$(grep "^CORS_ALLOW_ORIGINS=" .env.dev 2>/dev/null | cut -d'=' -f2-)

    if [ -z "$cors_origins" ]; then
        log_error "CORS_ALLOW_ORIGINS not found in .env.dev"
        return 1
    fi

    echo "Current CORS_ALLOW_ORIGINS: $cors_origins"

    # Check for required domains
    local required_domains=(
        "dev.theangrygamershow.com"
        "auth.theangrygamershow.com"
        "api.theangrygamershow.com"
        "discord.theangrygamershow.com"
        "dashboard.theangrygamershow.com"
    )

    local missing_domains=()

    for domain in "${required_domains[@]}"; do
        if echo "$cors_origins" | grep -q "$domain"; then
            log_success "Domain $domain found in CORS origins"
        else
            log_error "Domain $domain missing from CORS origins"
            missing_domains+=("$domain")
        fi
    done

    if [ ${#missing_domains[@]} -gt 0 ]; then
        echo "Missing domains in CORS configuration:"
        printf " - https://%s\n" "${missing_domains[@]}"
        return 1
    fi

    return 0
}

# Check frontend environment variables
validate_frontend_env() {
    echo ""
    echo "=== Frontend Environment Variables ==="

    local required_frontend_vars=(
        "VITE_AUTH_URL=https://auth.theangrygamershow.com"
        "VITE_API_URL=https://api.theangrygamershow.com"
    )

    for var in "${required_frontend_vars[@]}"; do
        if grep -q "^$var" .env.dev; then
            log_success "Frontend variable configured: $var"
        else
            log_error "Frontend variable missing or incorrect: $var"
        fi
    done

    # Check OAuth redirect URL
    if grep -q "DISCORD_REDIRECT_URI=https://auth.theangrygamershow.com" .env.dev; then
        log_success "OAuth redirect URL configured for tunnel"
    else
        log_error "OAuth redirect URL not configured for tunnel"
    fi
}

# Validate service configuration files
validate_service_configs() {
    echo ""
    echo "=== Service Configuration Files ==="

    # Check if CORS utilities exist
    if [ -f "src/utils/cors.py" ]; then
        log_success "CORS utility module found"

        # Check CORS utility content
        if grep -q "get_cors_origins" src/utils/cors.py; then
            log_success "CORS origins function found"
        else
            log_warning "CORS origins function may be missing"
        fi
    else
        log_warning "CORS utility module not found at src/utils/cors.py"
    fi

    # Check FastAPI service files for CORS middleware
    local service_files=(
        "src/devonboarder/auth_service.py"
        "src/xp/api/__init__.py"
        "src/discord_integration/api.py"
    )

    for service_file in "${service_files[@]}"; do
        if [ -f "$service_file" ]; then
            echo "Checking CORS configuration in $service_file"

            if grep -q "CORSMiddleware" "$service_file"; then
                log_success "CORS middleware found in $service_file"

                if grep -q "get_cors_origins" "$service_file"; then
                    log_success "CORS origins function used in $service_file"
                else
                    log_warning "CORS origins function not used in $service_file"
                fi
            else
                log_error "CORS middleware missing in $service_file"
            fi
        else
            log_warning "Service file not found: $service_file"
        fi
    done
}

# Test actual CORS headers
test_live_cors_headers() {
    echo ""
    echo "=== Live CORS Headers Test ==="

    echo "Note: This test requires services to be running"
    echo "Run 'bash scripts/setup_tunnel.sh --start' first if needed"

    local test_urls=(
        "https://auth.theangrygamershow.com/health"
        "https://api.theangrygamershow.com/health"
        "https://discord.theangrygamershow.com/health"
    )

    for url in "${test_urls[@]}"; do
        echo "Testing CORS headers for: $url"

        local cors_response
        cors_response=$(curl -s -I -X OPTIONS \
            -H "Origin: https://dev.theangrygamershow.com" \
            -H "Access-Control-Request-Method: GET" \
            -H "Access-Control-Request-Headers: Content-Type,Authorization" \
            --max-time 10 "$url" 2>/dev/null)

        if curl -s -I -X OPTIONS \
            -H "Origin: https://dev.theangrygamershow.com" \
            -H "Access-Control-Request-Method: GET" \
            -H "Access-Control-Request-Headers: Content-Type,Authorization" \
            --max-time 10 "$url" >/dev/null 2>&1; then
            local cors_origin
            local cors_methods
            local cors_headers

            cors_origin=$(echo "$cors_response" | grep -i "access-control-allow-origin" | tr -d '\r\n')
            cors_methods=$(echo "$cors_response" | grep -i "access-control-allow-methods" | tr -d '\r\n')
            cors_headers=$(echo "$cors_response" | grep -i "access-control-allow-headers" | tr -d '\r\n')

            if [ -n "$cors_origin" ]; then
                log_success "CORS origin header present: $cors_origin"
            else
                log_warning "CORS origin header missing for $url"
            fi

            if [ -n "$cors_methods" ]; then
                log_success "CORS methods header present: $cors_methods"
            else
                log_warning "CORS methods header missing for $url"
            fi

            if [ -n "$cors_headers" ]; then
                log_success "CORS headers header present: $cors_headers"
            else
                log_warning "CORS headers header missing for $url"
            fi
        else
            log_warning "Could not test CORS headers for $url (service may not be running)"
        fi
    done
}

# Generate CORS configuration recommendations
generate_cors_recommendations() {
    echo ""
    echo "=== CORS Configuration Recommendations ==="

    if [ $VALIDATION_ERRORS -gt 0 ]; then
        echo "Critical CORS configuration issues found:"
        echo ""
        echo "1. Update .env.dev CORS_ALLOW_ORIGINS:"
        echo "   CORS_ALLOW_ORIGINS=https://dev.theangrygamershow.com,https://auth.theangrygamershow.com,https://api.theangrygamershow.com,https://discord.theangrygamershow.com,https://dashboard.theangrygamershow.com"
        echo ""
        echo "2. Ensure all FastAPI services use:"
        echo "   from src.utils.cors import get_cors_origins"
        echo "   app.add_middleware(CORSMiddleware, allow_origins=get_cors_origins(), ...)"
        echo ""
        echo "3. Verify OAuth redirect URLs are updated for tunnel domains"
    fi

    if [ $VALIDATION_WARNINGS -gt 0 ]; then
        echo ""
        echo "CORS configuration warnings to address:"
        echo "- Review service-specific CORS settings"
        echo "- Test cross-origin requests after deployment"
        echo "- Consider implementing CORS preflight caching"
    fi

    echo ""
    echo "Best Practices:"
    echo "- Use specific origins instead of '*' for production"
    echo "- Include credentials support: allow_credentials=True"
    echo "- Allow necessary headers: Content-Type, Authorization, X-Requested-With"
    echo "- Allow necessary methods: GET, POST, PUT, DELETE, OPTIONS"
}

# Generate validation report
generate_validation_report() {
    echo ""
    echo "=== CORS VALIDATION SUMMARY ==="
    echo "Date: $(date)"
    echo "Log File: $LOG_FILE"
    echo ""
    echo "Validation Results:"
    echo "  Errors: $VALIDATION_ERRORS"
    echo "  Warnings: $VALIDATION_WARNINGS"
    echo ""

    if [ $VALIDATION_ERRORS -eq 0 ]; then
        if [ $VALIDATION_WARNINGS -eq 0 ]; then
            echo "SUCCESS: CORS configuration is valid"
            echo "Ready for cross-origin testing"
            return 0
        else
            echo "SUCCESS WITH WARNINGS: CORS configuration has minor issues"
            echo "Consider addressing warnings for optimal performance"
            return 0
        fi
    else
        echo "FAILURE: CORS configuration has critical errors"
        echo "Fix errors before testing cross-origin requests"
        return 1
    fi
}

# Main execution
main() {
    echo "CORS Configuration Validation for Multi-Subdomain Architecture"
    echo "Validating configuration for DevOnboarder tunnel implementation"
    echo ""

    validate_env_cors
    validate_frontend_env
    validate_service_configs
    test_live_cors_headers
    generate_cors_recommendations
    generate_validation_report
}

main "$@"
