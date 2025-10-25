#!/bin/bash
# =============================================================================
# File: scripts/phase2_complete_test.sh
# Purpose: Complete Phase 2 testing with Docker Compose V2 compatibility
# Usage: bash scripts/phase2_complete_test.sh
# =============================================================================

# Ensure we're in the project root
cd "$(dirname "$0")/.." || exit

# Initialize logging
mkdir -p logs
LOG_FILE="logs/phase2_complete_test_$(date %Y%m%d_%H%M%S).log"

echo "DevOnboarder Phase 2: Complete Integration Test"
echo "Log file: $LOG_FILE"

# Detect available Docker Compose command
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null && docker-compose version &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo "Error: No working Docker Compose command found"
    echo "Please ensure Docker Desktop is running with proper WSL integration"
    echo ""
    echo "Quick Resolution:"
    echo "1. Ensure Docker Desktop is running with WSL integration enabled"
    echo "2. Or install legacy docker-compose with:"
    echo "   sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
    echo "   sudo chmod x /usr/local/bin/docker-compose"
    exit 1
fi

echo "Using Docker Compose command: $COMPOSE_CMD"

# Test phases
run_phase1_validation() {
    echo ""
    echo "=== Phase 1: Configuration Validation ==="

    # Run configuration validation
    if bash scripts/test_tunnel_integration.sh --config-only; then
        echo "Phase 1 Configuration: PASS"
        return 0
    else
        echo "Phase 1 Configuration: FAIL"
        return 1
    fi
}

run_phase2_cors_testing() {
    echo ""
    echo "=== Phase 2: CORS Configuration Testing ==="

    # Run CORS validation
    if bash scripts/validate_cors_configuration.sh; then
        echo "Phase 2 CORS Configuration: PASS"
        return 0
    else
        echo "Phase 2 CORS Configuration: FAIL"
        return 1
    fi
}

run_phase2_service_integration() {
    echo ""
    echo "=== Phase 2: Service Integration Testing ==="

    # Start services and run integration tests
    if bash scripts/phase2_start_and_test.sh; then
        echo "Phase 2 Service Integration: PASS"
        return 0
    else
        echo "Phase 2 Service Integration: FAIL"
        return 1
    fi
}

# Main execution
main() {
    local failures=0

    echo "Starting comprehensive Phase 2 testing"
    echo "Docker Compose Command: $COMPOSE_CMD"
    echo "Test Start Time: $(date)"

    # Phase 1: Validate configuration
    if ! run_phase1_validation; then
        failures=$((failures  1))
    fi

    # Phase 2A: Validate CORS setup
    if ! run_phase2_cors_testing; then
        failures=$((failures  1))
    fi

    # Phase 2B: Full service integration
    if ! run_phase2_service_integration; then
        failures=$((failures  1))
    fi

    # Summary
    echo ""
    echo "=== Test Summary ==="
    echo "Test Completion Time: $(date)"
    echo "Docker Compose Command Used: $COMPOSE_CMD"

    if [ $failures -eq 0 ]; then
        echo "All Phase 2 tests PASSED"
        echo "DevOnboarder Cloudflare tunnel implementation is complete and working"
        echo ""
        echo "Access your services at:"
        echo "  - Main App: https://dev.theangrygamershow.com"
        echo "  - Auth Service: https://auth.theangrygamershow.com"
        echo "  - API Service: https://api.theangrygamershow.com"
        echo "  - Discord Integration: https://discord.theangrygamershow.com"
        echo "  - Dashboard: https://dashboard.theangrygamershow.com"
        return 0
    else
        echo "Phase 2 testing FAILED with $failures failed test phases"
        echo ""
        echo "Troubleshooting:"
        echo "1. Check Docker environment: $COMPOSE_CMD version"
        echo "2. Verify Cloudflare tunnel credentials in: cloudflared/"
        echo "3. Ensure all services are configured in docker-compose.dev.yaml"
        echo "4. Review logs in: $LOG_FILE"
        return 1
    fi
}

# Execute main function and capture output
main 2>&1 | tee -a "$LOG_FILE"
exit_code=${PIPESTATUS[0]}

echo "Complete log available at: $LOG_FILE"
exit "$exit_code"
