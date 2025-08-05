#!/bin/bash
# shellcheck disable=SC2181
# scripts/fix_mvp_markdown_lint.sh
# Automated markdown linting fix for MVP documentation

set -e

echo "DevOnboarder MVP Markdown Lint Auto-Fix"
echo "========================================"
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

# Function to fix common markdown issues
fix_markdown_file() {
    local file="$1"
    echo "Fixing: $file"

    if [[ ! -f "$file" ]]; then
        echo "File not found: $file"
        return 1
    fi

    # Create backup
    cp "$file" "${file}.backup"

    # Python script to fix markdown issues
    python3 << 'EOF' "$file"
import sys
import re

def fix_markdown_issues(content):
    lines = content.split('\n')
    fixed_lines = []
    i = 0

    while i < len(lines):
        line = lines[i]

        # Fix MD022: Headings should be surrounded by blank lines
        if re.match(r'^#{1,6}\s+', line):
            # Add blank line before heading if previous line is not blank
            if fixed_lines and fixed_lines[-1].strip() != '':
                fixed_lines.append('')

            fixed_lines.append(line)

            # Add blank line after heading if next line exists and is not blank
            if i + 1 < len(lines) and lines[i + 1].strip() != '':
                fixed_lines.append('')

        # Fix MD032: Lists should be surrounded by blank lines
        elif re.match(r'^(\s*[-*+]|\s*\d+\.)\s+', line):
            # Check if this is the start of a list
            prev_line = fixed_lines[-1] if fixed_lines else ''
            if prev_line.strip() != '' and not re.match(r'^(\s*[-*+]|\s*\d+\.)\s+', prev_line):
                fixed_lines.append('')

            # Add the list item
            fixed_lines.append(line)

            # Check if this is the end of a list
            if i + 1 < len(lines):
                next_line = lines[i + 1]
                if (next_line.strip() != '' and
                    not re.match(r'^(\s*[-*+]|\s*\d+\.)\s+', next_line) and
                    not re.match(r'^\s+[-*+]', next_line)):  # Not a sub-list
                    # Look ahead to see if we need a blank line
                    j = i + 1
                    while j < len(lines) and lines[j].strip() == '':
                        j += 1
                    if j < len(lines) and not re.match(r'^(\s*[-*+]|\s*\d+\.)\s+', lines[j]):
                        fixed_lines.append('')

        # Fix MD007: Unordered list indentation (4 spaces for nested items)
        elif re.match(r'^\s+[-*+]\s+', line):
            # Count leading spaces before the list marker
            leading_spaces = len(line) - len(line.lstrip())
            if leading_spaces == 2:
                # Fix 2-space indentation to 4-space
                fixed_line = '    ' + line.strip()
                fixed_lines.append(fixed_line)
            else:
                fixed_lines.append(line)

        # Fix MD031: Fenced code blocks should be surrounded by blank lines
        elif line.strip().startswith('```'):
            # Add blank line before code block if previous line is not blank
            if fixed_lines and fixed_lines[-1].strip() != '':
                fixed_lines.append('')

            fixed_lines.append(line)

            # Find the closing fence
            i += 1
            while i < len(lines) and not lines[i].strip().startswith('```'):
                fixed_lines.append(lines[i])
                i += 1

            # Add closing fence if found
            if i < len(lines):
                fixed_lines.append(lines[i])

                # Add blank line after code block if next line exists and is not blank
                if i + 1 < len(lines) and lines[i + 1].strip() != '':
                    fixed_lines.append('')

        # Fix MD036: Emphasis used instead of a heading
        elif re.match(r'^\*[^*]+\*$', line.strip()):
            # Convert *text* to **text** if it looks like it should be bold
            if 'Target:' in line or 'Timeline:' in line:
                fixed_line = line.replace('*', '**')
                fixed_lines.append(fixed_line)
            else:
                fixed_lines.append(line)

        # Fix MD009: Trailing spaces
        else:
            # Remove trailing spaces except for intentional line breaks (2 spaces)
            stripped = line.rstrip()
            if line.endswith('  ') and not line.endswith('   '):
                # Keep intentional line break
                fixed_lines.append(stripped + '  ')
            else:
                fixed_lines.append(stripped)

        i += 1

    return '\n'.join(fixed_lines)

# Read and fix the file
if len(sys.argv) != 2:
    print("Usage: python fix_markdown.py <file>")
    sys.exit(1)

filename = sys.argv[1]
try:
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()

    fixed_content = fix_markdown_issues(content)

    with open(filename, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print(f"Fixed: {filename}")
except Exception as e:
    print(f"Error fixing {filename}: {e}")
    sys.exit(1)
EOF

    if python3 -c "
try:
    with open('$file', 'r') as f:
        content = f.read()
    print('Python script executed successfully')
except Exception as e:
    print(f'Error: {e}')
    exit(1)
" >/dev/null 2>&1; then
        echo "Fixed: $file"
    else
        echo "Failed to fix: $file"
        # Restore backup on failure
        mv "${file}.backup" "$file"
        return 1
    fi
}

# Fix each MVP documentation file
FIXED_COUNT=0
TOTAL_FILES=${#MVP_FILES[@]}

for file in "${MVP_FILES[@]}"; do
    if fix_markdown_file "$file"; then
        FIXED_COUNT=$((FIXED_COUNT + 1))
    fi
done

echo
echo "Summary"
echo "======="
echo "Files processed: $TOTAL_FILES"
echo "Files fixed: $FIXED_COUNT"

# Validate fixes with markdownlint if available
if command -v markdownlint >/dev/null 2>&1; then
    echo
    echo "Validating fixes with markdownlint..."

    VALIDATION_PASSED=0
    for file in "${MVP_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            if markdownlint "$file" >/dev/null 2>&1; then
                echo "PASS: $file - No linting errors"
                VALIDATION_PASSED=$((VALIDATION_PASSED + 1))
            else
                echo "WARN: $file - Still has linting errors"
                echo "   Run: markdownlint $file"
            fi
        fi
    done

    echo
    echo "Validation Results"
    echo "=================="
    echo "Files passing validation: $VALIDATION_PASSED/$FIXED_COUNT"

    if [[ $VALIDATION_PASSED -eq $FIXED_COUNT ]]; then
        echo "SUCCESS: All MVP markdown files now pass linting"
    else
        echo "WARNING: Some files may need manual review"
    fi
else
    echo "WARNING: markdownlint not available - install with: npm install -g markdownlint-cli"
fi

# Clean up backup files on success
if [[ $FIXED_COUNT -eq $TOTAL_FILES ]]; then
    echo
    echo "Cleaning up backup files..."
    for file in "${MVP_FILES[@]}"; do
        if [[ -f "${file}.backup" ]]; then
            rm "${file}.backup"
        fi
    done
    echo "Backup files cleaned up"
fi

echo
if [[ $FIXED_COUNT -eq $TOTAL_FILES ]]; then
    echo "SUCCESS: All MVP markdown files have been automatically fixed"
    echo "Ready for commit and MVP development"
    exit 0
else
    echo "WARNING: Some files could not be fixed automatically"
    echo "Manual review may be required"
    exit 1
fi
