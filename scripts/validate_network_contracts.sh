#!/usr/bin/env bash
# Docker Service Mesh Phase 1: Network Contract Validation
# Validates that services are properly connected to their designated network tiers

set -euo pipefail

# Colors for output
# shellcheck disable=SC2034 # Colors reserved for future enhanced output
RED='\033[0;31m'
# shellcheck disable=SC2034
GREEN='\033[0;32m'
# shellcheck disable=SC2034
YELLOW='\033[1;33m'
# shellcheck disable=SC2034
BLUE='\033[0;34m'
# shellcheck disable=SC2034
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2034 # PROJECT_ROOT may be used by sourced scripts
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Docker Service Mesh Phase 1: Network Contract Validation"
echo "========================================================="

# Function to check if a service is connected to expected networks
check_service_networks() {
    local service_name="$1"
    local expected_networks="$2"
    local container_name="$3"

    echo "Checking service: $service_name"

    # Check if container exists and is running
    if ! docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        echo "  Status: Container $container_name not running - SKIP"
        return 0
    fi

    # Get actual networks for the container
    local actual_networks
    actual_networks=$(docker inspect "$container_name" --format '{{range $net, $conf := .NetworkSettings.Networks}}{{$net}} {{end}}' 2>/dev/null || echo "")

    if [[ -z "$actual_networks" ]]; then
        echo "  Status: Could not retrieve network information - ERROR"
        return 1
    fi

    echo "  Expected: $expected_networks"
    echo "  Actual: $actual_networks"

    # Check each expected network
    local all_networks_found=true
    for expected_net in $expected_networks; do
        if [[ "$actual_networks" =~ $expected_net ]]; then
            echo "    Network $expected_net: FOUND"
        else
            echo "    Network $expected_net: MISSING"
            all_networks_found=false
        fi
    done

    if $all_networks_found; then
        echo "  Status: PASS"
        return 0
    else
        echo "  Status: FAIL"
        return 1
    fi
}

NETWORKS=("devonboarder_auth_tier" "devonboarder_api_tier" "devonboarder_data_tier")
for network in "${NETWORKS[@]}"; do
    if docker network ls | grep -q "$network"; then
        echo "SUCCESS $network exists"
    else
        echo "FAILED $network missing"
    fi
done

# Check service assignments
echo ""
echo "SYMBOL  Service Network Assignments:"

# Function to check service network
check_service_network() {
    local service=$1
    local expected_network=$2

    if docker ps --format "table {{.Names}}" | grep -q "$service"; then
        local networks
        networks=$(docker inspect "$service" --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}' 2>/dev/null || echo "not found")
        if echo "$networks" | grep -q "$expected_network"; then
            echo "SUCCESS $service → $expected_network"
        else
            echo "FAILED $service → expected: $expected_network, actual: $networks"
        fi
    else
        echo "WARNING  $service not running"
    fi
}

# Expected assignments
check_service_network "auth-service" "devonboarder_auth_tier"
check_service_network "devonboarder-backend" "devonboarder_api_tier"
check_service_network "devonboarder-bot" "devonboarder_api_tier"
check_service_network "devonboarder-db" "devonboarder_data_tier"

# Test data tier isolation
echo ""
echo "SYMBOL Security Validation:"

if docker ps --format "table {{.Names}}" | grep -q "devonboarder-backend"; then
    echo "Testing data tier isolation..."
    # Try to ping db from backend (should work if on same network)
    if docker exec devonboarder-backend ping -c 1 devonboarder-db >/dev/null 2>&1; then
        echo "WARNING  Backend can reach database (check network isolation)"
    else
        echo "FAILED Backend cannot reach database (isolation working or connection issue)"
    fi
fi

# DNS alias testing
echo ""
echo "SYMBOL DNS Resolution Testing:"

if docker ps --format "table {{.Names}}" | grep -q "devonboarder-backend"; then
    # Test internal DNS resolution
    if docker exec devonboarder-backend nslookup auth-service >/dev/null 2>&1; then
        echo "SUCCESS Service discovery working"
    else
        echo "FAILED Service discovery not working"
    fi
fi

echo ""
echo "STATS Summary:"
echo "Run this script after implementing Phase 1 to validate network setup"
echo "Expected: All services assigned to correct tiers with proper isolation"
