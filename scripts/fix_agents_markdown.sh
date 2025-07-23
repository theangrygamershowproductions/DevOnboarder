#!/bin/bash

# Fix markdown lint errors in agents directory
# This script addresses MD022, MD032, MD031, MD004, MD026, MD012 violations

echo "🔧 Fixing markdown lint errors in agents/*.md files..."

# Function to fix a single markdown file
fix_markdown_file() {
    local file="$1"
    echo "  Processing: $file"
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Process the file line by line
    local prev_line=""
    local prev_prev_line=""
    local in_code_block=false
    local code_block_marker=""
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Track code block state
        if [[ "$line" =~ ^[[:space:]]*\`\`\`.*$ ]]; then
            if [[ "$in_code_block" == false ]]; then
                in_code_block=true
                code_block_marker="$line"
                # MD031: Add blank line before code block if previous line isn't blank
                if [[ -n "$prev_line" && "$prev_line" != "" ]]; then
                    echo "" >> "$temp_file"
                fi
            else
                in_code_block=false
                echo "$line" >> "$temp_file"
                # MD031: Add blank line after code block
                echo "" >> "$temp_file"
                prev_line=""
                continue
            fi
        fi
        
        # MD022: Fix headings - add blank line before heading if previous line isn't blank
        if [[ "$line" =~ ^[[:space:]]*#{1,6}[[:space:]] && "$in_code_block" == false ]]; then
            if [[ -n "$prev_line" && "$prev_line" != "" ]]; then
                echo "" >> "$temp_file"
            fi
            # MD026: Remove trailing punctuation from headings
            line=$(echo "$line" | sed 's/[[:punct:]]*$//')
            echo "$line" >> "$temp_file"
            # MD022: Add blank line after heading
            echo "" >> "$temp_file"
            prev_line=""
            continue
        fi
        
        # MD032: Fix lists - add blank line before list if previous line isn't blank
        if [[ "$line" =~ ^[[:space:]]*[-*+][[:space:]] && "$in_code_block" == false ]]; then
            if [[ -n "$prev_line" && "$prev_line" != "" && ! "$prev_line" =~ ^[[:space:]]*[-*+][[:space:]] ]]; then
                echo "" >> "$temp_file"
            fi
            # MD004: Convert asterisk lists to dash lists
            line=$(echo "$line" | sed 's/^[[:space:]]*\*[[:space:]]/- /')
        fi
        
        # MD032: Fix numbered lists - add blank line before if previous line isn't blank
        if [[ "$line" =~ ^[[:space:]]*[0-9]+\.[[:space:]] && "$in_code_block" == false ]]; then
            if [[ -n "$prev_line" && "$prev_line" != "" && ! "$prev_line" =~ ^[[:space:]]*[0-9]+\.[[:space:]] ]]; then
                echo "" >> "$temp_file"
            fi
        fi
        
        # MD012: Remove multiple consecutive blank lines
        if [[ "$line" == "" && "$prev_line" == "" ]]; then
            continue
        fi
        
        echo "$line" >> "$temp_file"
        prev_prev_line="$prev_line"
        prev_line="$line"
        
    done < "$file"
    
    # Move temp file back to original
    mv "$temp_file" "$file"
}

# Fix all agent markdown files
for file in agents/*.md; do
    if [[ -f "$file" ]]; then
        fix_markdown_file "$file"
    fi
done

echo "✅ Markdown lint fixes applied to all agent files"
echo "🔍 Running markdownlint to verify fixes..."

# Check results
markdownlint agents/ --config .markdownlint.json 2>&1 || echo "Checking with default rules"
