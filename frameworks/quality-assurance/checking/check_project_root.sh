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
    exit 1
fi

if [ ! -d "$PROJECT_ROOT" ]; then
    exit 1
fi

if [ ! -f "$PROJECT_ROOT/.github/copilot-instructions.md" ]; then
    exit 1
fi

if [ ! -f "$PROJECT_ROOT/pyproject.toml" ]; then
    exit 1
fi

if [ ! -d "$PROJECT_ROOT/logs" ]; then
    mkdir -p "$PROJECT_ROOT/logs"
fi
