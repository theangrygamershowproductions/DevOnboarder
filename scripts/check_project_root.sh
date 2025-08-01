#!/usr/bin/env bash
# =============================================================================
# File: scripts/check_project_root.sh
# Purpose: Validate PROJECT_ROOT environment variable and DevOnboarder compliance
# Author: DevOnboarder Project
# Standards: Compliant with copilot-instructions.md
# =============================================================================

set -euo pipefail

# Check if PROJECT_ROOT is set and valid
if [ -z "${PROJECT_ROOT:-}" ]; then
    echo "ERROR: PROJECT_ROOT environment variable not set"
    echo "Run: source scripts/set_project_root.sh"
    exit 1
fi

if [ ! -d "$PROJECT_ROOT" ]; then
    echo "ERROR: PROJECT_ROOT directory does not exist: $PROJECT_ROOT"
    exit 1
fi

if [ ! -f "$PROJECT_ROOT/.github/copilot-instructions.md" ]; then
    echo "ERROR: PROJECT_ROOT appears invalid. Missing core DevOnboarder files."
    echo "PROJECT_ROOT: $PROJECT_ROOT"
    echo "Expected: DevOnboarder repository root with .github/copilot-instructions.md"
    exit 1
fi

if [ ! -f "$PROJECT_ROOT/pyproject.toml" ]; then
    echo "ERROR: PROJECT_ROOT missing pyproject.toml file"
    echo "PROJECT_ROOT: $PROJECT_ROOT"
    exit 1
fi

if [ ! -d "$PROJECT_ROOT/logs" ]; then
    echo "WARNING: PROJECT_ROOT missing logs/ directory. Creating it now."
    mkdir -p "$PROJECT_ROOT/logs"
fi

echo "PROJECT_ROOT validation: SUCCESS"
echo "Location: $PROJECT_ROOT"
