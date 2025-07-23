#!/usr/bin/env bash
# Manual markdown fixes for the specific issues

set -euo pipefail

echo "🔧 Manual Markdown Fixes"
echo "========================"

# Fix AUTOMATION_INTEGRATION_SUMMARY.md
echo "📝 Fixing AUTOMATION_INTEGRATION_SUMMARY.md..."

# Create a Python script to fix the markdown properly
python3 << 'EOF'
import re

def fix_markdown_file(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    lines = content.split('\n')
    fixed_lines = []
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Fix heading spacing
        if line.startswith('#'):
            # Add blank line before heading if needed
            if fixed_lines and fixed_lines[-1].strip():
                fixed_lines.append('')
            fixed_lines.append(line)
            # Add blank line after heading if needed
            if i + 1 < len(lines) and lines[i + 1].strip():
                fixed_lines.append('')
        
        # Fix list numbering
        elif re.match(r'^\d+\.', line):
            # Reset numbering to 1
            fixed_line = re.sub(r'^\d+\.', '1.', line)
            
            # Add blank line before list if needed
            if fixed_lines and fixed_lines[-1].strip() and not re.match(r'^\d+\.', fixed_lines[-1]):
                fixed_lines.append('')
            fixed_lines.append(fixed_line)
        
        # Fix bullet list spacing
        elif re.match(r'^[\s]*[-*]', line):
            # Add blank line before list if needed
            if fixed_lines and fixed_lines[-1].strip() and not re.match(r'^[\s]*[-*]', fixed_lines[-1]):
                fixed_lines.append('')
            fixed_lines.append(line)
        
        # Fix code block spacing
        elif line.strip().startswith('```'):
            # Add blank line before code block if needed
            if fixed_lines and fixed_lines[-1].strip():
                fixed_lines.append('')
            fixed_lines.append(line)
        
        # Fix indentation for sub-lists
        elif line.strip().startswith('- ') and line.startswith('  '):
            # Fix indentation to 4 spaces
            fixed_line = '    ' + line.strip()
            fixed_lines.append(fixed_line)
        
        else:
            fixed_lines.append(line)
        
        i += 1
    
    # Remove trailing spaces
    fixed_lines = [line.rstrip() for line in fixed_lines]
    
    # Remove excessive blank lines
    final_lines = []
    prev_blank = False
    for line in fixed_lines:
        if line.strip() == '':
            if not prev_blank:
                final_lines.append(line)
            prev_blank = True
        else:
            final_lines.append(line)
            prev_blank = False
    
    # Write back
    with open(filename, 'w') as f:
        f.write('\n'.join(final_lines))
    
    print(f"✅ Fixed {filename}")

# Fix all our report files
files = [
    'AUTOMATION_INTEGRATION_SUMMARY.md',
    'CI_CORRECTION_REPORT.md', 
    'VERIFICATION_REPORT.md'
]

for filename in files:
    try:
        fix_markdown_file(filename)
    except FileNotFoundError:
        print(f"⚠️  {filename} not found")
EOF

echo ""
echo "🎉 Manual markdown fixes applied!"
