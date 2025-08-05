#!/bin/bash

# scripts/fix_mvp_markdown_lint_simple.sh
# Simple automated markdown linting fix for MVP documentation

set -e

echo "🔧 DevOnboarder MVP Markdown Lint Auto-Fix (Simple)"
echo "=================================================="
echo "Timestamp: $(date)"
echo

# MVP documentation files to fix
MVP_FILES=(
    "codex/mvp/MVP_PROJECT_PLAN.md"
    "codex/mvp/mvp_delivery_checklist.md"
    "codex/mvp/mvp_quality_gates.md"
    "codex/mvp/post_mvp_strategic_plan.md"
    "codex/mvp/mvp_task_coordination.md"
)

# Function to fix common markdown issues using sed
fix_markdown_file() {
    local file="$1"
    echo "🔍 Fixing: $file"

    if [[ ! -f "$file" ]]; then
        echo "⚠️  File not found: $file"
        return 1
    fi

    # Create backup
    cp "$file" "${file}.backup"

    # Create temporary file for processing
    local temp_file="${file}.tmp"

    # Process the file line by line
    local in_list=false
    local in_code_block=false
    local prev_line=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Check if we're entering/exiting a code block
        if [[ "$line" =~ ^\`\`\` ]]; then
            if [[ "$in_code_block" == false ]]; then
                # Starting code block - add blank line before if needed
                if [[ -n "$prev_line" && "$prev_line" != "" ]]; then
                    echo "" >> "$temp_file"
                fi
                in_code_block=true
            else
                # Ending code block
                in_code_block=false
            fi
            echo "$line" >> "$temp_file"
            # Add blank line after closing code block if this was the end
            if [[ "$in_code_block" == false ]]; then
                echo "" >> "$temp_file"
            fi
        elif [[ "$in_code_block" == true ]]; then
            # Inside code block - don't modify
            echo "$line" >> "$temp_file"
        elif [[ "$line" =~ ^#{1,6}[[:space:]] ]]; then
            # Heading - add blank line before if needed
            if [[ -n "$prev_line" && "$prev_line" != "" ]]; then
                echo "" >> "$temp_file"
            fi
            echo "$line" >> "$temp_file"
            echo "" >> "$temp_file"  # Always add blank line after heading
        elif [[ "$line" =~ ^[[:space:]]*[-*+][[:space:]] ]] || [[ "$line" =~ ^[[:space:]]*[0-9]+\.[[:space:]] ]]; then
            # List item
            if [[ "$in_list" == false ]]; then
                # Starting a list - add blank line before if needed
                if [[ -n "$prev_line" && "$prev_line" != "" ]]; then
                    echo "" >> "$temp_file"
                fi
                in_list=true
            fi

            # Fix indentation for nested lists (2 spaces -> 4 spaces)
            if [[ "$line" =~ ^[[:space:]]{2}[-*+][[:space:]] ]]; then
                line="    ${line#  }"
            fi

            echo "$line" >> "$temp_file"
        elif [[ "$line" =~ ^[[:space:]]*$ ]]; then
            # Blank line
            if [[ "$in_list" == true ]]; then
                in_list=false
            fi
            echo "$line" >> "$temp_file"
        else
            # Regular content
            if [[ "$in_list" == true ]]; then
                # End of list - add blank line
                echo "" >> "$temp_file"
                in_list=false
            fi

            # Remove trailing spaces (except intentional line breaks)
            if [[ "$line" =~ [[:space:]]{3,}$ ]]; then
                line="${line%"${line##*[![:space:]]}"}"
            fi

            echo "$line" >> "$temp_file"
        fi

        prev_line="$line"
    done < "$file"

    # Replace original with fixed version
    mv "$temp_file" "$file"

    echo "✅ Fixed: $file"
    return 0
}

# Check if markdownlint is available
if ! command -v markdownlint >/dev/null 2>&1; then
    echo "⚠️  markdownlint not found. Installing..."
    if command -v npm >/dev/null 2>&1; then
        npm install -g markdownlint-cli 2>/dev/null || echo "⚠️  Could not install markdownlint globally"
    fi
fi

# Fix each MVP documentation file
FIXED_COUNT=0
TOTAL_FILES=${#MVP_FILES[@]}

for file in "${MVP_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        if fix_markdown_file "$file"; then
            FIXED_COUNT=$((FIXED_COUNT + 1))
        fi
    else
        echo "⚠️  File not found: $file"
    fi
done

echo
echo "📊 Summary"
echo "=========="
echo "Files processed: $TOTAL_FILES"
echo "Files fixed: $FIXED_COUNT"

# Validate fixes with markdownlint if available
if command -v markdownlint >/dev/null 2>&1; then
    echo
    echo "🔍 Validating fixes with markdownlint..."

    VALIDATION_PASSED=0
    for file in "${MVP_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            echo -n "Checking $file... "
            if markdownlint "$file" >/dev/null 2>&1; then
                echo "✅ PASS"
                VALIDATION_PASSED=$((VALIDATION_PASSED + 1))
            else
                echo "❌ FAIL"
                echo "   Errors:"
                markdownlint "$file" | head -5 | sed 's/^/     /'
            fi
        fi
    done

    echo
    echo "📈 Validation Results"
    echo "===================="
    echo "Files passing validation: $VALIDATION_PASSED/$FIXED_COUNT"

    if [[ $VALIDATION_PASSED -eq $FIXED_COUNT ]] && [[ $FIXED_COUNT -gt 0 ]]; then
        echo "🎉 All MVP markdown files now pass linting!"
    else
        echo "⚠️  Some files may need manual review"
        echo "💡 Common remaining issues usually require manual adjustment"
    fi
else
    echo "⚠️  markdownlint not available for validation"
fi

# Clean up backup files on success
if [[ $FIXED_COUNT -eq $TOTAL_FILES ]]; then
    echo
    echo "🧹 Cleaning up backup files..."
    for file in "${MVP_FILES[@]}"; do
        if [[ -f "${file}.backup" ]]; then
            rm "${file}.backup"
            echo "   Removed: ${file}.backup"
        fi
    done
    echo "✅ Backup files cleaned up"
else
    echo
    echo "💾 Backup files preserved in case of issues:"
    for file in "${MVP_FILES[@]}"; do
        if [[ -f "${file}.backup" ]]; then
            echo "   Backup: ${file}.backup"
        fi
    done
fi

echo
if [[ $VALIDATION_PASSED -eq $FIXED_COUNT ]] && [[ $FIXED_COUNT -gt 0 ]]; then
    echo "✅ All MVP markdown files have been automatically fixed!"
    echo "🚀 Ready for commit and MVP development"
    exit 0
else
    echo "⚠️  Some files may need manual review for remaining issues"
    echo "🔧 Run individual markdownlint commands to see specific issues"
    exit 1
fi
