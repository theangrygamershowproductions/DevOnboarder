#!/bin/bash

# Issue Closure Template Generator
# Generates populated issue closure comments using template files
# Compliant with DevOnboarder terminal output policy

set -euo pipefail

# Script logging
SCRIPT_NAME="$(basename "$0" .sh)"
LOG_FILE="logs/${SCRIPT_NAME}_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting issue closure template generation"

# Configuration
TEMPLATE_DIR="templates/issue-closure"
OUTPUT_DIR="logs/issue-closure-comments"

# Function to show usage
show_usage() {
    echo "Usage: $0 <template-type> <issue-number> [options]"
    echo ""
    echo "Template Types:"
    echo "  pr-completion    - For issues resolved by PR merge"
    echo "  bug-fix         - For bug resolution"
    echo "  ci-failure-fix  - For CI/build failure fixes"
    echo "  feature-completion - For feature implementation"
    echo ""
    echo "Options:"
    echo "  --pr-number NUM        PR number (for pr-completion)"
    echo "  --pr-title TITLE       PR title (for pr-completion)"
    echo "  --branch NAME          Branch name"
    echo "  --impact TEXT          Impact description"
    echo "  --next-steps TEXT      Next steps description"
    echo "  --root-cause TEXT      Root cause analysis"
    echo "  --fix-description TEXT Fix description"
    echo "  --resolver NAME        Person resolving the issue"
    echo ""
    echo "Example:"
    echo "  $0 pr-completion 1437 --pr-number 1449 --pr-title 'Fix template system' --resolver 'Development Team'"
}

# Parse arguments
if [[ $# -lt 2 ]]; then
    show_usage
    exit 1
fi

TEMPLATE_TYPE="$1"
ISSUE_NUMBER="$2"
shift 2

# Default values
PR_NUMBER=""
PR_TITLE=""
BRANCH_NAME=""
IMPACT_DESCRIPTION=""
NEXT_STEPS=""
ROOT_CAUSE=""
FIX_DESCRIPTION=""
RESOLVER=""
FEATURE_NAME=""
IMPLEMENTATION_APPROACH=""
KEY_COMPONENTS=""
ACCEPTANCE_CRITERIA_STATUS=""
DEPLOYMENT_DETAILS=""
# Variables for future template expansion - currently unused
# shellcheck disable=SC2034
BUILD_SYSTEM=""
# shellcheck disable=SC2034
FAILURE_TYPE=""
# shellcheck disable=SC2034
ERROR_DETAILS=""
# shellcheck disable=SC2034
ROOT_CAUSE_ANALYSIS=""
# shellcheck disable=SC2034
RESOLUTION_DESCRIPTION=""
# shellcheck disable=SC2034
CHANGES_MADE=""
# shellcheck disable=SC2034
PREVENTION_MEASURES=""
# shellcheck disable=SC2034
TEST_RESULTS=""
# shellcheck disable=SC2034
VERIFICATION_METHOD=""
# shellcheck disable=SC2034
RESOLUTION_STEPS=""
# shellcheck disable=SC2034
AFFECTED_COMPONENTS=""

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        --pr-number)
            PR_NUMBER="$2"
            shift 2
            ;;
        --pr-title)
            PR_TITLE="$2"
            shift 2
            ;;
        --branch)
            BRANCH_NAME="$2"
            shift 2
            ;;
        --impact)
            IMPACT_DESCRIPTION="$2"
            shift 2
            ;;
        --next-steps)
            NEXT_STEPS="$2"
            shift 2
            ;;
        --root-cause)
            # shellcheck disable=SC2034
            ROOT_CAUSE="$2"
            shift 2
            ;;
        --fix-description)
            # shellcheck disable=SC2034
            FIX_DESCRIPTION="$2"
            shift 2
            ;;
        --resolver)
            RESOLVER="$2"
            shift 2
            ;;
        --feature-name)
            # shellcheck disable=SC2034
            FEATURE_NAME="$2"
            shift 2
            ;;
        --implementation-approach)
            # shellcheck disable=SC2034
            IMPLEMENTATION_APPROACH="$2"
            shift 2
            ;;
        --key-components)
            # shellcheck disable=SC2034
            KEY_COMPONENTS="$2"
            shift 2
            ;;
        --acceptance-criteria)
            # shellcheck disable=SC2034
            ACCEPTANCE_CRITERIA_STATUS="$2"
            shift 2
            ;;
        --deployment-details)
            # shellcheck disable=SC2034
            DEPLOYMENT_DETAILS="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate template exists
TEMPLATE_FILE="$TEMPLATE_DIR/$TEMPLATE_TYPE.md"
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Error: Template file not found: $TEMPLATE_FILE"
    echo "Available templates:"
    ls -1 "$TEMPLATE_DIR"/*.md 2>/dev/null || echo "No templates found"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Generate current timestamp
CURRENT_DATE="$(date -Iseconds)"
CLOSURE_DATE="$CURRENT_DATE"

# Set defaults if not provided
if [[ -z "$RESOLVER" ]]; then
    RESOLVER="DevOnboarder Team"
fi

# For PR completion template, get additional info if PR number provided
if [[ "$TEMPLATE_TYPE" == "pr-completion" && -n "$PR_NUMBER" ]]; then
    # Get PR info from GitHub CLI if available
    if command -v gh >/dev/null 2>&1; then
        if [[ -z "$PR_TITLE" ]]; then
            PR_TITLE="$(gh pr view "$PR_NUMBER" --json title --jq '.title' 2>/dev/null || echo 'PR Title Not Available')"
        fi
        if [[ -z "$BRANCH_NAME" ]]; then
            BRANCH_NAME="$(gh pr view "$PR_NUMBER" --json headRefName --jq '.headRefName' 2>/dev/null || echo 'Branch Not Available')"
        fi
        COMMIT_COUNT="$(gh pr view "$PR_NUMBER" --json commits --jq '.commits | length' 2>/dev/null || echo '1')"
        MERGE_DATE="$(gh pr view "$PR_NUMBER" --json mergedAt --jq '.mergedAt' 2>/dev/null || echo "$CURRENT_DATE")"
    else
        echo "Warning: GitHub CLI not available, using placeholder values"
        if [[ -z "$PR_TITLE" ]]; then
            PR_TITLE="Pull Request $PR_NUMBER"
        fi
        if [[ -z "$BRANCH_NAME" ]]; then
            BRANCH_NAME="feature-branch"
        fi
        COMMIT_COUNT="1"
        MERGE_DATE="$CURRENT_DATE"
    fi
fi

# Output file
OUTPUT_FILE="$OUTPUT_DIR/issue-${ISSUE_NUMBER}-${TEMPLATE_TYPE}-comment.md"

# Copy template and perform substitutions
cp "$TEMPLATE_FILE" "$OUTPUT_FILE"

# Perform substitutions using a safer approach
# Create a temporary script to avoid sed escaping issues
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << 'EOF'
import sys

# Read the template
with open(sys.argv[1], 'r') as f:
    content = f.read()

# Perform replacements
replacements = {
    '{PR_NUMBER}': sys.argv[2],
    '{PR_TITLE}': sys.argv[3],
    '{BRANCH_NAME}': sys.argv[4],
    '{MERGE_DATE}': sys.argv[5],
    '{COMMIT_COUNT}': sys.argv[6],
    '{CLOSURE_DATE}': sys.argv[7],
    '{RESOLVER}': sys.argv[8],
    '{IMPACT_DESCRIPTION}': sys.argv[9],
    '{NEXT_STEPS}': sys.argv[10],
    '{ROOT_CAUSE}': sys.argv[11] if len(sys.argv) > 11 else '',
    '{FIX_DESCRIPTION}': sys.argv[12] if len(sys.argv) > 12 else '',
    '{FEATURE_NAME}': sys.argv[13] if len(sys.argv) > 13 else '',
    '{IMPLEMENTATION_APPROACH}': sys.argv[14] if len(sys.argv) > 14 else '',
    '{KEY_COMPONENTS}': sys.argv[15] if len(sys.argv) > 15 else '',
    '{ACCEPTANCE_CRITERIA_STATUS}': sys.argv[16] if len(sys.argv) > 16 else '',
    '{DEPLOYMENT_DETAILS}': sys.argv[17] if len(sys.argv) > 17 else '',
    '{BUILD_SYSTEM}': sys.argv[18] if len(sys.argv) > 18 else '',
    '{FAILURE_TYPE}': sys.argv[19] if len(sys.argv) > 19 else '',
    '{ERROR_DETAILS}': sys.argv[20] if len(sys.argv) > 20 else '',
    '{ROOT_CAUSE_ANALYSIS}': sys.argv[21] if len(sys.argv) > 21 else '',
    '{RESOLUTION_DESCRIPTION}': sys.argv[22] if len(sys.argv) > 22 else '',
    '{CHANGES_MADE}': sys.argv[23] if len(sys.argv) > 23 else '',
    '{PREVENTION_MEASURES}': sys.argv[24] if len(sys.argv) > 24 else '',
    '{AFFECTED_COMPONENTS}': sys.argv[25] if len(sys.argv) > 25 else '',
    '{RESOLUTION_STEPS}': sys.argv[26] if len(sys.argv) > 26 else '',
    '{TEST_RESULTS}': sys.argv[27] if len(sys.argv) > 27 else '',
    '{VERIFICATION_METHOD}': sys.argv[28] if len(sys.argv) > 28 else ''
}

for placeholder, value in replacements.items():
    content = content.replace(placeholder, value)

# Write back to file
with open(sys.argv[1], 'w') as f:
    f.write(content)
EOF

# Use Python for safe string replacement
python3 "$TEMP_SCRIPT" "$OUTPUT_FILE" "$PR_NUMBER" "$PR_TITLE" "$BRANCH_NAME" "$MERGE_DATE" "$COMMIT_COUNT" "$CLOSURE_DATE" "$RESOLVER" "$IMPACT_DESCRIPTION" "$NEXT_STEPS" "$ROOT_CAUSE" "$FIX_DESCRIPTION" "$FEATURE_NAME" "$IMPLEMENTATION_APPROACH" "$KEY_COMPONENTS" "$ACCEPTANCE_CRITERIA_STATUS" "$DEPLOYMENT_DETAILS" "$BUILD_SYSTEM" "$FAILURE_TYPE" "$ERROR_DETAILS" "$ROOT_CAUSE_ANALYSIS" "$RESOLUTION_DESCRIPTION" "$CHANGES_MADE" "$PREVENTION_MEASURES" "$AFFECTED_COMPONENTS" "$RESOLUTION_STEPS" "$TEST_RESULTS" "$VERIFICATION_METHOD"

# Clean up
rm -f "$TEMP_SCRIPT"

echo "Template generated successfully"
echo "Output file: $OUTPUT_FILE"
echo "Template type: $TEMPLATE_TYPE"
echo "Issue number: $ISSUE_NUMBER"

# Show usage instructions
echo ""
echo "To use this comment:"
echo "1. Review the generated file: cat $OUTPUT_FILE"
echo "2. Add comment to issue: gh issue comment $ISSUE_NUMBER --body-file $OUTPUT_FILE"
echo "3. Close the issue: gh issue close $ISSUE_NUMBER --reason completed"

echo "Template generation complete"
