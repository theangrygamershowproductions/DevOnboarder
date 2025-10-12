#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# DevOnboarder Branch Workflow Enforcer
# PREVENTS the recurring main branch work violation
#
# Usage: source this script before ANY development work
# Or: ./scripts/enforce_branch_workflow.sh

set -euo pipefail

# Check for pre-commit flag
PRE_COMMIT_MODE=false
if [[ "${1:-}" == "--pre-commit" ]]; then
    PRE_COMMIT_MODE=true
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

enforce_branch_workflow() {
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")

    if [[ "$PRE_COMMIT_MODE" == "true" ]]; then
        # Silent check for pre-commit hooks - just exit with error code
        if [[ "$current_branch" == "main" ]]; then
            error "Cannot commit to main branch. Create a feature branch first."
            exit 1
        fi
        return 0
    fi

    echo
    echo "🔍 DevOnboarder Branch Workflow Check"
    echo "====================================="

    if [[ "$current_branch" == "main" ]]; then
        echo
        echo -e "${RED}🚨 CRITICAL WORKFLOW VIOLATION!"
        error_msg " You are on the 'main' branch"
        success_msg " DevOnboarder requires feature branch workflow"
        echo
        check "This prevents the recurring issue of working directly on main"
        echo
        tool "Required actions:"
        echo "   [1] Create feature branch for your work"
        echo "   [2] Exit and follow proper workflow manually"
        echo
        read -r -p "Create feature branch now? [y/N]: " create_branch

        if [[ "$create_branch" =~ ^[Yy]$ ]]; then
            echo
            note "Feature branch naming conventions:"
            echo "   feat/feature-description    - New features"
            echo "   fix/bug-description         - Bug fixes"
            echo "   docs/update-description     - Documentation"
            echo "   refactor/component-name     - Code refactoring"
            echo "   test/test-description       - Test improvements"
            echo "   chore/maintenance-task      - Maintenance"
            echo
            read -r -p "Enter branch name (with prefix): " branch_name

            if [[ -n "$branch_name" ]]; then
                if git checkout -b "$branch_name" 2>/dev/null; then
                    echo
                    success_msg " SUCCESS: Created and switched to branch: $branch_name"
                    success_msg " Workflow compliance achieved"
                    echo
                    check "Next steps:"
                    echo "   • Make your changes"
                    echo "   • Use ./scripts/safe_commit.sh for commits"
                    echo "   • Create PR when ready"
                    echo "   • Delete feature branch after merge"
                    return 0
                else
                    echo
                    error_msg " Failed to create branch '$branch_name'"
                    echo "   Check if branch already exists or name is invalid"
                    return 1
                fi
            else
                echo
                error_msg " No branch name provided"
                echo "   Cannot proceed without proper branch"
                return 1
            fi
        else
            echo
            debug_msg "  Workflow violation not resolved"
            echo "   Please create feature branch manually:"
            echo "   git checkout -b feat/your-feature-name"
            return 1
        fi
    else
        echo
        success_msg " Workflow compliance: Working on '$current_branch'"
        echo "   You're following proper DevOnboarder branch workflow"
        return 0
    fi
}

# If script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    enforce_branch_workflow
fi
