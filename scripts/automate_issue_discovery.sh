#!/bin/bash

# automate_issue_discovery.sh - Automated issue discovery and triage workflow
# Follows DevOnboarder terminal output compliance and centralized logging

set -euo pipefail

# Centralized logging setup
mkdir -p logs
LOG_FILE="logs/issue_discovery_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Load DevOnboarder environment
if [[ -f "scripts/load_token_environment.sh" ]]; then
    # shellcheck source=scripts/load_token_environment.sh
    source scripts/load_token_environment.sh
fi

echo "Starting automated issue discovery workflow"
echo "Log file: $LOG_FILE"

# Function to discover CI failure issues
discover_ci_issues() {
    echo "=== Discovering CI failure issues ==="

    if ! command -v gh >/dev/null 2>&1; then
        echo "WARNING: GitHub CLI not available, skipping CI issue discovery"
        return 1
    fi

    local ci_labels=("ci-failure" "ci-timeout" "ci-flaky" "workflow-failure")
    local ci_issues=()

    for label in "${ci_labels[@]}"; do
        echo "Searching for issues with label: $label"
        local issues
        issues=$(gh issue list --label "$label" --state open --json number,title,updatedAt,assignees --jq '.[] | "\(.number):\(.title):\(.updatedAt):\(.assignees | length)"' 2>/dev/null || true)

        if [[ -n "$issues" ]]; then
            echo "Found issues with label '$label':"
            while read -r issue_line; do
                if [[ -n "$issue_line" ]]; then
                    ci_issues+=("$issue_line")
                    echo "  $issue_line"
                fi
            done <<< "$issues"
        fi
    done

    echo "Total CI-related issues found: ${#ci_issues[@]}"
    printf '%s\n' "${ci_issues[@]}"
}

# Function to discover tracking issues
discover_tracking_issues() {
    echo "=== Discovering tracking issues ==="

    if ! command -v gh >/dev/null 2>&1; then
        echo "WARNING: GitHub CLI not available, skipping tracking issue discovery"
        return 1
    fi

    local tracking_patterns=(
        "is:open label:tracking"
        "is:open track"
        "is:open milestone"
        "is:open epic"
    )

    local tracking_issues=()

    for pattern in "${tracking_patterns[@]}"; do
        echo "Searching with pattern: $pattern"
        local issues
        issues=$(gh issue list --search "$pattern" --json number,title,labels,milestone --jq '.[] | "\(.number):\(.title):\(.labels | map(.name) | join(",")):\(.milestone.title // "none")"' 2>/dev/null || true)

        if [[ -n "$issues" ]]; then
            echo "Found issues with pattern '$pattern':"
            while read -r issue_line; do
                if [[ -n "$issue_line" ]]; then
                    # Check for duplicates
                    local issue_number
                    issue_number=$(echo "$issue_line" | cut -d: -f1)
                    local already_found=false

                    for existing_issue in "${tracking_issues[@]}"; do
                        local existing_number
                        existing_number=$(echo "$existing_issue" | cut -d: -f1)
                        if [[ "$existing_number" == "$issue_number" ]]; then
                            already_found=true
                            break
                        fi
                    done

                    if [[ "$already_found" == false ]]; then
                        tracking_issues+=("$issue_line")
                        echo "  $issue_line"
                    fi
                fi
            done <<< "$issues"
        fi
    done

    echo "Total tracking issues found: ${#tracking_issues[@]}"
    printf '%s\n' "${tracking_issues[@]}"
}

# Function to discover stale issues
discover_stale_issues() {
    echo "=== Discovering stale issues ==="

    if ! command -v gh >/dev/null 2>&1; then
        echo "WARNING: GitHub CLI not available, skipping stale issue discovery"
        return 1
    fi

    # Calculate date 30 days ago
    local thirty_days_ago
    if command -v date >/dev/null 2>&1; then
        if date --version 2>/dev/null | grep -q GNU; then
            # GNU date
            thirty_days_ago=$(date -d "30 days ago" +%Y-%m-%d)
        else
            # BSD date (macOS)
            thirty_days_ago=$(date -v-30d +%Y-%m-%d)
        fi
    else
        echo "WARNING: Date command not available, using approximate date"
        thirty_days_ago="2024-01-01"
    fi

    echo "Looking for issues not updated since: $thirty_days_ago"

    local stale_search="is:open updated:<$thirty_days_ago"
    local stale_issues
    stale_issues=$(gh issue list --search "$stale_search" --json number,title,updatedAt,assignees --jq '.[] | "\(.number):\(.title):\(.updatedAt):\(.assignees | length)"' 2>/dev/null || true)

    if [[ -n "$stale_issues" ]]; then
        echo "Found stale issues:"
        local stale_count=0
        while read -r issue_line; do
            if [[ -n "$issue_line" ]]; then
                echo "  $issue_line"
                ((stale_count++))
            fi
        done <<< "$stale_issues"
        echo "Total stale issues found: $stale_count"
    else
        echo "No stale issues found"
    fi

    echo "$stale_issues"
}

# Function to discover high priority issues
discover_priority_issues() {
    echo "=== Discovering high priority issues ==="

    if ! command -v gh >/dev/null 2>&1; then
        echo "WARNING: GitHub CLI not available, skipping priority issue discovery"
        return 1
    fi

    local priority_labels=("priority:high" "priority:critical" "urgent" "blocker" "security")
    local priority_issues=()

    for label in "${priority_labels[@]}"; do
        echo "Searching for priority issues with label: $label"
        local issues
        issues=$(gh issue list --label "$label" --state open --json number,title,labels,assignees --jq '.[] | "\(.number):\(.title):\(.labels | map(.name) | join(",")):\(.assignees | length)"' 2>/dev/null || true)

        if [[ -n "$issues" ]]; then
            echo "Found priority issues with label '$label':"
            while read -r issue_line; do
                if [[ -n "$issue_line" ]]; then
                    priority_issues+=("$issue_line")
                    echo "  $issue_line"
                fi
            done <<< "$issues"
        fi
    done

    echo "Total priority issues found: ${#priority_issues[@]}"
    printf '%s\n' "${priority_issues[@]}"
}

# Function to analyze issue health
analyze_issue_health() {
    local ci_count="$1"
    local tracking_count="$2"
    local stale_count="$3"
    local priority_count="$4"

    echo "=== Issue Health Analysis ==="
    echo "CI-related issues: $ci_count"
    echo "Tracking issues: $tracking_count"
    echo "Stale issues: $stale_count"
    echo "Priority issues: $priority_count"

    local total_issues=$((ci_count + tracking_count + stale_count + priority_count))
    echo "Total issues requiring attention: $total_issues"

    # Determine health status
    local health_status="UNKNOWN"
    if [[ "$priority_count" -gt 5 || "$ci_count" -gt 10 ]]; then
        health_status="CRITICAL"
    elif [[ "$stale_count" -gt 20 || "$total_issues" -gt 25 ]]; then
        health_status="WARNING"
    elif [[ "$total_issues" -gt 10 ]]; then
        health_status="ATTENTION"
    else
        health_status="GOOD"
    fi

    echo "Overall issue health: $health_status"

    # Provide recommendations
    echo ""
    echo "RECOMMENDATIONS:"
    case "$health_status" in
        "CRITICAL")
            echo "1. IMMEDIATE: Address all priority and CI issues"
            echo "2. Triage high-impact issues first"
            echo "3. Consider issue creation freeze until resolved"
            ;;
        "WARNING")
            echo "1. Schedule issue triage session"
            echo "2. Close or update stale issues"
            echo "3. Assign ownership to open issues"
            ;;
        "ATTENTION")
            echo "1. Regular issue grooming recommended"
            echo "2. Monitor CI issue patterns"
            echo "3. Update tracking issue status"
            ;;
        "GOOD")
            echo "1. Continue current issue management practices"
            echo "2. Regular monitoring sufficient"
            ;;
    esac

    return 0
}

# Function to generate triage actions
generate_triage_actions() {
    echo "=== Generating Triage Actions ==="

    local actions_file
    actions_file="logs/triage_actions_$(date +%Y%m%d_%H%M%S).txt"

    cat > "$actions_file" << 'EOF'
# Issue Triage Action Plan
# Generated by automate_issue_discovery.sh

## Priority Actions
[ ] Review all priority:high and priority:critical issues
[ ] Assign owners to unassigned critical issues
[ ] Update status on all tracking issues

## CI Health Actions
[ ] Review CI failure patterns
[ ] Close resolved CI issues
[ ] Create automation for recurring CI problems

## Stale Issue Actions
[ ] Review issues not updated in 30+ days
[ ] Close issues that are no longer relevant
[ ] Update or re-prioritize still-relevant issues

## General Maintenance
[ ] Update issue labels for consistency
[ ] Link related issues to tracking issues
[ ] Document resolution patterns for common issues

## Automation Opportunities
[ ] Identify recurring issue patterns
[ ] Create templates for common issue types
[ ] Set up automated labeling rules
EOF

    echo "Triage action plan generated: $actions_file"
    echo "Use this checklist for systematic issue management"
}

# Main workflow
main() {
    local discover_all=true
    local discover_ci=false
    local discover_tracking=false
    local discover_stale=false
    local discover_priority=false
    local generate_actions=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --ci)
                discover_all=false
                discover_ci=true
                shift
                ;;
            --tracking)
                discover_all=false
                discover_tracking=true
                shift
                ;;
            --stale)
                discover_all=false
                discover_stale=true
                shift
                ;;
            --priority)
                discover_all=false
                discover_priority=true
                shift
                ;;
            --actions)
                generate_actions=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --ci          Discover CI-related issues only"
                echo "  --tracking    Discover tracking issues only"
                echo "  --stale       Discover stale issues only"
                echo "  --priority    Discover priority issues only"
                echo "  --actions     Generate triage action plan"
                echo "Examples:"
                echo "  $0                    # Discover all issue types"
                echo "  $0 --ci --priority    # Discover CI and priority issues"
                echo "  $0 --actions          # Generate triage action plan"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    echo "=== Automated Issue Discovery ==="

    local ci_count=0
    local tracking_count=0
    local stale_count=0
    local priority_count=0

    # Step 1: Discover issues based on selection
    if [[ "$discover_all" == true || "$discover_ci" == true ]]; then
        local ci_issues
        ci_issues=$(discover_ci_issues)
        ci_count=$(echo "$ci_issues" | wc -l)
        if [[ -z "$ci_issues" ]]; then
            ci_count=0
        fi
    fi

    if [[ "$discover_all" == true || "$discover_tracking" == true ]]; then
        local tracking_issues
        tracking_issues=$(discover_tracking_issues)
        tracking_count=$(echo "$tracking_issues" | wc -l)
        if [[ -z "$tracking_issues" ]]; then
            tracking_count=0
        fi
    fi

    if [[ "$discover_all" == true || "$discover_stale" == true ]]; then
        local stale_issues
        stale_issues=$(discover_stale_issues)
        stale_count=$(echo "$stale_issues" | wc -l)
        if [[ -z "$stale_issues" ]]; then
            stale_count=0
        fi
    fi

    if [[ "$discover_all" == true || "$discover_priority" == true ]]; then
        local priority_issues
        priority_issues=$(discover_priority_issues)
        priority_count=$(echo "$priority_issues" | wc -l)
        if [[ -z "$priority_issues" ]]; then
            priority_count=0
        fi
    fi

    # Step 2: Analyze issue health
    analyze_issue_health "$ci_count" "$tracking_count" "$stale_count" "$priority_count"

    # Step 3: Generate triage actions if requested
    if [[ "$generate_actions" == true ]]; then
        generate_triage_actions
    fi

    echo "=== Issue discovery completed ==="
    echo "Log file: $LOG_FILE"
    echo "Summary:"
    echo "- CI issues: $ci_count"
    echo "- Tracking issues: $tracking_count"
    echo "- Stale issues: $stale_count"
    echo "- Priority issues: $priority_count"
}

# Execute main function with all arguments
main "$@"
