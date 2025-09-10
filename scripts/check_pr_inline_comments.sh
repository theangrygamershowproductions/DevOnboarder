#!/bin/bash

# DevOnboarder PR Inline Comments Checker
# Efficiently extracts and displays Copilot and reviewer inline comments

set -euo pipefail

show_usage() {
    cat << 'EOF'
DevOnboarder PR Inline Comments Checker

Usage: check_pr_inline_comments.sh [OPTIONS] PR_NUMBER

OPTIONS:
    --summary           Show summary of comments only
    --copilot-only      Show only Copilot comments
    --suggestions       Show only comments with code suggestions
    --format=json       Output raw JSON format
    --open-browser      Open all comment URLs in browser

EXAMPLES:
    ./scripts/check_pr_inline_comments.sh 1330
    ./scripts/check_pr_inline_comments.sh --copilot-only 1330
    ./scripts/check_pr_inline_comments.sh --suggestions 1330
    ./scripts/check_pr_inline_comments.sh --summary 1330

ENVIRONMENT:
    Requires GitHub CLI (gh) with proper authentication
EOF
}

# Parse command line arguments
SUMMARY_ONLY=false
COPILOT_ONLY=false
SUGGESTIONS_ONLY=false
OUTPUT_FORMAT="human"
OPEN_BROWSER=false
PR_NUMBER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --summary)
            SUMMARY_ONLY=true
            shift
            ;;
        --copilot-only)
            COPILOT_ONLY=true
            shift
            ;;
        --suggestions)
            SUGGESTIONS_ONLY=true
            shift
            ;;
        --format=*)
            OUTPUT_FORMAT="${1#*=}"
            shift
            ;;
        --open-browser)
            OPEN_BROWSER=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            if [[ -z "$PR_NUMBER" ]]; then
                PR_NUMBER="$1"
            else
                echo "Error: Unknown option $1"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "$PR_NUMBER" ]]; then
    echo "Error: PR number is required"
    show_usage
    exit 1
fi

# Validate PR number is numeric
if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "Error: PR number must be numeric"
    exit 1
fi

# Get repository information
REPO_INFO=$(gh repo view --json owner,name)
OWNER=$(echo "$REPO_INFO" | jq -r '.owner.login')
REPO=$(echo "$REPO_INFO" | jq -r '.name')

echo "Fetching inline comments for PR #$PR_NUMBER..."
echo "Repository: $OWNER/$REPO"
echo ""

# Fetch inline comments
COMMENTS_JSON=$(gh api "/repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments" 2>/dev/null || {
    echo "Error: Failed to fetch comments for PR #$PR_NUMBER"
    echo "Make sure the PR exists and you have proper access"
    exit 1
})

# Check if no comments found
COMMENT_COUNT=$(echo "$COMMENTS_JSON" | jq length)
if [[ "$COMMENT_COUNT" -eq 0 ]]; then
    echo "No inline comments found for PR #$PR_NUMBER"
    exit 0
fi

# Output raw JSON if requested
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    echo "$COMMENTS_JSON"
    exit 0
fi

# Filter comments based on options
FILTERED_COMMENTS="$COMMENTS_JSON"

if [[ "$COPILOT_ONLY" == true ]]; then
    FILTERED_COMMENTS=$(echo "$FILTERED_COMMENTS" | jq '[.[] | select(.user.login == "Copilot" or .user.login == "copilot-pull-request-reviewer[bot]")]')
fi

if [[ "$SUGGESTIONS_ONLY" == true ]]; then
    FILTERED_COMMENTS=$(echo "$FILTERED_COMMENTS" | jq '[.[] | select(.body | contains("```suggestion"))]')
fi

FILTERED_COUNT=$(echo "$FILTERED_COMMENTS" | jq length)

# Summary mode
if [[ "$SUMMARY_ONLY" == true ]]; then
    echo "📊 INLINE COMMENTS SUMMARY"
    echo "=========================="
    echo "Total comments: $COMMENT_COUNT"
    echo "Filtered comments: $FILTERED_COUNT"
    echo ""

    # Group by file
    echo "📁 COMMENTS BY FILE:"
    echo "$FILTERED_COMMENTS" | jq -r '.[] | .path' | sort | uniq -c | sort -nr | while read -r count file; do
        printf "  %2d  %s\n" "$count" "$file"
    done
    echo ""

    # Group by user
    echo "👤 COMMENTS BY USER:"
    echo "$FILTERED_COMMENTS" | jq -r '.[] | .user.login' | sort | uniq -c | sort -nr | while read -r count user; do
        printf "  %2d  %s\n" "$count" "$user"
    done
    echo ""

    # Show suggestions count
    SUGGESTIONS_COUNT=$(echo "$FILTERED_COMMENTS" | jq '[.[] | select(.body | contains("```suggestion"))] | length')
    echo "💡 Code suggestions: $SUGGESTIONS_COUNT"

    exit 0
fi

# Open URLs in browser if requested
if [[ "$OPEN_BROWSER" == true ]]; then
    echo "Opening comment URLs in browser..."
    echo "$FILTERED_COMMENTS" | jq -r '.[].html_url' | while read -r url; do
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$url" 2>/dev/null &
        elif command -v open >/dev/null 2>&1; then
            open "$url" 2>/dev/null &
        else
            echo "Browser opening not supported on this system"
            echo "URL: $url"
        fi
    done
    exit 0
fi

# Full output mode
echo "📋 INLINE COMMENTS DETAILS"
echo "=========================="
echo "Showing $FILTERED_COUNT of $COMMENT_COUNT total comments"
echo ""

# Process each comment
echo "$FILTERED_COMMENTS" | jq -c '.[]' | while IFS= read -r comment; do
    # Extract comment details
    COMMENT_ID=$(echo "$comment" | jq -r '.id')
    USER=$(echo "$comment" | jq -r '.user.login')
    CREATED_AT=$(echo "$comment" | jq -r '.created_at')
    FILE_PATH=$(echo "$comment" | jq -r '.path')
    LINE_NUMBER=$(echo "$comment" | jq -r '.line')
    BODY=$(echo "$comment" | jq -r '.body')
    HTML_URL=$(echo "$comment" | jq -r '.html_url')

    # Format timestamp
    FORMATTED_DATE=$(date -d "$CREATED_AT" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "$CREATED_AT")

    echo "┌─────────────────────────────────────────────────────────────"
    echo "│ 💬 Comment ID: $COMMENT_ID"
    echo "│ 👤 User: $USER"
    echo "│ 📅 Date: $FORMATTED_DATE"
    echo "│ 📁 File: $FILE_PATH"
    echo "│ 📍 Line: $LINE_NUMBER"
    echo "│ 🔗 URL: $HTML_URL"
    echo "├─────────────────────────────────────────────────────────────"

    # Format comment body with proper indentation
    while IFS= read -r line; do
        echo "│ $line"
    done <<< "$BODY"

    echo "└─────────────────────────────────────────────────────────────"
    echo ""
done

echo "✅ Complete! Found $FILTERED_COUNT relevant inline comments."

# Show quick action suggestions
if [[ "$FILTERED_COUNT" -gt 0 ]]; then
    echo ""
    echo "🚀 QUICK ACTIONS:"
    echo "  View in browser:  ./scripts/check_pr_inline_comments.sh --open-browser $PR_NUMBER"
    echo "  Summary only:     ./scripts/check_pr_inline_comments.sh --summary $PR_NUMBER"
    echo "  Copilot only:     ./scripts/check_pr_inline_comments.sh --copilot-only $PR_NUMBER"
    echo "  Suggestions only: ./scripts/check_pr_inline_comments.sh --suggestions $PR_NUMBER"
fi
