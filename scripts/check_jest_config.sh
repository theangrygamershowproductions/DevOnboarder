#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# scripts/check_jest_config.sh
# Validates Jest timeout configuration to prevent CI hanging

set -euo pipefail

LOG_FILE="logs/jest_config_check_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder Jest Configuration Checker"
echo "======================================="
echo "Checking Jest configuration for timeout settings..."

if [[ ! -f "bot/package.json" ]]; then
    error "bot/package.json not found"
    exit 1
fi

# Check if Jest timeout is configured
if grep -q "testTimeout" bot/package.json; then
    success "Jest timeout configured"
    echo "Configuration found:"
    grep -A 2 "testTimeout" bot/package.json | sed 's/^/  /'

    # Extract timeout value for validation
    TIMEOUT=$(grep "testTimeout" bot/package.json | sed 's/.*testTimeout": *\([0-9]*\).*/\1/')

    if [[ "$TIMEOUT" -ge 30000 ]]; then
        success "Timeout value ($TIMEOUT ms) is adequate for CI"
    else
        warning "Timeout value ($TIMEOUT ms) may be too low for CI"
        echo "Recommendation: Use 30000ms or higher"
    fi
else
    error "Jest timeout NOT configured - CI may hang"
    echo "Solution: Add 'testTimeout: 30000' to Jest config in bot/package.json"
    echo ""
    echo "Example Jest configuration:"
    echo '  "jest": {'
    echo '    "preset": "ts-jest",'
    echo '    "testEnvironment": "node",'
    echo '    "testTimeout": 30000,'
    echo '    "collectCoverage": true'
    echo '  }'
    exit 1
fi

echo ""
echo "Jest configuration check complete"
echo "Log saved to: $LOG_FILE"
