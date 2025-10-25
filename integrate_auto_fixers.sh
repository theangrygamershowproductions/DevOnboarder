#!/bin/bash
# Integration script to add auto-fixer tools to DevOnboarder's QC system.
#
# This script:
# 1. Updates qc_pre_push.sh to optionally run auto-fixers
# 2. Adds make targets for auto-fixing
# 3. Documents the integration
#
# Run this script to integrate the auto-fixer tools with DevOnboarder's existing
# quality control infrastructure.

echo "DevOnboarder Auto-Fixer Integration"
echo "===================================="

# Check if we're in the right directory
if [[ ! -f "scripts/qc_pre_push.sh" ]]; then
    echo " Not in DevOnboarder root directory"
    echo "Please run from the repository root"
    exit 1
fi

echo "Adding auto-fixer make targets..."

# Add make targets to Makefile if they don't exist
if ! grep -q "autofix:" Makefile 2>/dev/null; then
    cat >> Makefile << 'EOF'

# Auto-fixer targets
autofix:
	@echo "Running DevOnboarder auto-fixers..."
	source .venv/bin/activate && python scripts/comprehensive_auto_fixer.py --all

autofix-markdown:
	@echo "Fixing markdown files..."
	source .venv/bin/activate && python scripts/fix_markdown_formatting.py --all

autofix-shell:
	@echo "Fixing shell scripts..."
	source .venv/bin/activate && python scripts/fix_shell_scripts.py --all

autofix-python:
	@echo "Running Python formatters..."
	source .venv/bin/activate && python scripts/comprehensive_auto_fixer.py --python

EOF
    echo " Added auto-fixer make targets"
else
    echo "ℹ️  Auto-fixer make targets already exist"
fi

# Create integration script for optional auto-fixing in QC
cat > scripts/qc_with_autofix.sh << 'EOF'
#!/bin/bash
# DevOnboarder QC with Auto-Fix Integration
#
# Extended QC script that optionally runs auto-fixers before validation.
#
# Usage:
#     ./scripts/qc_with_autofix.sh           # QC only
#     ./scripts/qc_with_autofix.sh --fix     # Auto-fix then QC
#     ./scripts/qc_with_autofix.sh --fix-dry # Show what would be fixed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Change to repository root
cd "$REPO_ROOT"

# Parse arguments
RUN_AUTOFIX=false
DRY_RUN=false

case "${1:-}" in
    --fix)
        RUN_AUTOFIX=true
        ;;
    --fix-dry)
        RUN_AUTOFIX=true
        DRY_RUN=true
        ;;
    "")
        # No auto-fix, just QC
        ;;
    *)
        echo "Usage: $0 [--fix|--fix-dry]"
        echo "  --fix      Run auto-fixers before QC"
        echo "  --fix-dry  Show what auto-fixers would do"
        exit 1
        ;;
esac

# Ensure virtual environment is activated
if [[ "${VIRTUAL_ENV:-}" == "" ]]; then
    echo "Activating virtual environment..."
    source .venv/bin/activate
fi

# Run auto-fixers if requested
if [[ "$RUN_AUTOFIX" == true ]]; then
    echo "Running auto-fixers..."

    if [[ "$DRY_RUN" == true ]]; then
        echo "DRY RUN: Would run auto-fixers"
        python scripts/comprehensive_auto_fixer.py --all --dry-run
    else
        echo "Applying auto-fixes..."
        python scripts/comprehensive_auto_fixer.py --all

        # Check if any files were modified
        if ! git diff --quiet; then
            echo "Auto-fixes applied. Files modified:"
            git diff --name-only
            echo ""
            echo "Note: Review changes and commit if appropriate"
            echo ""
        else
            echo "No auto-fixes needed"
        fi
    fi
fi

# Run standard QC
echo "Running DevOnboarder QC validation..."
exec ./scripts/qc_pre_push.sh
EOF

chmod x scripts/qc_with_autofix.sh
echo " Created QC integration script: scripts/qc_with_autofix.sh"

# Update README with auto-fixer information
if [[ -f "README.md" ]] && ! grep -q "auto-fixer" README.md; then
    echo "" >> README.md
    echo "## Auto-Fixer Tools" >> README.md
    echo "" >> README.md
    echo "DevOnboarder includes comprehensive auto-fixer tools for maintaining code quality:" >> README.md
    echo "" >> README.md
    echo "\`\`\`bash" >> README.md
    echo "# Fix all file types" >> README.md
    echo "make autofix" >> README.md
    echo "" >> README.md
    echo "# Fix specific file types" >> README.md
    echo "make autofix-markdown" >> README.md
    echo "make autofix-shell" >> README.md
    echo "make autofix-python" >> README.md
    echo "" >> README.md
    echo "# QC with auto-fixing" >> README.md
    echo "./scripts/qc_with_autofix.sh --fix" >> README.md
    echo "\`\`\`" >> README.md
    echo "" >> README.md
    echo "See [docs/tools/auto-fixers.md](docs/tools/auto-fixers.md) for complete documentation." >> README.md

    echo " Updated README.md with auto-fixer information"
else
    echo "ℹ️  README.md already contains auto-fixer information or doesn't exist"
fi

echo ""
echo "Integration complete! 🎉"
echo ""
echo "Available commands:"
echo "  make autofix                     # Fix all file types"
echo "  make autofix-markdown            # Fix markdown files only"
echo "  make autofix-shell               # Fix shell scripts only"
echo "  make autofix-python              # Run Python formatters"
echo "  ./scripts/qc_with_autofix.sh     # QC only"
echo "  ./scripts/qc_with_autofix.sh --fix # Auto-fix then QC"
echo ""
echo "Documentation: docs/tools/auto-fixers.md"
echo ""
echo "Next steps:"
echo "1. Test the auto-fixers: make autofix --dry-run"
echo "2. Review the documentation: docs/tools/auto-fixers.md"
echo "3. Integrate into your workflow: ./scripts/qc_with_autofix.sh --fix"
