#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# DevOnboarder Automatic Branch Management System
# Automatically creates and switches to appropriate branches based on work type

set -euo pipefail

# DevOnboarder centralized logging pattern
LOG_DIR="$(dirname "$0")/../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/branch_management_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Virtual environment activation pattern
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "DevOnboarder Automatic Branch Management System"
echo "Project Root: $PROJECT_ROOT"

# Check for virtual environment
if [[ ! -d "$PROJECT_ROOT/.venv" ]]; then
    error "Virtual environment not found at $PROJECT_ROOT/.venv"
    echo "Run: python -m venv .venv && source .venv/bin/activate && pip install -e .[test]"
    exit 1
fi

# Branch naming conventions based on DevOnboarder patterns
declare -A BRANCH_TYPES=(
    ["feat"]="New features and enhancements"
    ["fix"]="Bug fixes and corrections"
    ["docs"]="Documentation updates and improvements"
    ["refactor"]="Code refactoring without functionality changes"
    ["test"]="Test improvements and additions"
    ["chore"]="Maintenance tasks and tooling"
    ["ci"]="CI/CD and automation improvements"
    ["security"]="Security fixes and improvements"
    ["perf"]="Performance optimizations"
    ["style"]="Code style and formatting changes"
)

# Common work patterns and their suggested branch types
declare -A WORK_PATTERNS=(
    ["dashboard"]="feat"
    ["integration"]="feat"
    ["monitoring"]="feat"
    ["api"]="feat"
    ["authentication"]="feat"
    ["database"]="feat"
    ["frontend"]="feat"
    ["backend"]="feat"
    ["cli"]="feat"
    ["automation"]="feat"
    ["aar"]="feat"
    ["readme"]="docs"
    ["guide"]="docs"
    ["documentation"]="docs"
    ["markdown"]="docs"
    ["linting"]="docs"
    ["formatting"]="docs"
    ["bug"]="fix"
    ["error"]="fix"
    ["issue"]="fix"
    ["problem"]="fix"
    ["failure"]="fix"
    ["broken"]="fix"
    ["workflow"]="ci"
    ["github-actions"]="ci"
    ["pipeline"]="ci"
    ["build"]="ci"
    ["deploy"]="ci"
    ["test-suite"]="test"
    ["testing"]="test"
    ["coverage"]="test"
    ["validation"]="test"
    ["security-fix"]="security"
    ["vulnerability"]="security"
    ["permissions"]="security"
    ["token"]="security"
    ["optimization"]="perf"
    ["performance"]="perf"
    ["speed"]="perf"
    ["memory"]="perf"
    ["cleanup"]="chore"
    ["maintenance"]="chore"
    ["update"]="chore"
    ["upgrade"]="chore"
)

# Function to detect work type from current changes
detect_work_type() {
    local work_description="$1"
    local detected_type=""
    local confidence=0

    # Convert to lowercase for pattern matching
    local description_lower
    description_lower=$(echo "$work_description" | tr '[:upper:]' '[:lower:]')

    # Check against work patterns
    for pattern in "${!WORK_PATTERNS[@]}"; do
        if [[ "$description_lower" == *"$pattern"* ]]; then
            local pattern_type="${WORK_PATTERNS[$pattern]}"
            echo "Pattern matched: '$pattern' suggests type '$pattern_type'"

            # Increase confidence for exact matches
            if [[ "$description_lower" == "$pattern" ]]; then
                confidence=$((confidence + 10))
            else
                confidence=$((confidence + 5))
            fi

            if [[ -z "$detected_type" ]] || [[ "$confidence" -gt 5 ]]; then
                detected_type="$pattern_type"
            fi
        fi
    done

    # Analyze file changes for additional context
    if git status --porcelain >/dev/null 2>&1; then
        local changed_files
        changed_files=$(git status --porcelain | awk '{print $2}' | tr '\n' ' ')
        echo "Analyzing changed files: $changed_files"

        # Documentation files
        if [[ "$changed_files" == *"docs/"* ]] || [[ "$changed_files" == *".md"* ]]; then
            if [[ -z "$detected_type" ]] || [[ "$detected_type" == "chore" ]]; then
                detected_type="docs"
                echo "Documentation files detected, suggesting: docs"
            fi
        fi

        # CI/CD files
        if [[ "$changed_files" == *".github/"* ]] || [[ "$changed_files" == *"Makefile"* ]]; then
            if [[ -z "$detected_type" ]] || [[ "$detected_type" == "chore" ]]; then
                detected_type="ci"
                echo "CI/CD files detected, suggesting: ci"
            fi
        fi

        # Scripts and features
        if [[ "$changed_files" == *"scripts/"* ]] && [[ "$changed_files" == *".py"* ]]; then
            if [[ -z "$detected_type" ]]; then
                detected_type="feat"
                echo "New scripts detected, suggesting: feat"
            fi
        fi

        # Test files
        if [[ "$changed_files" == *"test"* ]] || [[ "$changed_files" == *"spec"* ]]; then
            if [[ -z "$detected_type" ]]; then
                detected_type="test"
                echo "Test files detected, suggesting: test"
            fi
        fi
    fi

    # Default to feat if nothing else detected
    if [[ -z "$detected_type" ]]; then
        detected_type="feat"
        echo "No specific pattern detected, defaulting to: feat"
    fi

    echo "$detected_type"
}

# Function to suggest branch name
suggest_branch_name() {
    local work_type="$1"
    local work_description="$2"

    # Clean up description for branch name
    local clean_description
    clean_description=$(echo "$work_description" | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9 -]//g' | \
        sed 's/  */ /g' | \
        sed 's/^ *//g' | \
        sed 's/ *$//g' | \
        tr ' ' '-' | \
        sed 's/--*/-/g')

    # Truncate if too long
    if [[ ${#clean_description} -gt 40 ]]; then
        clean_description="${clean_description:0:40}"
        # Ensure we don't cut off in the middle of a word
        clean_description="${clean_description%-[^-]*}"
    fi

    echo "${work_type}/${clean_description}"
}

# Function to create and switch to branch
create_and_switch_branch() {
    local branch_name="$1"
    local from_branch="${2:-main}"

    echo "Creating and switching to branch: $branch_name"
    echo "Base branch: $from_branch"

    # Ensure we're on the base branch and up to date
    git checkout "$from_branch"
    git pull origin "$from_branch"

    # Create and switch to new branch
    git checkout -b "$branch_name"

    echo "Successfully created and switched to branch: $branch_name"
    echo "Branch tracking: git branch --set-upstream-to=origin/$from_branch $branch_name"

    # Set up tracking (optional, for pushing later)
    git branch --set-upstream-to=origin/"$from_branch" "$branch_name" 2>/dev/null || true
}

# Function to show current status and suggestions
show_status_and_suggestions() {
    echo ""
    echo "Current Git Status:"
    echo "==================="
    git status --short

    echo ""
    echo "Current Branch: $(git branch --show-current)"
    echo "Available Branch Types:"
    for type in "${!BRANCH_TYPES[@]}"; do
        echo "  $type: ${BRANCH_TYPES[$type]}"
    done
}

# Main function
main() {
    local work_description=""
    local suggested_type=""
    local branch_name=""
    local auto_mode=false
    local force_type=""

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --description|-d)
                work_description="$2"
                shift 2
                ;;
            --type|-t)
                force_type="$2"
                shift 2
                ;;
            --auto|-a)
                auto_mode=true
                shift
                ;;
            --help|-h)
                echo "DevOnboarder Automatic Branch Management System"
                echo ""
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  -d, --description TEXT    Work description for branch naming"
                echo "  -t, --type TYPE          Force specific branch type"
                echo "  -a, --auto               Auto-detect and create branch"
                echo "  -h, --help               Show this help message"
                echo ""
                echo "Available Types:"
                for type in "${!BRANCH_TYPES[@]}"; do
                    echo "  $type: ${BRANCH_TYPES[$type]}"
                done
                echo ""
                echo "Examples:"
                echo "  $0 -d \"ci dashboard integration\" -a"
                echo "  $0 -t feat -d \"user authentication\""
                echo "  $0 --auto  # Auto-detect from current changes"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    # Show current status
    show_status_and_suggestions

    # Auto-detect if no description provided
    if [[ -z "$work_description" ]] && [[ "$auto_mode" == true ]]; then
        # Try to detect from current changes
        if git status --porcelain | grep -q .; then
            work_description="auto-detected-work"
            echo ""
            echo "Auto-detecting work type from current changes..."
        else
            echo ""
            echo "No changes detected for auto-detection"
            echo "Please provide a work description with -d"
            exit 1
        fi
    fi

    # Interactive mode if no description
    if [[ -z "$work_description" ]]; then
        echo ""
        read -r -p "Enter work description: " work_description
        if [[ -z "$work_description" ]]; then
            echo "Work description is required"
            exit 1
        fi
    fi

    # Detect or use forced type
    if [[ -n "$force_type" ]]; then
        if [[ -z "${BRANCH_TYPES[$force_type]:-}" ]]; then
            echo "Invalid branch type: $force_type"
            echo "Available types: ${!BRANCH_TYPES[*]}"
            exit 1
        fi
        suggested_type="$force_type"
        echo "Using forced type: $suggested_type"
    else
        suggested_type=$(detect_work_type "$work_description")
        echo "Detected work type: $suggested_type"
    fi

    # Generate branch name
    branch_name=$(suggest_branch_name "$suggested_type" "$work_description")
    echo "Suggested branch name: $branch_name"

    # Confirm or modify in interactive mode
    if [[ "$auto_mode" != true ]]; then
        echo ""
        read -r -p "Create branch '$branch_name'? [Y/n/edit]: " response
        case $response in
            [nN]|[nN][oO])
                echo "Branch creation cancelled"
                exit 0
                ;;
            [eE]|[eE][dD][iI][tT])
                read -r -p "Enter custom branch name: " custom_branch
                if [[ -n "$custom_branch" ]]; then
                    branch_name="$custom_branch"
                fi
                ;;
            *)
                # Default to yes
                ;;
        esac
    fi

    # Check if branch already exists
    if git branch --list | grep -q "$branch_name"; then
        echo "Branch '$branch_name' already exists"
        read -r -p "Switch to existing branch? [Y/n]: " switch_response
        if [[ "$switch_response" =~ ^[nN] ]]; then
            echo "Operation cancelled"
            exit 0
        fi
        git checkout "$branch_name"
        echo "Switched to existing branch: $branch_name"
    else
        # Create new branch
        create_and_switch_branch "$branch_name"
    fi

    echo ""
    echo "Ready for development on branch: $branch_name"
    echo "Type: $suggested_type (${BRANCH_TYPES[$suggested_type]})"
    echo ""
    echo "Next steps:"
    echo "1. Make your changes"
    echo "2. Commit with: scripts/safe_commit.sh \"TYPE(scope): description\""
    echo "3. Push with: git push origin $branch_name"
}

# Run main function with all arguments
main "$@"
