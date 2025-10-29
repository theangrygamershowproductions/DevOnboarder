#!/bin/bash

# Automated Terminal Output Violations Fixer
# Applies common fixes to Token Architecture v2.1 scripts
# DevOnboarder ZERO TOLERANCE POLICY automated compliance

set -euo pipefail

# Initialize logging
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date %Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

TARGET_SCRIPT="$1"

if [[ ! -f "$TARGET_SCRIPT" ]]; then
    echo " Script not found: $TARGET_SCRIPT"
    exit 1
fi

echo "Fixing terminal output violations in: $TARGET_SCRIPT"
echo "Creating backup..."

# Create backup
cp "$TARGET_SCRIPT" "${TARGET_SCRIPT}.backup"

# Create temporary file for fixes
TMP_FILE=$(mktemp)
cp "$TARGET_SCRIPT" "$TMP_FILE"

echo "Applying automated fixes..."

# Fix 1: Remove common emojis with safe replacements
sed -i 's/ /Success: /g' "$TMP_FILE"
sed -i 's/ /Error: /g' "$TMP_FILE"
sed -i 's/ /Warning: /g' "$TMP_FILE"
sed -i 's/ /Checking: /g' "$TMP_FILE"
sed -i 's/ /Ready: /g' "$TMP_FILE"
sed -i 's/ /Info: /g' "$TMP_FILE"
sed -i 's/ /List: /g' "$TMP_FILE"
sed -i 's/TARGET: /Target: /g' "$TMP_FILE"
sed -i 's/🎨 /Style: /g' "$TMP_FILE"
sed -i 's/LINK: /Link: /g' "$TMP_FILE"
sed -i 's/📦 /Package: /g' "$TMP_FILE"

# Fix 2: Common variable expansion patterns
# These are the most dangerous ones that cause hanging
sed -i 's/echo "Status: $\([A-Z_]*\)"/printf "Status: %s\\n" "$\1"/g' "$TMP_FILE"
sed -i 's/echo ".*length: ${\(.*\)}.*"/printf "Length: %d\\n" "${\1}"/g' "$TMP_FILE"
sed -i 's/echo ".*\$\([A-Z_]*\).*"/printf "Value: %s\\n" "$\1"/g' "$TMP_FILE"

# Fix 3: Remove remaining standalone emojis
sed -i 's///g' "$TMP_FILE"
sed -i 's///g' "$TMP_FILE"
sed -i 's///g' "$TMP_FILE"
sed -i 's///g' "$TMP_FILE"
sed -i 's///g' "$TMP_FILE"
sed -i 's///g' "$TMP_FILE"
sed -i 's///g' "$TMP_FILE"
sed -i 's/TARGET://g' "$TMP_FILE"
sed -i 's/🎨//g' "$TMP_FILE"
sed -i 's/LINK://g' "$TMP_FILE"
sed -i 's/📦//g' "$TMP_FILE"

# Apply fixes
cp "$TMP_FILE" "$TARGET_SCRIPT"
rm "$TMP_FILE"

# Verify the fix
echo "Verifying fixes..."
VIOLATIONS_AFTER=$(bash scripts/fix_terminal_output_violations.sh 2>/dev/null | grep "$TARGET_SCRIPT" -A 5 | grep "CRITICAL VIOLATIONS" | awk '{print $4}' || echo "0")

if [[ "$VIOLATIONS_AFTER" == "0" ]]; then
    echo " All violations fixed in $TARGET_SCRIPT"
    echo "Backup available at: ${TARGET_SCRIPT}.backup"
    exit 0
else
    echo "PARTIAL: $VIOLATIONS_AFTER violations remain in $TARGET_SCRIPT"
    echo "Manual fixes may be required for complex patterns"
    echo "Backup available at: ${TARGET_SCRIPT}.backup"
    exit 1
fi
