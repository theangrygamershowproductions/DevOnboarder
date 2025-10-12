#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Framework Audit Script
# Comprehensive validation of framework documentation consistency and preventable errors

set -euo pipefail

# ANSI Color codes for consistent visual formatting
RED='\033[0;31m'     # Critical errors, missing files, security issues
GREEN='\033[0;32m'   # Success, passed checks, positive results
YELLOW='\033[1;33m'  # Warnings, non-critical issues, recommendations
BLUE='\033[0;34m'    # Folder paths, structural elements, links
PURPLE='\033[0;35m'  # Naming patterns, special categories
CYAN='\033[0;36m'    # Informational issues, logging, formatting
NC='\033[0m'         # No Color - reset

echo "# Frameworks Audit ($(date -u '+%Y-%m-%dT%H:%M:%S%Z'))"
echo ""
echo "Root: ${BLUE}frameworks"
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

    echo "| ${BLUE}$framework_name${NC} | $status_snippet | — | $script_count | — |"
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
    echo "### ${BLUE}$framework_name${NC} → ${BLUE}${framework_name//_/-}"

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

echo "------------------------------------------------------------------"
echo ""

# NEW: Script Quality & Security Checks
echo "## Script Quality & Security Checks"

# Track issues found
issues_found=false

for framework_dir in frameworks/*/; do
    framework_name=$(basename "$framework_dir")
    echo "### ${BLUE}$framework_name"

    # Find all shell scripts
    scripts=$(find "$framework_dir" -name "*.sh" -type f 2>/dev/null || true)

    if [[ -z "$scripts" ]]; then
        echo "_No shell scripts found._"
        echo ""
        continue
    fi

    echo "#### Shell Scripts Found:"
    echo "\`\`\`text"
    echo "$scripts" | sed 's|.*/||' | sort
    echo "\`\`\`"

    # Check each script
    while IFS= read -r script; do
        [[ -z "$script" ]] && continue

        script_name=$(basename "$script")
        issues=""

        # Check shebang
        if ! head -n1 "$script" | grep -q "^#!/"; then
            issues="${issues}${RED}[MISSING SHEBANG]${NC} "
        fi

        # Check permissions (should be executable)
        if [[ ! -x "$script" ]]; then
            issues="${issues}${RED}[NOT EXECUTABLE]${NC} "
        fi

        # Check for world-writable (security issue)
        if [[ $(stat -c %a "$script" 2>/dev/null | tail -c1) == "6" ]] || [[ $(stat -c %a "$script" 2>/dev/null | tail -c1) == "7" ]]; then
            issues="${issues}${RED}[WORLD WRITABLE]${NC} "
        fi

        # Check for terminal output violations (critical for CI compatibility)
        if grep -q "echo.*SUCCESS:\|echo.*ERROR:\|echo.*DEPLOY:\|echo.*CHECK:\|echo.*🔍\|echo.*NOTE:\|echo.*💡\|echo.*WARNING:\|echo.*TOOL:\|echo.*TARGET:" "$script"; then
            issues="${issues}${YELLOW}[EMOJIS IN ECHO]${NC} "
        fi

        if grep -q "echo.*\$[A-Z_].*[^\"']" "$script" | grep -v "echo.*\".*\$[A-Z_].*\"" | grep -v "echo.*'.*\$[A-Z_].*'" | grep -v "printf"; then
            issues="${issues}${YELLOW}[VAR EXPANSION IN ECHO]${NC} "
        fi

        if grep -q "cat << 'EOF'" "$script"; then
            issues="${issues}${YELLOW}[HERE-DOC SYNTAX]${NC} "
        fi

        # Only check error handling for complex scripts (>50 lines)
        script_lines=$(wc -l < "$script")
        if [[ $script_lines -gt 50 ]] && ! grep -q "set -euo pipefail\|set -e\|trap.*ERR" "$script"; then
            issues="${issues}${YELLOW}[WEAK ERROR HANDLING]${NC} "
        fi

        # CRITICAL: Check for centralized logging (DevOnboarder infrastructure requirement)
        # Must validate proper logging implementation for troubleshooting and repository health
        logging_issues=""

        # Check for basic logging setup
        if ! grep -q "exec > >(tee -a.*logs/\|LOG_FILE.*logs/" "$script"; then
            logging_issues="${logging_issues}NO_LOGGING_SETUP "
        fi

        # Check for proper log directory creation
        if ! grep -q "mkdir -p logs" "$script"; then
            logging_issues="${logging_issues}NO_LOG_DIR_CREATION "
        fi

        # Check for timestamped log filenames (critical for troubleshooting)
        if ! grep -q "LOG_FILE.*logs/.*\$(date\|basename.*date" "$script"; then
            logging_issues="${logging_issues}NO_TIMESTAMPED_LOGS "
        fi

        # Check for script name in log filename (for easy identification)
        if ! grep -q "LOG_FILE.*logs/.*basename.*\$0" "$script"; then
            logging_issues="${logging_issues}NO_SCRIPT_NAME_IN_LOG "
        fi

        # Convert logging issues to proper error messages
        if [[ -n "$logging_issues" ]]; then
            if [[ "$logging_issues" == "NO_LOGGING_SETUP "* ]]; then
                issues="${issues}${RED}[NOT USING CENTRALIZED LOGGING]${NC} "
            else
                issues="${issues}${YELLOW}[INCOMPLETE LOGGING: $logging_issues]${NC} "
            fi
        fi

        if [[ -n "$issues" ]]; then
            echo "- **$script_name**: $issues"
            issues_found=true
        fi

    done <<< "$scripts"

    echo ""
done

if [[ "$issues_found" != true ]]; then
    echo "_No script quality or security issues found._"
fi

echo ""
echo "------------------------------------------------------------------"
echo ""

# NEW: Documentation Quality Checks
echo "## Documentation Quality Checks"

for framework_dir in frameworks/*/; do
    framework_name=$(basename "$framework_dir")
    readme_file="$framework_dir/README.md"

    echo "### ${BLUE}$framework_name"

    if [[ ! -f "$readme_file" ]]; then
        echo "${RED}[MISSING README.md]"
        echo ""
        continue
    fi

    issues=""

    # Check for required sections
    required_sections=("Description" "Usage" "Requirements" "Scripts")
    for section in "${required_sections[@]}"; do
        if ! grep -qi "^#[[:space:]]*$section" "$readme_file"; then
            issues="${issues}${RED}[MISSING '$section' SECTION]${NC} "
        fi
    done

    # Check for broken internal links
    while IFS= read -r line; do
        # Extract links that reference scripts
        script_links=$(echo "$line" | grep -o "frameworks/[^)]*\.sh" || true)
        if [[ -n "$script_links" ]]; then
            for link in $script_links; do
                # Convert relative link to absolute path
                full_path="${link#frameworks/}"
                full_path="$framework_dir$full_path"
                if [[ ! -f "$full_path" ]]; then
                    issues="${issues}${YELLOW}[BROKEN SCRIPT LINK: $link]${NC} "
                fi
            done
        fi
    done < "$readme_file"

    # Check markdown formatting (basic checks)
    if grep -q "^#[^# ]" "$readme_file" | grep -v "^#[[:space:]]"; then
        issues="${issues}${CYAN}[MISSING SPACE AFTER HEADING]${NC} "
    fi

    if [[ -n "$issues" ]]; then
        echo "$issues"
    else
        echo "${GREEN}[README QUALITY CHECKS PASSED]"
    fi

    echo ""
done

echo ""
echo "------------------------------------------------------------------"
echo ""

# NEW: Framework Consistency Checks
echo "## Framework Consistency Checks"

# Check for consistent script naming patterns
echo "### Script Naming Patterns"
for framework_dir in frameworks/*/; do
    framework_name=$(basename "$framework_dir")

    # Count different naming patterns
    kebab_case=$(find "$framework_dir" -name "*-*.sh" -type f | wc -l)
    snake_case=$(find "$framework_dir" -name "*_*.sh" -type f | wc -l)
    camel_case=$(find "$framework_dir" -name "*[a-z][A-Z]*.sh" -type f | wc -l)

    total_scripts=$(find "$framework_dir" -name "*.sh" -type f | wc -l)

    if [[ $total_scripts -gt 0 ]]; then
        echo "- **${BLUE}$framework_name${NC}**: ${CYAN}$kebab_case kebab-case${NC}, ${YELLOW}$snake_case snake_case${NC}, ${PURPLE}$camel_case camelCase${NC} ($total_scripts total)"
    fi
done

echo ""
echo "### Framework Structure Consistency"
# Check that all frameworks have similar directory structures
echo "| Framework | Has scripts/ | Has README | Has tests/ |"
echo "|---|:---:|:---:|:---:|"

for framework_dir in frameworks/*/; do
    framework_name=$(basename "$framework_dir")

    has_scripts=$([[ -d "$framework_dir/scripts" ]] && echo "${GREEN}[YES]" || echo "${RED}[NO]")
    has_readme=$([[ -f "$framework_dir/README.md" ]] && echo "${GREEN}[YES]" || echo "${RED}[NO]")
    has_tests=$([[ -d "$framework_dir/tests" ]] && echo "${GREEN}[YES]" || echo "${RED}[NO]")

    echo "| ${BLUE}$framework_name${NC} | $has_scripts | $has_readme | $has_tests |"
done

echo ""
echo "------------------------------------------------------------------"
echo ""

# Summary
echo "## Summary"
echo ""
echo "**Audit completed at $(date -u '+%Y-%m-%dT%H:%M:%S%Z')**"
echo ""
echo "- Frameworks scanned: $(find frameworks -mindepth 1 -maxdepth 1 -type d | wc -l)"
echo "- Total scripts found: $(find frameworks -name "*.sh" -type f | wc -l)"
echo "- Migration artifacts: $(echo "$migration_files" | wc -l 2>/dev/null || echo "0")"
echo ""
echo "_This audit helps prevent repeatable errors in framework development and maintenance._"
