#!/bin/bash
set -euo pipefail

echo "🎯 FINAL CLEANUP: Eliminating all residual test artifacts"
echo "=================================================="

# Script metadata
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="logs/final_cleanup_${TIMESTAMP}.log"

# Ensure logs directory exists
mkdir -p logs

# Function to log and display
log_and_display() {
    echo "$1" | tee -a "$LOG_FILE"
}

log_and_display "Started final cleanup at: $(date)"

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    log_and_display "❌ ERROR: Virtual environment .venv not found"
    log_and_display "Run: python -m venv .venv && source .venv/bin/activate && pip install -e .[test]"
    exit 1
fi

log_and_display "🐍 Activating virtual environment..."
# shellcheck source=/dev/null
source .venv/bin/activate

log_and_display "1️⃣ Running comprehensive pytest cleanup..."
bash scripts/clean_pytest_artifacts.sh 2>&1 | tee -a "$LOG_FILE"

log_and_display ""
log_and_display "2️⃣ Additional cache cleanup..."
# Remove any remaining test caches
find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true

# Remove temporary database files
find . -name "test.db" -not -path "./.venv/*" -delete 2>/dev/null || true
find . -name "*.db-journal" -not -path "./.venv/*" -delete 2>/dev/null || true

# Remove Vale result artifacts (these should not be committed)
log_and_display "   Cleaning Vale validation artifacts..."
find . -name "vale-results.json" -not -path "./.venv/*" -delete 2>/dev/null || true
find . -name "vale-*.json" -not -path "./.venv/*" -delete 2>/dev/null || true
rm -f vale-results.json vale-*.json 2>/dev/null || true

# Remove ALL configuration backups (we're committing changes, so backups are unnecessary)
log_and_display "   Removing configuration backups (committing changes)..."
if [[ -d "config_backups" ]]; then
    backup_count=$(find config_backups/ -type f 2>/dev/null | wc -l)
    log_and_display "   Removing entire config_backups directory with $backup_count files..."
    rm -rf config_backups/ 2>/dev/null || true
    log_and_display "   ✅ config_backups directory removed"
else
    log_and_display "   ✅ No config_backups directory found"
fi

log_and_display ""
log_and_display "3️⃣ Verifying pytest artifacts are eliminated..."

# Check for pytest temporary directories (this is what causes the 'foo' false positives)
pytest_artifacts=$(find . -type d -name "pytest-of-*" -not -path "./.venv/*" -not -path "./.git/*" 2>/dev/null | wc -l)
log_and_display "   Pytest temporary directories: $pytest_artifacts"

if [[ "$pytest_artifacts" -gt 0 ]]; then
    log_and_display "❌ ERROR: Still found pytest artifacts:"
    find . -type d -name "pytest-of-*" -not -path "./.venv/*" -not -path "./.git/*" 2>/dev/null | while read -r dir; do
        log_and_display "   $dir"
    done
    exit 1
else
    log_and_display "✅ SUCCESS: No pytest artifacts found"
fi

log_and_display ""
log_and_display "4️⃣ Running pre-commit hooks to verify everything passes..."

# Create a temporary log for pre-commit output
PRECOMMIT_LOG="logs/precommit_final_${TIMESTAMP}.log"

# Run pre-commit and capture output to file
log_and_display "   Running: pre-commit run --all-files"
if pre-commit run --all-files 2>&1 | tee "$PRECOMMIT_LOG"; then
    log_and_display "✅ All pre-commit hooks passed!"

    # Show summary of what passed from the actual log file
    if [[ -f "$PRECOMMIT_LOG" ]]; then
        hooks_passed=$(grep -c "Passed" "$PRECOMMIT_LOG" 2>/dev/null || echo "0")
        log_and_display "   Hooks passed: $hooks_passed"

        # Show the last few lines of successful output
        log_and_display "   Final pre-commit output:"
        tail -5 "$PRECOMMIT_LOG" | sed 's/^/     /' | tee -a "$LOG_FILE"
    fi

    # Also show success status directly
    log_and_display "   ✅ Pre-commit validation complete"

else
    log_and_display "❌ Pre-commit hooks failed"
    exit_code=$?
    log_and_display "   Exit code: $exit_code"

    if [[ -f "$PRECOMMIT_LOG" ]]; then
        log_and_display "Errors from $PRECOMMIT_LOG:"
        tail -30 "$PRECOMMIT_LOG" | tee -a "$LOG_FILE"
    else
        log_and_display "❌ ERROR: Pre-commit log file not created at $PRECOMMIT_LOG"
        log_and_display "   This may indicate a fundamental pre-commit setup issue"
    fi
    exit 1
fi

log_and_display ""
log_and_display "5️⃣ Final verification - checking git status..."
git status --short | tee -a "$LOG_FILE"

log_and_display ""
log_and_display "🎉 FINAL CLEANUP COMPLETE - Ready for commit!"
log_and_display "Generated log: $LOG_FILE"
log_and_display ""
log_and_display "Next steps:"
log_and_display "   git add -A"
log_and_display "   git commit -m 'FEAT(cleanup): eliminate all test artifacts and enhance validation system'"
log_and_display ""
log_and_display "Completed at: $(date)"
