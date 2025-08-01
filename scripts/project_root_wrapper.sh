#!/usr/bin/env bash
# =============================================================================
# File: scripts/project_root_wrapper.sh
# Purpose: Universal wrapper that ensures PROJECT_ROOT before executing commands
# Author: DevOnboarder Project
# Standards: Compliant with copilot-instructions.md and centralized logging policy
# =============================================================================

set -euo pipefail

# Establish PROJECT_ROOT if not already set
if [ -z "${PROJECT_ROOT:-}" ]; then
    source "$(dirname "$0")/set_project_root.sh"
fi

# Validate PROJECT_ROOT
source "$(dirname "$0")/check_project_root.sh"

# Change to PROJECT_ROOT for reliable execution
cd "$PROJECT_ROOT"

# Execute the provided command with all arguments
exec "$@"
