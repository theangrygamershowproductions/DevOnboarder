#!/usr/bin/env bash
# Quick Validation Helper for DevOnboarder
# Provides easy shortcuts for common validation tasks

set -eo pipefail

SCRIPT_DIR=$(dirname "$0")
VALIDATE_SCRIPT="$SCRIPT_DIR/validate_ci_locally.sh"

show_quick_help() {
    echo "DEPLOY DevOnboarder Quick Validation Helper"
    echo "==============================================="
    echo
    echo "QUICK SHORTCUTS:"
    echo "  $0 lint               # Run only linting (YAML, Shellcheck, Black, Ruff)"
    echo "  $0 test               # Run only tests (Python, Frontend, Bot)"
    echo "  $0 security           # Run only security checks"
    echo "  $0 frontend           # Run only frontend validation"
    echo "  $0 bot                # Run only bot validation"
    echo "  $0 build              # Run only build pipeline"
    echo "  $0 fast               # Run fast checks (no Docker/services)"
    echo "  $0 list               # List all available sections and steps"
    echo "  $0 full               # Run complete validation suite"
    echo
    echo "ADVANCED USAGE:"
    echo "  $0 step \"Python Tests\"  # Run specific step"
    echo "  $0 step 21             # Run step by number"
    echo "  $0 dry frontend        # Preview what frontend would run"
    echo
    echo "TROUBLESHOOTING:"
    echo "  $0 fix-yaml           # Run only YAML linting"
    echo "  $0 fix-shell          # Run only Shellcheck"
    echo "  $0 fix-python         # Run Python linting and tests"
    echo
    echo "EXAMPLES:"
    echo "  $0 lint               # Quick linting check before commit"
    echo "  $0 test               # Run all tests without slow Docker builds"
    echo "  $0 frontend           # Test only frontend changes"
    echo "  $0 dry build          # See what build pipeline would do"
    echo
    echo "Full validation script help:"
    echo "  bash $VALIDATE_SCRIPT --help"
}

case "${1:-help}" in
    "lint")
        echo "SEARCH Running linting checks only..."
        bash "$VALIDATE_SCRIPT" --section validation
        ;;
    "test")
        echo "EMOJI Running all tests..."
        bash "$VALIDATE_SCRIPT" --section build --step "Python Tests"
        bash "$VALIDATE_SCRIPT" --section frontend --step "Frontend Tests"
        bash "$VALIDATE_SCRIPT" --section bot --step "Bot Tests"
        ;;
    "security")
        echo "SYMBOL Running security checks..."
        bash "$VALIDATE_SCRIPT" --section security
        ;;
    "frontend")
        echo "SYMBOL Running frontend validation..."
        bash "$VALIDATE_SCRIPT" --section frontend
        ;;
    "bot")
        echo "Bot Running bot validation..."
        bash "$VALIDATE_SCRIPT" --section bot
        ;;
    "build")
        echo "SYMBOL Running build pipeline..."
        bash "$VALIDATE_SCRIPT" --section build
        ;;
    "fast")
        echo "SYMBOL Running fast checks (no Docker/services)..."
        bash "$VALIDATE_SCRIPT" --section validation
        bash "$VALIDATE_SCRIPT" --section documentation
        bash "$VALIDATE_SCRIPT" --section frontend
        bash "$VALIDATE_SCRIPT" --section bot
        bash "$VALIDATE_SCRIPT" --section security
        ;;
    "list")
        bash "$VALIDATE_SCRIPT" --list
        ;;
    "full")
        echo "TARGET Running complete validation suite..."
        bash "$VALIDATE_SCRIPT"
        ;;
    "step")
        if [[ -n "$2" ]]; then
            echo "TARGET Running specific step: $2"
            bash "$VALIDATE_SCRIPT" --step "$2"
        else
            echo "FAILED Error: Please specify a step name or number"
            echo "Example: $0 step \"Python Tests\""
            exit 1
        fi
        ;;
    "dry")
        if [[ -n "$2" ]]; then
            echo "SEARCH Dry run for section: $2"
            bash "$VALIDATE_SCRIPT" --dry-run --section "$2"
        else
            echo "FAILED Error: Please specify a section for dry run"
            echo "Example: $0 dry frontend"
            exit 1
        fi
        ;;
    "fix-yaml")
        echo "CONFIG Running YAML linting..."
        bash "$VALIDATE_SCRIPT" --step "YAML Linting"
        ;;
    "fix-shell")
        echo "CONFIG Running Shellcheck..."
        bash "$VALIDATE_SCRIPT" --step "Shellcheck Linting"
        ;;
    "fix-python")
        echo "CONFIG Running Python checks..."
        bash "$VALIDATE_SCRIPT" --step "Black Formatting"
        bash "$VALIDATE_SCRIPT" --step "Ruff Linting"
        bash "$VALIDATE_SCRIPT" --step "MyPy Type Check"
        bash "$VALIDATE_SCRIPT" --step "Python Tests"
        ;;
    "help"|"--help"|"-h")
        show_quick_help
        ;;
    *)
        echo "FAILED Unknown command: $1"
        echo "Use '$0 help' to see available commands"
        exit 1
        ;;
esac
