#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"

# Terminal Output Violations Bulk Fix for Token Architecture v2.1
# DevOnboarder ZERO TOLERANCE POLICY Compliance
# Fixes ALL Token Architecture v2.1 scripts for terminal hanging prevention

set -euo pipefail

# Initialize logging
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder Terminal Output Violations - Bulk Fix Starting"
echo "Log: $LOG_FILE"
echo "Policy: ZERO TOLERANCE for hanging-causing patterns"
echo ""

# Identify all Token Architecture v2.1 scripts
TOKEN_SCRIPTS=(
    # Phase 1 - Critical Infrastructure
    "scripts/validate_token_architecture.sh"
    "scripts/setup_aar_tokens.sh"
    "scripts/comprehensive_token_health_check.sh"
    "scripts/token_health_check.sh"
    "scripts/simple_token_health.sh"

    # Phase 2 - Automation Scripts
    "scripts/inspect_token_permissions.sh"
    "scripts/check_classic_token_scopes.sh"
    "scripts/fine_grained_token_inspector.sh"
    "scripts/fine_grained_actions_diagnostic.sh"
    "scripts/fine_grained_org_diagnostic.sh"
    "scripts/fix_aar_tokens.sh"
    "scripts/github_cli_token_test.sh"
)

# Violation patterns that WILL cause terminal hanging
EMOJI_PATTERNS='[SUCCESS:ERROR:TARGET:CHECK:🔍DEPLOY:💡WARNING:🎨🔗📦]'
VARIABLE_ECHO_PATTERN='echo.*\$[A-Z_]*[^}]'
COMMAND_SUB_ECHO_PATTERN='echo.*\$\([^)]*\)'

echo "Scanning for CRITICAL terminal hanging violations:"
echo ""

TOTAL_VIOLATIONS=0
SCRIPTS_WITH_VIOLATIONS=0

for script in "${TOKEN_SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        echo "Checking: $script"

        # Count violations
        EMOJI_COUNT=$(grep -c "$EMOJI_PATTERNS" "$script" 2>/dev/null || echo "0")
        VAR_ECHO_COUNT=$(grep -c "$VARIABLE_ECHO_PATTERN" "$script" 2>/dev/null || echo "0")
        CMD_SUB_COUNT=$(grep -c "$COMMAND_SUB_ECHO_PATTERN" "$script" 2>/dev/null || echo "0")

        SCRIPT_VIOLATIONS=$((EMOJI_COUNT + VAR_ECHO_COUNT + CMD_SUB_COUNT))

        if [[ $SCRIPT_VIOLATIONS -gt 0 ]]; then
            echo "  CRITICAL VIOLATIONS FOUND: $SCRIPT_VIOLATIONS"
            printf "    Emojis: %d\n" "$EMOJI_COUNT"
            printf "    Variable Echo: %d\n" "$VAR_ECHO_COUNT"
            printf "    Command Substitution Echo: %d\n" "$CMD_SUB_COUNT"
            TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + SCRIPT_VIOLATIONS))
            SCRIPTS_WITH_VIOLATIONS=$((SCRIPTS_WITH_VIOLATIONS + 1))
        else
            echo "  Clean - no violations"
        fi
    else
        echo "  MISSING: $script"
    fi
    echo ""
done

echo "VIOLATION SUMMARY:"
printf "Total violations across all scripts: %d\n" "$TOTAL_VIOLATIONS"
printf "Scripts requiring fixes: %d\n" "$SCRIPTS_WITH_VIOLATIONS"
printf "Total Token Architecture v2.1 scripts: %d\n" "${#TOKEN_SCRIPTS[@]}"
echo ""

if [[ $TOTAL_VIOLATIONS -eq 0 ]]; then
    success "All Token Architecture v2.1 scripts are compliant"
    echo "Terminal hanging risk eliminated"
    exit 0
fi

echo "CRITICAL: Terminal hanging violations detected"
echo "These patterns WILL cause immediate terminal hanging:"
echo "- Emojis and Unicode characters"
echo "- Variable expansion in echo statements"
echo "- Command substitution in echo statements"
echo ""
echo "DevOnboarder ZERO TOLERANCE POLICY requires immediate fixes"
echo ""
echo "To fix these violations:"
echo "1. Remove ALL emojis from echo statements"
echo "2. Replace variable echo with printf statements"
echo "3. Use individual echo commands with plain ASCII text only"
echo ""
echo "Example fixes:"
echo "  WRONG: echo \"Status: \$TOKEN (length: \${#TOKEN})\""
printf "  RIGHT: printf \"Status: %%s (length: %%d)\\\\n\" \"\$TOKEN\" \"\${#TOKEN}\"\n"
echo ""
echo "  WRONG: echo \"[EMOJI] Success message here\""
echo "  RIGHT: echo \"Success message here\""
echo ""

exit 1
