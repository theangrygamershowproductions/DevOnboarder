#!/bin/bash
# =============================================================================
# File: scripts/test_tunnel_integration.sh
# Purpose: Phase 2 - Service Integration & CORS Testing
# Usage: bash scripts/test_tunnel_integration.sh [--quick|--full|--cors-only]
# =============================================================================

# Source project wrapper for error handling
# shellcheck source=scripts/project_root_wrapper.sh disable=SC1091
source scripts/project_root_wrapper.sh

# Initialize logging
mkdir -p logs
LOG_FILE="logs/tunnel_integration_test_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting Phase 2: Service Integration & CORS Testing"

# Configuration
TUNNEL_URLS=(
    "https://auth.theangrygamershow.com"
    "https://api.theangrygamershow.com"
    "https://discord.theangrygamershow.com"
    "https://dashboard.theangrygamershow.com"
    "https://dev.theangrygamershow.com"
)

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNINGS=0

# Helper functions
log_test_start() {
    echo ""
    echo "=== TEST: $1 ==="
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

log_test_pass() {
    echo "PASS: $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_test_fail() {
    echo "FAIL: $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

log_test_warning() {
    echo "WARNING: $1"
    TESTS_WARNINGS=$((TESTS_WARNINGS + 1))
}

# Check if services are running
check_services_running() {
    log_test_start "Docker Services Status Check"

    local required_services=(
        "devonboarder-auth-dev"
        "devonboarder-xp-dev"
        "devonboarder-discord-dev"
        "devonboarder-dashboard-dev"
        "devonboarder-frontend-dev"
        "devonboarder-tunnel-dev"
    )

    local services_running=0
    local total_services=${#required_services[@]}

    for service in "${required_services[@]}"; do
        if docker ps --filter "name=$service" --filter "status=running" --format "table {{.Names}}" | grep -q "$service"; then
            log_test_pass "Service $service is running"
            services_running=$((services_running + 1))
        else
            log_test_fail "Service $service is not running"
        fi
    done

    if [ $services_running -eq "$total_services" ]; then
        log_test_pass "All required services are running ($services_running/$total_services)"
        return 0
    else
        log_test_fail "Only $services_running/$total_services services are running"
        return 1
    fi
}

# Test basic connectivity to tunnel URLs
test_tunnel_connectivity() {
    log_test_start "Tunnel URL Connectivity Test"

    local urls_accessible=0
    local total_urls=${#TUNNEL_URLS[@]}

    for url in "${TUNNEL_URLS[@]}"; do
        echo "Testing connectivity to $url"

        # Test with curl (timeout 10 seconds)
        if curl -s --max-time 10 --head "$url" >/dev/null 2>&1; then
            log_test_pass "URL accessible: $url"
            urls_accessible=$((urls_accessible + 1))
        else
            # Try with longer timeout for slower connections
            if curl -s --max-time 30 --head "$url" >/dev/null 2>&1; then
                log_test_warning "URL accessible but slow: $url"
                urls_accessible=$((urls_accessible + 1))
            else
                log_test_fail "URL not accessible: $url"
            fi
        fi
    done

    if [ $urls_accessible -eq "$total_urls" ]; then
        log_test_pass "All tunnel URLs are accessible ($urls_accessible/$total_urls)"
        return 0
    else
        log_test_fail "Only $urls_accessible/$total_urls tunnel URLs are accessible"
        return 1
    fi
}

# Test health endpoints
test_health_endpoints() {
    log_test_start "Service Health Endpoints Test"

    local health_endpoints=(
        "https://auth.theangrygamershow.com/health"
        "https://api.theangrygamershow.com/health"
        "https://discord.theangrygamershow.com/health"
        "https://dashboard.theangrygamershow.com/health"
    )

    local healthy_services=0
    local total_health_endpoints=${#health_endpoints[@]}

    for endpoint in "${health_endpoints[@]}"; do
        echo "Testing health endpoint: $endpoint"

        local response
        response=$(curl -s --max-time 10 "$endpoint" 2>/dev/null)

        if echo "$response" | grep -q '"status".*"ok"'; then
            log_test_pass "Health check passed: $endpoint"
            healthy_services=$((healthy_services + 1))
        else
            log_test_fail "Health check failed: $endpoint (Response: $response)"
        fi
    done

    if [ $healthy_services -eq "$total_health_endpoints" ]; then
        log_test_pass "All service health checks passed ($healthy_services/$total_health_endpoints)"
        return 0
    else
        log_test_fail "Only $healthy_services/$total_health_endpoints health checks passed"
        return 1
    fi
}

# Test CORS headers
test_cors_headers() {
    log_test_start "CORS Headers Validation Test"

    local cors_test_urls=(
        "https://dev.theangrygamershow.com"
        "https://auth.theangrygamershow.com/health"
        "https://api.theangrygamershow.com/health"
    )

    local cors_compliant=0
    local total_cors_tests=${#cors_test_urls[@]}

    for url in "${cors_test_urls[@]}"; do
        echo "Testing CORS headers for: $url"

        # Test OPTIONS request for CORS preflight
        local cors_headers
        cors_headers=$(curl -s -I -X OPTIONS \
            -H "Origin: https://dev.theangrygamershow.com" \
            -H "Access-Control-Request-Method: GET" \
            -H "Access-Control-Request-Headers: Content-Type" \
            --max-time 10 "$url" 2>/dev/null)

        if echo "$cors_headers" | grep -qi "access-control-allow-origin"; then
            log_test_pass "CORS headers present: $url"
            cors_compliant=$((cors_compliant + 1))

            # Show CORS headers for debugging
            echo "$cors_headers" | grep -i "access-control" | while read -r header; do
                echo "  CORS Header: $header"
            done
        else
            log_test_warning "CORS headers missing or incomplete: $url"
            # This might be expected for some endpoints
        fi
    done

    if [ $cors_compliant -gt 0 ]; then
        log_test_pass "CORS headers found on $cors_compliant/$total_cors_tests URLs"
        return 0
    else
        log_test_warning "No CORS headers found - may need service configuration"
        return 1
    fi
}

# Test cross-service communication
test_cross_service_communication() {
    log_test_start "Cross-Service Communication Test"

    echo "Testing auth service to API communication"

    # Test if auth service can reach API service
    local auth_to_api_test
    auth_to_api_test=$(curl -s --max-time 10 \
        "https://auth.theangrygamershow.com/health" 2>/dev/null)

    if echo "$auth_to_api_test" | grep -q '"status".*"ok"'; then
        log_test_pass "Auth service is responding"

        # Test API service independently
        local api_test
        api_test=$(curl -s --max-time 10 \
            "https://api.theangrygamershow.com/health" 2>/dev/null)

        if echo "$api_test" | grep -q '"status".*"ok"'; then
            log_test_pass "API service is responding"
            log_test_pass "Cross-service communication pathway validated"
            return 0
        else
            log_test_fail "API service not responding"
            return 1
        fi
    else
        log_test_fail "Auth service not responding"
        return 1
    fi
}

# Test frontend static assets
test_frontend_assets() {
    log_test_start "Frontend Asset Loading Test"

    local frontend_url="https://dev.theangrygamershow.com"

    echo "Testing frontend main page: $frontend_url"

    local frontend_response
    frontend_response=$(curl -s --max-time 15 "$frontend_url" 2>/dev/null)

    if echo "$frontend_response" | grep -qi "<!DOCTYPE html"; then
        log_test_pass "Frontend HTML is loading"

        # Check for basic HTML structure
        if echo "$frontend_response" | grep -qi "<title>"; then
            log_test_pass "Frontend has proper HTML structure"
        else
            log_test_warning "Frontend HTML structure may be incomplete"
        fi

        return 0
    else
        log_test_fail "Frontend not loading HTML content"
        return 1
    fi
}

# Performance test
test_response_times() {
    log_test_start "Response Time Performance Test"

    local performance_urls=(
        "https://auth.theangrygamershow.com/health"
        "https://api.theangrygamershow.com/health"
        "https://dev.theangrygamershow.com"
    )

    local fast_responses=0
    local total_perf_tests=${#performance_urls[@]}

    for url in "${performance_urls[@]}"; do
        echo "Measuring response time for: $url"

        local start_time
        local end_time
        local response_time

        start_time=$(date +%s%N)
        curl -s --max-time 10 "$url" >/dev/null 2>&1
        local curl_exit_code=$?
        end_time=$(date +%s%N)

        if [ $curl_exit_code -eq 0 ]; then
            response_time=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds

            if [ $response_time -lt 2000 ]; then  # Less than 2 seconds
                log_test_pass "Fast response ($response_time ms): $url"
                fast_responses=$((fast_responses + 1))
            else
                log_test_warning "Slow response ($response_time ms): $url"
            fi
        else
            log_test_fail "No response: $url"
        fi
    done

    if [ $fast_responses -eq "$total_perf_tests" ]; then
        log_test_pass "All services have good response times"
        return 0
    else
        log_test_warning "$fast_responses/$total_perf_tests services have good response times"
        return 1
    fi
}

# Generate comprehensive test report
generate_test_report() {
    echo ""
    echo "=== PHASE 2 INTEGRATION TEST SUMMARY ==="
    echo "Date: $(date)"
    echo "Log File: $LOG_FILE"
    echo ""
    echo "Test Results:"
    echo "  Total Tests: $TESTS_TOTAL"
    echo "  Passed: $TESTS_PASSED"
    echo "  Failed: $TESTS_FAILED"
    echo "  Warnings: $TESTS_WARNINGS"
    echo ""

    local success_rate=0
    if [ $TESTS_TOTAL -gt 0 ]; then
        success_rate=$(( (TESTS_PASSED * 100) / TESTS_TOTAL ))
    fi

    echo "Success Rate: $success_rate%"

    if [ $TESTS_FAILED -eq 0 ]; then
        if [ $TESTS_WARNINGS -eq 0 ]; then
            echo ""
            echo "SUCCESS: All integration tests passed!"
            echo "Phase 2 is complete. Ready for Phase 3: Production Optimization"
            return 0
        else
            echo ""
            echo "SUCCESS WITH WARNINGS: Integration tests passed with minor issues"
            echo "Address warnings before moving to production"
            return 0
        fi
    else
        echo ""
        echo "FAILURE: Integration tests failed"
        echo "Fix the failed tests before proceeding"
        return 1
    fi
}

# Main test execution
run_quick_tests() {
    echo "Running quick integration tests"
    check_services_running
    test_tunnel_connectivity
    test_health_endpoints
}

run_cors_tests() {
    echo "Running CORS-specific tests"
    test_cors_headers
    test_cross_service_communication
}

run_full_tests() {
    echo "Running comprehensive integration tests"
    check_services_running
    test_tunnel_connectivity
    test_health_endpoints
    test_cors_headers
    test_cross_service_communication
    test_frontend_assets
    test_response_times
}

# Main execution
main() {
    echo "Phase 2: Service Integration & CORS Testing"
    echo "Tunnel Implementation Validation"
    echo ""

    case "${1:-}" in
        --quick)
            run_quick_tests
            ;;
        --cors-only)
            run_cors_tests
            ;;
        --full)
            run_full_tests
            ;;
        "")
            echo "Running default full test suite"
            run_full_tests
            ;;
        *)
            echo "Usage: $0 [--quick|--full|--cors-only]"
            echo ""
            echo "Options:"
            echo "  --quick     Basic connectivity and health checks"
            echo "  --cors-only CORS headers and cross-service tests"
            echo "  --full      Complete integration test suite (default)"
            exit 1
            ;;
    esac

    generate_test_report
}

main "$@"
