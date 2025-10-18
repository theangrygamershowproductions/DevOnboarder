#!/usr/bin/env bash
# Root Cache Pollution Validator for DevOnboarder
# Ensures centralized cache management compliance
set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$PROJECT_ROOT"

# Terminal output compliance - no emojis or special characters
echo "Validating centralized cache management compliance"
echo "Target: No cache pollution in repository root"
echo "Expected: All cache directories in logs/"

# Check for root cache pollution
POLLUTION_FOUND=false

# Check for pytest cache pollution
if [ -d ".pytest_cache" ]; then
    echo "VIOLATION: .pytest_cache found in repository root"
    POLLUTION_FOUND=true
fi

# Check for mypy cache pollution
if [ -d ".mypy_cache" ]; then
    echo "VIOLATION: .mypy_cache found in repository root"
    POLLUTION_FOUND=true
fi

# Check for ruff cache pollution
if [ -d ".ruff_cache" ]; then
    echo "VIOLATION: .ruff_cache found in repository root"
    POLLUTION_FOUND=true
fi

# Check for coverage cache pollution
if [ -d ".coverage" ]; then
    echo "VIOLATION: .coverage found in repository root"
    POLLUTION_FOUND=true
fi

# Verify centralized cache directories exist
if [ ! -d "logs/.pytest_cache" ] && [ ! -d "logs/.mypy_cache" ]; then
    echo " No cache directories in logs/ yet (will be created on first run)"
fi

if [ "$POLLUTION_FOUND" = true ]; then
    echo "FAILED: Cache pollution detected in repository root"
    echo "Solution: Run cache cleanup with: bash scripts/manage_logs.sh cache clean"
    exit 1
else
    echo " No cache pollution found in repository root"
    echo "Centralized cache management compliance verified"
    exit 0
fi
