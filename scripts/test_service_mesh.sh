#!/usr/bin/env bash
# Docker Service Mesh Phase 1: Test and Validation
# Tests the tiered network implementation and service mesh functionality

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Docker Service Mesh Phase 1: Testing Framework"
echo "=============================================="

# Function to start services with new network configuration
start_service_mesh() {
    echo "Starting Docker Service Mesh Phase 1..."
    echo "Bringing up services with tiered network architecture..."

    cd "$SCRIPT_DIR/.."

    # Stop any existing services
    docker compose -f docker-compose.dev.yaml down 2>/dev/null || true

    # Start with new tiered network configuration
    docker compose -f docker-compose.dev.yaml up -d --wait

    echo "Services started successfully!"
}

# Function to test service mesh functionality
test_service_mesh() {
    echo
    echo "Testing Service Mesh Functionality"
    echo "=================================="

    local failed_tests=0

    # Test 1: Verify all expected networks exist
    echo "Test 1: Network Creation"
    for network in devonboarder_auth_tier devonboarder_api_tier devonboarder_data_tier devonboarder_edge_tier; do
        if docker network inspect "$network" >/dev/null 2>&1; then
            echo "  SYMBOL Network $network exists"
        else
            echo "  SYMBOL Network $network missing"
            ((failed_tests++))
        fi
    done

    # Test 2: Health checks for critical services
    echo
    echo "Test 2: Service Health Checks"

    # Wait for services to be healthy
    echo "Waiting for services to become healthy..."
    sleep 30

    # Check auth service
    if docker exec devonboarder-auth-dev curl -f http://localhost:8002/health >/dev/null 2>&1; then
        echo "  SYMBOL Auth service health check passed"
    else
        echo "  SYMBOL Auth service health check failed"
        ((failed_tests++))
    fi

    # Check backend service
    if docker exec devonboarder-xp-dev curl -f http://localhost:8001/health >/dev/null 2>&1; then
        echo "  SYMBOL Backend service health check passed"
    else
        echo "  SYMBOL Backend service health check failed"
        ((failed_tests++))
    fi

    # Check discord integration
    if docker exec devonboarder-discord-dev curl -f http://localhost:8081/health >/dev/null 2>&1; then
        echo "  SYMBOL Discord integration health check passed"
    else
        echo "  SYMBOL Discord integration health check failed"
        ((failed_tests++))
    fi

    # Test 3: External connectivity via Traefik
    echo
    echo "Test 3: External Connectivity"

    # Test Traefik dashboard
    if curl -f http://localhost:8090 >/dev/null 2>&1; then
        echo "  SYMBOL Traefik dashboard accessible"
    else
        echo "  SYMBOL Traefik dashboard not accessible"
        ((failed_tests++))
    fi

    return $failed_tests
}

# Function to run validation
run_validation() {
    echo
    echo "Running Network Contract Validation"
    echo "==================================="

    if bash "$SCRIPT_DIR/validate_network_contracts.sh"; then
        echo "  SYMBOL Network contract validation passed"
        return 0
    else
        echo "  SYMBOL Network contract validation failed"
        return 1
    fi
}

# Function to display service mesh status
display_status() {
    echo
    echo "Docker Service Mesh Status"
    echo "=========================="

    echo
    echo "Running Containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=devonboarder-"

    echo
    echo "Network Assignments:"
    for container in $(docker ps --format "{{.Names}}" --filter "name=devonboarder-"); do
        echo "  $container:"
        docker inspect "$container" --format '{{range $net, $conf := .NetworkSettings.Networks}}    - {{$net}}{{end}}' 2>/dev/null || echo "    No network info"
    done

    echo
    echo "Service URLs:"
    echo "  - Auth Service: http://localhost:8002/health"
    echo "  - Backend API: http://localhost:8001/health"
    echo "  - Discord Integration: http://localhost:8081/health"
    echo "  - Dashboard: http://localhost:8003/health"
    echo "  - Traefik Dashboard: http://localhost:8090"
}

# Main execution
main() {
    local command="${1:-test}"

    case "$command" in
        "start")
            start_service_mesh
            ;;
        "test")
            echo "Running comprehensive Docker Service Mesh Phase 1 test..."

            local test_failures=0
            local validation_failures=0

            # Run tests
            test_service_mesh || test_failures=$?

            # Run validation
            run_validation || validation_failures=$?

            # Display status
            display_status

            # Final results
            echo
            echo "TEST RESULTS"
            echo "============"
            echo "Test failures: $test_failures"
            echo "Validation failures: $validation_failures"

            local total_failures=$((test_failures + validation_failures))

            if [[ $total_failures -eq 0 ]]; then
                echo
                echo "SYMBOL SUCCESS: Docker Service Mesh Phase 1 implementation complete!"
                echo "   All services running with tiered network architecture"
                echo "   Network contracts validated and enforced"
                echo "   Ready for Phase 2 implementation"
                exit 0
            else
                echo
                echo "FAILED FAILED: $total_failures total failures detected"
                echo "   Check logs and network configuration"
                exit 1
            fi
            ;;
        "status")
            display_status
            ;;
        "stop")
            echo "Stopping Docker Service Mesh..."
            docker compose -f docker-compose.dev.yaml down
            echo "Services stopped"
            ;;
        *)
            echo "Usage: $0 [start|test|status|stop]"
            echo "  start  - Start services with tiered network architecture"
            echo "  test   - Run comprehensive test suite (default)"
            echo "  status - Display current service mesh status"
            echo "  stop   - Stop all services"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
