#!/bin/bash

# scripts/mvp_health_monitor.sh
# Continuous health monitoring for MVP services

set -e

# Configuration
MONITOR_INTERVAL=${MONITOR_INTERVAL:-30}  # seconds
LOG_FILE=${LOG_FILE:-"logs/mvp_health_monitor.log"}
ALERT_THRESHOLD=${ALERT_THRESHOLD:-3}     # consecutive failures before alert

# Create logs directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Initialize counters
declare -A failure_counts
declare -A last_status

echo "HOSPITAL: DevOnboarder MVP Health Monitor Started"
echo "=========================================="
echo "Monitor interval: ${MONITOR_INTERVAL}s"
echo "Log file: $LOG_FILE"
echo "Alert threshold: $ALERT_THRESHOLD consecutive failures"
echo "Timestamp: $(date)"
echo

# Helper function to log with timestamp
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Health check function
check_service_health() {
    local service_name="$1"
    local check_command="$2"
    local expected_pattern="$3"

    if output=$(eval "$check_command" 2>&1); then
        if [[ -z "$expected_pattern" ]] || echo "$output" | grep -q "$expected_pattern"; then
            # Success - reset failure count
            failure_counts["$service_name"]=0
            if [[ "${last_status[$service_name]}" != "HEALTHY" ]]; then
                log_message "INFO" "$service_name: RECOVERED - Service is now healthy"
            fi
            last_status["$service_name"]="HEALTHY"
            return 0
        else
            # Unexpected output
            failure_counts["$service_name"]=$((${failure_counts[$service_name]:-0}  1))
            log_message "WARN" "$service_name: UNHEALTHY - Unexpected output: $(echo "$output" | head -1)"
            return 1
        fi
    else
        # Command failed
        failure_counts["$service_name"]=$((${failure_counts[$service_name]:-0}  1))
        log_message "ERROR" "$service_name: FAILED - Command error: $(echo "$output" | head -1)"
        return 1
    fi
}

# Alert function
send_alert() {
    local service_name="$1"
    local failure_count="$2"

    log_message "ALERT" "$service_name: CRITICAL - $failure_count consecutive failures detected!"

    # If GitHub CLI is available, create an issue
    if command -v gh >/dev/null 2>&1; then
        gh issue create \
            --title "🚨 MVP Health Alert: $service_name Service Failure" \
            --body "**Service**: $service_name
**Failure Count**: $failure_count consecutive failures
**Timestamp**: $(date)
**Log File**: $LOG_FILE

This is an automated alert from the MVP health monitoring system.

**Next Steps**:
1. Check service logs: \`docker-compose logs $service_name\`
2. Verify service configuration
3. Restart service if necessary: \`docker-compose restart $service_name\`
4. Run full health check: \`bash scripts/mvp_readiness_check.sh\`" \
            --label "bug,critical,mvp,automated" 2>/dev/null || true
    fi
}

# Performance monitoring function
monitor_performance() {
    local timestamp
    timestamp=$(date '%Y-%m-%d %H:%M:%S')

    # API response times
    auth_time=$(curl -w '%{time_total}' -s -o /dev/null http://localhost:8002/health 2>/dev/null || echo "999")
    xp_time=$(curl -w '%{time_total}' -s -o /dev/null http://localhost:8001/health 2>/dev/null || echo "999")

    # Memory usage
    memory_usage=$(free -m | awk 'NR==2{printf "%.1f", $3*100/$2}')

    # Log performance metrics
    echo "[$timestamp] [PERF] Auth API: ${auth_time}s, XP API: ${xp_time}s, Memory: ${memory_usage}%" >> "$LOG_FILE"

    # Alert on performance issues
    if (( $(echo "$auth_time > 5.0" | bc -l 2>/dev/null || echo 0) )); then
        log_message "WARN" "Auth API slow response: ${auth_time}s"
    fi

    if (( $(echo "$xp_time > 5.0" | bc -l 2>/dev/null || echo 0) )); then
        log_message "WARN" "XP API slow response: ${xp_time}s"
    fi
}

# System resource monitoring
monitor_resources() {
    local timestamp
    timestamp=$(date '%Y-%m-%d %H:%M:%S')

    # Disk usage
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

    # CPU load
    cpu_load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')

    # Docker container status
    container_count=$(docker ps --format "table {{.Names}}" | grep -c devonboarder 2>/dev/null || echo 0)

    echo "[$timestamp] [SYS] Disk: ${disk_usage}%, CPU Load: ${cpu_load}, Containers: ${container_count}" >> "$LOG_FILE"

    # Alert on resource issues
    if [[ $disk_usage -gt 90 ]]; then
        log_message "WARN" "High disk usage: ${disk_usage}%"
    fi

    if [[ $container_count -lt 2 ]]; then
        log_message "WARN" "Low container count: $container_count (expected: 2)"
    fi
}

# Trap to handle cleanup on exit
cleanup() {
    log_message "INFO" "Health monitor stopping..."
    exit 0
}

trap cleanup SIGINT SIGTERM

# Main monitoring loop
log_message "INFO" "Health monitoring started"

while true; do
    echo " Health Check - $(date '%H:%M:%S')"

    # Service health checks
    check_service_health "auth-service" "curl -sf http://localhost:8002/health" "healthy\\|ok\\|running"
    check_service_health "xp-api" "curl -sf http://localhost:8001/health" "healthy\\|ok\\|running"
    check_service_health "frontend" "curl -sf http://localhost:8081" "<!DOCTYPE html"

    # Database connectivity
    check_service_health "database" "python -c 'import psycopg2; psycopg2.connect(host=\"localhost\", database=\"devonboarder\", user=\"devonboarder\", password=\"devonboarder\")'" ""

    # Discord bot process check
    check_service_health "discord-bot" "pgrep -f 'node.*bot' || docker ps --filter 'name=devonboarder-bot' --format '{{.Names}}'" "bot\\|devonboarder-bot"

    # Check for services that need alerts
    for service in "${!failure_counts[@]}"; do
        count=${failure_counts[$service]}
        if [[ $count -ge $ALERT_THRESHOLD ]]; then
            send_alert "$service" "$count"
        fi
    done

    # Performance and resource monitoring
    monitor_performance
    monitor_resources

    # Status summary
    healthy_count=0
    total_services=5

    for service in auth-service xp-api frontend database discord-bot; do
        if [[ "${last_status[$service]}" == "HEALTHY" ]]; then
            healthy_count=$((healthy_count  1))
        fi
    done

    echo " Status: $healthy_count/$total_services services healthy"

    if [[ $healthy_count -eq $total_services ]]; then
        echo " All services operational"
    else
        echo "  Some services need attention"
    fi

    echo "⏰ Next check in ${MONITOR_INTERVAL}s..."
    echo

    sleep "$MONITOR_INTERVAL"
done
