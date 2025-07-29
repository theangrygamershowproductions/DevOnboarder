#!/bin/bash
set -euo pipefail

# Enhanced Root Artifact Guard - Phase 3.1 Advanced Detection Engine
# Part of DevOnboarder Enhanced Potato Policy Phase 3 implementation

SCRIPT_NAME="Enhanced Root Artifact Guard v3.1"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Global variables
VIOLATIONS=0
VIOLATION_FILES=()
CONTEXT_MODE=""
CLEANUP_SUGGESTIONS=()

# Function to log messages with timestamp
log_message() {
    echo -e "${1}[$(date '+%H:%M:%S')] ${2}${NC}"
}

# Function to detect execution context
detect_context() {
    if [[ "${CI:-false}" == "true" ]]; then
        CONTEXT_MODE="CI"
    elif [[ -n "${GITHUB_ACTIONS:-}" ]]; then
        CONTEXT_MODE="GITHUB_ACTIONS"
    elif [[ -n "${PRE_COMMIT:-}" ]]; then
        CONTEXT_MODE="PRE_COMMIT"
    else
        CONTEXT_MODE="LOCAL"
    fi
    log_message "$BLUE" "🔍 $SCRIPT_NAME: Running in $CONTEXT_MODE context"
}

# Enhanced artifact pattern definitions
declare -A ARTIFACT_PATTERNS=(
    # Python artifacts
    ["python_cache"]="__pycache__ *.pyc *.pyo *.pyd .Python"
    ["python_testing"]="pytest-of-* .pytest_cache .tox .coverage* htmlcov/ .mypy_cache"
    ["python_packaging"]="build/ dist/ *.egg-info/ .eggs/"

    # Node.js artifacts
    ["nodejs_packages"]="node_modules"
    ["nodejs_cache"]="npm-debug.log* yarn-debug.log* yarn-error.log* .npm .yarn"

    # Database artifacts
    ["database_files"]="test.db *.db-journal *.sqlite *.sqlite3"

    # Documentation artifacts
    ["docs_artifacts"]="vale-results.json .vale-cache"

    # Build artifacts
    ["build_artifacts"]="*.o *.so *.dylib *.dll target/ cmake-build-*/"

    # IDE artifacts
    ["ide_artifacts"]=".vscode/settings.json .idea/ *.swp *.swo *~"

    # OS artifacts
    ["os_artifacts"]="Thumbs.db .DS_Store desktop.ini"

    # CI artifacts
    ["ci_artifacts"]="junit.xml coverage.xml test-results.xml"

    # Backup artifacts
    ["backup_artifacts"]="config_backups/ *.bak *.backup *.orig"
)

# Function to check artifact patterns with enhanced detection
check_artifact_pattern() {
    local pattern_name="$1"
    local patterns="${ARTIFACT_PATTERNS[$pattern_name]}"
    local found_violations=0

    for pattern in $patterns; do
        # Use find for more precise matching
        while IFS= read -r -d '' file; do
            if [[ -e "$file" ]]; then
                local size_mb=0
                if [[ -f "$file" ]]; then
                    size_mb=$(du -m "$file" 2>/dev/null | cut -f1 || echo "0")
                elif [[ -d "$file" ]]; then
                    size_mb=$(du -sm "$file" 2>/dev/null | cut -f1 || echo "0")
                fi

                log_message "$RED" "❌ VIOLATION [$pattern_name]: $file"
                if [[ "$size_mb" -gt 0 ]]; then
                    echo "   Size: ${size_mb}MB"
                fi

                # Add context-aware suggestions
                add_cleanup_suggestion "$pattern_name" "$file"

                VIOLATION_FILES+=("$file")
                found_violations=$((found_violations + 1))
            fi
        done < <(find . -maxdepth 1 -name "$pattern" -print0 2>/dev/null)
    done

    return $found_violations
}

# Function to add context-aware cleanup suggestions
add_cleanup_suggestion() {
    local pattern_name="$1"
    local file="$2"

    case "$pattern_name" in
        "python_cache")
            CLEANUP_SUGGESTIONS+=("rm -rf $file  # Python cache - safe to remove")
            ;;
        "python_testing")
            if [[ "$file" == *".coverage"* ]]; then
                CLEANUP_SUGGESTIONS+=("mv $file logs/  # Move coverage to logs/")
            else
                CLEANUP_SUGGESTIONS+=("rm -rf $file  # Test artifact - safe to remove")
            fi
            ;;
        "nodejs_packages")
            if [[ "$file" == "./node_modules" ]]; then
                CLEANUP_SUGGESTIONS+=("rm -rf $file  # Should use frontend/node_modules or bot/node_modules")
            fi
            ;;
        "database_files")
            CLEANUP_SUGGESTIONS+=("rm -f $file  # Temporary database - safe to remove")
            ;;
        "docs_artifacts")
            CLEANUP_SUGGESTIONS+=("mv $file logs/  # Move documentation artifacts to logs/")
            ;;
        *)
            CLEANUP_SUGGESTIONS+=("rm -rf $file  # Artifact cleanup")
            ;;
    esac
}

# Function to check virtual environment compliance
check_venv_compliance() {
    log_message "$BLUE" "🐍 Checking virtual environment compliance..."

    # Check if virtual environment exists
    if [[ ! -d ".venv" ]]; then
        if [[ "$CONTEXT_MODE" == "LOCAL" ]]; then
            log_message "$YELLOW" "⚠️  No .venv directory found"
            echo "   DevOnboarder requires virtual environment usage"
            echo "   Run: python -m venv .venv && source .venv/bin/activate"
        fi
        return 1
    fi

    # Check for Python artifacts that might indicate non-venv usage
    if [[ -d "__pycache__" ]] && [[ "$CONTEXT_MODE" == "LOCAL" ]]; then
        log_message "$YELLOW" "⚠️  Root __pycache__ detected - ensure using virtual environment"
        return 1
    fi

    log_message "$GREEN" "✅ Virtual environment compliance OK"
    return 0
}

# Enhanced main pollution check with pattern-based detection
check_root_pollution() {
    log_message "$GREEN" "🔍 $SCRIPT_NAME: Scanning repository root for pollution artifacts..."
    detect_context

    local total_violations=0

    # Check each artifact pattern category
    for pattern_name in "${!ARTIFACT_PATTERNS[@]}"; do
        log_message "$BLUE" "📋 Checking $pattern_name artifacts..."

        if check_artifact_pattern "$pattern_name"; then
            violations=$?
            total_violations=$((total_violations + violations))
            log_message "$YELLOW" "   Found $violations $pattern_name violations"
        fi
    done

    # Virtual environment compliance check
    check_venv_compliance

    # Additional checks for specific contexts
    if [[ "$CONTEXT_MODE" == "CI" ]]; then
        check_ci_specific_artifacts
    fi

    VIOLATIONS=$total_violations
    return $total_violations
}

# Function to check CI-specific artifacts
check_ci_specific_artifacts() {
    log_message "$BLUE" "🔧 Checking CI-specific artifacts..."

    # Check for CI cache pollution
    if [[ -d ".github/workflows" ]]; then
        # Look for workflow artifacts in root
        for artifact in "test-results" "coverage-reports" "build-logs"; do
            if [[ -e "$artifact" ]]; then
                log_message "$RED" "❌ CI VIOLATION: $artifact should be in logs/ or removed"
                VIOLATION_FILES+=("$artifact")
                VIOLATIONS=$((VIOLATIONS + 1))
            fi
        done
    fi
}

# Enhanced cleanup suggestions with categorization
suggest_enhanced_cleanup() {
    log_message "$YELLOW" "🔧 $SCRIPT_NAME: Enhanced cleanup suggestions:"
    echo ""

    if [[ ${#CLEANUP_SUGGESTIONS[@]} -gt 0 ]]; then
        log_message "$BLUE" "📋 Specific cleanup commands:"
        printf '%s\n' "${CLEANUP_SUGGESTIONS[@]}"
        echo ""
    fi

    log_message "$BLUE" "🚀 Automated cleanup options:"
    echo "   # Safe automated cleanup"
    echo "   bash scripts/enhanced_root_artifact_guard.sh --auto-clean"
    echo ""
    echo "   # Interactive cleanup wizard"
    echo "   bash scripts/enhanced_root_artifact_guard.sh --wizard"
    echo ""
    echo "   # Comprehensive cleanup with backups"
    echo "   bash scripts/final_cleanup.sh"
    echo ""

    if [[ "$CONTEXT_MODE" == "LOCAL" ]]; then
        log_message "$PURPLE" "💡 DevOnboarder best practices:"
        echo "   • Always use virtual environment: source .venv/bin/activate"
        echo "   • Direct test outputs to logs/: pytest --cov=src --cov-report=html:logs/htmlcov"
        echo "   • Use proper npm install locations: cd frontend && npm ci"
        echo "   • Clean artifacts before commits: bash scripts/final_cleanup.sh"
    fi
}

# Function for automated cleanup (Phase 3.2 preview)
auto_cleanup() {
    log_message "$YELLOW" "🤖 Starting automated cleanup..."

    # Create backup timestamp
    backup_dir="logs/artifact_backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    log_message "$BLUE" "💾 Creating backup in $backup_dir"

    # Safe cleanup with backup
    for file in "${VIOLATION_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            if [[ -f "$file" ]] && [[ $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0) -gt 1048576 ]]; then
                # Backup files larger than 1MB
                cp -r "$file" "$backup_dir/" 2>/dev/null || true
                log_message "$BLUE" "💾 Backed up large file: $file"
            fi

            rm -rf "$file"
            log_message "$GREEN" "🗑️  Removed: $file"
        fi
    done

    log_message "$GREEN" "✅ Automated cleanup complete"
}

# Interactive cleanup wizard (Phase 3.4 preview)
cleanup_wizard() {
    log_message "$PURPLE" "🧙 Interactive Cleanup Wizard"
    echo ""

    if [[ ${#VIOLATION_FILES[@]} -eq 0 ]]; then
        log_message "$GREEN" "✅ No artifacts found to clean!"
        return 0
    fi

    echo "Found ${#VIOLATION_FILES[@]} artifacts to review:"
    echo ""

    for i in "${!VIOLATION_FILES[@]}"; do
        file="${VIOLATION_FILES[$i]}"
        echo "[$((i+1))] $file"

        if [[ -f "$file" ]]; then
            size=$(du -h "$file" 2>/dev/null | cut -f1 || echo "unknown")
            echo "    Size: $size"
        fi

        echo -n "Remove this artifact? [y/N/q]: "
        read -r response

        case "$response" in
            [Yy]*)
                rm -rf "$file"
                log_message "$GREEN" "✅ Removed: $file"
                ;;
            [Qq]*)
                echo "Wizard cancelled"
                return 1
                ;;
            *)
                echo "Skipped: $file"
                ;;
        esac
        echo ""
    done

    log_message "$GREEN" "🎉 Cleanup wizard complete!"
}

# Enhanced main execution
main() {
    cd "$PROJECT_ROOT"

    if ! check_root_pollution; then
        log_message "$GREEN" "✅ $SCRIPT_NAME: Repository root is clean!"
        log_message "$GREEN" "   No pollution artifacts detected"

        # Still check virtual environment compliance
        if [[ "$CONTEXT_MODE" == "LOCAL" ]]; then
            check_venv_compliance
        fi

        exit 0
    else
        log_message "$RED" "❌ $SCRIPT_NAME: Found $VIOLATIONS types of root pollution"
        log_message "$RED" "   ${#VIOLATION_FILES[@]} total artifacts detected"
        echo ""

        log_message "$YELLOW" "📋 Root pollution violates DevOnboarder Enhanced Potato Policy:"
        echo "   • Artifacts must be contained in designated directories"
        echo "   • Test outputs should go to logs/ directory"
        echo "   • Virtual environment usage is mandatory"
        echo "   • Clean repository state required for commits"
        echo ""

        suggest_enhanced_cleanup
        echo ""
        log_message "$RED" "🛑 Fix root pollution before proceeding"
        exit 1
    fi
}

# Enhanced command line argument handling
case "${1:-check}" in
    --check|check)
        main
        ;;
    --auto-clean|auto-clean)
        if check_root_pollution; then
            auto_cleanup
            main  # Re-check after cleanup
        else
            log_message "$GREEN" "✅ No cleanup needed"
        fi
        ;;
    --wizard|wizard)
        if check_root_pollution; then
            cleanup_wizard
            main  # Re-check after wizard
        else
            log_message "$GREEN" "✅ Repository is already clean"
        fi
        ;;
    --patterns|patterns)
        log_message "$BLUE" "📋 Enhanced artifact detection patterns:"
        for pattern_name in "${!ARTIFACT_PATTERNS[@]}"; do
            echo "  $pattern_name: ${ARTIFACT_PATTERNS[$pattern_name]}"
        done
        ;;
    --help|help)
        echo "$SCRIPT_NAME - Enhanced repository hygiene enforcement"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  check      Check for root pollution artifacts (default)"
        echo "  auto-clean Run automated cleanup with backup"
        echo "  wizard     Interactive cleanup wizard"
        echo "  patterns   Show detected artifact patterns"
        echo "  help       Show this help message"
        echo ""
        echo "This enhanced script enforces DevOnboarder Enhanced Potato Policy"
        echo "Phase 3 with advanced pattern detection, context awareness,"
        echo "and intelligent cleanup automation."
        ;;
    *)
        log_message "$RED" "❌ Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
