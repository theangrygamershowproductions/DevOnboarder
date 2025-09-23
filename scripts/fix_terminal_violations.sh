#!/bin/bash
# scripts/fix_terminal_violations.sh
# Systematic terminal output violation fixer

set -euo pipefail

echo "🔧 DevOnboarder Terminal Violation Fixer"
echo "========================================"
echo "Timestamp: $(date)"
echo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to fix a specific violation type
fix_violation() {
    local file="$1"
    local pattern="$2"
    local replacement="$3"
    local description="$4"

    if grep -q "$pattern" "$file"; then
        echo -e "${YELLOW}Fixing $description in $file${NC}"

        # Create backup
        cp "$file" "${file}.bak"

        # Apply fix
        sed "$replacement" "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"

        # Verify fix
        if grep -q "$pattern" "$file"; then
            echo -e "${RED}❌ Fix failed for $file${NC}"
            mv "${file}.bak" "$file"  # Restore backup
        else
            echo -e "${GREEN}✅ Fixed $description in $file${NC}"
            rm "${file}.bak"
        fi
    fi
}

# Critical fixes (immediate shell interpretation issues)
echo "🚨 PHASE 1: Critical Fixes (Shell Interpretation Issues)"
echo "------------------------------------------------------"

# Fix command substitution in echo (most dangerous)
find "$REPO_ROOT" -name "*.sh" -not -path "*/node_modules/*" -not -path "*/.venv/*" | while read -r file; do
    # Fix: echo "$(command)" → printf "Result: %s\n" "$(command)"
    fix_violation "$file" 'echo "\$\(' "s/echo \"\\\$(/printf \"Result: %s\\\\n\" \"\$(/g" "command substitution in echo"
done

# Fix variable expansion in echo
find "$REPO_ROOT" -name "*.sh" -not -path "*/node_modules/*" -not -path "*/.venv/*" | while read -r file; do
    # Fix: printf "%s\n" "$AR"
    fix_violation "$file" "echo \"\\\$\{\|echo \".*\\\$[A-Za-z_]" 's/echo "\$\{.*\$[A-Za-z_]/printf "%s\\n" "$/g' "variable expansion in echo"
done

echo
echo "📊 PHASE 1 COMPLETE"
echo "=================="

# Run validation to check progress
echo "Running validation check..."
VIOLATIONS_BEFORE=$(bash "$REPO_ROOT/scripts/terminal_zero_tolerance_validator.sh" 2>/dev/null | grep "Total violations:" | sed 's/Total violations: //' || echo "unknown")

printf "%s\n" "$VIOLATIONS_BEFORE"
echo
echo "🎯 Next Steps:"
echo "1. Review the fixes above"
echo "2. Test affected scripts manually"
echo "3. Run: bash scripts/fix_terminal_violations.sh (for Phase 2)"
echo "4. Gradually enable blocking mode in validation_summary.sh"
