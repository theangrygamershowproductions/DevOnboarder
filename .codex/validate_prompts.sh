#!/bin/bash

# validate_prompts.sh
# Validates prompt structure and metadata for Codex compatibility

set -e

echo "SEARCH Validating Codex prompt structure..."

# Check for required directories
if [ ! -d ".codex" ]; then
    echo "WARNING  .codex directory not found - this is optional for now"
fi

# Validate YAML frontmatter in all prompt files
validate_yaml_frontmatter() {
    local file="$1"
    echo "Validating YAML frontmatter in: $file"

    # Check if file starts with YAML frontmatter
    if ! head -1 "$file" | grep -q "^---$"; then
        echo "FAILED Missing YAML frontmatter delimiter in: $file"
        return 1
    fi

    # Extract frontmatter (between first and second ---)
    local frontmatter
    frontmatter=$(sed -n '1,/^---$/p' "$file" | sed '1d;$d')

    # Check required fields for all files
    local required_fields=("title" "description" "author" "created_at" "updated_at" "tags" "project" "codex_scope" "codex_role" "codex_type" "codex_runtime")
    for field in "${required_fields[@]}"; do
        if ! echo "$frontmatter" | grep -q "^$field:"; then
            echo "FAILED Missing required field '$field' in: $file"
            return 1
        fi
    done

    # Validate specific field values for consistency
    if ! echo "$frontmatter" | grep -q "^author: \"TAGS Engineering\""; then
        echo "FAILED Incorrect author field - should be 'TAGS Engineering' in: $file"
        return 1
    fi

    if ! echo "$frontmatter" | grep -q "^project: \"core-instructions\""; then
        echo "FAILED Incorrect project field - should be 'core-instructions' in: $file"
        return 1
    fi

    if ! echo "$frontmatter" | grep -q "^codex_runtime: false"; then
        echo "FAILED Incorrect codex_runtime - should be 'false' for draft mode in: $file"
        return 1
    fi

    # Check for agent-specific fields
    if echo "$frontmatter" | grep -q "^codex_type: \"AGENT\""; then
        if ! echo "$frontmatter" | grep -q "^discord_role_required:"; then
            echo "FAILED Missing discord_role_required field for AGENT type in: $file"
            return 1
        fi
        if ! echo "$frontmatter" | grep -q "^authentication_required: true"; then
            echo "FAILED Missing or incorrect authentication_required field for AGENT type in: $file"
            return 1
        fi
    fi

    echo "SUCCESS YAML frontmatter valid in: $file"
}

# Validate integration status consistency
validate_integration_status() {
    local file="$1"
    echo "Validating integration status in: $file"

    # Check for integration guards in agent files
    if [[ "$file" == *"agent_"* ]]; then
        if ! grep -q "DRAFT.*Not Live" "$file"; then
            echo "WARNING  Agent file missing draft mode warning: $file"
        fi

        if ! grep -q "Related Integration Docs" "$file"; then
            echo "WARNING  Missing integration documentation links: $file"
        fi
    fi

    # Verify no live triggers are enabled
    if grep -q "codex_runtime.*true" "$file"; then
        echo "FAILED Live runtime detected - should be false in draft mode: $file"
        return 1
    fi

    echo "SUCCESS Integration status valid in: $file"
}

# Validate naming convention
validate_naming_convention() {
    local file="$1"
    local basename
    basename=$(basename "$file" .md)

    # Check agent/prompt files
    if [[ "$basename" =~ ^agent_[a-z0-9]+_[a-z0-9]+$ ]]; then
        echo "SUCCESS Agent naming convention valid: $file"
    # Check charter files
    elif [[ "$basename" =~ ^charter_[a-z0-9]+_[a-z0-9]+$ ]]; then
        echo "SUCCESS Charter naming convention valid: $file"
    # Check checklist files
    elif [[ "$basename" =~ ^checklist_[a-z0-9]+_[a-z0-9]+$ ]]; then
        echo "SUCCESS Checklist naming convention valid: $file"
    else
        echo "WARNING  Non-standard filename (may be intentional): $file"
    fi
}

# Validate title format in frontmatter
validate_title_format() {
    local file="$1"
    local title
    title=$(grep "^title:" "$file" | sed 's/title: *"*//' | sed 's/"*$//')

    if [[ "$title" =~ ^[A-Z]+:[A-Z]+:[A-Z]+$ ]]; then
        echo "SUCCESS Codex title format valid: $title"
    else
        echo "WARNING  Title format could be enhanced for Codex: $title"
        echo "    Recommended format: ORG:ROLE:TYPE (e.g., TAGS:CFO:PROMPT)"
    fi
}

# Main validation
echo "EMOJI Starting prompt validation..."

# Find all markdown files in org folders
find . -name "*.md" -path "*/[A-Z]*/*" -not -path "./.venv/*" -not -path "./.git/*" | while read -r file; do
    echo ""
    echo "SEARCH Validating: $file"

    # Skip README files
    if [[ "$file" =~ README\.md$ ]]; then
        echo "⏭EMOJI  Skipping README file"
        continue
    fi

    validate_yaml_frontmatter "$file"
    validate_naming_convention "$file"
    validate_title_format "$file"
    validate_integration_status "$file"  # New integration validation
done

# Validate index.json if it exists
if [ -f ".codex/index.json" ]; then
    echo ""
    echo "SEARCH Validating .codex/index.json..."
    if command -v jq >/dev/null 2>&1; then
        if jq empty .codex/index.json 2>/dev/null; then
            echo "SUCCESS index.json is valid JSON"
        else
            echo "FAILED index.json contains invalid JSON"
            exit 1
        fi
    else
        echo "WARNING  jq not available - skipping JSON validation"
    fi
fi

echo ""
echo "EMOJI Prompt validation complete!"
echo ""
echo "STATS Summary:"
echo "  SUCCESS All prompts have required YAML frontmatter"
echo "  SUCCESS Naming conventions validated"
echo "  SUCCESS Ready for Codex integration"
echo ""
echo "CONFIG Next steps:"
echo "  • Ensure CI pipeline includes this validation"
echo "  • Consider adding runtime capability when ready"
echo "  • Monitor for additional role/org expansion needs"
