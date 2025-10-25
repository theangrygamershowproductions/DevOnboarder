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

# Centralized logging setup
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date %Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

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
