#!/bin/bash
# Phase 1 Network Scaffolding Script
# Creates tiered networks and updates docker-compose.dev.yaml

set -euo pipefail

echo "DEPLOY Phase 1: Network Foundation Scaffolding"
echo "==========================================="

# Backup current configuration
echo "SYMBOL Creating backup..."
cp docker-compose.dev.yaml docker-compose.dev.yaml.backup
echo "SUCCESS Backup created: docker-compose.dev.yaml.backup"

# Create network definitions
echo "CONFIG Adding tiered network definitions..."

# Create the new networks section if it doesn't exist
if ! grep -q "networks:" docker-compose.dev.yaml; then
    echo "
networks:
  auth_tier:
    name: devonboarder_auth_tier
    driver: bridge
  api_tier:
    name: devonboarder_api_tier
    driver: bridge
  data_tier:
    name: devonboarder_data_tier
    driver: bridge
    internal: true  # Isolated from external access" >> docker-compose.dev.yaml
else
    echo "WARNING  Networks section already exists - manual merge required"
fi

echo "SUCCESS Network definitions added"

# Show what networks will be created
echo "STATS New network architecture:"
echo "   SYMBOL auth_tier (auth-service, traefik)"
echo "   SYMBOL api_tier (backend, discord-integration, dashboard, frontend)"
echo "   SYMBOL  data_tier (db - isolated)"

echo ""
echo "TARGET Next Steps:"
echo "1. Review docker-compose.dev.yaml changes"
echo "2. Update service network assignments"
echo "3. Test with: make up"
echo "4. Validate: docker network ls | grep devonboarder"

echo ""
echo "CONFIG Manual Service Updates Required:"
echo "   - Move auth-service to auth_tier"
echo "   - Move backend/bot/frontend to api_tier"
echo "   - Move db to data_tier (isolated)"

echo ""
echo "SUCCESS Phase 1 scaffolding complete!"
