#!/bin/bash
set -euo pipefail

echo "Comprehensive pytest sandbox artifact cleanup"

echo "Removing pytest temporary directories"
find . -type d -name "pytest-of-*" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./venv/*" -not -path "./node_modules/*" | while read -r dir; do
    printf "Removing directory: %s\n" "$dir"
    rm -rf "$dir"
done

echo "Cleaning ALL coverage artifacts"
find . -name ".coverage*" -type f -not -path "./.venv/*" -not -path "./venv/*" -delete 2>/dev/null || true
find . -name "coverage.xml" -type f -not -path "./.venv/*" -not -path "./venv/*" -delete 2>/dev/null || true
find . -name "coverage.json" -type f -not -path "./.venv/*" -not -path "./venv/*" -delete 2>/dev/null || true
find . -name "coverage-final.json" -type f -not -path "./.venv/*" -not -path "./venv/*" -delete 2>/dev/null || true
find . -name ".nyc_output" -type d -not -path "./.venv/*" -not -path "./venv/*" -exec rm -rf {} + 2>/dev/null || true
rm -rf htmlcov/ .coverage coverage/ 2>/dev/null || true

if [[ -d "logs/" ]]; then
    echo "Cleaning logs coverage artifacts"
    find logs/ -name ".coverage*" -delete 2>/dev/null || true
    find logs/ -name "coverage.xml" -delete 2>/dev/null || true
    find logs/ -name "coverage.json" -delete 2>/dev/null || true
    rm -rf logs/htmlcov/ 2>/dev/null || true

    echo "Cleaning dashboard execution logs"
    find logs/ -name "dashboard_execution_*.log" -delete 2>/dev/null || true

    echo "Cleaning timestamped log files"
    find logs/ -name "*_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].log" -delete 2>/dev/null || true

    echo "Cleaning validation artifacts"
    find logs/ -name "validation_*.log" -delete 2>/dev/null || true

    echo "Cleaning temporary database files"
    find logs/ -name "tmp*.db" -delete 2>/dev/null || true
    find logs/ -name "*.db" -delete 2>/dev/null || true

    echo "Moving stray root logs into logs/"
    for lf in env_audit.log env_audit.json diagnostics.log gh_cli.log audit.md; do
        if [[ -f "$lf" ]]; then
            mv -f "$lf" logs/ 2>/dev/null || true
            printf "Moved log file: %s\n" "$lf"
        fi
    done
fi

echo "Cleaning pytest cache"
find . -type d -name ".pytest_cache" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./venv/*" -exec rm -rf {} + 2>/dev/null || true

echo "Cleaning ALL Python cache"
find . -type d -name "__pycache__" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./venv/*" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./venv/*" -delete 2>/dev/null || true
find . -name "*.pyo" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./venv/*" -delete 2>/dev/null || true

echo "Cleaning test databases"
find . -name "test.db" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./venv/*" -delete 2>/dev/null || true
find . -name "*.db-journal" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./venv/*" -delete 2>/dev/null || true

echo "Removing configuration backups"
if [[ -d "config_backups" ]]; then
    backup_count=$(find config_backups/ -type f 2>/dev/null | wc -l || echo "0")
    printf "Removing entire config_backups directory with %s files\n" "$backup_count"
    rm -rf config_backups/ 2>/dev/null || true
    echo "config_backups directory removed"
fi

echo "Cleaning Vale validation artifacts"
find . -name "vale-results.json" -not -path "./.venv/*" -not -path "./venv/*" -delete 2>/dev/null || true
find . -name "vale-*.json" -not -path "./.venv/*" -not -path "./venv/*" -delete 2>/dev/null || true
rm -f vale-results.json vale-*.json 2>/dev/null || true

echo "Cleaning tox artifacts"
rm -rf .tox/ 2>/dev/null || true

echo "Cleaning top-level coverage"
rm -rf htmlcov/ .coverage coverage.xml 2>/dev/null || true

echo "Purging test artifact files with foo references"
find . -type f \( -name "*.log" -o -name "*.yaml" -o -name "*.yml" -o -name "*.txt" -o -name "*.json" \) \
    -not -path "./.git/*" \
    -not -path "./.venv/*" \
    -not -path "./node_modules/*" \
    -not -path "./tests/*" \
    -not -path "./frontend/src/*" \
    -not -path "./bot/src/*" \
    -not -path "./docs/*" \
    -exec grep -l "ModuleNotFoundError.*foo\|import foo\|from foo" {} \; 2>/dev/null | while read -r file; do
        printf "Removing foo reference file: %s\n" "$file"
        rm -f "$file"
    done

remaining_pytest=$(find . -name "*pytest*" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./venv/*" -not -path "./node_modules/*" -not -path "./*/node_modules/*" -not -path "./tests/*" -not -path "./frontend/*" -not -path "./bot/*" -type f 2>/dev/null | wc -l)
remaining_coverage=$(find . \( -name "*coverage*" -o -name ".coverage*" \) -not -path "./.git/*" -not -path "./.venv/*" -not -path "./venv/*" -not -path "./node_modules/*" -not -path "./*/node_modules/*" -not -path "./tests/*" -not -path "./frontend/*" -not -path "./bot/*" -type f 2>/dev/null | wc -l)
remaining_cache=$(find . -name "__pycache__" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./venv/*" 2>/dev/null | wc -l)

echo "Enhanced cleanup summary"
printf -- "- %d pytest artifacts remaining (target: 0)\n" "$remaining_pytest"
printf -- "- %d coverage artifacts remaining (target: 0)\n" "$remaining_coverage"
printf -- "- %d cache directories remaining (target: 0)\n" "$remaining_cache"

if [[ -d "logs/" ]]; then
    remaining_logs=$(find logs/ -type f 2>/dev/null | wc -l)
    printf -- "- %d log files remaining\n" "$remaining_logs"
fi

if [[ "$remaining_pytest" -gt 0 ]]; then
    echo "DEBUG: Remaining pytest files"
    find . -name "*pytest*" -not -path "./.git/*" -not -path "./.venv/*" -not -path "./venv/*" -not -path "./node_modules/*" -not -path "./*/node_modules/*" -not -path "./tests/*" -not -path "./frontend/*" -not -path "./bot/*" -type f 2>/dev/null | head -5 | while read -r f; do
        printf -- "     %s\n" "$f"
    done || true
fi

if [[ "$remaining_coverage" -gt 0 ]]; then
    echo "DEBUG: Remaining coverage files"
    find . \( -name "*coverage*" -o -name ".coverage*" \) -not -path "./.git/*" -not -path "./.venv/*" -not -path "./venv/*" -not -path "./node_modules/*" -not -path "./*/node_modules/*" -not -path "./tests/*" -not -path "./frontend/*" -not -path "./bot/*" -type f 2>/dev/null | head -5 | while read -r f; do
        printf -- "     %s\n" "$f"
    done || true
fi

foo_refs=$(grep -r "ModuleNotFoundError.*foo\|import foo\|from foo" . \
    --exclude-dir=.git \
    --exclude-dir=.venv \
    --exclude-dir=venv \
    --exclude-dir=node_modules \
    --exclude-dir=tests \
    --exclude-dir=frontend/src \
    --exclude-dir=bot/src \
    --exclude-dir=docs \
    --exclude-dir=.codex \
    --exclude="*clean_pytest_artifacts.sh" \
    --exclude="README.md" 2>/dev/null | wc -l || echo "0")
foo_refs=$(echo "$foo_refs" | tr -d '\n')

printf -- "- %s 'foo' references remaining in non-test files (target: 0)\n" "$foo_refs"

if [[ "$foo_refs" -gt 0 ]]; then
    echo "WARNING: foo references still exist in non-test files"
    grep -r "ModuleNotFoundError.*foo\|import foo\|from foo" . \
        --exclude-dir=.git \
        --exclude-dir=.venv \
        --exclude-dir=venv \
        --exclude-dir=node_modules \
        --exclude-dir=tests \
        --exclude-dir=frontend/src \
        --exclude-dir=bot/src \
        --exclude-dir=docs \
        --exclude-dir=.codex \
        --exclude="*clean_pytest_artifacts.sh" \
        --exclude="README.md" 2>/dev/null | head -3 | while read -r f; do
            printf -- "     %s\n" "$f"
        done || true
    echo "These may be blocking pre-commit validation"
fi

if [[ "$remaining_pytest" -eq 0 && "$remaining_coverage" -eq 0 && "$foo_refs" -eq 0 ]]; then
    echo "Enhanced comprehensive cleanup complete - ALL artifacts eliminated"
    exit 0
else
    echo "Cleanup complete but some artifacts remain - check counts above"
    exit 0
fi
