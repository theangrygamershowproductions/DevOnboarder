#!/bin/bash
set -euo pipefail

echo "📊 DevOnboarder Log Analysis Report"
echo "=================================="

if [[ ! -d "logs/" ]]; then
    echo "❌ No logs directory found"
    exit 0
fi

# Clean artifacts first for accurate analysis
echo "🧹 Cleaning test artifacts for accurate analysis..."
if [[ -f "scripts/clean_pytest_artifacts.sh" ]]; then
    bash scripts/clean_pytest_artifacts.sh
fi

echo
echo "📁 Current Log Directory Contents:"
echo "----------------------------------"

# Count files by type
total_files=$(find logs/ -type f 2>/dev/null | wc -l)
total_size=$(du -sh logs/ 2>/dev/null | cut -f1)

echo "Total files: $total_files"
echo "Total size: $total_size"
echo

# Categorize logs
echo "📋 Log Categories:"
echo "  Test runs: $(find logs/ -name "test_run_*.log" 2>/dev/null | wc -l)"
echo "  Coverage data: $(find logs/ -name "coverage_data_*" 2>/dev/null | wc -l)"
echo "  Validation logs: $(find logs/ -name "*_validation_*.log" 2>/dev/null | wc -l)"
echo "  ESLint logs: $(find logs/ -name "*_eslint_*.log" 2>/dev/null | wc -l)"
echo "  Other logs: $(find logs/ -type f ! -name "test_run_*.log" ! -name "coverage_data_*" ! -name "*_validation_*.log" ! -name "*_eslint_*.log" 2>/dev/null | wc -l)"

echo
echo "🕒 Recent Activity (last 5 files):"
echo "-----------------------------------"
if [[ $total_files -gt 0 ]]; then
    find logs/ -type f -printf "%T@ %p\n" 2>/dev/null | sort -n | tail -5 | while read -r timestamp file; do
        date -d "@${timestamp}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null | tr -d '\n'
        echo " - $(basename "$file")"
    done
else
    echo "No log files found"
fi

echo
echo "🔍 Analysis complete. Use 'bash scripts/manage_logs.sh list' for detailed view."
