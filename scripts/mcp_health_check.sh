#!/usr/bin/env bash
# MCP Fleet Health Check - Diagnostic tool for TAGS MCP server ecosystem
# Consumes canonical registry: ecosystem/tags-mcp-servers/servers/servers.yml
#
# Usage:
#   ./scripts/mcp_health_check.sh           # Check prod servers (default)
#   ./scripts/mcp_health_check.sh --env dev # Check dev servers
#   ./scripts/mcp_health_check.sh --all     # Check all implemented servers
#
# Exit codes:
#   0 - All checked servers are UP
#   1 - One or more servers are DOWN or unreachable

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default: check production servers
ENV_FILTER="${1:-prod}"

# Locate registry (relative to DevOnboarder root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVONBOARDER_ROOT="$(dirname "$SCRIPT_DIR")"
REGISTRY_PATH="${DEVONBOARDER_ROOT}/../tags-mcp-servers/servers/servers.yml"

if [[ ! -f "$REGISTRY_PATH" ]]; then
    echo -e "${RED}ERROR: MCP registry not found at: $REGISTRY_PATH${NC}" >&2
    echo "Expected location: ecosystem/tags-mcp-servers/servers/servers.yml" >&2
    exit 1
fi

# Parse registry and extract server health check targets
# Output format: "name|host|port|health_endpoint"
parse_registry() {
    local registry_path="$1"
    local env_filter="$2"
    
    python3 - "$registry_path" "$env_filter" <<'PYEOF'
import sys
import yaml
from pathlib import Path

registry_path = sys.argv[1]
env_filter = sys.argv[2]

with open(registry_path) as f:
    registry = yaml.safe_load(f)

defaults = registry['defaults']
prod_base = defaults['prod_base']
staging_base = defaults['staging_base']
dev_base = defaults['dev_base']

for name, config in registry['servers'].items():
    # Skip non-implemented servers
    if config['status'] != 'implemented':
        continue
    
    # Skip servers without health endpoints
    if not config.get('health_endpoint', False):
        continue
    
    port_offset = config['port_offset']
    
    # Calculate ports for each environment
    prod_port = prod_base + port_offset
    staging_port = staging_base + port_offset
    dev_port = dev_base + port_offset
    
    # Filter by environment
    if env_filter == 'prod':
        ports = [('prod', prod_port)]
    elif env_filter == 'staging':
        ports = [('staging', staging_port)]
    elif env_filter == 'dev':
        ports = [('dev', dev_port)]
    elif env_filter == 'all':
        ports = [('prod', prod_port), ('staging', staging_port), ('dev', dev_port)]
    else:
        continue
    
    # Output: name|env|host|port
    for env, port in ports:
        print(f"{name}|{env}|127.0.0.1|{port}")
PYEOF
}

# Check health of a single server
check_server() {
    local name="$1"
    local env="$2"
    local host="$3"
    local port="$4"
    local url="http://${host}:${port}/healthz"
    
    # Attempt health check with aggressive timeout
    if timeout 1s curl -sf --max-time 1 --connect-timeout 0.5 "$url" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} ${name} [${env}] - UP - ${url}"
        return 0
    else
        echo -e "${RED}✗${NC} ${name} [${env}] - DOWN - ${url}"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${BLUE}=== MCP Fleet Health Check ===${NC}"
    echo -e "Environment: ${YELLOW}${ENV_FILTER}${NC}"
    echo -e "Registry: ${REGISTRY_PATH}"
    echo ""
    
    local total=0
    local up=0
    local down=0
    
    # Debug: test parse_registry output
    local parse_output
    parse_output=$(parse_registry "$REGISTRY_PATH" "$ENV_FILTER" 2>&1)
    local parse_exit=$?
    
    if [[ $parse_exit -ne 0 ]]; then
        echo -e "${RED}ERROR: Failed to parse registry${NC}" >&2
        echo "$parse_output" >&2
        exit 1
    fi
    
    local line_count
    line_count=$(echo "$parse_output" | wc -l)
    echo -e "${BLUE}Found ${line_count} servers to check${NC}"
    echo ""
    
    # Parse registry and check each server
    while IFS='|' read -r name env host port; do
        ((total++)) || true
        # Run check_server in a way that doesn't trigger set -e
        set +e
        check_server "$name" "$env" "$host" "$port"
        local result=$?
        set -e
        
        if [[ $result -eq 0 ]]; then
            ((up++)) || true
        else
            ((down++)) || true
        fi
    done <<< "$parse_output"
    
    echo ""
    echo -e "${BLUE}=== Summary ===${NC}"
    echo -e "Total checked: ${total}"
    echo -e "${GREEN}UP: ${up}${NC}"
    echo -e "${RED}DOWN: ${down}${NC}"
    
    if [[ $down -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}Note: This is a diagnostic tool. Servers may be down in local dev.${NC}"
        exit 1
    fi
    
    exit 0
}

# Handle --help flag
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "MCP Fleet Health Check - Diagnostic tool for TAGS MCP servers"
    echo ""
    echo "Usage:"
    echo "  ./scripts/mcp_health_check.sh              # Check prod servers (default)"
    echo "  ./scripts/mcp_health_check.sh --env prod   # Check prod servers explicitly"
    echo "  ./scripts/mcp_health_check.sh --env staging # Check staging servers"
    echo "  ./scripts/mcp_health_check.sh --env dev    # Check dev servers"
    echo "  ./scripts/mcp_health_check.sh --all        # Check all environments"
    echo ""
    echo "Exit codes:"
    echo "  0 - All checked servers are UP"
    echo "  1 - One or more servers are DOWN"
    echo ""
    echo "Registry: ecosystem/tags-mcp-servers/servers/servers.yml"
    exit 0
fi

# Parse environment flag
if [[ "${1:-}" == "--env" ]]; then
    ENV_FILTER="${2:-prod}"
    shift 2 || true
elif [[ "${1:-}" == "--all" ]]; then
    ENV_FILTER="all"
    shift || true
fi

main
