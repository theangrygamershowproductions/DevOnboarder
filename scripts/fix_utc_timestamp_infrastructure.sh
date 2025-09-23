#!/usr/bin/env bash
# DevOnboarder UTC Timestamp Infrastructure Fix
#
# INFRASTRUCTURE CHANGE LOG:
# - Created: 2025-09-21
# - Purpose: Systematically fix all scripts with misleading UTC timestamps
# - Evidence: docs/troubleshooting/TIMESTAMP_SYNCHRONIZATION_DIAGNOSTIC_ISSUE.md
# - Impact: Ensures diagnostic accuracy across entire DevOnboarder automation ecosystem

set -euo pipefail

# Create logs directory
mkdir -p logs
LOG_FILE="logs/utc_timestamp_infrastructure_fix_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== DevOnboarder UTC Timestamp Infrastructure Fix ==="
echo "Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "Purpose: Fix critical diagnostic accuracy issue"
echo "Evidence: docs/troubleshooting/TIMESTAMP_SYNCHRONIZATION_DIAGNOSTIC_ISSUE.md"
echo ""

# Function to fix a Python script's timestamp usage
fix_python_script() {
    local script_path="$1"
    local script_name
    script_name="$(basename "$script_path")"

    echo "Processing: $script_path"

    # Check if file exists and contains the problematic pattern
    if [ ! -f "$script_path" ]; then
        echo "  SKIP: File not found"
        return 0
    fi

    if ! grep -q "datetime\.now()\.strftime.*UTC" "$script_path"; then
        echo "  SKIP: No problematic UTC patterns found"
        return 0
    fi

    echo "  FOUND: Problematic UTC timestamp patterns"

    # Create backup
    cp "$script_path" "${script_path}.utc_fix_backup"
    echo "  BACKUP: Created ${script_path}.utc_fix_backup"

    # Add import statement if not present
    if ! grep -q "from src.utils.timestamps import" "$script_path"; then
        echo "  ADDING: Import statement for UTC utilities"

        # Find import section and add our import
        # Look for existing datetime import
        if grep -q "from datetime import datetime" "$script_path"; then
            # Add after datetime import
            sed -i '/from datetime import datetime/a\\n# INFRASTRUCTURE CHANGE: Import standardized UTC timestamp utilities\n# Purpose: Fix critical diagnostic issue with GitHub API timestamp synchronization\n# Evidence: docs/troubleshooting/TIMESTAMP_SYNCHRONIZATION_DIAGNOSTIC_ISSUE.md\n# Date: 2025-09-21\ntry:\n    from src.utils.timestamps import get_utc_display_timestamp\nexcept ImportError:\n    # Fallback for standalone script execution\n    from datetime import timezone\n\n    def get_utc_display_timestamp() -> str:\n        """Fallback UTC timestamp function."""\n        return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")' "$script_path"
        elif grep -q "import.*datetime" "$script_path"; then
            # Add after any datetime import
            sed -i '/import.*datetime/a\\n# INFRASTRUCTURE CHANGE: Import standardized UTC timestamp utilities\n# Purpose: Fix critical diagnostic issue with GitHub API timestamp synchronization\n# Evidence: docs/troubleshooting/TIMESTAMP_SYNCHRONIZATION_DIAGNOSTIC_ISSUE.md\n# Date: 2025-09-21\ntry:\n    from src.utils.timestamps import get_utc_display_timestamp\nexcept ImportError:\n    # Fallback for standalone script execution\n    from datetime import timezone\n\n    def get_utc_display_timestamp() -> str:\n        """Fallback UTC timestamp function."""\n        return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")' "$script_path"
        else
            echo "  WARNING: Could not find datetime import to place new import after"
        fi
    fi

    # Replace the problematic patterns
    echo "  FIXING: Replacing datetime.now().strftime patterns"

    # Create a temporary file for the replacement
    temp_file="${script_path}.tmp"

    # INFRASTRUCTURE CHANGE: Replace datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC") with get_utc_display_timestamp()
    # Add infrastructure change comment before the replacement
    python3 << 'EOF' > "$temp_file"
import sys
import re

script_path = sys.argv[1]

with open(script_path, 'r') as f:
    content = f.read()

# INFRASTRUCTURE CHANGE: Pattern to match datetime.now().strftime with UTC in format string
pattern = r'datetime\.now\(\)\.strftime\(["\'][^"\']*UTC[^"\']*["\']\)'

# Find all matches
matches = re.finditer(pattern, content)
match_count = 0

# Process matches in reverse order to avoid offset issues
for match in reversed(list(matches)):
    match_count += 1
    start, end = match.span()

    # Add infrastructure change comment and replacement
    replacement = '''# INFRASTRUCTURE CHANGE: Use proper UTC timestamp instead of local time
        # INFRASTRUCTURE CHANGE: Before: datetime.now().strftime("...UTC...")  # Claims UTC but uses local time
        # After: get_utc_display_timestamp()  # Actually uses UTC
        # Evidence: docs/troubleshooting/TIMESTAMP_SYNCHRONIZATION_DIAGNOSTIC_ISSUE.md
        get_utc_display_timestamp()'''

    # Replace the match
    content = content[:start] + replacement + content[end:]

print(f"Replaced {match_count} patterns")

with open(script_path + '.tmp', 'w') as f:
    f.write(content)
EOF

    python3 - "$script_path"

    # Move temp file back
    if [ -f "$temp_file" ]; then
        mv "$temp_file" "$script_path"
        echo "  SUCCESS: Applied UTC timestamp fixes"
    else
        echo "  ERROR: Failed to create replacement file"
        return 1
    fi

    echo "  COMPLETE: $script_name infrastructure change applied"
    echo ""
}

# List of scripts identified in the audit
SCRIPTS_TO_FIX=(
    "scripts/comprehensive_emoji_fix.py"
    "scripts/analyze_issue_triage.py"
    "scripts/update_devonboarder_dictionary.py"
    "scripts/comment_on_issue.py"
    "scripts/enhanced_ci_failure_analyzer.py"
    "scripts/generate_aar_portal.py"
    "scripts/validate_frontmatter_content.py"
    "scripts/ci_health_aar_integration.py"
    "scripts/file_version_tracker.py"
)

echo "Scripts to process: ${#SCRIPTS_TO_FIX[@]}"
echo ""

FIXED_COUNT=0
SKIPPED_COUNT=0
ERROR_COUNT=0

for script in "${SCRIPTS_TO_FIX[@]}"; do
    if fix_python_script "$script"; then
        if [ -f "${script}.utc_fix_backup" ]; then
            FIXED_COUNT=$((FIXED_COUNT + 1))
        else
            SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        fi
    else
        ERROR_COUNT=$((ERROR_COUNT + 1))
        echo "ERROR: Failed to process $script"
    fi
done

echo "=== INFRASTRUCTURE CHANGE SUMMARY ==="
echo "Scripts processed: ${#SCRIPTS_TO_FIX[@]}"
echo "Scripts fixed: $FIXED_COUNT"
echo "Scripts skipped: $SKIPPED_COUNT"
echo "Scripts with errors: $ERROR_COUNT"
echo ""
echo "Evidence documentation: docs/troubleshooting/TIMESTAMP_SYNCHRONIZATION_DIAGNOSTIC_ISSUE.md"
echo "Log file: $LOG_FILE"
echo ""

if [ $FIXED_COUNT -gt 0 ]; then
    echo "NEXT STEPS:"
    echo "1. Review the changes in fixed scripts"
    echo "2. Test timestamp accuracy with: python -c \"from src.utils.timestamps import get_utc_display_timestamp; print(get_utc_display_timestamp())\""
    echo "3. Run QC validation: ./scripts/qc_pre_push.sh"
    echo "4. Commit infrastructure changes with evidence documentation"
    echo ""
fi

echo "Infrastructure fix complete: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
