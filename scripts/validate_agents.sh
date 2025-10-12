#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
set -euo pipefail

# Agent validation script for Codex agents
# Validates frontmatter against agent-schema.json

SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCHEMA_FILE="$PROJECT_ROOT/schema/agent-schema.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

bot "Validating Codex Agent Files..."

if [ ! -f "$SCHEMA_FILE" ]; then
    error_msg " Agent schema not found: $SCHEMA_FILE" >&2
    exit 1
fi

# Check if ajv is available
if [ ! -f "$PROJECT_ROOT/node_modules/.bin/ajv" ]; then
    debug_msg "  ajv-cli not found locally, trying npx..."
    AJV_CMD="npx -y ajv-cli"
else
    AJV_CMD="$PROJECT_ROOT/node_modules/.bin/ajv"
fi

# Add draft-07 meta-schema support
AJV_OPTS="--meta-schema"

validation_errors=0
total_files=0

# Find all agent files
for agent_file in $(find "$PROJECT_ROOT" -path "*/.codex/agents/*.md" -o -path "*/agents/*.md" | sort); do
    if [ ! -f "$agent_file" ]; then
        continue
    fi

    total_files=$((total_files + 1))
    agent_name=$(basename "$agent_file" .md)

    # Check if file has frontmatter
    if [ "$(head -n1 "$agent_file")" != "---" ]; then
        debug_msg "  $agent_name: No frontmatter found"
        continue
    fi

    # Extract frontmatter
    tmp_frontmatter=$(mktemp)
    tmp_json=$(mktemp)

    # Extract YAML frontmatter (between --- markers)
    sed -n '/^---$/,/^---$/p' "$agent_file" | sed '1d;$d' > "$tmp_frontmatter"

    # Convert YAML to JSON using Python
    if ! python3 -c "
import sys, yaml, json
try:
    with open('$tmp_frontmatter') as f:
        data = yaml.safe_load(f.read() or '{}')
    with open('$tmp_json', 'w') as f:
        json.dump(data, f, indent=2)
except Exception as e:
    print(f'YAML parsing error: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null; then
        error_msg " $agent_name: Failed to parse YAML frontmatter"
        validation_errors=$((validation_errors + 1))
        rm -f "$tmp_frontmatter" "$tmp_json"
        continue
    fi

    # Validate against schema
    if $AJV_CMD validate $AJV_OPTS -s "$SCHEMA_FILE" -d "$tmp_json" >/dev/null 2>&1; then
        success_msg " $agent_name: Valid"
    else
        error_msg " $agent_name: Schema validation failed"
        echo "   Detailed errors:"
        $AJV_CMD validate $AJV_OPTS -s "$SCHEMA_FILE" -d "$tmp_json" 2>&1 | sed 's/^/   /' || true
        validation_errors=$((validation_errors + 1))
    fi

    # Cleanup
    rm -f "$tmp_frontmatter" "$tmp_json"
done

echo ""
report "Agent Validation Summary:"
echo "   Total files: $total_files"
echo "   Validation errors: $validation_errors"

if [ $validation_errors -eq 0 ]; then
    echo -e "${GREEN}🎉 All agent files are valid!"
    exit 0
else
    echo -e "${RED}💥 $validation_errors agent file(s) failed validation"
    exit 1
fi
