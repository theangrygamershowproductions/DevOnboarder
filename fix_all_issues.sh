#!/bin/bash

echo "DevOnboarder: Comprehensive Issue Fix Script"
echo "============================================"

# Fix shellcheck issues first
echo "1. Fixing shellcheck issues..."

# Fix backup_docs.sh quoting issues
sed -i 's/mtime $RETENTION_DAYS/mtime "$RETENTION_DAYS"/g' scripts/backup_docs.sh

# Fix detect_content_duplication.sh issues
# Remove unused variable declaration
sed -i '/^declare -A DEVONBOARDER_SYNONYMS=/,/^)$/d' scripts/detect_content_duplication.sh

# Replace grep | wc -l with grep -c
sed -i 's/grep '"'"'^#'"'"' 2>\/dev\/null | wc -l/grep -c '"'"'^#'"'"' 2>\/dev\/null/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^FMPRIO15_'"'"' | wc -l/grep -c '"'"'^FMPRIO15_'"'"'/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^FMMERGE14_'"'"' | wc -l/grep -c '"'"'^FMMERGE14_'"'"'/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^FMGROUP12_'"'"' | wc -l/grep -c '"'"'^FMGROUP12_'"'"'/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^FMUNIQ11_'"'"' | wc -l/grep -c '"'"'^FMUNIQ11_'"'"'/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^FMTAG10_'"'"' | wc -l/grep -c '"'"'^FMTAG10_'"'"'/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^FMTITLE9_'"'"' | wc -l/grep -c '"'"'^FMTITLE9_'"'"'/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^FMDOC8_'"'"' | wc -l/grep -c '"'"'^FMDOC8_'"'"'/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^FMPROJ7_'"'"' | wc -l/grep -c '"'"'^FMPROJ7_'"'"'/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^FMDESC6_'"'"' | wc -l/grep -c '"'"'^FMDESC6_'"'"'/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^HDR3_'"'"' | wc -l/grep -c '"'"'^HDR3_'"'"'/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^SEM3_'"'"' | wc -l/grep -c '"'"'^SEM3_'"'"'/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^FIRST2_'"'"' | wc -l/grep -c '"'"'^FIRST2_'"'"'/g' scripts/detect_content_duplication.sh
sed -i 's/grep '"'"'^NORM1_'"'"' | wc -l/grep -c '"'"'^NORM1_'"'"'/g' scripts/detect_content_duplication.sh

echo "2. Fixing markdown formatting issues..."

# Fix PRIORITY_MATRIX_FIXES_COMPLETE.md markdown issues
python3 << 'EOF'
import re

# Read the file
with open('PRIORITY_MATRIX_FIXES_COMPLETE.md', 'r') as f:
    content = f.read()

# Fix MD032 (lists surrounded by blank lines)
# Add blank line before lists
content = re.sub(r'([^\n])\n(- [^\n])', r'\1\n\n\2', content)
content = re.sub(r'([^\n])\n(\d\. [^\n])', r'\1\n\n\2', content)

# Add blank line after lists (before non-list content)
content = re.sub(r'(- [^\n])\n([^-\d\n][^\n]*)', r'\1\n\n\2', content)
content = re.sub(r'(\d\. [^\n])\n([^-\d\n][^\n]*)', r'\1\n\n\2', content)

# Fix MD031 (fenced code blocks surrounded by blank lines)
content = re.sub(r'([^\n])\n(```[^\n]*)', r'\1\n\n\2', content)
content = re.sub(r'(```)\n([^`\n][^\n]*)', r'\1\n\n\2', content)

# Fix MD022 (headings surrounded by blank lines)
content = re.sub(r'([^\n])\n(#{1,6} [^\n])', r'\1\n\n\2', content)
content = re.sub(r'(#{1,6} [^\n])\n([^#\n][^\n]*)', r'\1\n\n\2', content)

# Write back
with open('PRIORITY_MATRIX_FIXES_COMPLETE.md', 'w') as f:
    f.write(content)

print("Fixed PRIORITY_MATRIX_FIXES_COMPLETE.md")
EOF

# Fix heading style issues in policy files
python3 << 'EOF'
import re

def fix_heading_style(filename):
    with open(filename, 'r') as f:
        content = f.read()

    # Convert ATX headings to setext style for h2 and h3
    # H2: ## Title  Title\n========
    content = re.sub(r'^## (.)$', r'\1\n'  '=' * 50, content, flags=re.MULTILINE)

    # H3: ### Title  Title\n--------
    content = re.sub(r'^### (.)$', r'\1\n'  '-' * 30, content, flags=re.MULTILINE)

    with open(filename, 'w') as f:
        f.write(content)

    print(f"Fixed heading styles in {filename}")

fix_heading_style('docs/policies/quality-control-policy.md')
fix_heading_style('docs/policies/security-best-practices.md')
EOF

echo "3. Running validation..."
source .venv/bin/activate
pre-commit run --all-files || echo "Some issues may remain for review"

echo "Fix script complete!"
