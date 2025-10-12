#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Phase 2: Automated Content Duplication Monitoring
# Integrates with DevOnboarder quality gates to prevent regression

set -euo pipefail

# Configuration
DOCS_ROOT="${DOCS_ROOT:-docs}"
LOG_DIR="${LOG_DIR:-logs}"
MONITORING_THRESHOLD="${MONITORING_THRESHOLD:-75}"
MAX_DUPLICATIONS="${MAX_DUPLICATIONS:-10}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/duplication_monitoring_$TIMESTAMP.log"

# Ensure logging directory exists
mkdir -p "$LOG_DIR"

# Initialize logging
exec > >(tee -a "$LOG_FILE") 2>&1

echo "MONITOR: DevOnboarder Content Duplication Monitoring"
echo "================================================"
echo "Timestamp: $(date)"
echo "Phase: 2 - Automation Opportunities"
echo "Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
echo

# Function: Quick duplication check (optimized for speed)
quick_duplication_check() {
    echo "INFO: Running quick duplication check..."

    local pattern_count=0
    local critical_patterns=("virtual environment" "terminal output" "quality control" "commit message")

    echo "   Checking critical duplication patterns..."
    for pattern in "${critical_patterns[@]}"; do
        local file_count
        file_count=$(grep -r -l "$pattern" "$DOCS_ROOT" 2>/dev/null | wc -l || echo "0")

        if [[ "$file_count" -gt "$MAX_DUPLICATIONS" ]]; then
            echo "   WARNING:  Pattern '$pattern' found in $file_count files (threshold: $MAX_DUPLICATIONS)"
            ((pattern_count++))
        else
            echo "   SUCCESS: Pattern '$pattern' found in $file_count files (within threshold)"
        fi
    done

    return "$pattern_count"
}

# Function: Pattern monitoring with alerts
monitor_pattern_growth() {
    echo "TREND: Monitoring pattern growth trends..."

    local monitoring_file="$LOG_DIR/pattern_growth_tracking.csv"

    # Create header if file doesn't exist
    if [[ ! -f "$monitoring_file" ]]; then
        echo "timestamp,virtual_env_count,terminal_output_count,quality_control_count,commit_message_count,total_files" > "$monitoring_file"
    fi

    # Count current occurrences
    local venv_count terminal_count qc_count commit_count total_files
    venv_count=$(grep -r -l "virtual environment" "$DOCS_ROOT" 2>/dev/null | wc -l || echo "0")
    terminal_count=$(grep -r -l "terminal output" "$DOCS_ROOT" 2>/dev/null | wc -l || echo "0")
    qc_count=$(grep -r -l "quality control" "$DOCS_ROOT" 2>/dev/null | wc -l || echo "0")
    commit_count=$(grep -r -l "commit message" "$DOCS_ROOT" 2>/dev/null | wc -l || echo "0")
    total_files=$(find "$DOCS_ROOT" -name "*.md" -type f | wc -l || echo "0")

    # Record current data
    echo "$TIMESTAMP,$venv_count,$terminal_count,$qc_count,$commit_count,$total_files" >> "$monitoring_file"

    echo "   STATS: Current pattern distribution:"
    echo "      - Virtual environment: $venv_count files"
    echo "      - Terminal output: $terminal_count files"
    echo "      - Quality control: $qc_count files"
    echo "      - Commit message: $commit_count files"
    echo "      - Total documentation files: $total_files"

    # Check for growth trends (compare with previous entry)
    local previous_entry
    previous_entry=$(tail -2 "$monitoring_file" | head -1 2>/dev/null || echo "")

    if [[ -n "$previous_entry" ]]; then
        echo "   TREND: Growth analysis available in: $monitoring_file"
    else
        echo "   NOTE: First monitoring entry recorded"
    fi
}

# Function: Integration with DevOnboarder quality gates
integrate_quality_gates() {
    echo "🚪 Integrating with DevOnboarder quality gates..."

    local quality_gate_script="scripts/qc_duplication_gate.sh"

    # Create quality gate integration script
    cat > "$quality_gate_script" << 'EOF'
#!/bin/bash
# DevOnboarder Quality Gate: Content Duplication Check
# Integrates duplication monitoring with CI/CD pipeline

set -euo pipefail

MAX_CRITICAL_DUPLICATIONS="${MAX_CRITICAL_DUPLICATIONS:-10}"
CRITICAL_PATTERNS=("virtual environment" "terminal output" "quality control")

echo "🚪 Quality Gate: Content Duplication Check"
echo "==========================================="

failure_count=0

for pattern in "${CRITICAL_PATTERNS[@]}"; do
    file_count=$(grep -r -l "$pattern" docs 2>/dev/null | wc -l || echo "0")

    if [[ "$file_count" -gt "$MAX_CRITICAL_DUPLICATIONS" ]]; then
        error "FAIL: Pattern '$pattern' found in $file_count files (max: $MAX_CRITICAL_DUPLICATIONS)"
        ((failure_count++))
    else
        success "PASS: Pattern '$pattern' found in $file_count files"
    fi
done

if [[ "$failure_count" -gt 0 ]]; then
    echo
    error "Quality gate FAILED: $failure_count critical duplication patterns exceeded threshold"
    echo "TIP: Suggestion: Run './scripts/detect_content_duplication.sh suggest' for consolidation guidance"
    exit 1
else
    echo
    success "Quality gate PASSED: All duplication patterns within acceptable limits"
    exit 0
fi
EOF

    chmod +x "$quality_gate_script"
    echo "   SUCCESS: Quality gate script created: $quality_gate_script"
    echo "   TIP: Usage: Add to CI pipeline or pre-commit hooks"
}

# Function: Automated alerting for duplication growth
setup_duplication_alerts() {
    echo "ALERT: Setting up duplication growth alerts..."

    local alert_script="scripts/duplication_alert.sh"

    cat > "$alert_script" << 'EOF'
#!/bin/bash
# Automated duplication growth alerting
# Monitors trends and sends alerts when growth exceeds thresholds

set -euo pipefail

GROWTH_THRESHOLD="${GROWTH_THRESHOLD:-20}"  # 20% growth threshold
ALERT_LOG="${ALERT_LOG:-logs/duplication_alerts.log}"

echo "ALERT: Duplication Growth Alert System"
echo "=================================="

# Read the last two monitoring entries
monitoring_file="logs/pattern_growth_tracking.csv"

if [[ ! -f "$monitoring_file" ]]; then
    note "No monitoring data available yet"
    exit 0
fi

# Get current and previous data
current_data=$(tail -1 "$monitoring_file" 2>/dev/null || echo "")
previous_data=$(tail -2 "$monitoring_file" | head -1 2>/dev/null || echo "")

if [[ -z "$previous_data" || "$current_data" == "$previous_data" ]]; then
    echo "STATS: Insufficient data for growth analysis"
    exit 0
fi

# Parse data (format: timestamp,venv,terminal,qc,commit,total)
IFS=',' read -r prev_ts prev_venv prev_terminal prev_qc prev_commit prev_total <<< "$previous_data"
IFS=',' read -r curr_ts curr_venv curr_terminal curr_qc curr_commit curr_total <<< "$current_data"

# Calculate growth percentages
venv_growth=$(( (curr_venv - prev_venv) * 100 / (prev_venv + 1) ))
terminal_growth=$(( (curr_terminal - prev_terminal) * 100 / (prev_terminal + 1) ))
qc_growth=$(( (curr_qc - prev_qc) * 100 / (prev_qc + 1) ))

echo "TREND: Growth Analysis:"
echo "   Virtual Environment: $venv_growth% (${prev_venv} → ${curr_venv})"
echo "   Terminal Output: $terminal_growth% (${prev_terminal} → ${curr_terminal})"
echo "   Quality Control: $qc_growth% (${prev_qc} → ${curr_qc})"

# Check for concerning growth
alerts_triggered=0

if [[ "$venv_growth" -gt "$GROWTH_THRESHOLD" ]]; then
    echo "ALERT: ALERT: Virtual environment duplication grew by $venv_growth%"
    echo "$(date): Virtual environment duplication growth: $venv_growth%" >> "$ALERT_LOG"
    ((alerts_triggered++))
fi

if [[ "$terminal_growth" -gt "$GROWTH_THRESHOLD" ]]; then
    echo "ALERT: ALERT: Terminal output duplication grew by $terminal_growth%"
    echo "$(date): Terminal output duplication growth: $terminal_growth%" >> "$ALERT_LOG"
    ((alerts_triggered++))
fi

if [[ "$qc_growth" -gt "$GROWTH_THRESHOLD" ]]; then
    echo "ALERT: ALERT: Quality control duplication grew by $qc_growth%"
    echo "$(date): Quality control duplication growth: $qc_growth%" >> "$ALERT_LOG"
    ((alerts_triggered++))
fi

if [[ "$alerts_triggered" -gt 0 ]]; then
    echo
    warning " $alerts_triggered duplication growth alerts triggered"
    echo "TIP: Consider running consolidation workflow: ./scripts/auto_consolidate_content.sh"
    exit 1
else
    echo
    success "No concerning duplication growth detected"
    exit 0
fi
EOF

    chmod +x "$alert_script"
    echo "   SUCCESS: Alert script created: $alert_script"
    echo "   TIP: Usage: Run periodically via cron or CI monitoring"
}

# Function: GitHub Actions integration
create_github_actions_integration() {
    bot "Creating GitHub Actions integration..."

    local workflow_file=".github/workflows/duplication-monitoring.yml"
    local workflow_dir
    workflow_dir=$(dirname "$workflow_file")

    # Create .github/workflows directory if it doesn't exist
    mkdir -p "$workflow_dir"

    cat > "$workflow_file" << 'EOF'
name: Documentation Duplication Monitoring

on:
  push:
    branches: [ main, docs/* ]
    paths: [ 'docs/**' ]
  pull_request:
    branches: [ main ]
    paths: [ 'docs/**' ]
  schedule:
    # Run monitoring daily at 6 AM UTC
    - cron: '0 6 * * *'

jobs:
  duplication-monitoring:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Set up monitoring environment
      run: |
        mkdir -p logs
        chmod +x scripts/monitor_duplication.sh scripts/qc_duplication_gate.sh

    - name: Run duplication monitoring
      run: |
        ./scripts/monitor_duplication.sh

    - name: Run quality gate check
      run: |
        ./scripts/qc_duplication_gate.sh

    - name: Check for growth alerts
      run: |
        ./scripts/duplication_alert.sh || echo "Growth alerts detected - see logs"

    - name: Upload monitoring artifacts
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: duplication-monitoring-${{ github.run_id }}
        path: |
          logs/duplication_monitoring_*.log
          logs/pattern_growth_tracking.csv
          logs/duplication_alerts.log
        retention-days: 30

    - name: Comment on PR with results
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v7
      with:
        script: |
          const fs = require('fs');
          try {
            const logFiles = fs.readdirSync('logs').filter(f => f.includes('duplication_monitoring_'));
            if (logFiles.length > 0) {
              const logContent = fs.readFileSync(`logs/${logFiles[0]}`, 'utf8');
              const summary = logContent.split('\n').slice(0, 20).join('\n');

              github.rest.issues.createComment({
                issue_number: context.issue.number,
                owner: context.repo.owner,
                repo: context.repo.repo,
                body: `## STATS: Content Duplication Monitoring Results\n\n\`\`\`\n${summary}\n\`\`\`\n\n[Full monitoring logs available in artifacts]`
              });
            }
          } catch (error) {
            console.log('Could not post monitoring results:', error.message);
          }
EOF

    echo "   SUCCESS: GitHub Actions workflow created: $workflow_file"
    echo "   BOT: Automated monitoring will run on docs changes and daily"
}

# Function: Display usage information
show_usage() {
    cat << 'EOF'
Usage: monitor_duplication.sh [OPTIONS]

Automated content duplication monitoring for DevOnboarder documentation.

OPTIONS:
    --quick-check        Run quick pattern check only
    --setup-gates       Set up quality gate integration
    --create-alerts     Create alerting system
    --github-actions    Generate GitHub Actions workflow
    --threshold N       Set duplication threshold (default: 75)
    --max-duplications N Set maximum allowed duplications (default: 10)
    --help              Show this help message

ENVIRONMENT VARIABLES:
    DOCS_ROOT             Documentation root directory (default: docs)
    LOG_DIR              Log directory (default: logs)
    MONITORING_THRESHOLD  Duplication similarity threshold (default: 75)
    MAX_DUPLICATIONS     Maximum allowed pattern duplications (default: 10)

EXAMPLES:
    # Full monitoring workflow
    ./scripts/monitor_duplication.sh

    # Quick check only
    ./scripts/monitor_duplication.sh --quick-check

    # Set up all monitoring components
    ./scripts/monitor_duplication.sh --setup-gates --create-alerts --github-actions

INTEGRATION:
    This monitoring system integrates with:
    - Phase 1 content duplication detection tools
    - DevOnboarder quality gate system (qc_pre_push.sh)
    - GitHub Actions CI/CD pipeline
    - Automated alerting for growth trends
    - Pre-commit hooks for immediate feedback

MONITORING FEATURES:
    1. Quick pattern-based duplication detection
    2. Growth trend tracking with historical data
    3. Quality gate integration for CI/CD blocking
    4. Automated alerting for threshold violations
    5. GitHub Actions workflow for continuous monitoring

EOF
}

# Main monitoring workflow
main() {
    local quick_check=false
    local setup_gates=false
    local create_alerts=false
    local github_actions=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quick-check)
                quick_check=true
                shift
                ;;
            --setup-gates)
                setup_gates=true
                shift
                ;;
            --create-alerts)
                create_alerts=true
                shift
                ;;
            --github-actions)
                github_actions=true
                shift
                ;;
            --threshold)
                MONITORING_THRESHOLD="$2"
                shift 2
                ;;
            --max-duplications)
                MAX_DUPLICATIONS="$2"
                shift 2
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    echo "ACTION: Starting Content Duplication Monitoring"
    echo "Configuration:"
    echo "   - Documentation root: $DOCS_ROOT"
    echo "   - Monitoring threshold: $MONITORING_THRESHOLD%"
    echo "   - Max duplications: $MAX_DUPLICATIONS"
    echo "   - Quick check only: $quick_check"
    echo

    # Run quick duplication check
    local duplication_issues=0
    if quick_duplication_check; then
        success "Quick duplication check passed"
    else
        duplication_issues=$?
        warning " Quick duplication check found $duplication_issues issues"
    fi

    # Skip additional steps if quick-check mode
    if [[ "$quick_check" == "true" ]]; then
        echo "STATS: Quick check complete - skipping additional monitoring setup"
        exit "$duplication_issues"
    fi

    # Run pattern monitoring
    monitor_pattern_growth

    # Set up integration components as requested
    if [[ "$setup_gates" == "true" ]]; then
        integrate_quality_gates
    fi

    if [[ "$create_alerts" == "true" ]]; then
        setup_duplication_alerts
    fi

    if [[ "$github_actions" == "true" ]]; then
        create_github_actions_integration
    fi

    echo
    success "Content duplication monitoring complete!"
    echo "   DOC: Log: $LOG_FILE"
    echo "   STATS: Monitoring data: $LOG_DIR/pattern_growth_tracking.csv"

    if [[ "$duplication_issues" -gt 0 ]]; then
        echo "   WARNING:  $duplication_issues duplication issues detected"
        echo "   TIP: Run './scripts/auto_consolidate_content.sh' for consolidation"
    fi

    exit "$duplication_issues"
}

# Execute main workflow if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
