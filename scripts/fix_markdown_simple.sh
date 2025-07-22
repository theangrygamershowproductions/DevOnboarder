#!/usr/bin/env bash
# filepath: scripts/fix_markdown_simple.sh
# Simple markdown formatting fixes for documentation quality automation

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🔧 Simple Markdown Formatting Fixes"
echo "=================================="

# Target files that need formatting fixes
target_files=(
    "VERIFICATION_REPORT.md"
    "PROJECT_RESOLUTION_SUMMARY.md" 
    "ISSUE_RESOLUTION_SUMMARY.md"
    "agents/documentation-quality.md"
)

fixed_count=0

for file in "${target_files[@]}"; do
    if [ -f "$file" ]; then
        echo -n "🔧 Processing $(basename "$file")... "
        
        # Simple fixes using sed
        # Add blank lines around headings (MD022)
        sed -i '/^#/{
            x
            /^$/!{
                i\\

            }
            x
        }' "$file" 2>/dev/null || true
        
        # Remove excessive blank lines
        sed -i '/^$/N;/^\n$/d' "$file" 2>/dev/null || true
        
        echo -e "${GREEN}✅${NC}"
        ((fixed_count++))
    else
        echo "⚠️  File not found: $file"
    fi
done

echo ""
echo -e "${BLUE}📊 Summary: Processed $fixed_count files${NC}"
echo -e "${GREEN}🎉 Markdown formatting improvements applied!${NC}"
