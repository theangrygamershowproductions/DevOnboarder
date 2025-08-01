#!/usr/bin/env bash
# =============================================================================
# File: scripts/set_project_root.sh
# Purpose: Establish and validate PROJECT_ROOT environment variable
# Author: DevOnboarder Project
# Standards: Compliant with copilot-instructions.md
# =============================================================================

set -euo pipefail

# Automatically set and export PROJECT_ROOT
export PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$PROJECT_ROOT"

# Verify we're in a valid DevOnboarder repository
if [ ! -f "$PROJECT_ROOT/.github/copilot-instructions.md" ]; then
    exit 1
fi

if [ ! -f "$PROJECT_ROOT/pyproject.toml" ]; then
    exit 1
fi
