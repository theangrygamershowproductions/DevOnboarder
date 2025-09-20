#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# DevOnboarder Vale Documentation Linting Wrapper
# =============================================================================
# Purpose: Convenient wrapper for running Vale in virtual environment
# Usage: ./scripts/run_vale.sh [vale arguments]
# Dependencies: vale (Python package), virtual environment
# Output: Vale validation results
# =============================================================================

# Ensure we're running from repository root
if [[ ! -f "pyproject.toml" ]]; then
    echo "Error: Must run from repository root (where pyproject.toml exists)"
    exit 1
fi

# Activate virtual environment
if [[ ! -d ".venv" ]]; then
    echo "Error: Virtual environment not found. Run: python -m venv .venv && source .venv/bin/activate && pip install -e .[test]"
    exit 1
fi

source .venv/bin/activate

# Ensure logs directory exists
mkdir -p logs

# Run Vale with Python wrapper (correct syntax for DevOnboarder)
echo "Running Vale documentation linting..."
python -c "import vale.main; vale.main.main()" "$@"
