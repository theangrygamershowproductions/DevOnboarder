#!/usr/bin/env bash
# Fix specific markdown issues in our report files

set -euo pipefail

files=(
    "AUTOMATION_INTEGRATION_SUMMARY.md"
    "CI_CORRECTION_REPORT.md"
    "VERIFICATION_REPORT.md"
)

echo "🔧 Fixing Markdown Issues in Report Files"
echo "========================================="

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "📝 Processing $file..."
        
        # Create temporary file
        temp_file="${file}.tmp"
        
        # Fix trailing spaces
        sed 's/[[:space:]]*$//' "$file" > "$temp_file"
        
        # Fix numbered lists to use consistent numbering
        sed -i 's/^2\. /1. /' "$temp_file"
        sed -i 's/^3\. /1. /' "$temp_file"
        
        # Add blank lines around headings
        sed -i '/^#/{
            x
            /^$/!{
                i\

            }
            x
        }' "$temp_file"
        
        # Add blank lines after headings
        sed -i '/^#/{
            N
            /\n$/!{
                s/$/\
/
            }
        }' "$temp_file"
        
        # Add blank lines around lists
        sed -i '/^[[:space:]]*[-*]/{
            x
            /^$/!{
                i\

            }
            x
        }' "$temp_file"
        
        # Add blank lines around numbered lists
        sed -i '/^[[:space:]]*[0-9]/{
            x
            /^$/!{
                i\

            }
            x
        }' "$temp_file"
        
        # Add blank lines around fenced code blocks
        sed -i '/^```/{
            x
            /^$/!{
                i\

            }
            x
        }' "$temp_file"
        
        # Remove excessive blank lines
        sed -i '/^$/N;/^\n$/d' "$temp_file"
        
        # Move temp file back
        mv "$temp_file" "$file"
        echo "   ✅ Fixed $file"
    else
        echo "   ⚠️  $file not found"
    fi
done

echo ""
echo "🎉 Markdown formatting fixes applied!"
