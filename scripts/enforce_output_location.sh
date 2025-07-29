#!/bin/bash
set -euo pipefail

# Root Artifact Guard - Prevent pollution of repository root
# Part of DevOnboarder CI Triage Guard system

SCRIPT_NAME="Root Artifact Guard"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to log messages
log_message() {
    echo -e "${1}${2}${NC}"
}

# Function to check for root pollution artifacts
check_root_pollution() {
    local violations=0
    local violation_files=()

    log_message "$GREEN" "🔍 $SCRIPT_NAME: Scanning repository root for pollution artifacts..."

    # Check for pytest artifacts in root
    if find . -maxdepth 1 -name "pytest-of-*" -type d 2>/dev/null | grep -q .; then
        log_message "$RED" "❌ VIOLATION: Pytest sandbox directories in root"
        find . -maxdepth 1 -name "pytest-of-*" -type d | while read -r dir; do
            echo "   $dir"
            violation_files+=("$dir")
        done
        violations=$((violations + 1))
    fi

    # Check for coverage files in root (should be in logs/)
    coverage_files=$(find . -maxdepth 1 -name ".coverage*" -type f 2>/dev/null | wc -l)
    if [[ "$coverage_files" -gt 0 ]]; then
        log_message "$RED" "❌ VIOLATION: Coverage files in root (should be in logs/)"
        find . -maxdepth 1 -name ".coverage*" -type f | while read -r file; do
            echo "   $file → should be logs/$(basename "$file")"
            violation_files+=("$file")
        done
        violations=$((violations + 1))
    fi

    # Check for Vale results in root (should be in logs/)
    if find . -maxdepth 1 -name "vale-results.json" -type f 2>/dev/null | grep -q .; then
        log_message "$RED" "❌ VIOLATION: Vale results in root (should be in logs/)"
        find . -maxdepth 1 -name "vale-results.json" -type f | while read -r file; do
            echo "   $file → should be logs/vale-results.json"
            violation_files+=("$file")
        done
        violations=$((violations + 1))
    fi

    # Check for temporary database files in root
    if find . -maxdepth 1 -name "test.db" -o -name "*.db-journal" -type f 2>/dev/null | grep -q .; then
        log_message "$RED" "❌ VIOLATION: Temporary database files in root"
        find . -maxdepth 1 -name "test.db" -o -name "*.db-journal" -type f | while read -r file; do
            echo "   $file → temporary file should be cleaned"
            violation_files+=("$file")
        done
        violations=$((violations + 1))
    fi

    # Check for Python cache in root (should be cleaned or in .venv)
    if find . -maxdepth 1 -name "__pycache__" -type d 2>/dev/null | grep -q .; then
        log_message "$RED" "❌ VIOLATION: Python cache directories in root"
        find . -maxdepth 1 -name "__pycache__" -type d | while read -r dir; do
            echo "   $dir → should be cleaned"
            violation_files+=("$dir")
        done
        violations=$((violations + 1))
    fi

    # Check for config backups (should be removed when committing)
    if [[ -d "config_backups" ]]; then
        backup_count=$(find config_backups/ -type f 2>/dev/null | wc -l)
        if [[ "$backup_count" -gt 0 ]]; then
            log_message "$RED" "❌ VIOLATION: Configuration backups present ($backup_count files)"
            echo "   config_backups/ → should be removed when committing changes"
            violation_files+=("config_backups/")
            violations=$((violations + 1))
        fi
    fi

    # Check for tox artifacts
    if [[ -d ".tox" ]]; then
        log_message "$RED" "❌ VIOLATION: Tox artifacts in root"
        echo "   .tox/ → should be cleaned"
        violation_files+=(".tox/")
        violations=$((violations + 1))
    fi

    # Check for npm/node artifacts outside designated directories
    if find . -maxdepth 1 -name "node_modules" -type d 2>/dev/null | grep -v -E "^\\./bot/node_modules$|^\\./frontend/node_modules$" | grep -q .; then
        log_message "$RED" "❌ VIOLATION: Unexpected node_modules in root"
        find . -maxdepth 1 -name "node_modules" -type d | while read -r dir; do
            echo "   $dir → should be in bot/ or frontend/ only"
            violation_files+=("$dir")
        done
        violations=$((violations + 1))
    fi

    return $violations
}

# Function to suggest cleanup commands
suggest_cleanup() {
    log_message "$YELLOW" "🔧 $SCRIPT_NAME: Suggested cleanup commands:"
    echo ""
    echo "   # Run comprehensive cleanup script"
    echo "   bash scripts/final_cleanup.sh"
    echo ""
    echo "   # Or manual cleanup:"
    echo "   rm -rf .pytest_cache __pycache__ .tox config_backups/"
    echo "   rm -f .coverage* test.db *.db-journal vale-results.json"
    echo "   find . -name 'pytest-of-*' -type d -exec rm -rf {} +"
    echo ""
    echo "   # Then re-run validation:"
    echo "   pre-commit run --all-files"
}

# Main execution
main() {
    cd "$PROJECT_ROOT"

    if check_root_pollution; then
        log_message "$GREEN" "✅ $SCRIPT_NAME: No root pollution artifacts detected"
        log_message "$GREEN" "   Repository root is clean and properly organized"
        exit 0
    else
        violations=$?
        log_message "$RED" "❌ $SCRIPT_NAME: Found $violations types of root pollution"
        echo ""
        log_message "$YELLOW" "📋 Root pollution violates DevOnboarder CI hygiene standards:"
        echo "   • Test artifacts should be in logs/ or cleaned after use"
        echo "   • Coverage data should be redirected to logs/.coverage"
        echo "   • Vale results should output to logs/vale-results.json"
        echo "   • Temporary files should be cleaned before commit"
        echo "   • Config backups are unnecessary when committing changes"
        echo ""
        suggest_cleanup
        echo ""
        log_message "$RED" "🛑 Fix root pollution before proceeding with commit"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-check}" in
    --check|check)
        main
        ;;
    --clean|clean)
        log_message "$YELLOW" "🧹 $SCRIPT_NAME: Running automatic cleanup..."
        bash scripts/final_cleanup.sh
        echo ""
        log_message "$GREEN" "✅ Cleanup complete. Re-checking..."
        main
        ;;
    --help|help)
        echo "$SCRIPT_NAME - Prevent repository root pollution"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  check     Check for root pollution artifacts (default)"
        echo "  clean     Run automatic cleanup then check"
        echo "  help      Show this help message"
        echo ""
        echo "This script enforces DevOnboarder CI hygiene by preventing"
        echo "test artifacts, coverage files, and temporary data from"
        echo "polluting the repository root directory."
        ;;
    *)
        log_message "$RED" "❌ Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
