#!/usr/bin/env bash
# filepath: scripts/fix_markdown_formatting.sh
# Automatically fix common markdown formatting issues

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🔧 Markdown Formatting Auto-Fix"
echo "==============================="

# Process specific files that need fixing
target_files=(
    "VERIFICATION_REPORT.md"
    "PROJECT_RESOLUTION_SUMMARY.md"
    "ISSUE_RESOLUTION_SUMMARY.md"
    "agents/documentation-quality.md"
)

echo -e "${BLUE}📋 Processing $(#target_files[@]) target files${NC}"

fixed_files=0
total_fixes=0

# Simple fix function for specific markdown issues
fix_markdown_simple() {
    local file="$1"
    local temp_file="${file}.tmp"
    
    echo -n "🔧 Fixing $(basename "$file")... "
    
    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}⚠️ (file not found)${NC}"
        return
    fi
    
    # Use sed to fix common issues
    fixes=0
    
    # Copy original file
    cp "$file" "$temp_file"
    
    # Fix MD022: Add blank lines around headings
    sed -i '/^#/{ 
        x; 
        /^$/!{s/^/\n/; H; s/.*//}; 
        x; 
        /^#/!s/$/\n/; 
    }' "$temp_file" 2>/dev/null || true
    
    # Fix MD032: Add blank lines around lists  
    sed -i '/^[[:space:]]*[-*]/{ 
        x; 
        /^$/!{s/^/\n/; H; s/.*//}; 
        x; 
    }' "$temp_file" 2>/dev/null || true
    
    # Count differences
    if ! diff -q "$file" "$temp_file" >/dev/null 2>&1; then
        fixes=1
        mv "$temp_file" "$file"
        echo -e "${GREEN}✅ (formatting applied)${NC}"
        ((fixed_files++))
        ((total_fixes++))
    else
        rm -f "$temp_file"
        echo -e "${GREEN}✅ (no fixes needed)${NC}"
    fi
}

# Process each target file
for file in "${target_files[@]}"; do
    if [ -f "$file" ]; then
        fix_markdown_simple "$file"
    fi
done

echo ""
echo -e "${BLUE}📊 Summary:${NC}"
echo "   ✅ Files processed: ${#target_files[@]}"
echo "   🔧 Files fixed: $fixed_files"
echo "   📋 Total fixes applied: $total_fixes"

if [ $total_fixes -gt 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 Markdown formatting fixes applied successfully!${NC}"
    echo -e "${YELLOW}💡 Consider running 'git add .' to stage the changes${NC}"
else
    echo ""
    echo -e "${GREEN}✅ All target files already properly formatted!${NC}"
fi
