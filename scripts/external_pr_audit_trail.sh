#!/bin/bash
# external_pr_audit_trail.sh - Comprehensive audit trail for external PR operations
# Version: 1.0.0
# Security Level: Tier 3 - Audit & Compliance
# Description: Generates detailed audit reports for external PR security operations

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs"
REPORTS_DIR="$PROJECT_ROOT/reports"
AUDIT_LOG="$LOG_DIR/maintainer_audit.log"
WORKFLOW_LOG="$LOG_DIR/workflow_operations.log"
TOKEN_LOG="$LOG_DIR/token_operations.log"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_audit() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "$timestamp: AUDIT_$level: $message" >> "$AUDIT_LOG"
}

log_error() {
    local message="$1"
    echo -e "${RED}ERROR: $message${NC}" >&2
    log_audit "ERROR" "$message"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}SUCCESS: $message${NC}"
}

log_info() {
    local message="$1"
    echo -e "${BLUE}INFO: $message${NC}"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}WARNING: $message${NC}"
}

# Data collection functions
collect_workflow_data() {
    local days="${1:-30}"

    log_info "Collecting workflow data for last $days days..."

    # Get workflow runs from GitHub CLI
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI not available for workflow data collection"
        return 1
    fi

    # Collect external PR validation workflow runs
    gh run list \
        --workflow="External PR Validation" \
        --limit 100 \
        --json number,createdAt,status,conclusion \
        --jq '.[] | select(.createdAt | fromdate > (now - '"$days"' * 24 * 60 * 60))' \
        > "$REPORTS_DIR/workflow_validation_runs.json" 2>/dev/null || true

    # Collect privileged workflow runs
    gh run list \
        --workflow="External PR Privileged Operations" \
        --limit 100 \
        --json number,createdAt,status,conclusion \
        --jq '.[] | select(.createdAt | fromdate > (now - '"$days"' * 24 * 60 * 60))' \
        > "$REPORTS_DIR/workflow_privileged_runs.json" 2>/dev/null || true

    log_success "Workflow data collected"
}

collect_pr_data() {
    local days="${1:-30}"

    log_info "Collecting PR data for last $days days..."

    # Get recent PRs
    gh pr list \
        --limit 100 \
        --json number,title,author,createdAt,mergedAt,closedAt,labels \
        --jq '.[] | select(.createdAt | fromdate > (now - '"$days"' * 24 * 60 * 60))' \
        > "$REPORTS_DIR/recent_prs.json" 2>/dev/null || true

    # Get external PRs specifically (from forks)
    gh pr list \
        --limit 100 \
        --json number,title,author,headRepository,createdAt,mergedAt,closedAt,labels \
        --jq '.[] | select(.headRepository.isFork == true and (.createdAt | fromdate > (now - '"$days"' * 24 * 60 * 60)))' \
        > "$REPORTS_DIR/external_prs.json" 2>/dev/null || true

    log_success "PR data collected"
}

collect_audit_logs() {
    local days="${1:-30}"

    log_info "Processing audit logs for last $days days..."

    local cutoff_date
    cutoff_date=$(date -u -d "$days days ago" +"%Y-%m-%d")

    # Process maintainer audit log
    if [[ -f "$AUDIT_LOG" ]]; then
        awk -v cutoff="$cutoff_date" '$1 >= cutoff' "$AUDIT_LOG" > "$REPORTS_DIR/audit_log_recent.txt"
    fi

    # Process workflow operations log
    if [[ -f "$WORKFLOW_LOG" ]]; then
        awk -v cutoff="$cutoff_date" '$1 >= cutoff' "$WORKFLOW_LOG" > "$REPORTS_DIR/workflow_log_recent.txt"
    fi

    # Process token operations log
    if [[ -f "$TOKEN_LOG" ]]; then
        awk -v cutoff="$cutoff_date" '$1 >= cutoff' "$TOKEN_LOG" > "$REPORTS_DIR/token_log_recent.txt"
    fi

    log_success "Audit logs processed"
}

# Analysis functions
analyze_security_events() {
    log_info "Analyzing security events..."

    local security_events=0
    local blocked_prs=0
    local emergency_fixes=0

    # Count security blocks
    if [[ -f "$REPORTS_DIR/audit_log_recent.txt" ]]; then
        blocked_prs=$(grep -c "SECURITY_BLOCK" "$REPORTS_DIR/audit_log_recent.txt" || echo "0")
        emergency_fixes=$(grep -c "EMERGENCY_FIX" "$REPORTS_DIR/audit_log_recent.txt" || echo "0")
        security_events=$((blocked_prs + emergency_fixes))
    fi

    # Count failed workflow runs
    local failed_workflows=0
    if [[ -f "$REPORTS_DIR/workflow_validation_runs.json" ]]; then
        failed_workflows=$(jq '[.[] | select(.conclusion == "failure")] | length' "$REPORTS_DIR/workflow_validation_runs.json" 2>/dev/null || echo "0")
    fi

    cat > "$REPORTS_DIR/security_analysis.json" << EOF
{
  "security_events": $security_events,
  "blocked_prs": $blocked_prs,
  "emergency_fixes": $emergency_fixes,
  "failed_workflows": $failed_workflows,
  "analysis_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

    log_success "Security analysis completed"
}

analyze_workflow_performance() {
    log_info "Analyzing workflow performance..."

    local total_runs=0
    local successful_runs=0
    local avg_duration=0

    if [[ -f "$REPORTS_DIR/workflow_validation_runs.json" ]]; then
        total_runs=$(jq length "$REPORTS_DIR/workflow_validation_runs.json" 2>/dev/null || echo "0")
        successful_runs=$(jq '[.[] | select(.conclusion == "success")] | length' "$REPORTS_DIR/workflow_validation_runs.json" 2>/dev/null || echo "0")
    fi

    # Calculate success rate
    local success_rate="0%"
    if [[ $total_runs -gt 0 ]]; then
        success_rate="$((successful_runs * 100 / total_runs))%"
    fi

    cat > "$REPORTS_DIR/workflow_performance.json" << EOF
{
  "total_validation_runs": $total_runs,
  "successful_validation_runs": $successful_runs,
  "success_rate": "$success_rate",
  "analysis_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

    log_success "Workflow performance analysis completed"
}

analyze_pr_trends() {
    log_info "Analyzing PR trends..."

    local total_prs=0
    local external_prs=0
    local merged_prs=0
    local external_merged_prs=0

    if [[ -f "$REPORTS_DIR/recent_prs.json" ]]; then
        total_prs=$(jq length "$REPORTS_DIR/recent_prs.json" 2>/dev/null || echo "0")
        merged_prs=$(jq '[.[] | select(.mergedAt != null)] | length' "$REPORTS_DIR/recent_prs.json" 2>/dev/null || echo "0")
    fi

    if [[ -f "$REPORTS_DIR/external_prs.json" ]]; then
        external_prs=$(jq length "$REPORTS_DIR/external_prs.json" 2>/dev/null || echo "0")
        external_merged_prs=$(jq '[.[] | select(.mergedAt != null)] | length' "$REPORTS_DIR/external_prs.json" 2>/dev/null || echo "0")
    fi

    # Calculate percentages
    local external_percentage="0%"
    local external_merge_percentage="0%"

    if [[ $total_prs -gt 0 ]]; then
        external_percentage="$((external_prs * 100 / total_prs))%"
    fi

    if [[ $external_prs -gt 0 ]]; then
        external_merge_percentage="$((external_merged_prs * 100 / external_prs))%"
    fi

    cat > "$REPORTS_DIR/pr_trends.json" << EOF
{
  "total_prs": $total_prs,
  "external_prs": $external_prs,
  "merged_prs": $merged_prs,
  "external_merged_prs": $external_merged_prs,
  "external_pr_percentage": "$external_percentage",
  "external_merge_rate": "$external_merge_percentage",
  "analysis_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

    log_success "PR trends analysis completed"
}

# Report generation functions
generate_comprehensive_report() {
    local report_file="$REPORTS_DIR/external_pr_audit_report_$(date +%Y%m%d_%H%M%S).md"
    local days="${1:-30}"

    log_info "Generating comprehensive audit report..."

    # Read analysis data
    local security_data="{}"
    local workflow_data="{}"
    local pr_data="{}"

    [[ -f "$REPORTS_DIR/security_analysis.json" ]] && security_data=$(cat "$REPORTS_DIR/security_analysis.json")
    [[ -f "$REPORTS_DIR/workflow_performance.json" ]] && workflow_data=$(cat "$REPORTS_DIR/workflow_performance.json")
    [[ -f "$REPORTS_DIR/pr_trends.json" ]] && pr_data=$(cat "$REPORTS_DIR/pr_trends.json")

    cat > "$report_file" << EOF
# External PR Security Audit Report
Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Reporting Period: Last $days days

## Executive Summary

This report provides a comprehensive audit of external pull request security operations, including workflow performance, security events, and contribution trends.

## Security Overview

### Security Events
- **Total Security Events**: $(echo "$security_data" | jq -r '.security_events // 0')
- **Blocked PRs**: $(echo "$security_data" | jq -r '.blocked_prs // 0')
- **Emergency Fixes Applied**: $(echo "$security_data" | jq -r '.emergency_fixes // 0')
- **Failed Workflow Runs**: $(echo "$security_data" | jq -r '.failed_workflows // 0')

### Risk Assessment
EOF

    # Risk assessment logic
    local blocked_prs
    blocked_prs=$(echo "$security_data" | jq -r '.blocked_prs // 0')
    local failed_workflows
    failed_workflows=$(echo "$security_data" | jq -r '.failed_workflows // 0')

    if [[ $blocked_prs -gt 5 || $failed_workflows -gt 10 ]]; then
        echo "- **HIGH RISK**: Elevated security incidents detected" >> "$report_file"
    elif [[ $blocked_prs -gt 2 || $failed_workflows -gt 5 ]]; then
        echo "- **MEDIUM RISK**: Some security concerns noted" >> "$report_file"
    else
        echo "- **LOW RISK**: Security operations normal" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## Workflow Performance

### Validation Workflows
- **Total Runs**: $(echo "$workflow_data" | jq -r '.total_validation_runs // 0')
- **Successful Runs**: $(echo "$workflow_data" | jq -r '.successful_validation_runs // 0')
- **Success Rate**: $(echo "$workflow_data" | jq -r '.success_rate // "0%"')

### Performance Analysis
EOF

    local success_rate
    success_rate=$(echo "$workflow_data" | jq -r '.success_rate // "0%"' | sed 's/%//')

    if [[ $success_rate -ge 95 ]]; then
        echo "- **EXCELLENT**: High workflow reliability" >> "$report_file"
    elif [[ $success_rate -ge 85 ]]; then
        echo "- **GOOD**: Acceptable workflow performance" >> "$report_file"
    else
        echo "- **CONCERNS**: Workflow reliability needs attention" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## Contribution Trends

### PR Statistics
- **Total PRs**: $(echo "$pr_data" | jq -r '.total_prs // 0')
- **External PRs**: $(echo "$pr_data" | jq -r '.external_prs // 0')
- **External PR Percentage**: $(echo "$pr_data" | jq -r '.external_pr_percentage // "0%"')
- **Merged PRs**: $(echo "$pr_data" | jq -r '.merged_prs // 0')
- **External Merged PRs**: $(echo "$pr_data" | jq -r '.external_merged_prs // 0')
- **External Merge Rate**: $(echo "$pr_data" | jq -r '.external_merge_rate // "0%"')

### Trend Analysis
EOF

    local external_percentage
    external_percentage=$(echo "$pr_data" | jq -r '.external_pr_percentage // "0%"' | sed 's/%//')

    if [[ $external_percentage -gt 50 ]]; then
        echo "- **COMMUNITY DRIVEN**: High external contribution rate" >> "$report_file"
    elif [[ $external_percentage -gt 25 ]]; then
        echo "- **BALANCED**: Good mix of internal and external contributions" >> "$report_file"
    else
        echo "- **INTERNAL FOCUS**: Primarily internal contributions" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## Recent Security Events

### Blocked External PRs
EOF

    if [[ -f "$REPORTS_DIR/audit_log_recent.txt" ]]; then
        grep "SECURITY_BLOCK" "$REPORTS_DIR/audit_log_recent.txt" | head -10 | while read -r line; do
            echo "- $line" >> "$report_file"
        done
    else
        echo "- No blocked PRs in reporting period" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

### Emergency Fixes
EOF

    if [[ -f "$REPORTS_DIR/audit_log_recent.txt" ]]; then
        grep "EMERGENCY_FIX" "$REPORTS_DIR/audit_log_recent.txt" | head -10 | while read -r line; do
            echo "- $line" >> "$report_file"
        done
    else
        echo "- No emergency fixes in reporting period" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## Recommendations

### Security Improvements
EOF

    if [[ $(echo "$security_data" | jq -r '.blocked_prs // 0') -gt 0 ]]; then
        echo "- Review blocked PR patterns to identify common security issues" >> "$report_file"
    fi

    if [[ $(echo "$workflow_data" | jq -r '.success_rate // "0%"' | sed 's/%//') -lt 90 ]]; then
        echo "- Investigate workflow failures to improve reliability" >> "$report_file"
    fi

    cat >> "$report_file" << EOF
- Regular security training for maintainers handling external PRs
- Automated alerts for security events and workflow failures

### Process Improvements
- Consider CODEOWNERS integration for automatic reviewer assignment
- Implement PR size limits for external contributions
- Add automated dependency vulnerability scanning

### Monitoring Enhancements
- Set up alerts for workflow failure rates above 10%
- Monitor external PR merge rates for quality assurance
- Track maintainer response times for external PRs

## Raw Data Files

The following data files were generated for this report:
- \`security_analysis.json\` - Security event analysis
- \`workflow_performance.json\` - Workflow performance metrics
- \`pr_trends.json\` - PR contribution trends
- \`audit_log_recent.txt\` - Recent audit log entries
- \`workflow_log_recent.txt\` - Recent workflow operations
- \`token_log_recent.txt\` - Recent token operations

## Report Generation Details

- **Generated By**: $(whoami)@$(hostname)
- **Script Version**: 1.0.0
- **Data Collection Method**: GitHub CLI API calls
- **Analysis Period**: $days days
- **Report ID**: $(basename "$report_file")

---
**DevOnboarder External PR Security Audit System**
**Report Generated**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

    log_success "Comprehensive audit report generated: $report_file"
    echo "Report saved to: $report_file"
}

generate_security_incident_report() {
    local report_file="$REPORTS_DIR/security_incidents_$(date +%Y%m%d_%H%M%S).md"
    local days="${1:-30}"

    log_info "Generating security incident report..."

    cat > "$report_file" << EOF
# Security Incident Report - External PR Operations
Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Reporting Period: Last $days days

## Security Incidents

### Blocked External PRs
EOF

    if [[ -f "$REPORTS_DIR/audit_log_recent.txt" ]]; then
        local incident_count=0
        while read -r line; do
            if echo "$line" | grep -q "SECURITY_BLOCK"; then
                echo "#### Incident #$((++incident_count))" >> "$report_file"
                echo "- **Timestamp**: $(echo "$line" | cut -d' ' -f1)" >> "$report_file"
                echo "- **Details**: $(echo "$line" | cut -d' ' -f3-)" >> "$report_file"
                echo "" >> "$report_file"
            fi
        done < "$REPORTS_DIR/audit_log_recent.txt"
    fi

    cat >> "$report_file" << EOF
### Failed Security Validations
EOF

    if [[ -f "$REPORTS_DIR/workflow_validation_runs.json" ]]; then
        jq -r '.[] | select(.conclusion == "failure") | "- \(.createdAt): Workflow run #\(.number) failed"' "$REPORTS_DIR/workflow_validation_runs.json" 2>/dev/null >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## Incident Response Summary

### Total Incidents: $incident_count
### Response Actions Required:
EOF

    if [[ $incident_count -gt 0 ]]; then
        echo "- Review each blocked PR for false positives" >> "$report_file"
        echo "- Update security policies based on incident patterns" >> "$report_file"
        echo "- Notify security team of elevated incident rates" >> "$report_file"
    else
        echo "- No security incidents in reporting period" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## Prevention Measures

- Enhanced fork detection and validation
- Improved Potato Policy enforcement
- Regular security training for maintainers
- Automated incident alerting

---
**Security Incident Report**
**Generated**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

    log_success "Security incident report generated: $report_file"
    echo "Report saved to: $report_file"
}

# Interactive menu
show_menu() {
    echo
    echo "=== External PR Audit Trail System ==="
    echo "Security Level: Tier 3 - Audit & Compliance"
    echo
    echo "Available operations:"
    echo "1. Generate Full Audit Report"
    echo "2. Generate Security Incident Report"
    echo "3. Collect Current Data"
    echo "4. Analyze Security Events"
    echo "5. Analyze Workflow Performance"
    echo "6. Analyze PR Trends"
    echo "7. View Recent Audit Logs"
    echo "8. Exit"
    echo
}

# Main menu handler
handle_menu_choice() {
    local choice="$1"
    local days="${2:-30}"

    case "$choice" in
        1) # Generate Full Audit Report
            collect_audit_logs "$days"
            collect_workflow_data "$days"
            collect_pr_data "$days"
            analyze_security_events
            analyze_workflow_performance
            analyze_pr_trends
            generate_comprehensive_report "$days"
            ;;
        2) # Generate Security Incident Report
            collect_audit_logs "$days"
            collect_workflow_data "$days"
            analyze_security_events
            generate_security_incident_report "$days"
            ;;
        3) # Collect Current Data
            collect_audit_logs "$days"
            collect_workflow_data "$days"
            collect_pr_data "$days"
            log_success "Data collection completed"
            ;;
        4) # Analyze Security Events
            collect_audit_logs "$days"
            analyze_security_events
            log_success "Security analysis completed"
            ;;
        5) # Analyze Workflow Performance
            collect_workflow_data "$days"
            analyze_workflow_performance
            log_success "Workflow analysis completed"
            ;;
        6) # Analyze PR Trends
            collect_pr_data "$days"
            analyze_pr_trends
            log_success "PR trends analysis completed"
            ;;
        7) # View Recent Audit Logs
            echo "Recent audit log entries:"
            echo "========================"
            if [[ -f "$REPORTS_DIR/audit_log_recent.txt" ]]; then
                tail -20 "$REPORTS_DIR/audit_log_recent.txt"
            else
                echo "No recent audit logs found. Run data collection first."
            fi
            ;;
        8) # Exit
            echo "Exiting audit trail system"
            exit 0
            ;;
        *)
            log_error "Invalid choice"
            ;;
    esac
}

# Main function
main() {
    # Create directories
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$LOG_DIR"

    log_info "Audit trail system started"

    # Interactive mode
    while true; do
        show_menu
        read -p "Enter your choice (1-8): " choice
        read -p "Enter reporting period in days (default: 30): " days
        days="${days:-30}"
        handle_menu_choice "$choice" "$days"
        echo
        read -p "Press Enter to continue..."
    done
}

# Command-line mode
if [[ $# -gt 0 ]]; then
    case "$1" in
        "full-report")
            days="${2:-30}"
            handle_menu_choice "1" "$days"
            ;;
        "security-report")
            days="${2:-30}"
            handle_menu_choice "2" "$days"
            ;;
        "collect-data")
            days="${2:-30}"
            handle_menu_choice "3" "$days"
            ;;
        "analyze-security")
            days="${2:-30}"
            handle_menu_choice "4" "$days"
            ;;
        "analyze-workflows")
            days="${2:-30}"
            handle_menu_choice "5" "$days"
            ;;
        "analyze-prs")
            days="${2:-30}"
            handle_menu_choice "6" "$days"
            ;;
        "view-logs")
            handle_menu_choice "7"
            ;;
        *)
            echo "Usage: $0 [command] [days]"
            echo "Commands:"
            echo "  full-report [days]      - Generate comprehensive audit report"
            echo "  security-report [days]  - Generate security incident report"
            echo "  collect-data [days]     - Collect current audit data"
            echo "  analyze-security [days] - Analyze security events"
            echo "  analyze-workflows [days]- Analyze workflow performance"
            echo "  analyze-prs [days]      - Analyze PR trends"
            echo "  view-logs              - View recent audit logs"
            echo "  (no args for interactive mode)"
            exit 1
            ;;
    esac
else
    main
fi