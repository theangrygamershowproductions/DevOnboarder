#!/bin/bash
# token_expiry_scheduler.sh - Scheduled token expiry monitoring for DevOnboarder
# Version: 1.0.0
# Security Level: Tier 3 - Infrastructure Monitoring
# Description: Automated scheduler for token expiry monitoring and notifications

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCHEDULER_CONFIG="$PROJECT_ROOT/.token_scheduler.conf"
LOG_FILE="$PROJECT_ROOT/logs/token_scheduler.log"
PID_FILE="$PROJECT_ROOT/.token_scheduler.pid"

# Default schedule (cron format)
DEFAULT_SCHEDULE="0 */6 * * *"  # Every 6 hours
DEFAULT_REPORT_SCHEDULE="0 9 * * 1"  # Weekly on Monday at 9 AM

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_scheduler() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "$timestamp: SCHEDULER_$level: $message" >> "$LOG_FILE"
    echo "$timestamp: SCHEDULER_$level: $message" >&2
}

log_error() {
    local message="$1"
    echo -e "${RED}ERROR: $message${NC}" >&2
    log_scheduler "ERROR" "$message"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}SUCCESS: $message${NC}"
    log_scheduler "SUCCESS" "$message"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}WARNING: $message${NC}"
    log_scheduler "WARNING" "$message"
}

log_info() {
    local message="$1"
    echo -e "${BLUE}INFO: $message${NC}"
    log_scheduler "INFO" "$message"
}

# Load configuration
load_config() {
    if [[ -f "$SCHEDULER_CONFIG" ]]; then
        source "$SCHEDULER_CONFIG"
    else
        # Create default configuration
        cat > "$SCHEDULER_CONFIG" << EOF
# Token Expiry Scheduler Configuration
# Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Monitoring schedule (cron format)
MONITOR_SCHEDULE="$DEFAULT_SCHEDULE"

# Report generation schedule (cron format)
REPORT_SCHEDULE="$DEFAULT_REPORT_SCHEDULE"

# Notification settings
ENABLE_NOTIFICATIONS=true
NOTIFICATION_EMAIL=""
NOTIFICATION_SLACK_WEBHOOK=""

# Infrastructure team contacts
INFRA_TEAM="@theangrygamershowproductions/infrastructure"
DEVSECOPS_TEAM="@tags-devsecops"

# Monitoring thresholds (days)
CRITICAL_THRESHOLD=7
WARNING_THRESHOLD=30
INFO_THRESHOLD=45

# Enable debug mode
DEBUG_MODE=false

# Lock file location
LOCK_FILE="/tmp/token_scheduler.lock"
EOF
        log_info "Created default scheduler configuration: $SCHEDULER_CONFIG"
    fi
}

# Check if another instance is running
check_instance() {
    if [[ -f "$PID_FILE" ]]; then
        local existing_pid
        existing_pid=$(cat "$PID_FILE")

        if kill -0 "$existing_pid" 2>/dev/null; then
            log_warning "Another scheduler instance is running (PID: $existing_pid)"
            return 1
        else
            log_warning "Removing stale PID file (PID: $existing_pid)"
            rm -f "$PID_FILE"
        fi
    fi

    echo $$ > "$PID_FILE"
    return 0
}

# Cleanup function
cleanup() {
    local exit_code=$?
    rm -f "$PID_FILE"
    log_info "Scheduler shutdown (exit code: $exit_code)"
    exit $exit_code
}

# Trap signals
trap cleanup EXIT INT TERM

# Check if current time matches cron schedule
matches_schedule() {
    local cron_schedule="$1"
    local current_time
    current_time=$(date +"%M %H %d %m %w")

    # Use a simple cron parser (basic implementation)
    # This is a simplified version - for production, consider using a proper cron parser

    # Parse cron fields: minute hour day month weekday
    local cron_parts
    IFS=' ' read -ra cron_parts <<< "$cron_schedule"

    local current_minute current_hour current_day current_month current_weekday
    IFS=' ' read -ra current_parts <<< "$current_time"

    local cron_minute="${cron_parts[0]}"
    local cron_hour="${cron_parts[1]}"
    local cron_day="${cron_parts[2]}"
    local cron_month="${cron_parts[3]}"
    local cron_weekday="${cron_parts[4]}"

    # Check each field
    if [[ "$cron_minute" != "*" && "$cron_minute" != "${current_parts[0]}" ]]; then return 1; fi
    if [[ "$cron_hour" != "*" && "$cron_hour" != "${current_parts[1]}" ]]; then return 1; fi
    if [[ "$cron_day" != "*" && "$cron_day" != "${current_parts[2]}" ]]; then return 1; fi
    if [[ "$cron_month" != "*" && "$cron_month" != "${current_parts[3]}" ]]; then return 1; fi
    if [[ "$cron_weekday" != "*" && "$cron_weekday" != "${current_parts[4]}" ]]; then return 1; fi

    return 0
}

# Run monitoring cycle
run_monitoring_cycle() {
    log_info "Starting scheduled monitoring cycle"

    local integrator_script="$SCRIPT_DIR/token_expiry_integrator.py"

    if [[ ! -f "$integrator_script" ]]; then
        log_error "Token expiry integrator script not found: $integrator_script"
        return 1
    fi

    # Run the monitoring cycle
    if python3 "$integrator_script" cycle; then
        log_success "Monitoring cycle completed successfully"
        return 0
    else
        log_error "Monitoring cycle failed"
        return 1
    fi
}

# Run report generation
run_report_generation() {
    log_info "Starting scheduled report generation"

    local integrator_script="$SCRIPT_DIR/token_expiry_integrator.py"

    if [[ ! -f "$integrator_script" ]]; then
        log_error "Token expiry integrator script not found: $integrator_script"
        return 1
    fi

    # Generate comprehensive report
    if python3 "$integrator_script" report; then
        log_success "Report generation completed successfully"
        return 0
    else
        log_error "Report generation failed"
        return 1
    fi
}

# Send notifications (if enabled)
send_notifications() {
    if [[ "${ENABLE_NOTIFICATIONS:-false}" != "true" ]]; then
        return 0
    fi

    log_info "Checking for notifications to send"

    local notification_dir="$PROJECT_ROOT/notifications"

    if [[ ! -d "$notification_dir" ]]; then
        log_warning "Notification directory not found: $notification_dir"
        return 0
    fi

    # Find recent critical notifications (last 24 hours)
    local recent_notifications
    recent_notifications=$(find "$notification_dir" -name "*.md" -mtime -1 2>/dev/null | wc -l)

    if [[ $recent_notifications -gt 0 ]]; then
        log_info "Found $recent_notifications recent notifications"

        # Send email notification if configured
        if [[ -n "${NOTIFICATION_EMAIL:-}" ]]; then
            log_info "Sending email notification to: $NOTIFICATION_EMAIL"

            # Create email content
            local email_subject="🚨 DevOnboarder Token Expiry Alert - $recent_notifications Critical Issues"
            local email_body="Critical token expiry issues detected in DevOnboarder ecosystem.

Recent notifications: $recent_notifications
Notification directory: $notification_dir
Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

Please review the notifications and take appropriate action.

Infrastructure Team: $INFRA_TEAM
DevSecOps Team: $DEVSECOPS_TEAM

---
DevOnboarder Token Expiry Scheduler v1.0.0"

            # Send email (using mail command if available)
            if command -v mail &> /dev/null; then
                echo "$email_body" | mail -s "$email_subject" "$NOTIFICATION_EMAIL"
                log_success "Email notification sent"
            else
                log_warning "Mail command not available, skipping email notification"
            fi
        fi

        # Send Slack notification if configured
        if [[ -n "${NOTIFICATION_SLACK_WEBHOOK:-}" ]]; then
            log_info "Sending Slack notification"

            local slack_payload
            slack_payload=$(cat << EOF
{
  "text": "🚨 *DevOnboarder Token Expiry Alert*",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Critical Token Issues Detected*\n\n$recent_notifications token expiry issues require immediate attention."
      }
    },
    {
      "type": "section",
      "fields": [
        {
          "type": "mrkdwn",
          "text": "*Infrastructure Team:*\n$INFRA_TEAM"
        },
        {
          "type": "mrkdwn",
          "text": "*DevSecOps Team:*\n$DEVSECOPS_TEAM"
        }
      ]
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Action Required:*\nReview notifications in: \`$notification_dir\`"
      }
    }
  ]
}
EOF
            )

            # Send Slack notification
            if curl -s -X POST -H 'Content-type: application/json' \
                   --data "$slack_payload" "$NOTIFICATION_SLACK_WEBHOOK" > /dev/null; then
                log_success "Slack notification sent"
            else
                log_warning "Failed to send Slack notification"
            fi
        fi
    else
        log_info "No recent critical notifications found"
    fi
}

# Main scheduler loop
run_scheduler() {
    log_info "Token expiry scheduler started"
    log_info "Monitoring schedule: ${MONITOR_SCHEDULE:-$DEFAULT_SCHEDULE}"
    log_info "Report schedule: ${REPORT_SCHEDULE:-$DEFAULT_REPORT_SCHEDULE}"

    local last_monitor_check=""
    local last_report_check=""

    while true; do
        local current_time
        current_time=$(date +"%Y-%m-%d %H:%M")

        # Check monitoring schedule
        if [[ "$current_time" != "$last_monitor_check" ]] && \
           matches_schedule "${MONITOR_SCHEDULE:-$DEFAULT_SCHEDULE}"; then

            log_info "Running scheduled monitoring cycle"
            if run_monitoring_cycle; then
                send_notifications
            fi
            last_monitor_check="$current_time"
        fi

        # Check report schedule
        if [[ "$current_time" != "$last_report_check" ]] && \
           matches_schedule "${REPORT_SCHEDULE:-$DEFAULT_REPORT_SCHEDULE}"; then

            log_info "Running scheduled report generation"
            run_report_generation
            last_report_check="$current_time"
        fi

        # Sleep for 1 minute before next check
        sleep 60
    done
}

# Interactive menu
show_menu() {
    echo
    echo "=== Token Expiry Scheduler ==="
    echo "Security Level: Tier 3 - Infrastructure Monitoring"
    echo
    echo "Available operations:"
    echo "1. Start Scheduler (daemon mode)"
    echo "2. Run Monitoring Cycle Now"
    echo "3. Generate Report Now"
    echo "4. Check Scheduler Status"
    echo "5. View Configuration"
    echo "6. Edit Configuration"
    echo "7. Stop Running Scheduler"
    echo "8. Exit"
    echo
}

# Handle menu choice
handle_menu_choice() {
    local choice="$1"

    case "$choice" in
        1) # Start Scheduler
            if check_instance; then
                log_info "Starting scheduler in daemon mode"
                run_scheduler &
                disown
                log_success "Scheduler started in background (PID: $$)"
            else
                log_error "Another scheduler instance is already running"
            fi
            ;;
        2) # Run Monitoring Cycle Now
            log_info "Running immediate monitoring cycle"
            if run_monitoring_cycle; then
                send_notifications
                log_success "Monitoring cycle completed"
            else
                log_error "Monitoring cycle failed"
            fi
            ;;
        3) # Generate Report Now
            log_info "Running immediate report generation"
            if run_report_generation; then
                log_success "Report generation completed"
            else
                log_error "Report generation failed"
            fi
            ;;
        4) # Check Scheduler Status
            if [[ -f "$PID_FILE" ]]; then
                local pid
                pid=$(cat "$PID_FILE")
                if kill -0 "$pid" 2>/dev/null; then
                    log_success "Scheduler is running (PID: $pid)"
                    echo "Process details:"
                    ps -p "$pid" -o pid,ppid,cmd,start,time
                else
                    log_warning "Scheduler PID file exists but process is not running"
                    rm -f "$PID_FILE"
                fi
            else
                log_info "Scheduler is not running"
            fi
            ;;
        5) # View Configuration
            if [[ -f "$SCHEDULER_CONFIG" ]]; then
                echo "Current configuration:"
                echo "===================="
                cat "$SCHEDULER_CONFIG"
            else
                log_warning "Configuration file not found"
            fi
            ;;
        6) # Edit Configuration
            if [[ -f "$SCHEDULER_CONFIG" ]]; then
                if command -v nano &> /dev/null; then
                    nano "$SCHEDULER_CONFIG"
                elif command -v vim &> /dev/null; then
                    vim "$SCHEDULER_CONFIG"
                else
                    log_warning "No text editor available (nano/vim)"
                    echo "You can edit the file manually: $SCHEDULER_CONFIG"
                fi
            else
                log_warning "Configuration file not found - run the scheduler first to create it"
            fi
            ;;
        7) # Stop Running Scheduler
            if [[ -f "$PID_FILE" ]]; then
                local pid
                pid=$(cat "$PID_FILE")
                if kill -0 "$pid" 2>/dev/null; then
                    log_info "Stopping scheduler (PID: $pid)"
                    kill "$pid"
                    rm -f "$PID_FILE"
                    log_success "Scheduler stopped"
                else
                    log_warning "Scheduler process not found"
                    rm -f "$PID_FILE"
                fi
            else
                log_info "No scheduler PID file found"
            fi
            ;;
        8) # Exit
            echo "Exiting scheduler"
            exit 0
            ;;
        *)
            log_error "Invalid choice"
            ;;
    esac
}

# Main function
main() {
    # Load configuration
    load_config

    # Create log directory
    mkdir -p "$(dirname "$LOG_FILE")"

    # Command-line mode
    if [[ $# -gt 0 ]]; then
        case "$1" in
            "start")
                if check_instance; then
                    log_info "Starting scheduler in daemon mode"
                    run_scheduler
                fi
                ;;
            "monitor")
                run_monitoring_cycle && send_notifications
                ;;
            "report")
                run_report_generation
                ;;
            "status")
                handle_menu_choice "4"
                ;;
            "stop")
                handle_menu_choice "7"
                ;;
            *)
                echo "Usage: $0 [command]"
                echo "Commands:"
                echo "  start     - Start scheduler in daemon mode"
                echo "  monitor   - Run monitoring cycle immediately"
                echo "  report    - Generate report immediately"
                echo "  status    - Check scheduler status"
                echo "  stop      - Stop running scheduler"
                echo "  (no args for interactive mode)"
                exit 1
                ;;
        esac
    else
        # Interactive mode
        while true; do
            show_menu
            read -p "Enter your choice (1-8): " choice
            handle_menu_choice "$choice"
            echo
            read -p "Press Enter to continue..."
        done
    fi
}

# Run main function
main "$@"