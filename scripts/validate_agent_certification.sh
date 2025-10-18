#!/usr/bin/env bash
set -euo pipefail

# Codex Agent Certification Validator
# Part of DevOnboarder Phase 2 rollout
# Validates YAML frontmatter schema for all .codex/agents/** prompts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_DIR="$REPO_ROOT/.codex/agents"

echo "Codex Agent Certification Validator"
echo "Scanning: $AGENTS_DIR"

if [ ! -d "$AGENTS_DIR" ]; then
    echo "Error: Agents directory not found: $AGENTS_DIR"
    exit 1
fi

TOTAL_AGENTS=0
CERTIFIED_AGENTS=0
FAILED_AGENTS=0

# Required fields for agent certification
REQUIRED_FIELDS=("agent" "purpose" "trigger" "environment" "permissions")

echo "Validating agent files..."

# Find all agent markdown files
while IFS= read -r -d '' agent_file; do
    TOTAL_AGENTS=$((TOTAL_AGENTS  1))
    agent_name=$(basename "$agent_file" .md)

    echo "Validating: $agent_name"

    # Check if file has YAML frontmatter
    if ! head -n 1 "$agent_file" | grep -q "^---$"; then
        echo "   Missing YAML frontmatter"
        FAILED_AGENTS=$((FAILED_AGENTS  1))
        continue
    fi

    # Extract frontmatter
    frontmatter=$(sed -n '2,/^---$/p' "$agent_file" | head -n -1)

    # Check required fields
    missing_fields=()
    for field in "${REQUIRED_FIELDS[@]}"; do
        if ! echo "$frontmatter" | grep -q "^$field:"; then
            missing_fields=("$field")
        fi
    done

    if [ ${#missing_fields[@]} -eq 0 ]; then
        echo "   All required fields present"
        CERTIFIED_AGENTS=$((CERTIFIED_AGENTS  1))
    else
        echo "   Missing fields: ${missing_fields[*]}"
        FAILED_AGENTS=$((FAILED_AGENTS  1))
    fi

done < <(find "$AGENTS_DIR" -name "*.md" -not -name "README.md" -print0)

echo
echo "Certification Summary:"
echo "  Total Agents: $TOTAL_AGENTS"
echo "  Certified: $CERTIFIED_AGENTS"
echo "  Failed: $FAILED_AGENTS"

if [ $FAILED_AGENTS -eq 0 ]; then
    echo "  Status: ALL AGENTS CERTIFIED"
    exit 0
else
    echo "  Status: CERTIFICATION INCOMPLETE"
    exit 1
fi
