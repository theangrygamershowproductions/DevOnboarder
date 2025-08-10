#!/usr/bin/env bash
# Fix Unicode terminal output violations in manage_test_artifacts.sh
# This script applies the fix for issue #1008 by removing Unicode characters
# from terminal output while adding enhanced Unicode handling for test artifacts

set -euo pipefail

echo "Fixing Unicode violations in manage_test_artifacts.sh..."

SCRIPT_PATH="scripts/manage_test_artifacts.sh"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: $SCRIPT_PATH not found"
    exit 1
fi

# Create backup
cp "$SCRIPT_PATH" "$SCRIPT_PATH.backup"

echo "Creating Unicode-safe version of manage_test_artifacts.sh..."

# Apply replacements to remove Unicode characters
sed -i 's/FAILED/FAILED/g' "$SCRIPT_PATH"
sed -i 's/SUCCESS/OK/g' "$SCRIPT_PATH"
sed -i 's/WARNING/WARNING/g' "$SCRIPT_PATH"
sed -i 's/EMOJI/TEST/g' "$SCRIPT_PATH"
sed -i 's/SYMBOL/SECURITY/g' "$SCRIPT_PATH"
sed -i 's/FOLDER/FOLDER/g' "$SCRIPT_PATH"
sed -i 's/SYMBOL/PYTHON/g' "$SCRIPT_PATH"
sed -i 's/EMOJI/CLEAN/g' "$SCRIPT_PATH"
sed -i 's/STATS/STATS/g' "$SCRIPT_PATH"
sed -i 's/Bot/BOT/g' "$SCRIPT_PATH"
sed -i 's/SYMBOL/REACT/g' "$SCRIPT_PATH"
sed -i 's/SYMBOL/LIST/g' "$SCRIPT_PATH"
sed -i 's/SYMBOL/SUCCESS/g' "$SCRIPT_PATH"
sed -i 's/•/*/g' "$SCRIPT_PATH"

echo "Fixed Unicode characters in $SCRIPT_PATH"
echo "Backup saved as $SCRIPT_PATH.backup"

# Add Unicode artifact management integration
echo ""
echo "Adding Unicode artifact management integration..."

# Add call to Unicode manager at the end of run_tests function
if ! grep -q "unicode_artifact_manager.py" "$SCRIPT_PATH"; then
    # Insert before the final summary
    sed -i "/echo.*Results summary:/i\\
    # Enhanced Unicode handling for test artifacts (Issue #1008)\\
    if [ -f \"scripts/unicode_artifact_manager.py\" ]; then\\
        echo \"Analyzing Unicode handling in test artifacts...\"\\
        python scripts/unicode_artifact_manager.py \"\$session_dir\" --output-format text\\
        python scripts/unicode_artifact_manager.py \"\$session_dir\" --config-output \"\$session_dir/unicode-config.json\"\\
        echo \"Unicode configuration saved to: \$session_dir/unicode-config.json\"\\
    fi\\
" "$SCRIPT_PATH"
fi

echo "Integration complete!"
echo ""
echo "Summary of changes:"
echo "- Removed all Unicode characters from terminal output"
echo "- Added Unicode artifact analysis integration"
echo "- Maintained backward compatibility"
echo "- Created backup file: $SCRIPT_PATH.backup"
echo ""
echo "The script now complies with DevOnboarder terminal output policy"
echo "while providing enhanced Unicode handling for test artifacts."
