#!/bin/bash
# Phase 3 Framework Terminal Output Compliance Fix
# Removes all emoji and Unicode violations from migrated scripts

set -e

# Centralized logging
mkdir -p logs
LOG_FILE="logs/phase3_terminal_compliance_$(date %Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Phase 3 Framework: Terminal Output Compliance Fix"
echo "================================================="
echo "Timestamp: $(date)"
echo "Log File: $LOG_FILE"
echo ""

FRAMEWORK_DIR="frameworks/monitoring_automation"
TOTAL_FIXES=0

# Define emoji replacements
declare -A EMOJI_MAP
EMOJI_MAP[""]=""
EMOJI_MAP[""]=""
EMOJI_MAP[""]=""
EMOJI_MAP[""]=""
EMOJI_MAP["TARGET:"]="TARGET:"
EMOJI_MAP[""]="ACTION:"
EMOJI_MAP["FAST:"]="QUICK:"
EMOJI_MAP[""]=""
EMOJI_MAP[""]=""
EMOJI_MAP[""]=""
EMOJI_MAP[""]=""

# Function to fix terminal output in a script
fix_script() {
    local script_path="$1"
    local fixes_made=0

    echo "Processing: $script_path"

    # Create backup
    cp "$script_path" "${script_path}.bak"

    # Apply emoji fixes
    for emoji in "${!EMOJI_MAP[@]}"; do
        replacement="${EMOJI_MAP[$emoji]}"

        # Fix echo statements with emojis
        if grep -q "echo.*$emoji" "$script_path"; then
            sed -i "s/echo \"\([^\"]*\)$emoji \([^\"]*\)\"/echo \"\1$replacement \2\"/g" "$script_path"
            sed -i "s/echo '\([^']*\)$emoji \([^']*\)'/echo '\1$replacement \2'/g" "$script_path"
            ((fixes_made))
            echo "  Fixed emoji: $emoji  $replacement"
        fi
    done

    # Fix echo -e with color codes and emojis
    if grep -q "echo -e.*\\\${.*}.*[TARGET:FAST:]" "$script_path"; then
        # Remove echo -e color formatting with emojis
        sed -i 's/echo -e "\${[^}]*}\([^"]*\)[TARGET:FAST:]\([^"]*\)\${[^}]*}"/echo "\1\2"/g' "$script_path"
        ((fixes_made))
        echo "  Fixed echo -e with colors and emojis"
    fi

    # Fix any remaining standalone emojis in echo
    for emoji in     TARGET:  FAST:    ; do
        if grep -q "$emoji" "$script_path"; then
            replacement="${EMOJI_MAP[$emoji]:-""}"
            sed -i "s/$emoji/$replacement/g" "$script_path"
            ((fixes_made))
            echo "  Fixed standalone emoji: $emoji  $replacement"
        fi
    done

    # Remove backup if no changes made
    if [ $fixes_made -eq 0 ]; then
        rm "${script_path}.bak"
        echo "  No fixes needed"
    else
        echo "  Total fixes: $fixes_made"
        TOTAL_FIXES=$((TOTAL_FIXES  fixes_made))
    fi

    echo ""
}

# Process all scripts in the framework
echo "Scanning for terminal output violations..."
echo ""

# Process monitoring scripts
echo "=== Monitoring Scripts ==="
for script in "$FRAMEWORK_DIR"/monitoring_scripts/*.{sh,py}; do
    [ -f "$script" ] && fix_script "$script"
done

# Process automation orchestration scripts
echo "=== Automation Orchestration Scripts ==="
for script in "$FRAMEWORK_DIR"/automation_orchestration/*.{sh,py}; do
    [ -f "$script" ] && fix_script "$script"
done

# Process health check scripts
echo "=== Health Check Scripts ==="
for script in "$FRAMEWORK_DIR"/health_checks/*.{sh,py}; do
    [ -f "$script" ] && fix_script "$script"
done

# Process alerting system scripts
echo "=== Alerting System Scripts ==="
for script in "$FRAMEWORK_DIR"/alerting_systems/*; do
    [ -f "$script" ] && fix_script "$script"
done

echo "==============================================="
echo "Phase 3 Terminal Output Compliance Fix Complete"
echo "==============================================="
echo "Total fixes applied: $TOTAL_FIXES"
echo "Backup files created with .bak extension"
echo ""

# Verify compliance
echo "Verifying compliance..."
VIOLATIONS=$(grep -r '[TARGET:FAST:]' "$FRAMEWORK_DIR" || true)

if [ -z "$VIOLATIONS" ]; then
    echo " No emoji violations found in Phase 3 framework"
    echo "Phase 3 framework is now compliant with terminal output policy"
else
    echo " Some violations may remain:"
    echo "$VIOLATIONS"
fi

echo ""
echo "Next steps:"
echo "1. Review fixed scripts for correctness"
echo "2. Test script functionality"
echo "3. Remove .bak files if satisfied with fixes"
echo "4. Proceed with integration testing"
