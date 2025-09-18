#!/bin/bash

# Validate Markdown Compliance in Generated Files
# Ensures all script-generated markdown follows DevOnboarder standards
# Part of Issue #1315 - Markdown compliance automation

set -euo pipefail

echo "Validating markdown compliance in generated files..."
echo "Target: Emoji usage violations in script-generated markdown content"
echo "Timestamp: $(date)"
echo ""

VIOLATIONS=0
REPORTS_DIR="reports"
AAR_DIR=".aar"
LOGS_DIR="logs"

# Create logs directory if needed
mkdir -p "$LOGS_DIR"

# Check for emoji violations in generated markdown
check_emoji_violations() {
    local file="$1"
    local emoji_patterns=("📊" "📋" "🎯" "✅" "❌" "⚠️" "🚀" "📝" "💡" "🔍")
    local file_violations=0

    for emoji in "${emoji_patterns[@]}"; do
        if grep -q "$emoji" "$file" 2>/dev/null; then
            echo "VIOLATION: $file contains emoji: $emoji" >&2
            file_violations=$((file_violations + 1))
        fi
    done

    echo $file_violations
}

# Check for markdown generation violations in scripts
check_script_violations() {
    local script="$1"
    local script_violations=0

    # Check for emoji usage in markdown generation contexts
    if grep -q 'cat.*>.*\.md.*<<.*EOF' "$script" 2>/dev/null; then
        # This script generates markdown files, check for emojis in the generation context
        local temp_file="/tmp/markdown_check_$$"

        # Extract the markdown generation sections
        awk '/cat.*>.*\.md.*<<.*EOF/,/^EOF$/' "$script" > "$temp_file" 2>/dev/null || true

        local emoji_patterns=("📊" "📋" "🎯" "✅" "❌" "⚠️" "🚀" "📝" "💡" "🔍")
        for emoji in "${emoji_patterns[@]}"; do
            if grep -q "$emoji" "$temp_file" 2>/dev/null; then
                echo "SCRIPT VIOLATION: $script generates markdown with emoji: $emoji" >&2
                script_violations=$((script_violations + 1))
            fi
        done

        rm -f "$temp_file"
    fi

    echo $script_violations
}

echo "Phase 1: Scanning generated markdown files"
echo "=========================================="

# Scan reports directory
if [[ -d "$REPORTS_DIR" ]]; then
    echo "Scanning $REPORTS_DIR for markdown violations..."
    while IFS= read -r -d '' file; do
        local_violations=$(check_emoji_violations "$file")
        if [[ $local_violations -gt 0 ]]; then
            echo "  Found violations in: $file"
            VIOLATIONS=$((VIOLATIONS + local_violations))
        fi
    done < <(find "$REPORTS_DIR" -name "*.md" -type f -print0)
fi

# Scan AAR directory
if [[ -d "$AAR_DIR" ]]; then
    echo "Scanning $AAR_DIR for markdown violations..."
    while IFS= read -r -d '' file; do
        local_violations=$(check_emoji_violations "$file")
        if [[ $local_violations -gt 0 ]]; then
            echo "  Found violations in: $file"
            VIOLATIONS=$((VIOLATIONS + local_violations))
        fi
    done < <(find "$AAR_DIR" -name "*.md" -type f -print0)
fi

echo ""
echo "Phase 2: Scanning script markdown generation"
echo "============================================"

# Check key scripts that generate markdown
MARKDOWN_SCRIPTS=(
    "scripts/automate_pr_process.sh"
    "scripts/generate_aar.sh"
    "scripts/manage_ci_failure_issues.sh"
    "scripts/update_systems_for_tokens.sh"
)

for script in "${MARKDOWN_SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        echo "Checking script: $script"
        script_violations=$(check_script_violations "$script")
        if [[ $script_violations -gt 0 ]]; then
            VIOLATIONS=$((VIOLATIONS + script_violations))
        fi
    else
        echo "Script not found: $script"
    fi
done

echo ""
echo "Phase 3: Validation Summary"
echo "==========================="

if [[ $VIOLATIONS -eq 0 ]]; then
    echo "SUCCESS: No markdown compliance violations found"
    echo "All script-generated markdown content follows DevOnboarder standards"
    exit 0
else
    echo "FOUND: $VIOLATIONS markdown compliance violations"
    echo ""
    echo "Next Steps:"
    echo "1. Fix emoji usage in script markdown generation"
    echo "2. Clean existing generated files with violations"
    echo "3. Re-run validation to confirm fixes"
    echo ""
    echo "Issue #1315: Markdown compliance automation - VIOLATIONS DETECTED"
    exit 1
fi
