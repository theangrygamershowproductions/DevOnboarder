#!/bin/bash

# scripts/validate_documentation_accuracy.sh
# Validates that documentation accurately reflects GitHub reality
# Part of comprehensive documentation integrity system - Issue #1341

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly README_FILE="$PROJECT_ROOT/README.md"

# Error tracking
VALIDATION_ERRORS=0

print_header() {
    echo "Documentation Accuracy Validation"
    echo "=================================="
    echo "Checking README.md against GitHub reality..."
    echo ""
}

validate_milestone_status() {
    local milestone_number="$1"
    local expected_status="$2"
    local description="$3"

    echo "Validating Milestone #$milestone_number ($description)..."

    # Get actual milestone status from GitHub
    if command -v gh >/dev/null 2>&1; then
        local actual_status
        actual_status=$(gh api "repos/theangrygamershowproductions/DevOnboarder/milestones/$milestone_number" --jq '.state' 2>/dev/null || echo "not_found")

        if [[ "$actual_status" == "not_found" ]]; then
            echo -e "  ${RED}✗${NC} Milestone #$milestone_number not found in GitHub"
            ((VALIDATION_ERRORS++))
            return
        fi

        # Convert status to README format
        local readme_status
        case "$actual_status" in
            "open") readme_status="Active" ;;
            "closed") readme_status="Complete" ;;
            *) readme_status="Unknown" ;;
        esac

        if [[ "$readme_status" == "$expected_status" ]]; then
            echo -e "  ${GREEN}✓${NC} Status matches: $expected_status"
        else
            echo -e "  ${RED}✗${NC} Status mismatch: README shows '$expected_status', GitHub shows '$readme_status'"
            echo "      Milestone #$milestone_number should be updated in README.md"
            ((VALIDATION_ERRORS++))
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} GitHub CLI not available, skipping milestone validation"
    fi
}

validate_project_links() {
    local project_number="$1"
    local readme_name="$2"

    echo "Validating Project #$project_number link..."

    if command -v gh >/dev/null 2>&1; then
        local actual_name
        actual_name=$(gh api "orgs/theangrygamershowproductions/projects/$project_number" --jq '.title' 2>/dev/null || echo "not_found")

        if [[ "$actual_name" == "not_found" ]]; then
            echo -e "  ${RED}✗${NC} Project #$project_number not found in GitHub"
            ((VALIDATION_ERRORS++))
            return
        fi

        # Check if README name matches or is acceptable variant
        if [[ "$actual_name" == "$readme_name" ]] || [[ "$readme_name" == *"$actual_name"* ]] || [[ "$actual_name" == *"$readme_name"* ]]; then
            echo -e "  ${GREEN}✓${NC} Project name acceptable: '$readme_name' (GitHub: '$actual_name')"
        else
            echo -e "  ${YELLOW}⚠${NC} Project name differs: README '$readme_name', GitHub '$actual_name'"
            echo "      Consider updating for consistency"
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} GitHub CLI not available, skipping project validation"
    fi
}

check_readme_phase_statuses() {
    echo "Checking Phase statuses in README.md..."

    # Extract phase information from README
    local phase1_line
    if [[ -f "$README_FILE" ]]; then
        phase1_line=$(grep -n "Phase 1.*|.*|.*|" "$README_FILE" | head -1 || echo "")
        # Note: Phase 2 and 3 checks reserved for future enhancement

        if [[ -n "$phase1_line" ]]; then
            if echo "$phase1_line" | grep -q "Complete"; then
                echo -e "  ${GREEN}✓${NC} Phase 1 shows Complete status"
                validate_milestone_status "1" "Complete" "Foundation Stabilization"
            elif echo "$phase1_line" | grep -q "Active"; then
                echo -e "  ${RED}✗${NC} Phase 1 shows Active status"
                validate_milestone_status "1" "Active" "Foundation Stabilization"
            else
                echo -e "  ${YELLOW}⚠${NC} Phase 1 status unclear in README"
            fi
        else
            echo -e "  ${YELLOW}⚠${NC} Phase 1 not found in README.md"
        fi

    else
        echo -e "  ${RED}✗${NC} README.md not found at $README_FILE"
        ((VALIDATION_ERRORS++))
    fi
}

check_project_links() {
    echo ""
    echo "Checking project links in README.md..."

    # Validate the three main project links
    validate_project_links "4" "Team Planning"
    validate_project_links "5" "Feature Release"
    validate_project_links "6" "Roadmap"
}

generate_summary() {
    echo ""
    echo "Validation Summary"
    echo "=================="

    if [[ $VALIDATION_ERRORS -eq 0 ]]; then
        echo -e "${GREEN}✓ All documentation accuracy checks passed!${NC}"
        echo "README.md accurately reflects GitHub project status."
        return 0
    else
        echo -e "${RED}✗ Found $VALIDATION_ERRORS documentation accuracy issue(s)${NC}"
        echo ""
        echo "Recommended actions:"
        echo "1. Review the issues listed above"
        echo "2. Update README.md to match GitHub reality"
        echo "3. Consider automating status updates"
        echo "4. Run this script regularly to prevent drift"
        echo ""
        echo "Related Issues:"
        echo "- Issue #1341: Comprehensive documentation integrity review"
        echo "- Issue #1261: Milestone documentation standardization"
        return 1
    fi
}

main() {
    print_header
    check_readme_phase_statuses
    check_project_links
    generate_summary
}

# Execute main function
main "$@"
