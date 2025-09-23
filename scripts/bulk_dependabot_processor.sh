#!/bin/bash
# Bulk Dependabot PR Processor
# Automated dependency update management for DevOnboarder
# Handles bulk processing of Dependabot-flagged dependency updates

set -euo pipefail

# Colors for output formatting - safe ANSI codes for CLI readability
if [[ "${CI:-}" == "true" || "${GITHUB_ACTIONS:-}" == "true" || "${NO_COLOR:-}" == "1" ]]; then
    # Disable colors in CI environments or when NO_COLOR is set
    readonly RED=''
    readonly GREEN=''
    readonly BLUE=''
    readonly YELLOW=''
    readonly PURPLE=''
    readonly NC=''
else
    # Safe ANSI color codes for improved CLI readability
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly BLUE='\033[0;34m'
    readonly YELLOW='\033[1;33m'
    readonly PURPLE='\033[0;35m'
    readonly NC='\033[0m' # No Color
fi

# Configuration
SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_NAME
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
readonly TIMESTAMP
LOG_FILE="logs/${SCRIPT_NAME%.*}_${TIMESTAMP}.log"
readonly LOG_FILE

# Create logs directory and setup logging
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Bulk Dependabot PR Processor starting at $(date)"
printf "%s\n" "$LOG_FILE"

# Function to display usage
usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  list          - List all open Dependabot PRs"
    echo "  analyze       - Analyze Dependabot PRs for safety and compatibility"
    echo "  process       - Process and merge safe Dependabot PRs"
    echo "  batch-merge   - Batch merge multiple Dependabot PRs with confirmation"
    echo "  status        - Show processing status and statistics"
    echo ""
    echo "Options:"
    echo "  --dry-run     - Show what would be done without making changes"
    echo "  --max-prs=N   - Limit processing to N PRs (default: 10)"
    echo "  --safe-only   - Only process PRs with no conflicts or test failures"
    echo "  --interactive - Prompt for confirmation before each operation"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 analyze --max-prs=5"
    echo "  $0 process --dry-run --safe-only"
    echo "  $0 batch-merge --max-prs=3 --interactive"
    exit 1
}

# Load token environment if available
load_tokens() {
    if [[ -f "scripts/load_token_environment.sh" ]]; then
        echo "Loading token environment..."
        # shellcheck source=/dev/null
        source scripts/load_token_environment.sh
    fi
}

# Function to list Dependabot PRs
list_dependabot_prs() {
    echo -e "${BLUE}AUTOMATED PR PROCESS CONTROLLER${NC}"

    # Get Dependabot PRs using GitHub CLI
    if ! gh pr list \
        --author "dependabot[bot]" \
        --state open \
        --json number,title,headRefName,createdAt,mergeStateStatus \
        --template '{{range .}}{{tablerow .number .title .headRefName (timeago .createdAt) .mergeStateStatus}}{{end}}' \
        > temp_dependabot_prs.txt; then
        echo -e "${RED}FAILED: Could not retrieve Dependabot PRs${NC}"
        return 1
    fi

    local pr_count
    pr_count=$(wc -l < temp_dependabot_prs.txt)

    if [[ "$pr_count" -eq 0 ]]; then
        echo -e "${YELLOW}INFO: No open Dependabot PRs found${NC}"
        rm -f temp_dependabot_prs.txt
        return 0
    fi

    echo -e "${GREEN}SUCCESS: Found $pr_count Dependabot PR(s)${NC}"
    echo ""
    echo "PR # | Title | Branch | Age | Status"
    echo "-----|-------|--------|-----|-------"
    cat temp_dependabot_prs.txt

    rm -f temp_dependabot_prs.txt
    return 0
}

# Function to analyze Dependabot PRs
analyze_dependabot_prs() {
    local max_prs="${MAX_PRS:-10}"
    local dry_run="${DRY_RUN:-false}"

    echo -e "${BLUE}Analyzing Dependabot PRs (max: $max_prs)...${NC}"

    # Get PR data in JSON format for analysis
    if ! gh pr list \
        --author "dependabot[bot]" \
        --state open \
        --limit "$max_prs" \
        --json number,title,headRefName,mergeStateStatus,mergeable,commits,changedFiles \
        > temp_pr_analysis.json; then
        echo -e "${RED}FAILED: Could not retrieve PR data for analysis${NC}"
        return 1
    fi

    local pr_count
    pr_count=$(jq length temp_pr_analysis.json)

    if [[ "$pr_count" -eq 0 ]]; then
        echo -e "${YELLOW}INFO: No Dependabot PRs to analyze${NC}"
        rm -f temp_pr_analysis.json
        return 0
    fi

    echo -e "${GREEN}SUCCESS: Analyzing $pr_count PR(s)${NC}"
    echo ""

    # Analyze each PR
    local safe_count=0
    local risky_count=0

    for ((i=0; i<pr_count; i++)); do
        local pr_data
        pr_data=$(jq ".[$i]" temp_pr_analysis.json)

        local pr_number
        pr_number=$(jq -r '.number' <<< "$pr_data")
        local title
        title=$(jq -r '.title' <<< "$pr_data")
        local merge_status
        merge_status=$(jq -r '.mergeStateStatus' <<< "$pr_data")
        local mergeable
        mergeable=$(jq -r '.mergeable' <<< "$pr_data")
        local changed_files
        changed_files=$(jq -r '.changedFiles' <<< "$pr_data")

        printf "%s\n" "$title"
        printf "%s\n" "$changed_files"

        # Safety assessment
        local is_safe=true
        local risk_reasons=""

        if [[ "$merge_status" != "CLEAN" ]]; then
            is_safe=false
            risk_reasons="${risk_reasons}merge conflicts; "
        fi

        if [[ "$mergeable" != "MERGEABLE" ]]; then
            is_safe=false
            risk_reasons="${risk_reasons}not mergeable; "
        fi

        if [[ "$changed_files" -gt 10 ]]; then
            is_safe=false
            risk_reasons="${risk_reasons}too many files changed; "
        fi

        # Check for lock file changes (good indicator of dependency updates)
        if gh pr view "$pr_number" --json files --jq '.files[].path' | grep -q "package-lock.json\|yarn.lock\|poetry.lock\|Pipfile.lock"; then
            echo "  Lock file changes detected (good for dependency updates)"
        else
            echo "  WARNING: No lock file changes detected"
        fi

        if [[ "$is_safe" == true ]]; then
            echo -e "  ${GREEN}SAFE TO MERGE${NC}"
            ((safe_count++))
        else
            echo -e "  ${RED}RISKY: ${risk_reasons%??}${NC}"
            ((risky_count++))
        fi

        echo ""
    done

    echo -e "${BLUE}Analysis Summary:${NC}"
    printf "%s\n" "$pr_count"
    printf "%s\n" "$safe_count"
    printf "%s\n" "$risky_count"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "${YELLOW}DRY RUN: No changes made${NC}"
    fi

    rm -f temp_pr_analysis.json
    return 0
}

# Function to process Dependabot PRs
process_dependabot_prs() {
    local max_prs="${MAX_PRS:-10}"
    local dry_run="${DRY_RUN:-false}"
    local safe_only="${SAFE_ONLY:-false}"
    local interactive="${INTERACTIVE:-false}"

    echo -e "${BLUE}Processing Dependabot PRs...${NC}"
    printf "%s\n" "$interactive"

    # First analyze to get safe PRs
    if ! analyze_dependabot_prs; then
        echo -e "${RED}FAILED: Analysis failed, cannot proceed${NC}"
        return 1
    fi

    # Get list of safe PRs from the analysis
    if ! gh pr list \
        --author "dependabot[bot]" \
        --state open \
        --limit "$max_prs" \
        --json number,mergeStateStatus,mergeable \
        > temp_safe_prs.json; then
        echo -e "${RED}FAILED: Could not get safe PR list${NC}"
        return 1
    fi

    local processed_count=0
    local merged_count=0
    local skipped_count=0

    local pr_count
    pr_count=$(jq length temp_safe_prs.json)

    for ((i=0; i<pr_count; i++)); do
        local pr_data
        pr_data=$(jq ".[$i]" temp_safe_prs.json)

        local pr_number
        pr_number=$(jq -r '.number' <<< "$pr_data")
        local merge_status
        merge_status=$(jq -r '.mergeStateStatus' <<< "$pr_data")
        local mergeable
        mergeable=$(jq -r '.mergeable' <<< "$pr_data")

        local should_process=true

        if [[ "$safe_only" == "true" ]]; then
            if [[ "$merge_status" != "CLEAN" || "$mergeable" != "MERGEABLE" ]]; then
                should_process=false
            fi
        fi

        if [[ "$should_process" == true ]]; then
            printf "%s\n" "$pr_number..."

            if [[ "$interactive" == "true" ]]; then
                read -p "Merge PR #$pr_number? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    printf "%s\n" "$pr_number"
                    ((skipped_count++))
                    continue
                fi
            fi

            if [[ "$dry_run" == "true" ]]; then
                echo -e "${YELLOW}DRY RUN: Would merge PR #$pr_number${NC}"
                ((processed_count++))
            else
                if gh pr merge "$pr_number" --merge --delete-branch; then
                    echo -e "${GREEN}SUCCESS: Merged PR #$pr_number${NC}"
                    ((merged_count++))
                    ((processed_count++))
                else
                    echo -e "${RED}FAILED: Could not merge PR #$pr_number${NC}"
                fi
            fi
        else
            printf "%s\n" "$pr_number (not safe or filtered out)"
            ((skipped_count++))
        fi
    done

    echo ""
    echo -e "${PURPLE}DEPENDENCY UPDATE COMPLETE${NC}"
    echo "==============================="
    printf "%s\n" "$processed_count"
    printf "%s\n" "$merged_count"
    printf "%s\n" "$skipped_count"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "${YELLOW}DRY RUN: No actual changes made${NC}"
    fi

    rm -f temp_safe_prs.json
    return 0
}

# Function to show status
show_status() {
    echo -e "${BLUE}Dependabot PR Processing Status${NC}"
    echo ""

    # Get overall statistics
    local total_open
    total_open=$(gh pr list --author "dependabot[bot]" --state open --json number | jq length)

    local total_merged_today
    total_merged_today=$(gh pr list --author "dependabot[bot]" --state merged --json number | jq 'length')

    local total_closed_today
    total_closed_today=$(gh pr list --author "dependabot[bot]" --state closed --json number | jq 'length')

    echo "Current Status:"
    printf "%s\n" "$total_open"
    printf "%s\n" "$total_merged_today"
    printf "%s\n" "$total_closed_today"
    echo ""

    # Show recent activity from logs
    if [[ -d "logs" ]]; then
        echo "Recent Processing Activity:"
        find logs -name "*bulk_dependabot*" -type f -mtime -7 -exec ls -la {} \; | head -5 || true
    fi
}

# Parse command line arguments
COMMAND=""
DRY_RUN=false
MAX_PRS=10
SAFE_ONLY=false
INTERACTIVE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        list|analyze|process|batch-merge|status)
            COMMAND="$1"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --max-prs=*)
            MAX_PRS="${1#*=}"
            shift
            ;;
        --safe-only)
            SAFE_ONLY=true
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -z "$COMMAND" ]]; then
    usage
fi

# Load tokens
load_tokens

# Execute command
case "$COMMAND" in
    "list")
        list_dependabot_prs
        ;;
    "analyze")
        analyze_dependabot_prs
        ;;
    "process"|"batch-merge")
        process_dependabot_prs
        ;;
    "status")
        show_status
        ;;
    *)
        printf "%s\n" "$COMMAND"
        usage
        ;;
esac

echo ""
echo "Bulk Dependabot PR Processor completed at $(date)"
printf "%s\n" "$LOG_FILE"
