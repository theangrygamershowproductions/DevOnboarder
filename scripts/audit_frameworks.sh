#!/bin/bash
# Framework Audit Script
# Comprehensive validation of framework documentation consistency

set -euo pipefail

echo "# Frameworks Audit ($(date -u '+%Y-%m-%dT%H:%M:%S%Z'))"
echo ""
echo "Root: frameworks"
echo ""

# Status & Script Count Check
echo "## Status & Script Count Check"
echo "| Framework | README Status Snippet | README Claim | Actual .sh | Match? |"
echo "|---|---|---:|---:|:---:|"

# Function to extract status from README
get_readme_status() {
    local readme="$1"
    if [[ -f "$readme" ]]; then
        # Look for status lines
        grep -i "^[*-]*[ ]*status:" "$readme" | head -1 | sed 's/.*status://i' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "—"
    else
        echo "—"
    fi
}

# Function to count scripts in framework
count_scripts() {
    local framework_dir="$1"
    if [[ -d "$framework_dir" ]]; then
        find "$framework_dir" -name "*.sh" -type f | wc -l
    else
        echo "0"
    fi
}

# Check each framework
for framework_dir in frameworks/*/; do
    framework_name=$(basename "$framework_dir")
    readme_file="$framework_dir/README.md"

    readme_status=$(get_readme_status "$readme_file")
    script_count=$(count_scripts "$framework_dir")

    # Extract status snippet for table
    status_snippet=$(echo "$readme_status" | sed 's/|//g' | cut -c1-50)
    if [[ "$status_snippet" == "—" ]]; then
        status_snippet="—"
    else
        status_snippet="**Status**: $status_snippet"
    fi

    echo "| $framework_name | $status_snippet | — | $script_count | — |"
done

echo ""
echo "------------------------------------------------------------------"
echo ""

# Migration/Temp Artifact Scan
echo "## Migration/Temp Artifact Scan"
migration_files=$(find frameworks -name "*MIGRATION*" -o -name "*migration*" -o -name "*temp*" -o -name "*TEMP*" 2>/dev/null || true)
if [[ -n "$migration_files" ]]; then
    echo "\`\`\`text"
    echo "$migration_files"
    echo "\`\`\`"
else
    echo "\`\`\`text"
    echo "\`\`\`"
fi

echo ""
echo "------------------------------------------------------------------"
echo ""

# Legacy Path Reference Scan
echo "## Legacy Path Reference Scan (underscore→hyphen)"

# Check each framework for legacy references
for framework_dir in frameworks/*/; do
    framework_name=$(basename "$framework_dir")
    echo "### $framework_name → ${framework_name//_/-}"

    if [[ -d "$framework_dir" ]]; then
        # Look for references to the old underscore version in README
        readme_file="$framework_dir/README.md"
        if [[ -f "$readme_file" ]]; then
            legacy_refs=$(grep -n "frameworks/$framework_name" "$readme_file" || true)
            if [[ -n "$legacy_refs" ]]; then
                echo "\`\`\`text"
                echo "$legacy_refs"
                echo "\`\`\`"
            else
                echo "_No occurrences._"
            fi
        else
            echo "_No README found._"
        fi
    else
        echo "_Directory not found._"
    fi
    echo ""
done
