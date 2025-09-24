#!/bin/bash
# Enhanced CI Failure Analysis with Automatic Misalignment Detection
# Integrates system misalignment detection into CI failure reporting
set -euo pipefail

# Centralized logging setup
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${PROJECT_ROOT}/logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ANALYSIS_FILE="${LOG_DIR}/enhanced_failure_analysis_${TIMESTAMP}.md"

# Initialize analysis report with placeholders
init_analysis_report() {
    cat > "$ANALYSIS_FILE" << 'EOF'
# Enhanced CI Failure Analysis Report

## Execution Context
- **Timestamp**: TIMESTAMP_PLACEHOLDER
- **Environment**: ENVIRONMENT_PLACEHOLDER
- **Trigger**: TRIGGER_PLACEHOLDER
- **Branch**: BRANCH_PLACEHOLDER
- **Commit**: COMMIT_PLACEHOLDER

## System Misalignment Analysis
MISALIGNMENT_PLACEHOLDER

## Quality Control Analysis
QC_ANALYSIS_PLACEHOLDER

## Recommendations
RECOMMENDATIONS_PLACEHOLDER

## Technical Details
TECHNICAL_DETAILS_PLACEHOLDER
EOF
}

# Safe replacement function using Python
safe_replace() {
    local file="$1"
    local placeholder="$2"
    local replacement="$3"

    python3 -c "
import sys

try:
    with open('$file', 'r') as f:
        content = f.read()

    content = content.replace('$placeholder', '''$replacement''')

    with open('$file', 'w') as f:
        f.write(content)
except Exception as e:
    print(f'Error replacing $placeholder: {e}', file=sys.stderr)
    sys.exit(1)
"
}

# Gather context information
gather_context() {
    local env_type="unknown"
    local trigger="manual"
    local branch="unknown"
    local commit="unknown"

    if [[ "${CI:-}" == "true" ]]; then
        env_type="GitHub Actions CI"
        trigger="${GITHUB_EVENT_NAME:-unknown}"
        branch="${GITHUB_REF_NAME:-unknown}"
        commit="${GITHUB_SHA:-unknown}"
    else
        env_type="local development"
        if command -v git >/dev/null 2>&1; then
            branch=$(git branch --show-current 2>/dev/null || echo "unknown")
            commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
        fi
    fi

    safe_replace "$ANALYSIS_FILE" "TIMESTAMP_PLACEHOLDER" "$(date -Iseconds)"
    safe_replace "$ANALYSIS_FILE" "ENVIRONMENT_PLACEHOLDER" "$env_type"
    safe_replace "$ANALYSIS_FILE" "TRIGGER_PLACEHOLDER" "$trigger"
    safe_replace "$ANALYSIS_FILE" "BRANCH_PLACEHOLDER" "$branch"
    safe_replace "$ANALYSIS_FILE" "COMMIT_PLACEHOLDER" "$commit"
}

# Run misalignment detection and integrate results
run_misalignment_analysis() {
    local misalignment_content=""

    if [[ -x "./scripts/detect_system_misalignment.sh" ]]; then
        echo "Running system misalignment detection..."

        if ! ./scripts/detect_system_misalignment.sh > "${LOG_DIR}/misalignment_output_${TIMESTAMP}.log" 2>&1; then
            echo "Warning: Misalignment detection returned non-zero exit code" >&2
        fi

        # Find the latest misalignment report
        local latest_report
        latest_report=$(find "$LOG_DIR" -name "misalignment_report_*.json" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2- || echo "")

        if [[ -n "$latest_report" && -f "$latest_report" ]]; then
            # Create a temporary file for the Python output to avoid shell escaping issues
            local temp_output="${LOG_DIR}/temp_misalignment_${TIMESTAMP}.md"

            python3 -c "
import json

try:
    with open('$latest_report', 'r') as f:
        data = json.load(f)

    severity = data.get('severity', 'unknown')
    misalignments = data.get('misalignments', [])
    recommendations = data.get('recommendations', [])
    qc_status = data.get('quality_checks', {}).get('status', 'unknown')
    qc_duration = data.get('quality_checks', {}).get('duration_seconds', 'unknown')

    output = []
    output.append(f'### Severity: {severity.upper()}')
    output.append(f'- **Misalignments Found**: {len(misalignments)}')
    output.append(f'- **Quality Check Status**: {qc_status}')
    output.append(f'- **QC Duration**: {qc_duration}s')
    output.append('')

    if misalignments:
        output.append('### Detected Misalignments:')
        for i, m in enumerate(misalignments, 1):
            category = m.get('category', 'unknown')
            description = m.get('description', 'No description')
            local_val = m.get('local_value', 'unknown')
            expected_val = m.get('expected_value', 'unknown')

            output.append(f'{i}. **{category}**: {description}')
            output.append(f'   - Local Value: \`{local_val}\`')
            output.append(f'   - Expected Value: \`{expected_val}\`')
            output.append('')
    else:
        output.append('No system misalignments detected.')
        output.append('')

    if recommendations:
        output.append('### Immediate Actions:')
        for i, rec in enumerate(recommendations, 1):
            output.append(f'{i}. {rec}')

    result = '\n'.join(output)

    with open('$temp_output', 'w') as f:
        f.write(result)

except Exception as e:
    with open('$temp_output', 'w') as f:
        f.write(f'Error analyzing misalignment report: {e}')
" 2>/dev/null || echo "Failed to analyze misalignment data" > "$temp_output"

            if [[ -f "$temp_output" ]]; then
                misalignment_content=$(cat "$temp_output")
                rm -f "$temp_output"
            fi
        else
            misalignment_content="Misalignment detection failed - no report generated"
        fi
    else
        misalignment_content="Misalignment detection script not available"
    fi

    safe_replace "$ANALYSIS_FILE" "MISALIGNMENT_PLACEHOLDER" "$misalignment_content"
}

# Analyze QC failure patterns
analyze_qc_failure() {
    local qc_content=""

    # Find the most recent QC log
    local latest_qc_log
    latest_qc_log=$(find "$LOG_DIR" -name "*qc*" -o -name "qc_output_*.log" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2- || echo "")

    if [[ -n "$latest_qc_log" && -f "$latest_qc_log" ]]; then
        local log_size
        log_size=$(wc -l < "$latest_qc_log" 2>/dev/null || echo "0")

        qc_content="### Quality Control Log Analysis
- **Log File**: $(basename "$latest_qc_log")
- **Log Size**: $log_size lines

#### Common Failure Patterns:"

        # Check for specific failure patterns
        if grep -q "coverage.*failed\|coverage.*below" "$latest_qc_log" 2>/dev/null; then
            qc_content+="
Coverage Issue: Test coverage below threshold"
        fi

        if grep -q "timeout\|timed out\|killed" "$latest_qc_log" 2>/dev/null; then
            qc_content+="
Timeout Issue: Process exceeded time limit"
        fi

        if grep -q "memory\|out of memory\|OOM" "$latest_qc_log" 2>/dev/null; then
            qc_content+="
Memory Issue: Insufficient memory available"
        fi

        if grep -q "permission denied\|not permitted" "$latest_qc_log" 2>/dev/null; then
            qc_content+="
Permission Issue: Access denied to required resources"
        fi

        if grep -q "No module named\|ModuleNotFoundError" "$latest_qc_log" 2>/dev/null; then
            qc_content+="
Dependency Issue: Missing Python modules"
        fi

        # Add last few lines of QC log for context
        qc_content+="

#### Last Lines of QC Log:
\`\`\`
$(tail -10 "$latest_qc_log" 2>/dev/null || echo "Could not read log file")
\`\`\`"
    else
        qc_content="No QC log found for analysis"
    fi

    safe_replace "$ANALYSIS_FILE" "QC_ANALYSIS_PLACEHOLDER" "$qc_content"
}

# Generate comprehensive recommendations
generate_recommendations() {
    local recommendations="### Immediate Actions:

1. **Environment Verification**: Run \`./scripts/detect_system_misalignment.sh\` to identify specific issues
2. **Virtual Environment**: Ensure virtual environment is activated with \`source .venv/bin/activate\`
3. **Dependencies**: Verify all dependencies are installed with \`pip install -e .[test]\`
4. **Tool Versions**: Check tool versions match \`.tool-versions\` requirements

### CI-Specific Actions:

1. **Download CI Artifacts**: Check the [CI logs and artifacts](${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-repo}/actions/runs/${GITHUB_RUN_ID:-0})
2. **Resource Monitoring**: Monitor CI runner resource usage (memory, disk space, CPU)
3. **Timeout Analysis**: If QC times out, consider breaking into smaller validation steps

### Local Testing:

1. **Replicate Locally**: Run the same commands locally to compare behavior
2. **Log Comparison**: Compare local QC output with CI QC output
3. **Environment Audit**: Use \`python -m diagnostics\` to verify local setup

### Long-term Solutions:

1. **CI Optimization**: Consider caching strategies to reduce execution time
2. **Resource Allocation**: Monitor if CI runners need more memory/CPU
3. **Parallel Execution**: Break QC into parallel jobs if possible
4. **Environment Standardization**: Ensure CI matches local development environment exactly"

    safe_replace "$ANALYSIS_FILE" "RECOMMENDATIONS_PLACEHOLDER" "$recommendations"
}

# Add technical details
add_technical_details() {
    local details
    details="### System Information:
- **OS**: $(uname -a 2>/dev/null || echo 'unknown')
- **Python**: $(python --version 2>/dev/null || echo 'not available')
- **Node**: $(node --version 2>/dev/null || echo 'not available')
- **Virtual Env**: ${VIRTUAL_ENV:-none}
- **Working Directory**: $(pwd)"

    # Environment variables (CI-specific)
    if [[ "${CI:-}" == "true" ]]; then
        details+="

### CI Environment Variables:
- **Runner OS**: ${RUNNER_OS:-unknown}
- **GitHub Workspace**: ${GITHUB_WORKSPACE:-unknown}
- **GitHub Repository**: ${GITHUB_REPOSITORY:-unknown}
- **GitHub Event**: ${GITHUB_EVENT_NAME:-unknown}"
    fi

    # Available logs
    details+="

### Available Diagnostic Files:"
    if [[ -d "$LOG_DIR" ]]; then
        local log_files
        log_files=$(find "$LOG_DIR" -name "*${TIMESTAMP}*" -type f 2>/dev/null | head -5)
        if [[ -n "$log_files" ]]; then
            echo "$log_files" | while read -r logfile; do
                details+="
- $(basename "$logfile")"
            done
        else
            details+="
- No diagnostic files found for this timestamp"
        fi
    fi

    safe_replace "$ANALYSIS_FILE" "TECHNICAL_DETAILS_PLACEHOLDER" "$details"
}

# Main execution
main() {
    echo "Starting Enhanced CI Failure Analysis..."

    cd "$PROJECT_ROOT"

    init_analysis_report
    gather_context
    run_misalignment_analysis
    analyze_qc_failure
    generate_recommendations
    add_technical_details

    echo
    echo "=== ENHANCED CI FAILURE ANALYSIS COMPLETE ==="
    echo "Report generated: $ANALYSIS_FILE"
    echo

    # Display summary
    if [[ -f "$ANALYSIS_FILE" ]]; then
        echo "=== SUMMARY ==="
        grep -E "(Timestamp|Environment|Severity|Misalignments Found)" "$ANALYSIS_FILE" || true
        echo
        echo "Full report: $ANALYSIS_FILE"
    fi

    # Return exit code based on severity
    local latest_report
    latest_report=$(find "$LOG_DIR" -name "misalignment_report_*.json" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2- || echo "")

    if [[ -n "$latest_report" && -f "$latest_report" ]]; then
        local severity
        severity=$(python3 -c "
import json
try:
    with open('$latest_report', 'r') as f:
        data = json.load(f)
    print(data.get('severity', 'unknown'))
except:
    print('unknown')
" 2>/dev/null || echo "unknown")

        case "$severity" in
            high) return 2 ;;
            medium) return 1 ;;
            *) return 0 ;;
        esac
    fi

    return 0
}

# Execute main function
main "$@"
