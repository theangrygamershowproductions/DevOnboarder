#!/usr/bin/env bash
#
# DevOnboarder PR Creation Script
#
# Automates pull request creation with proper templates and error handling
#
# Usage:
#     ./scripts/create_pr.sh [--template <type>] [--title <title>] [--draft]
#
# Options:
#     --template <type>  Use predefined template (feature|bugfix|docs|chore)
#     --title <title>    Override default title from branch name
#     --draft           Create as draft PR
#     --help            Show this help message
#
# Templates are stored in templates/pr/ directory
#

set -euo pipefail

# Script configuration
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
TEMPLATES_DIR="$PROJECT_ROOT/templates/pr"
LOG_DIR="$PROJECT_ROOT/logs"

# Initialize variables
TEMPLATE_TYPE=""
TITLE_OVERRIDE=""
DRAFT_MODE=false
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --template)
            TEMPLATE_TYPE="$2"
            shift 2
            ;;
        --title)
            TITLE_OVERRIDE="$2"
            shift 2
            ;;
        --draft)
            DRAFT_MODE=true
            shift
            ;;
        -h|--help)
            echo "DevOnboarder PR Creation Script"
            echo ""
            echo "Usage: $0 [--template <type>] [--title <title>] [--draft]"
            echo ""
            echo "Options:"
            echo "  --template <type>  Use predefined template (feature|bugfix|docs|chore)"
            echo "  --title <title>    Override default title from branch name"
            echo "  --draft           Create as draft PR"
            echo "  -h, --help        Show this help message"
            echo ""
            echo "Available templates:"
            if [[ -d "$TEMPLATES_DIR" ]]; then
                find "$TEMPLATES_DIR" -name "*.md" -exec basename {} .md \; | sort
            else
                echo "  (No templates directory found - will be created)"
            fi
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Ensure logs directory exists
mkdir -p "$LOG_DIR"
mkdir -p "$TEMPLATES_DIR"

echo "DevOnboarder PR Creation Tool"
echo "============================="
echo "Branch: $BRANCH_NAME"

# Detect template type from branch name if not specified
if [[ -z "$TEMPLATE_TYPE" ]]; then
    if [[ $BRANCH_NAME == feat/* ]]; then
        TEMPLATE_TYPE="feature"
    elif [[ $BRANCH_NAME == fix/* ]]; then
        TEMPLATE_TYPE="bugfix"
    elif [[ $BRANCH_NAME == docs/* ]]; then
        TEMPLATE_TYPE="docs"
    elif [[ $BRANCH_NAME == chore/* ]]; then
        TEMPLATE_TYPE="chore"
    else
        TEMPLATE_TYPE="feature"  # Default
    fi
    echo "Detected template type: $TEMPLATE_TYPE"
fi

# Generate default title from branch name if not overridden
if [[ -z "$TITLE_OVERRIDE" ]]; then
    # Convert branch name to title format
    # feat/documentation-qc-system -> FEAT(docs): documentation QC system
    if [[ $BRANCH_NAME =~ ^([^/]+)/(.+)$ ]]; then
        PREFIX=$(echo "${BASH_REMATCH[1]}" | tr '[:lower:]' '[:upper:]')
        SUFFIX=${BASH_REMATCH[2]//-/ }

        # Detect scope from content
        SCOPE=""
        if [[ $TEMPLATE_TYPE == "docs" ]] || [[ $SUFFIX =~ (doc|markdown|readme) ]]; then
            SCOPE="(docs)"
        elif [[ $SUFFIX =~ (script|automation|tool) ]]; then
            SCOPE="(scripts)"
        elif [[ $SUFFIX =~ (ci|workflow|github) ]]; then
            SCOPE="(ci)"
        elif [[ $SUFFIX =~ (test|spec) ]]; then
            SCOPE="(test)"
        fi

        DEFAULT_TITLE="${PREFIX}${SCOPE}: ${SUFFIX}"
    else
        DEFAULT_TITLE="$BRANCH_NAME"
    fi
else
    DEFAULT_TITLE="$TITLE_OVERRIDE"
fi

echo "Title: $DEFAULT_TITLE"

# Check for template file
TEMPLATE_FILE="$TEMPLATES_DIR/${TEMPLATE_TYPE}.md"
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Creating default $TEMPLATE_TYPE template..."
    case $TEMPLATE_TYPE in
        "feature")
            cat > "$TEMPLATE_FILE" << 'EOF'
## Summary

Brief description of the new feature and its purpose.

## Changes Made

### New Features
- Feature 1: Description
- Feature 2: Description

### Files Modified
- `file1.py`: Purpose of changes
- `file2.sh`: Purpose of changes

## Key Benefits

- **Benefit 1**: Description
- **Benefit 2**: Description
- **Benefit 3**: Description

## Testing

- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Usage Examples

```bash
# Example usage
./scripts/new_feature.sh --option value
```

## Integration Notes

- Compatible with existing DevOnboarder workflows
- Follows project quality standards
- Uses established logging patterns

---

This enhancement supports DevOnboarder's "quiet reliability" philosophy.
EOF
            ;;
        "docs")
            cat > "$TEMPLATE_FILE" << 'EOF'
## Summary

Documentation updates or new documentation added.

## Changes Made

### Documentation Updates
- **File 1**: Purpose and content summary
- **File 2**: Purpose and content summary

### Structure Changes
- New sections added
- Reorganized content
- Updated cross-references

## Key Improvements

- **Clarity**: Enhanced explanation of concepts
- **Completeness**: Added missing information
- **Accessibility**: Improved readability and navigation
- **Standards**: Aligned with DevOnboarder documentation guidelines

## Validation

- [ ] Markdownlint compliance verified
- [ ] Vale documentation linting passed
- [ ] Cross-references validated
- [ ] Code examples tested

## Integration

- Updates maintain consistency with existing documentation
- Follows DevOnboarder markdown standards
- Integrates with existing navigation structure

---

This documentation enhancement improves developer experience and knowledge transfer.
EOF
            ;;
        "bugfix")
            cat > "$TEMPLATE_FILE" << 'EOF'
## Summary

Brief description of the bug and the fix applied.

## Problem Description

- **Issue**: What was broken or not working correctly
- **Impact**: How it affected users or the system
- **Root Cause**: What caused the problem

## Solution

### Changes Made
- `file1.py`: Specific fix applied
- `file2.sh`: Additional changes needed

### Testing
- [ ] Bug reproduction confirmed
- [ ] Fix validated
- [ ] Regression testing completed
- [ ] Edge cases tested

## Validation

- **Before**: Behavior/error observed
- **After**: Expected behavior achieved
- **Tests**: Specific test cases that now pass

---

This fix maintains DevOnboarder's reliability and prevents future issues.
EOF
            ;;
        "chore")
            cat > "$TEMPLATE_FILE" << 'EOF'
## Summary

Maintenance, cleanup, or infrastructure improvements.

## Changes Made

### Maintenance Tasks
- Task 1: Description
- Task 2: Description

### Infrastructure Updates
- Update 1: Purpose
- Update 2: Purpose

## Benefits

- **Maintainability**: Improved code organization
- **Performance**: System optimizations
- **Security**: Updated dependencies or security improvements
- **Developer Experience**: Tooling or workflow improvements

## Validation

- [ ] All existing functionality preserved
- [ ] No breaking changes introduced
- [ ] Tests continue to pass
- [ ] Quality gates maintained

---

This maintenance work supports DevOnboarder's long-term stability.
EOF
            ;;
    esac
    echo "Template created: $TEMPLATE_FILE"
fi

# Template is ready - GitHub CLI will read it directly from file

# Build GitHub CLI command
GH_CMD="gh pr create"
GH_CMD="$GH_CMD --title \"$DEFAULT_TITLE\""
GH_CMD="$GH_CMD --body-file \"$TEMPLATE_FILE\""

# Add labels based on template type
case $TEMPLATE_TYPE in
    "feature")
        GH_CMD="$GH_CMD --label enhancement --label feature"
        ;;
    "docs")
        GH_CMD="$GH_CMD --label documentation"
        ;;
    "bugfix")
        GH_CMD="$GH_CMD --label bug --label bugfix"
        ;;
    "chore")
        GH_CMD="$GH_CMD --label maintenance --label chore"
        ;;
esac

# Add draft flag if requested
if [[ "$DRAFT_MODE" = true ]]; then
    GH_CMD="$GH_CMD --draft"
fi

echo ""
echo "Creating PR with template: $TEMPLATE_TYPE"
echo "Template file: $TEMPLATE_FILE"

# Execute the command
echo ""
echo "Executing: $GH_CMD"
if eval "$GH_CMD"; then
    echo ""
    echo "SUCCESS: Pull request created successfully"
    echo "You can edit the PR description on GitHub if needed"
else
    echo ""
    echo "ERROR: Failed to create pull request"
    echo "Check the error messages above for details"
    exit 1
fi
