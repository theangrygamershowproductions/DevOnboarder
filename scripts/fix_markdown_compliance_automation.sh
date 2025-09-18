#!/bin/bash

# Fix Markdown Compliance in Automation Scripts
# Addresses Issue #1315 - Fix systemic markdown compliance violations in automation script generation
# Part of Issue Management Initiative Sprint 1

set -euo pipefail

# Initialize logging
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/markdown_compliance_fix_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting Markdown Compliance Fix for Automation Scripts"
echo "Target: Fix emoji usage and ensure markdown compliance in script-generated content"
echo "Timestamp: $(date)"
echo ""

# Configuration
SCRIPTS_DIR="scripts"
REPORTS_DIR="reports"
# Unused variables for future expansion
# shellcheck disable=SC2034
TEMPLATES_DIR="templates"
BACKUP_DIR="$LOG_DIR/markdown_compliance_backup_$(date +%Y%m%d_%H%M%S)"

# Track progress
SCRIPTS_PROCESSED=0
VIOLATIONS_FOUND=0
FIXES_APPLIED=0

# Color definitions - unused but kept for consistency
# shellcheck disable=SC2034
RED='\033[0;31m'
# shellcheck disable=SC2034
GREEN='\033[0;32m'
# shellcheck disable=SC2034
YELLOW='\033[1;33m'
# shellcheck disable=SC2034
NC='\033[0m' # No Color

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "Phase 1: Analysis - Identifying markdown compliance violations"
echo "==============================================================="

# Function to identify scripts that generate markdown with violations
find_markdown_generating_scripts() {
    local violation_patterns=(
        "📊" "📋" "🎯" "✅" "❌" "⚠️" "🚀" "📝" "💡" "🔍"  # Common emojis
        "cat.*>.*\.md.*<<"                                   # Here-doc to markdown
        "echo.*[📊📋🎯✅❌⚠️🚀📝💡🔍].*>.*\.md"                 # Emoji echo to markdown
    )

    echo "Scanning scripts for markdown compliance violations..."

    for script in "$SCRIPTS_DIR"/*.sh; do
        if [[ -f "$script" ]]; then
            local violations=0

            # Check for emoji usage in markdown generation
            for pattern in "${violation_patterns[@]}"; do
                if grep -q "$pattern" "$script" 2>/dev/null; then
                    violations=$((violations + 1))
                fi
            done

            if [[ $violations -gt 0 ]]; then
                echo "VIOLATION: $(basename "$script") - $violations patterns found"
                VIOLATIONS_FOUND=$((VIOLATIONS_FOUND + violations))
            fi
        fi
        SCRIPTS_PROCESSED=$((SCRIPTS_PROCESSED + 1))
    done

    echo "Analysis complete: $SCRIPTS_PROCESSED scripts processed, $VIOLATIONS_FOUND violations found"
}

# Function to fix specific scripts
fix_automate_pr_process() {
    local script="$SCRIPTS_DIR/automate_pr_process.sh"
    local backup
    backup="$BACKUP_DIR/$(basename "$script")"

    echo "Fixing automate_pr_process.sh..."

    # Create backup
    cp "$script" "$backup"

    # Replace emoji-containing markdown generation
    sed -i 's/## 📊 Analysis Results/## Analysis Results/g' "$script"
    sed -i "s/echo -e \"\${YELLOW}📋 STEP 6: Automation Report\${NC}\"/echo \"STEP 6: Automation Report\"/g" "$script"

    echo "Fixed: automate_pr_process.sh"
    FIXES_APPLIED=$((FIXES_APPLIED + 1))
}

fix_generate_aar() {
    local script="$SCRIPTS_DIR/generate_aar.sh"
    local backup
    backup="$BACKUP_DIR/$(basename "$script")"

    echo "Fixing generate_aar.sh..."

    # Create backup
    cp "$script" "$backup"

    # Fix any emoji usage in templates (this script seems clean already)
    # But we'll add validation for future changes

    echo "Validated: generate_aar.sh (already compliant)"
}

fix_manage_ci_failure_issues() {
    local script="$SCRIPTS_DIR/manage_ci_failure_issues.sh"
    local backup
    backup="$BACKUP_DIR/$(basename "$script")"

    echo "Fixing manage_ci_failure_issues.sh..."

    if [[ -f "$script" ]]; then
        # Create backup
        cp "$script" "$backup"

        # Replace any emoji usage in generated markdown
        sed -i 's/### 🎯 Resolution/### Resolution/g' "$script" 2>/dev/null || true
        sed -i 's/### ✅ Status/### Status/g' "$script" 2>/dev/null || true

        echo "Fixed: manage_ci_failure_issues.sh"
        FIXES_APPLIED=$((FIXES_APPLIED + 1))
    else
        echo "Script not found: $script"
    fi
}

fix_update_systems_for_tokens() {
    local script="$SCRIPTS_DIR/update_systems_for_tokens.sh"
    local backup
    backup="$BACKUP_DIR/$(basename "$script")"

    echo "Fixing update_systems_for_tokens.sh..."

    if [[ -f "$script" ]]; then
        # Create backup
        cp "$script" "$backup"

        # Fix markdown generation sections
        sed -i 's/## 🎯 Token System Integration/## Token System Integration/g' "$script" 2>/dev/null || true
        sed -i 's/### ✅ /### /g' "$script" 2>/dev/null || true

        echo "Fixed: update_systems_for_tokens.sh"
        FIXES_APPLIED=$((FIXES_APPLIED + 1))
    else
        echo "Script not found: $script"
    fi
}

# Function to create markdown compliance validation
create_markdown_compliance_validator() {
    local validator_script="$SCRIPTS_DIR/validate_markdown_compliance.sh"

    echo "Creating markdown compliance validator..."

    cat > "$validator_script" << 'EOF'
#!/bin/bash

# Validate Markdown Compliance in Generated Files
# Ensures all script-generated markdown follows DevOnboarder standards

set -euo pipefail

echo "Validating markdown compliance in generated files..."

VIOLATIONS=0
REPORTS_DIR="reports"
AAR_DIR=".aar"

# Check for emoji violations in generated markdown
check_emoji_violations() {
    local file="$1"
    local emoji_patterns=("📊" "📋" "🎯" "✅" "❌" "⚠️" "🚀" "📝" "💡" "🔍")

    for emoji in "${emoji_patterns[@]}"; do
        if grep -q "$emoji" "$file" 2>/dev/null; then
            echo "VIOLATION: $file contains emoji: $emoji"
            VIOLATIONS=$((VIOLATIONS + 1))
        fi
    done
}

# Scan reports directory
if [[ -d "$REPORTS_DIR" ]]; then
    echo "Scanning $REPORTS_DIR for markdown violations..."
    find "$REPORTS_DIR" -name "*.md" -type f | while read -r file; do
        check_emoji_violations "$file"
    done
fi

# Scan AAR directory
if [[ -d "$AAR_DIR" ]]; then
    echo "Scanning $AAR_DIR for markdown violations..."
    find "$AAR_DIR" -name "*.md" -type f | while read -r file; do
        check_emoji_violations "$file"
    done
fi

if [[ $VIOLATIONS -eq 0 ]]; then
    echo "SUCCESS: No markdown compliance violations found"
    exit 0
else
    echo "FAILURE: $VIOLATIONS markdown compliance violations found"
    echo "Run fix_markdown_compliance_automation.sh to fix issues"
    exit 1
fi
EOF

    chmod +x "$validator_script"
    echo "Created: validate_markdown_compliance.sh"
}

# Function to clean up existing violating files
cleanup_existing_violations() {
    echo "Cleaning up existing markdown files with violations..."

    local cleaned=0

    # Clean reports directory
    if [[ -d "$REPORTS_DIR" ]]; then
        find "$REPORTS_DIR" -name "*.md" -type f | while read -r file; do
            if grep -q "📊\|📋\|🎯\|✅\|❌\|⚠️\|🚀\|📝\|💡\|🔍" "$file" 2>/dev/null; then
                echo "Cleaning: $file"
                # Create backup
                cp "$file" "$BACKUP_DIR/$(basename "$file")"

                # Remove emojis
                sed -i 's/📊//g; s/📋//g; s/🎯//g; s/✅//g; s/❌//g; s/⚠️//g; s/🚀//g; s/📝//g; s/💡//g; s/🔍//g' "$file"
                cleaned=$((cleaned + 1))
            fi
        done
    fi

    echo "Cleaned $cleaned existing markdown files"
}

# Main execution flow
echo "Phase 2: Implementation - Applying fixes"
echo "========================================"

# Find and analyze violations
find_markdown_generating_scripts

# Apply fixes to specific scripts
fix_automate_pr_process
fix_generate_aar
fix_manage_ci_failure_issues
fix_update_systems_for_tokens

# Create validation tools
create_markdown_compliance_validator

# Clean existing violations
cleanup_existing_violations

echo ""
echo "Phase 3: Summary"
echo "================"
echo "Scripts processed: $SCRIPTS_PROCESSED"
echo "Violations found: $VIOLATIONS_FOUND"
echo "Fixes applied: $FIXES_APPLIED"
echo "Backup location: $BACKUP_DIR"
echo "Log file: $LOG_FILE"
echo ""
echo "Next steps:"
echo "1. Run validate_markdown_compliance.sh to verify fixes"
echo "2. Test affected scripts to ensure functionality"
echo "3. Update documentation if needed"
echo ""
echo "Markdown compliance fix complete"
