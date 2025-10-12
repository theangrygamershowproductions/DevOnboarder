#!/bin/bash
# token_expiry_monitor.sh - Comprehensive token expiry monitoring and notification system
# Version: 1.0.0
# Security Level: Tier 3 - Infrastructure Monitoring
# Description: Monitors token expiry across DevOnboarder ecosystem and notifies infrastructure team

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOGS_DIR="$PROJECT_ROOT/logs"
REPORTS_DIR="$PROJECT_ROOT/reports"
NOTIFICATIONS_DIR="$PROJECT_ROOT/notifications"

# Notification thresholds (days)
CRITICAL_THRESHOLD=7    # Immediate action required
WARNING_THRESHOLD=30    # Plan rotation
INFO_THRESHOLD=45       # Monitor closely
TARGET_EXPIRY=90        # Current target expiry (will move to 45)

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
log_monitor() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "$timestamp: TOKEN_MONITOR_$level: $message" >> "$LOGS_DIR/token_monitor.log"
}

log_error() {
    local message="$1"
    echo -e "${RED}ERROR: $message${NC}" >&2
    log_monitor "ERROR" "$message"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}SUCCESS: $message${NC}"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}WARNING: $message${NC}"
}

log_info() {
    local message="$1"
    echo -e "${BLUE}INFO: $message${NC}"
}

log_critical() {
    local message="$1"
    echo -e "${RED}CRITICAL: $message${NC}"
    log_monitor "CRITICAL" "$message"
}

# Infrastructure team notification contacts
INFRASTRUCTURE_TEAM=(
    "@theangrygamershowproductions/infrastructure"
    "@tags-devsecops"
)

# Token classification from DevOnboarder architecture
CICD_TOKENS=(
    "AAR_TOKEN"
    "CI_BOT_TOKEN"
    "CI_ISSUE_AUTOMATION_TOKEN"
    "DEV_ORCHESTRATION_BOT_KEY"
    "PROD_ORCHESTRATION_BOT_KEY"
    "STAGING_ORCHESTRATION_BOT_KEY"
)

RUNTIME_TOKENS=(
    "DISCORD_BOT_TOKEN"
    "DISCORD_CLIENT_SECRET"
    "BOT_JWT"
    "CF_DNS_API_TOKEN"
    "TUNNEL_TOKEN"
)

# External PR maintainer tokens (from our implementation)
MAINTAINER_TOKENS=(
    "EXTERNAL_PR_MAINTAINER_TOKEN"
    "SECURITY_AUDIT_TOKEN"
    "EMERGENCY_OVERRIDE_TOKEN"
)

# Check token expiry using DevOnboarder's token_loader.py
check_token_expiry() {
    local token_name="$1"
    local token_type="$2"

    # Use DevOnboarder's token loader to check token status
    if ! python3 "$SCRIPT_DIR/token_loader.py" validate "$token_name" &>/dev/null; then
        echo "EXPIRED"
        return
    fi

    # For CI/CD tokens, check expiry dates from .tokens files
    if [[ "$token_type" == "cicd" ]]; then
        local token_file="$PROJECT_ROOT/.tokens"
        if [[ -f "$token_file" ]]; then
            if grep -q "^${token_name}=" "$token_file"; then
                local token_value
                token_value=$(grep "^${token_name}=" "$token_file" | cut -d'=' -f2-)

                # Check if it's a placeholder (not a real token)
                if [[ "$token_value" == CHANGE_ME* ]] || [[ "$token_value" == ci_test_* ]]; then
                    echo "PLACEHOLDER"
                    return
                fi

                # Estimate expiry based on DevOnboarder policy (90 days)
                # This is an approximation since GitHub doesn't provide exact expiry
                echo "APPROX_90_DAYS"
                return
            fi
        fi
    fi

    # For runtime tokens, check .env files
    if [[ "$token_type" == "runtime" ]]; then
        local env_file="$PROJECT_ROOT/.env"
        if [[ -f "$env_file" ]]; then
            if grep -q "^${token_name}=" "$env_file"; then
                local token_value
                token_value=$(grep "^${token_name}=" "$env_file" | cut -d'=' -f2-)

                if [[ "$token_value" == CHANGE_ME* ]]; then
                    echo "PLACEHOLDER"
                    return
                fi

                # Runtime tokens typically don't expire, but check for patterns
                echo "RUNTIME_NO_EXPIRY"
                return
            fi
        fi
    fi

    # For maintainer tokens, check our custom storage
    if [[ "$token_type" == "maintainer" ]]; then
        local maintainer_store="$HOME/.config/devonboarder/maintainer_tokens"
        local meta_file="$maintainer_store/${token_name}.meta"

        if [[ -f "$meta_file" ]]; then
            local expiry_date
            expiry_date=$(grep "expires:" "$meta_file" | cut -d: -f2- | sed 's/^ *//')

            if [[ -z "$expiry_date" ]]; then
                echo "NO_EXPIRY_INFO"
                return
            fi

            local current_date
            current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

            local expiry_epoch
            local current_epoch
            expiry_epoch=$(date -d "$expiry_date" +%s 2>/dev/null || echo "0")
            current_epoch=$(date -d "$current_date" +%s)

            if [[ $expiry_epoch -eq 0 ]]; then
                echo "INVALID_DATE"
                return
            fi

            local days_until_expiry=$(( (expiry_epoch - current_epoch) / 86400 ))

            if [[ $days_until_expiry -lt 0 ]]; then
                echo "EXPIRED"
            elif [[ $days_until_expiry -le $CRITICAL_THRESHOLD ]]; then
                echo "CRITICAL_${days_until_expiry}"
            elif [[ $days_until_expiry -le $WARNING_THRESHOLD ]]; then
                echo "WARNING_${days_until_expiry}"
            elif [[ $days_until_expiry -le $INFO_THRESHOLD ]]; then
                echo "INFO_${days_until_expiry}"
            else
                echo "HEALTHY_${days_until_expiry}"
            fi
            return
        fi
    fi

    echo "NOT_FOUND"
}

# Analyze token expiry status
analyze_token_status() {
    local token_name="$1"
    local token_type="$2"
    local status="$3"

    case "$status" in
        "EXPIRED")
            echo "EXPIRED"
            ;;
        "CRITICAL_"*)
            local days="${status#CRITICAL_}"
            echo "CRITICAL:$days"
            ;;
        "WARNING_"*)
            local days="${status#WARNING_}"
            echo "WARNING:$days"
            ;;
        "INFO_"*)
            local days="${status#INFO_}"
            echo "INFO:$days"
            ;;
        "HEALTHY_"*)
            local days="${status#HEALTHY_}"
            echo "HEALTHY:$days"
            ;;
        "APPROX_90_DAYS")
            # Based on DevOnboarder 90-day policy
            if [[ 90 -le $CRITICAL_THRESHOLD ]]; then
                echo "CRITICAL:90"
            elif [[ 90 -le $WARNING_THRESHOLD ]]; then
                echo "WARNING:90"
            elif [[ 90 -le $INFO_THRESHOLD ]]; then
                echo "INFO:90"
            else
                echo "HEALTHY:90"
            fi
            ;;
        "PLACEHOLDER")
            echo "PLACEHOLDER"
            ;;
        "RUNTIME_NO_EXPIRY")
            echo "RUNTIME_NO_EXPIRY"
            ;;
        "NO_EXPIRY_INFO")
            echo "NO_EXPIRY_INFO"
            ;;
        "INVALID_DATE")
            echo "INVALID_DATE"
            ;;
        "NOT_FOUND")
            echo "NOT_FOUND"
            ;;
        *)
            echo "UNKNOWN:$status"
            ;;
    esac
}

# Generate notifications for infrastructure team
generate_notification() {
    local token_name="$1"
    local token_type="$2"
    local status="$3"
    local analysis="$4"

    mkdir -p "$NOTIFICATIONS_DIR"

    local notification_file="$NOTIFICATIONS_DIR/token_expiry_$(date +%Y%m%d_%H%M%S).md"
    local severity="INFO"
    local action_required="Monitor"

    case "$analysis" in
        "EXPIRED")
            severity="CRITICAL"
            action_required="IMMEDIATE ROTATION REQUIRED"
            ;;
        "CRITICAL:"*)
            severity="CRITICAL"
            action_required="URGENT ROTATION REQUIRED"
            ;;
        "WARNING:"*)
            severity="WARNING"
            action_required="PLAN ROTATION"
            ;;
        "INFO:"*)
            severity="INFO"
            action_required="MONITOR CLOSELY"
            ;;
        "PLACEHOLDER")
            severity="WARNING"
            action_required="REPLACE PLACEHOLDER"
            ;;
        "NOT_FOUND")
            severity="WARNING"
            action_required="VERIFY TOKEN EXISTS"
            ;;
    esac

    cat > "$notification_file" << EOF
# 🚨 Token Expiry Alert - Infrastructure Team

**Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Severity:** $severity
**Token:** $token_name
**Type:** $token_type
**Status:** $analysis

## Details

- **Token Name:** $token_name
- **Token Type:** $token_type
- **Current Status:** $status
- **Analysis:** $analysis
- **Action Required:** $action_required

## Infrastructure Team Action Items

EOF

    case "$analysis" in
        "EXPIRED")
            cat >> "$notification_file" << EOF
### IMMEDIATE ACTION REQUIRED
1. **Generate new token** in GitHub (Settings > Developer settings > Personal access tokens)
2. **Update token** in appropriate file:
   - CI/CD tokens: \`.tokens\` file
   - Runtime tokens: \`.env\` file
   - Maintainer tokens: Use maintainer_token_manager.sh
3. **Test token** functionality
4. **Update documentation** if needed
5. **Notify team** of successful rotation

### Security Impact
- **HIGH**: Token has expired and is non-functional
- **Risk**: CI/CD pipelines may fail, external PR operations may be blocked
EOF
            ;;
        "CRITICAL:"*)
            local days="${analysis#CRITICAL:}"
            cat >> "$notification_file" << EOF
### URGENT ACTION REQUIRED
1. **Schedule token rotation** within $days days
2. **Prepare new token** generation
3. **Plan maintenance window** if needed
4. **Backup current configurations**

### Security Impact
- **MEDIUM**: Token expires in $days days
- **Risk**: Service disruption if rotation is delayed
EOF
            ;;
        "WARNING:"*)
            local days="${analysis#WARNING:}"
            cat >> "$notification_file" << EOF
### PLAN ROTATION
1. **Monitor token** expiry countdown
2. **Schedule rotation** within $days days
3. **Prepare rotation procedure**

### Security Impact
- **LOW**: Token expires in $days days
- **Risk**: Minimal immediate impact
EOF
            ;;
        "PLACEHOLDER")
            cat >> "$notification_file" << EOF
### REPLACE PLACEHOLDER TOKEN
1. **Generate real token** to replace placeholder
2. **Update configuration** file
3. **Test functionality**

### Security Impact
- **MEDIUM**: Placeholder token detected
- **Risk**: Service may not function properly
EOF
            ;;
        "NOT_FOUND")
            cat >> "$notification_file" << EOF
### VERIFY TOKEN CONFIGURATION
1. **Check token files** for $token_name
2. **Verify token exists** in GitHub
3. **Update configuration** if missing

### Security Impact
- **LOW**: Token not found in configuration
- **Risk**: Service may not function properly
EOF
            ;;
    esac

    cat >> "$notification_file" << EOF

## Token Information

### Current DevOnboarder Token Policy
- **CI/CD Tokens**: 90-day expiry (target: 45 days)
- **Runtime Tokens**: No expiry (service-dependent)
- **Maintainer Tokens**: 90-day expiry (manual management)

### Token Locations
- **CI/CD Tokens**: \`.tokens\` file (gitignored)
- **Runtime Tokens**: \`.env\` file (gitignored)
- **Maintainer Tokens**: \`~/.config/devonboarder/maintainer_tokens/\` (encrypted)

## Contact Information

**Infrastructure Team:** ${INFRASTRUCTURE_TEAM[*]}
**Security Team:** @tags-devsecops
**Generated By:** Token Expiry Monitor v1.0.0

---
**DevOnboarder Token Management System**
**Notification ID:** $(basename "$notification_file" .md)
EOF

    log_monitor "NOTIFICATION" "Generated $severity notification for $token_name ($analysis)"
    echo "📧 Notification generated: $notification_file"
}

# Send notifications to infrastructure team
send_notifications() {
    local notification_file="$1"

    # Check if we have GitHub CLI available
    if command -v gh &> /dev/null; then
        log_info "Sending notification via GitHub..."

        # Create infrastructure issue for critical notifications
        local severity
        severity=$(grep "Severity:" "$notification_file" | cut -d: -f2- | sed 's/^ *//')

        if [[ "$severity" == "CRITICAL" ]]; then
            local title
            title=$(grep "Token:" "$notification_file" | head -1 | cut -d: -f2- | sed 's/^ *//')
            title="🚨 CRITICAL: Token Expiry Alert - $title"

            local body
            body=$(cat "$notification_file")

            # Create GitHub issue
            if gh issue create \
                --title "$title" \
                --body "$body" \
                --label "infrastructure,security,token-expiry" \
                --assignee "${INFRASTRUCTURE_TEAM[0]#@}"; then

                log_success "Critical notification issue created in GitHub"
            else
                log_warning "Failed to create GitHub issue, notification saved locally"
            fi
        fi
    else
        log_warning "GitHub CLI not available, notification saved locally only"
    fi

    # Additional notification methods can be added here
    # - Slack notifications
    # - Email notifications
    # - PagerDuty alerts
}

# Generate comprehensive expiry report
generate_expiry_report() {
    local report_file="$REPORTS_DIR/token_expiry_report_$(date +%Y%m%d_%H%M%S).md"

    mkdir -p "$REPORTS_DIR"

    log_info "Generating comprehensive token expiry report..."

    cat > "$report_file" << EOF
# Token Expiry Status Report
Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Executive Summary

This report provides a comprehensive overview of token expiry status across the DevOnboarder ecosystem, including CI/CD automation tokens, runtime service tokens, and external PR maintainer tokens.

## Token Expiry Thresholds

- **Critical (< 7 days)**: Immediate action required
- **Warning (7-30 days)**: Plan rotation soon
- **Info (30-45 days)**: Monitor closely
- **Healthy (> 45 days)**: No action needed

## CI/CD Automation Tokens

These tokens are used for build, deployment, and automation processes. They follow a 90-day expiry policy (target: 45 days).

EOF

    local critical_count=0
    local warning_count=0
    local info_count=0
    local healthy_count=0
    local expired_count=0
    local placeholder_count=0

    # Check CI/CD tokens
    for token in "${CICD_TOKENS[@]}"; do
        local status
        status=$(check_token_expiry "$token" "cicd")
        local analysis
        analysis=$(analyze_token_status "$token" "cicd" "$status")

        echo "### $token" >> "$report_file"
        echo "- **Status:** $analysis" >> "$report_file"

        case "$analysis" in
            "EXPIRED")
                echo "- **Action:** 🚨 IMMEDIATE ROTATION REQUIRED" >> "$report_file"
                ((expired_count++))
                ;;
            "CRITICAL:"*)
                echo "- **Action:** 🔴 URGENT ROTATION REQUIRED" >> "$report_file"
                ((critical_count++))
                ;;
            "WARNING:"*)
                echo "- **Action:** 🟡 PLAN ROTATION" >> "$report_file"
                ((warning_count++))
                ;;
            "INFO:"*)
                echo "- **Action:** 🟢 MONITOR CLOSELY" >> "$report_file"
                ((info_count++))
                ;;
            "PLACEHOLDER")
                echo "- **Action:** 🟡 REPLACE PLACEHOLDER" >> "$report_file"
                ((placeholder_count++))
                ;;
            "APPROX_90_DAYS")
                echo "- **Action:** ✅ HEALTHY (90-day policy)" >> "$report_file"
                ((healthy_count++))
                ;;
            *)
                echo "- **Action:** ❓ STATUS UNKNOWN" >> "$report_file"
                ;;
        esac
        echo "" >> "$report_file"
    done

    cat >> "$report_file" << EOF
## Runtime Service Tokens

These tokens are used for application services and typically do not expire automatically.

EOF

    # Check runtime tokens
    for token in "${RUNTIME_TOKENS[@]}"; do
        local status
        status=$(check_token_expiry "$token" "runtime")
        local analysis
        analysis=$(analyze_token_status "$token" "runtime" "$status")

        echo "### $token" >> "$report_file"
        echo "- **Status:** $analysis" >> "$report_file"

        case "$analysis" in
            "PLACEHOLDER")
                echo "- **Action:** 🟡 REPLACE PLACEHOLDER" >> "$report_file"
                ((placeholder_count++))
                ;;
            "RUNTIME_NO_EXPIRY")
                echo "- **Action:** ✅ NO EXPIRY (service-dependent)" >> "$report_file"
                ((healthy_count++))
                ;;
            "NOT_FOUND")
                echo "- **Action:** 🟡 VERIFY CONFIGURATION" >> "$report_file"
                ;;
            *)
                echo "- **Action:** ❓ STATUS UNKNOWN" >> "$report_file"
                ;;
        esac
        echo "" >> "$report_file"
    done

    cat >> "$report_file" << EOF
## External PR Maintainer Tokens

These tokens are used for manual maintainer interventions in external PR operations.

EOF

    # Check maintainer tokens
    for token in "${MAINTAINER_TOKENS[@]}"; do
        local status
        status=$(check_token_expiry "$token" "maintainer")
        local analysis
        analysis=$(analyze_token_status "$token" "maintainer" "$status")

        echo "### $token" >> "$report_file"
        echo "- **Status:** $analysis" >> "$report_file"

        case "$analysis" in
            "EXPIRED")
                echo "- **Action:** 🚨 IMMEDIATE ROTATION REQUIRED" >> "$report_file"
                ((expired_count++))
                ;;
            "CRITICAL:"*)
                echo "- **Action:** 🔴 URGENT ROTATION REQUIRED" >> "$report_file"
                ((critical_count++))
                ;;
            "WARNING:"*)
                echo "- **Action:** 🟡 PLAN ROTATION" >> "$report_file"
                ((warning_count++))
                ;;
            "INFO:"*)
                echo "- **Action:** 🟢 MONITOR CLOSELY" >> "$report_file"
                ((info_count++))
                ;;
            "NO_EXPIRY_INFO")
                echo "- **Action:** 🟡 ADD EXPIRY TRACKING" >> "$report_file"
                ;;
            "NOT_FOUND")
                echo "- **Action:** 🟡 CREATE TOKEN" >> "$report_file"
                ;;
            *)
                echo "- **Action:** ❓ STATUS UNKNOWN" >> "$report_file"
                ;;
        esac
        echo "" >> "$report_file"
    done

    # Summary statistics
    cat >> "$report_file" << EOF
## Summary Statistics

### Status Overview
- **Expired Tokens:** $expired_count
- **Critical (< 7 days):** $critical_count
- **Warning (7-30 days):** $warning_count
- **Info (30-45 days):** $info_count
- **Healthy (> 45 days):** $healthy_count
- **Placeholders:** $placeholder_count

### Action Priority Matrix

EOF

    if [[ $expired_count -gt 0 ]]; then
        echo "#### 🚨 CRITICAL PRIORITY" >> "$report_file"
        echo "- **$expired_count token(s) have expired** and require immediate rotation" >> "$report_file"
        echo "- **Impact:** CI/CD pipelines may fail, external PR operations blocked" >> "$report_file"
        echo "" >> "$report_file"
    fi

    if [[ $critical_count -gt 0 ]]; then
        echo "#### 🔴 HIGH PRIORITY" >> "$report_file"
        echo "- **$critical_count token(s) expire within 7 days** and need urgent rotation" >> "$report_file"
        echo "- **Impact:** Service disruption risk increasing" >> "$report_file"
        echo "" >> "$report_file"
    fi

    if [[ $warning_count -gt 0 ]]; then
        echo "#### 🟡 MEDIUM PRIORITY" >> "$report_file"
        echo "- **$warning_count token(s) expire within 30 days** - plan rotation" >> "$report_file"
        echo "- **Impact:** Schedule maintenance windows" >> "$report_file"
        echo "" >> "$report_file"
    fi

    if [[ $info_count -gt 0 ]]; then
        echo "#### 🟢 LOW PRIORITY" >> "$report_file"
        echo "- **$info_count token(s) expire within 45 days** - monitor closely" >> "$report_file"
        echo "- **Impact:** Track for upcoming rotation" >> "$report_file"
        echo "" >> "$report_file"
    fi

    cat >> "$report_file" << EOF
## Recommendations

### Immediate Actions
EOF

    if [[ $expired_count -gt 0 || $critical_count -gt 0 ]]; then
        echo "- **URGENT:** Rotate expired and critical tokens immediately" >> "$report_file"
        echo "- **Schedule maintenance** for token rotation" >> "$report_file"
        echo "- **Test all services** after rotation" >> "$report_file"
    fi

    if [[ $warning_count -gt 0 ]]; then
        echo "- **Plan token rotation** for warning tokens within maintenance windows" >> "$report_file"
        echo "- **Prepare new tokens** in advance" >> "$report_file"
    fi

    cat >> "$report_file" << EOF
- **Replace all placeholder tokens** with real values
- **Implement automated monitoring** for token expiry
- **Consider moving to 45-day expiry** once processes are stable
- **Document token rotation procedures** for team knowledge

### Process Improvements
- **Automate token expiry alerts** via infrastructure monitoring
- **Implement token rotation checklists** for consistency
- **Add token health checks** to CI/CD pipelines
- **Create token rotation calendar** for planning

## Token Policy Information

### Current Policy
- **CI/CD Tokens:** 90-day expiry (repository-level automation tokens)
- **Runtime Tokens:** Service-dependent (typically no expiry)
- **Maintainer Tokens:** 90-day expiry (manual management)

### Target Policy (Future)
- **All Tokens:** 45-day expiry once processes are optimized
- **Automated Alerts:** 30-day, 14-day, 7-day, 1-day notifications
- **Self-Service Rotation:** Infrastructure team can rotate without external coordination

## Infrastructure Team Contacts

${INFRASTRUCTURE_TEAM[*]}

## Report Details

- **Generated By:** Token Expiry Monitor v1.0.0
- **Report ID:** $(basename "$report_file" .md)
- **Data Sources:** DevOnboarder token_loader.py, maintainer token store, configuration files
- **Monitoring Frequency:** Recommended weekly or as needed

---
**DevOnboarder Token Management System**
**Report Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

    log_success "Comprehensive expiry report generated: $report_file"
    echo "📊 Report saved to: $report_file"

    # Generate notifications for critical issues
    if [[ $expired_count -gt 0 || $critical_count -gt 0 ]]; then
        log_warning "Critical token issues detected - generating notifications"
        generate_critical_notifications "$report_file"
    fi
}

# Generate critical notifications for infrastructure team
generate_critical_notifications() {
    local report_file="$1"

    log_info "Generating critical notifications for infrastructure team..."

    # Extract critical tokens from report
    local critical_tokens=()
    while IFS= read -r line; do
        if [[ "$line" == *"### "* ]] && [[ "$line" == *"EXTERNAL_PR_MAINTAINER_TOKEN"* || "$line" == *"SECURITY_AUDIT_TOKEN"* || "$line" == *"EMERGENCY_OVERRIDE_TOKEN"* ]]; then
            local token_name="${line### }"
            token_name="${token_name%% *}"
            critical_tokens+=("$token_name")
        fi
    done < <(grep -A 2 "### EXTERNAL_PR_MAINTAINER_TOKEN\|### SECURITY_AUDIT_TOKEN\|### EMERGENCY_OVERRIDE_TOKEN" "$report_file")

    # Generate individual notifications
    for token in "${critical_tokens[@]}"; do
        local status
        status=$(check_token_expiry "$token" "maintainer")
        local analysis
        analysis=$(analyze_token_status "$token" "maintainer" "$status")

        if [[ "$analysis" == "EXPIRED" || "$analysis" == CRITICAL:* ]]; then
            generate_notification "$token" "maintainer" "$status" "$analysis"
        fi
    done

    # Send all notifications
    for notification_file in "$NOTIFICATIONS_DIR"/*.md; do
        if [[ -f "$notification_file" ]]; then
            send_notifications "$notification_file"
        fi
    done
}

# Interactive menu
show_menu() {
    echo
    echo "=== Token Expiry Monitor ==="
    echo "Security Level: Tier 3 - Infrastructure Monitoring"
    echo
    echo "Available operations:"
    echo "1. Check Single Token Expiry"
    echo "2. Monitor All Tokens"
    echo "3. Generate Expiry Report"
    echo "4. Check CI/CD Tokens Only"
    echo "5. Check Runtime Tokens Only"
    echo "6. Check Maintainer Tokens Only"
    echo "7. View Recent Notifications"
    echo "8. Exit"
    echo
}

# Main menu handler
handle_menu_choice() {
    local choice="$1"

    case "$choice" in
        1) # Check Single Token Expiry
            read -p "Enter token name: " token_name
            echo "Token types: cicd, runtime, maintainer"
            read -p "Enter token type: " token_type

            local status
            status=$(check_token_expiry "$token_name" "$token_type")
            local analysis
            analysis=$(analyze_token_status "$token_name" "$token_type" "$status")

            echo "Token: $token_name"
            echo "Type: $token_type"
            echo "Status: $status"
            echo "Analysis: $analysis"
            ;;
        2) # Monitor All Tokens
            echo "Monitoring all token categories..."
            echo

            echo "=== CI/CD Tokens ==="
            for token in "${CICD_TOKENS[@]}"; do
                local status
                status=$(check_token_expiry "$token" "cicd")
                local analysis
                analysis=$(analyze_token_status "$token" "cicd" "$status")
                printf "%-30s %-15s %s\n" "$token" "$status" "$analysis"
            done

            echo
            echo "=== Runtime Tokens ==="
            for token in "${RUNTIME_TOKENS[@]}"; do
                local status
                status=$(check_token_expiry "$token" "runtime")
                local analysis
                analysis=$(analyze_token_status "$token" "runtime" "$status")
                printf "%-30s %-15s %s\n" "$token" "$status" "$analysis"
            done

            echo
            echo "=== Maintainer Tokens ==="
            for token in "${MAINTAINER_TOKENS[@]}"; do
                local status
                status=$(check_token_expiry "$token" "maintainer")
                local analysis
                analysis=$(analyze_token_status "$token" "maintainer" "$status")
                printf "%-30s %-15s %s\n" "$token" "$status" "$analysis"
            done
            ;;
        3) # Generate Expiry Report
            generate_expiry_report
            ;;
        4) # Check CI/CD Tokens Only
            echo "=== CI/CD Token Status ==="
            for token in "${CICD_TOKENS[@]}"; do
                local status
                status=$(check_token_expiry "$token" "cicd")
                local analysis
                analysis=$(analyze_token_status "$token" "cicd" "$status")
                printf "%-30s %-15s %s\n" "$token" "$status" "$analysis"
            done
            ;;
        5) # Check Runtime Tokens Only
            echo "=== Runtime Token Status ==="
            for token in "${RUNTIME_TOKENS[@]}"; do
                local status
                status=$(check_token_expiry "$token" "runtime")
                local analysis
                analysis=$(analyze_token_status "$token" "runtime" "$status")
                printf "%-30s %-15s %s\n" "$token" "$status" "$analysis"
            done
            ;;
        6) # Check Maintainer Tokens Only
            echo "=== Maintainer Token Status ==="
            for token in "${MAINTAINER_TOKENS[@]}"; do
                local status
                status=$(check_token_expiry "$token" "maintainer")
                local analysis
                analysis=$(analyze_token_status "$token" "maintainer" "$status")
                printf "%-30s %-15s %s\n" "$token" "$status" "$analysis"
            done
            ;;
        7) # View Recent Notifications
            echo "Recent notifications:"
            echo "===================="
            if [[ -d "$NOTIFICATIONS_DIR" ]]; then
                ls -la "$NOTIFICATIONS_DIR"/*.md 2>/dev/null | head -10 || echo "No notifications found"
            else
                echo "No notifications directory found"
            fi
            ;;
        8) # Exit
            echo "Exiting token expiry monitor"
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
    mkdir -p "$LOGS_DIR"
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$NOTIFICATIONS_DIR"

    log_info "Token expiry monitor started"
    log_info "Monitoring thresholds: Critical=${CRITICAL_THRESHOLD}d, Warning=${WARNING_THRESHOLD}d, Info=${INFO_THRESHOLD}d"

    # Interactive mode
    while true; do
        show_menu
        read -p "Enter your choice (1-8): " choice
        handle_menu_choice "$choice"
        echo
        read -p "Press Enter to continue..."
    done
}

# Command-line mode
if [[ $# -gt 0 ]]; then
    case "$1" in
        "check")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 check <token_name> <token_type>"
                exit 1
            fi
            status=$(check_token_expiry "$2" "$3")
            analysis=$(analyze_token_status "$2" "$3" "$status")
            echo "$2: $status -> $analysis"
            ;;
        "monitor-all")
            handle_menu_choice "2"
            ;;
        "report")
            generate_expiry_report
            ;;
        "cicd-only")
            handle_menu_choice "4"
            ;;
        "runtime-only")
            handle_menu_choice "5"
            ;;
        "maintainer-only")
            handle_menu_choice "6"
            ;;
        *)
            echo "Usage: $0 [command] [args...]"
            echo "Commands:"
            echo "  check <name> <type>     - Check single token expiry"
            echo "  monitor-all             - Monitor all token categories"
            echo "  report                  - Generate comprehensive report"
            echo "  cicd-only               - Check CI/CD tokens only"
            echo "  runtime-only            - Check runtime tokens only"
            echo "  maintainer-only         - Check maintainer tokens only"
            echo "  (no args for interactive mode)"
            exit 1
            ;;
    esac
else
    main
fi