#!/usr/bin/env bash
# Pre-commit verification and commit script for DevOnboarder
# This script ensures all pre-commit hooks pass with comprehensive logging
# before committing changes to maintain the project's "quiet reliability" standards.

set -euo pipefail

# Script metadata
SCRIPT_NAME="$(basename "$0")"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_DIR="logs"

# Initialize logging
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/verify_commit_${TIMESTAMP}.log"

log_and_display() {
    echo "$1" | tee -a "$LOG_FILE"
}

main() {
    log_and_display "🔧 DevOnboarder Pre-commit Verification and Commit Script"
    log_and_display "Started at: $(date)"
    log_and_display "Script: $SCRIPT_NAME"
    log_and_display "Log file: $LOG_FILE"
    log_and_display ""

    # Activate virtual environment (mandatory per project policies)
    if [ ! -d ".venv" ]; then
        log_and_display "❌ ERROR: Virtual environment .venv not found"
        log_and_display "Run: python -m venv .venv && source .venv/bin/activate && pip install -e .[test]"
        exit 1
    fi

    log_and_display "🐍 Activating virtual environment..."
    # shellcheck source=/dev/null
    source .venv/bin/activate

    # Verify Python and pip are from virtual environment
    log_and_display "📍 Python executable: $(which python)"
    log_and_display "📍 Pip executable: $(which pip)"

    # Ensure logs directory exists
    mkdir -p logs

    # Validate YAML configuration
    log_and_display "📝 Validating pre-commit YAML configuration..."
    if python -c "import yaml; yaml.safe_load(open('.pre-commit-config.yaml'))" 2>&1 | tee -a "$LOG_FILE"; then
        log_and_display "✅ YAML configuration is valid"
    else
        log_and_display "❌ YAML configuration has syntax errors"
        exit 1
    fi

    # Check git status before proceeding
    log_and_display "📊 Current git status:"
    git status --short | tee -a "$LOG_FILE"

    # Clean all test artifacts before validation for clean state
    log_and_display "� Cleaning all test artifacts before validation..."
    if [ -f "scripts/manage_logs.sh" ]; then
        log_and_display "   Running comprehensive log cleanup..."
        bash scripts/manage_logs.sh clean 2>&1 | tee -a "$LOG_FILE"
    fi

    if [ -f "scripts/clean_pytest_artifacts.sh" ]; then
        log_and_display "   Running pytest cleanup..."
        bash scripts/clean_pytest_artifacts.sh 2>&1 | tee -a "$LOG_FILE"
    else
        log_and_display "   ⚠️  Pytest cleanup script not found"
    fi
    log_and_display ""

    # Test pre-commit hooks
    log_and_display "🧪 Testing pre-commit hooks with comprehensive logging..."
    PRECOMMIT_LOG="$LOG_DIR/precommit_test_${TIMESTAMP}.log"

    if pre-commit run --all-files 2>&1 | tee "$PRECOMMIT_LOG"; then
        log_and_display "✅ All pre-commit hooks passed"
    else
        log_and_display "❌ Pre-commit hooks failed. Check $PRECOMMIT_LOG for details"
        log_and_display "Recent log files in logs/ directory:"
        find logs/ -type f -printf "%T@ %p\n" 2>/dev/null | sort -n | tail -5 | cut -d' ' -f2- | while read -r file; do ls -la "$file"; done | tee -a "$LOG_FILE"
        exit 1
    fi

    # Stage all changes
    log_and_display "📦 Staging all changes..."
    git add .

    # Show what will be committed
    log_and_display "📋 Files to be committed:"
    git diff --cached --name-only | tee -a "$LOG_FILE"

    # Generate commit message if not provided
    if [ $# -eq 0 ]; then
        log_and_display "💬 No commit message provided. Using default message..."
        COMMIT_MSG="FEAT(validation): implement comprehensive agent validation system with enhanced logging

- Add JSON schema validation for agent frontmatter with RBAC support
- Implement Python validation script with detailed error reporting
- Integrate agent validation into pre-commit hooks and CI pipeline
- Fix database initialization issues in test suite with SQLAlchemy cleanup
- Update test coverage to 96% (exceeding 95% requirement)
- Add comprehensive logging to logs directory for all pre-commit hooks
- Fix SQLAlchemy table conflicts in feedback service tests
- Implement robust test database setup with proper cleanup
- Configure coverage output to logs directory to prevent file conflicts
- Add test.db to .gitignore to prevent unstaged file issues
- Fix YAML syntax error in .pre-commit-config.yaml
- Ensure all pre-commit hooks output logs to logs/ directory for troubleshooting"
    else
        COMMIT_MSG="$*"
    fi

    # Attempt commit
    log_and_display "💾 Committing changes with message:"
    echo "$COMMIT_MSG" | tee -a "$LOG_FILE"
    log_and_display ""

    if git commit -m "$COMMIT_MSG" 2>&1 | tee -a "$LOG_FILE"; then
        log_and_display "🎉 Commit successful!"

        # Show latest commit
        log_and_display "📝 Latest commit:"
        git log --oneline -1 | tee -a "$LOG_FILE"

        # Show log summary
        log_and_display "📊 Generated log files:"
        find logs/ -type f -printf "%T@ %p\n" 2>/dev/null | sort -n | tail -10 | cut -d' ' -f2- | while read -r file; do ls -la "$file"; done | tee -a "$LOG_FILE"

        log_and_display ""
        log_and_display "✅ All checks passed! Ready for push."
        log_and_display "📋 Next steps:"
        log_and_display "   git push origin feat/potato-ignore-policy-focused"
        log_and_display "   Check logs/ directory for detailed outputs"

    else
        log_and_display "❌ Commit failed. Check logs for details"
        exit 1
    fi

    log_and_display ""
    log_and_display "Completed at: $(date)"
}

# Usage information
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [commit_message]

This script:
1. Validates pre-commit YAML configuration
2. Runs all pre-commit hooks with logging
3. Stages all changes
4. Commits with provided message (or default)
5. Provides comprehensive logging for troubleshooting

Examples:
  $SCRIPT_NAME
  $SCRIPT_NAME "FEAT(api): add new user endpoint"

All outputs are logged to logs/ directory for troubleshooting.
EOF
}

# Handle help flag
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
    exit 0
fi

# Run main function
main "$@"
