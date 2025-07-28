#!/bin/bash
set -euo pipefail

# Comprehensive pytest and test artifact cleanup
echo "🧪 Comprehensive pytest sandbox artifact cleanup..."

# Enhanced pytest directory cleanup - more aggressive patterns
echo "   🗑️  Removing pytest temporary directories..."
find . -type d -name "pytest-of-*" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./node_modules/*" | while read -r dir; do
    echo "     Removing: $dir"
    rm -rf "$dir"
done

# AGGRESSIVE coverage cleanup (addressing the 31 coverage artifacts issue)
echo "   📊 Cleaning ALL coverage artifacts..."
find . -name ".coverage*" -type f -not -path "./.venv/*" -delete 2>/dev/null || true
find . -name "coverage.xml" -type f -not -path "./.venv/*" -delete 2>/dev/null || true
find . -name "coverage.json" -type f -not -path "./.venv/*" -delete 2>/dev/null || true
find . -name "coverage-final.json" -type f -not -path "./.venv/*" -delete 2>/dev/null || true
find . -name ".nyc_output" -type d -not -path "./.venv/*" -exec rm -rf {} + 2>/dev/null || true
rm -rf htmlcov/ .coverage coverage/ 2>/dev/null || true

# Clean coverage artifacts in logs/
if [[ -d "logs/" ]]; then
    echo "   📊 Cleaning logs coverage artifacts..."
    find logs/ -name ".coverage*" -delete 2>/dev/null || true
    find logs/ -name "coverage.xml" -delete 2>/dev/null || true
    find logs/ -name "coverage.json" -delete 2>/dev/null || true
    rm -rf logs/htmlcov/ 2>/dev/null || true

    echo "   📝 Cleaning timestamped log files..."
    find logs/ -name "*_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].log" -delete 2>/dev/null || true

    echo "   🔍 Cleaning validation artifacts..."
    find logs/ -name "validation_*.log" -delete 2>/dev/null || true
fi

# Clean pytest cache directories more thoroughly
echo "   📦 Cleaning pytest cache..."
find . -type d -name ".pytest_cache" -not -path "./.git/*" -not -path "./.venv/*" -exec rm -rf {} + 2>/dev/null || true

# Clean ALL Python cache (following DevOnboarder virtual environment standards)
echo "   🐍 Cleaning ALL Python cache..."
find . -type d -name "__pycache__" -not -path "./.git/*" -not -path "./.venv/*" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -not -path "./.git/*" -not -path "./.venv/*" -delete 2>/dev/null || true
find . -name "*.pyo" -not -path "./.git/*" -not -path "./.venv/*" -delete 2>/dev/null || true

# Clean any generated test database files
echo "   💾 Cleaning test databases..."
find . -name "test.db" -not -path "./.git/*" -not -path "./.venv/*" -delete 2>/dev/null || true
find . -name "*.db-journal" -not -path "./.git/*" -not -path "./.venv/*" -delete 2>/dev/null || true

# Remove ALL configuration backups (we're committing changes, so backups are unnecessary)
echo "   🗂️  Removing configuration backups..."
if [[ -d "config_backups" ]]; then
    backup_count=$(find config_backups/ -type f 2>/dev/null | wc -l || echo "0")
    echo "     Removing entire config_backups directory with $backup_count files..."
    rm -rf config_backups/ 2>/dev/null || true
    echo "     ✅ config_backups directory removed"
fi

# Remove Vale result artifacts (should not be committed)
echo "   📝 Cleaning Vale validation artifacts..."
find . -name "vale-results.json" -not -path "./.venv/*" -delete 2>/dev/null || true
find . -name "vale-*.json" -not -path "./.venv/*" -delete 2>/dev/null || true
rm -f vale-results.json vale-*.json 2>/dev/null || true

# Clean tox artifacts
echo "   🧪 Cleaning tox artifacts..."
rm -rf .tox/ 2>/dev/null || true

# Remove any top-level coverage artifacts
echo "   📈 Cleaning top-level coverage..."
rm -rf htmlcov/ .coverage coverage.xml 2>/dev/null || true

# CRITICAL: Remove any files containing 'foo' references (test artifacts only)
echo "   🎯 Purging test artifact files with 'foo' references..."
find . -type f \( -name "*.log" -o -name "*.yaml" -o -name "*.yml" -o -name "*.txt" -o -name "*.json" \) \
    -not -path "./.git/*" \
    -not -path "./.venv/*" \
    -not -path "./node_modules/*" \
    -not -path "./tests/*" \
    -not -path "./frontend/src/*" \
    -not -path "./bot/src/*" \
    -not -path "./docs/*" \
    -exec grep -l "ModuleNotFoundError.*foo\|import foo\|from foo" {} \; 2>/dev/null | while read -r file; do
        echo "     Removing foo reference file: $file"
        rm -f "$file"
    done

# Enhanced verification with detailed counts - exclude legitimate files
remaining_pytest=$(find . -name "*pytest*" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./node_modules/*" -not -path "./*/node_modules/*" -not -path "./tests/*" -not -path "./frontend/*" -not -path "./bot/*" -type f 2>/dev/null | wc -l)
remaining_coverage=$(find . \( -name "*coverage*" -o -name ".coverage*" \) -not -path "./.git/*" -not -path "./.venv/*" -not -path "./node_modules/*" -not -path "./*/node_modules/*" -not -path "./tests/*" -not -path "./frontend/*" -not -path "./bot/*" -type f 2>/dev/null | wc -l)
remaining_cache=$(find . -name "__pycache__" -not -path "./.git/*" -not -path "./.venv/*" 2>/dev/null | wc -l)

echo "   ✅ Enhanced cleanup summary:"
echo "     - $remaining_pytest pytest artifacts remaining (target: 0)"
echo "     - $remaining_coverage coverage artifacts remaining (target: 0)"
echo "     - $remaining_cache cache directories remaining (target: 0)"

if [[ -d "logs/" ]]; then
    remaining_logs=$(find logs/ -type f 2>/dev/null | wc -l)
    echo "     - $remaining_logs log files remaining"
fi

# Debug: Show what files are being counted if any remain
if [[ "$remaining_pytest" -gt 0 ]]; then
    echo "   🔍 DEBUG: Remaining pytest files:"
    find . -name "*pytest*" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./node_modules/*" -not -path "./*/node_modules/*" -not -path "./tests/*" -not -path "./frontend/*" -not -path "./bot/*" -type f 2>/dev/null | head -5 | sed 's/^/     /'
fi

if [[ "$remaining_coverage" -gt 0 ]]; then
    echo "   🔍 DEBUG: Remaining coverage files:"
    find . \( -name "*coverage*" -o -name ".coverage*" \) -not -path "./.git/*" -not -path "./.venv/*" -not -path "./node_modules/*" -not -path "./*/node_modules/*" -not -path "./tests/*" -not -path "./frontend/*" -not -path "./bot/*" -type f 2>/dev/null | head -5 | sed 's/^/     /'
fi

# Critical verification: Check for 'foo' references in non-test files
foo_refs=$(grep -r "ModuleNotFoundError.*foo\|import foo\|from foo" . \
    --exclude-dir=.git \
    --exclude-dir=.venv \
    --exclude-dir=node_modules \
    --exclude-dir=tests \
    --exclude-dir=frontend/src \
    --exclude-dir=bot/src \
    --exclude-dir=docs \
    --exclude="*clean_pytest_artifacts.sh" \
    --exclude="README.md" 2>/dev/null | wc -l || echo "0")
foo_refs=$(echo "$foo_refs" | tr -d '\n')

echo "     - ${foo_refs} 'foo' references remaining in non-test files (target: 0)"

if [[ "$foo_refs" -gt 0 ]]; then
    echo "   ⚠️  WARNING: 'foo' references still exist in non-test files!"
    grep -r "ModuleNotFoundError.*foo\|import foo\|from foo" . \
        --exclude-dir=.git \
        --exclude-dir=.venv \
        --exclude-dir=node_modules \
        --exclude-dir=tests \
        --exclude-dir=frontend/src \
        --exclude-dir=bot/src \
        --exclude-dir=docs \
        --exclude="*clean_pytest_artifacts.sh" \
        --exclude="README.md" 2>/dev/null | head -3
    echo "   These may be blocking pre-commit validation"
fi

# Final success check
if [[ "$remaining_pytest" -eq 0 && "$remaining_coverage" -eq 0 && "$foo_refs" -eq 0 ]]; then
    echo "🎉 Enhanced comprehensive cleanup complete - ALL artifacts eliminated"
    exit 0
else
    echo "⚠️  Cleanup complete but some artifacts remain - check counts above"
    exit 0  # Don't fail, just warn
fi
