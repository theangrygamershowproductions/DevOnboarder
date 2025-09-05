#!/bin/bash
# DevOnboarder System Misalignment Detection
# Automatically detects discrepancies between local and CI environments
set -euo pipefail

# Initialize logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${PROJECT_ROOT}/logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/system_misalignment_${TIMESTAMP}.log"
REPORT_FILE="${LOG_DIR}/misalignment_report_${TIMESTAMP}.json"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# JSON report structure
init_report() {
    cat > "$REPORT_FILE" << 'EOF'
{
  "timestamp": "",
  "environment": {
    "detected": "",
    "is_ci": false,
    "is_local": false
  },
  "misalignments": [],
  "system_info": {},
  "quality_checks": {},
  "recommendations": [],
  "severity": "unknown"
}
EOF
}

# Update JSON report
update_report() {
    local key="$1"
    local value="$2"

    # Use Python to safely update JSON
    python3 -c "
import json
import sys
with open('$REPORT_FILE', 'r') as f:
    data = json.load(f)

keys = '$key'.split('.')
current = data
for k in keys[:-1]:
    if k not in current:
        current[k] = {}
    current = current[k]
current[keys[-1]] = $value

with open('$REPORT_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
}

# Add misalignment to report
add_misalignment() {
    local category="$1"
    local description="$2"
    local local_value="$3"
    local expected_value="$4"
    local severity="${5:-medium}"

    python3 -c "
import json
with open('$REPORT_FILE', 'r') as f:
    data = json.load(f)

misalignment = {
    'category': '$category',
    'description': '$description',
    'local_value': '$local_value',
    'expected_value': '$expected_value',
    'severity': '$severity'
}

data['misalignments'].append(misalignment)

with open('$REPORT_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
    log "MISALIGNMENT: [$category] $description"
}

# Detect environment
detect_environment() {
    log "Detecting execution environment..."

    if [[ "${CI:-}" == "true" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]]; then
        update_report "environment.detected" '"ci"'
        update_report "environment.is_ci" 'True'
        log "Environment: CI (GitHub Actions)"
    else
        update_report "environment.detected" '"local"'
        update_report "environment.is_local" 'True'
        log "Environment: Local development"
    fi

    update_report "timestamp" "\"$(date -Iseconds)\""
}

# Collect system information
collect_system_info() {
    log "Collecting system information..."

    # Basic system info
    local os_info
    os_info=$(uname -a 2>/dev/null || echo "unknown")
    update_report "system_info.os" "\"$os_info\""

    # Python version
    local python_version
    if command -v python >/dev/null 2>&1; then
        python_version=$(python --version 2>&1 || echo "unknown")
        update_report "system_info.python_version" "\"$python_version\""
    fi

    # Node version
    local node_version
    if command -v node >/dev/null 2>&1; then
        node_version=$(node --version 2>/dev/null || echo "unknown")
        update_report "system_info.node_version" "\"$node_version\""
    fi

    # Virtual environment status
    local venv_status="${VIRTUAL_ENV:-none}"
    update_report "system_info.virtual_env" "\"$venv_status\""

    # Available memory (Linux/macOS)
    local memory_info
    if command -v free >/dev/null 2>&1; then
        memory_info=$(free -h | head -2 | tail -1 | awk '{print $2}' || echo "unknown")
    elif command -v vm_stat >/dev/null 2>&1; then
        memory_info=$(vm_stat | head -1 | awk '{print $4}' || echo "unknown")
    else
        memory_info="unknown"
    fi
    update_report "system_info.memory" "\"$memory_info\""

    # Disk space
    local disk_space
    disk_space=$(df -h . | tail -1 | awk '{print $4}' || echo "unknown")
    update_report "system_info.disk_available" "\"$disk_space\""
}

# Check tool versions against .tool-versions
check_tool_versions() {
    log "Checking tool versions against .tool-versions..."

    if [[ ! -f ".tool-versions" ]]; then
        add_misalignment "tools" "Missing .tool-versions file" "none" "present" "high"
        return
    fi

    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        local tool version
        tool=$(echo "$line" | awk '{print $1}')
        version=$(echo "$line" | awk '{print $2}')

        case "$tool" in
            python)
                if command -v python >/dev/null 2>&1; then
                    local current_python
                    current_python=$(python --version | awk '{print $2}')
                    if [[ "$current_python" != "$version"* ]]; then
                        add_misalignment "python_version" "Python version mismatch" "$current_python" "$version" "high"
                    fi
                fi
                ;;
            nodejs)
                if command -v node >/dev/null 2>&1; then
                    local current_node
                    current_node=$(node --version | sed 's/^v//')
                    if [[ "$current_node" != "$version"* ]]; then
                        add_misalignment "node_version" "Node.js version mismatch" "$current_node" "$version" "medium"
                    fi
                fi
                ;;
        esac
    done < .tool-versions
}

# Check virtual environment alignment
check_venv_alignment() {
    log "Checking virtual environment alignment..."

    if [[ -z "${VIRTUAL_ENV:-}" ]]; then
        add_misalignment "venv" "Virtual environment not activated" "none" ".venv activated" "high"
        return
    fi

    # Check if we're in the project's venv
    local expected_venv="${PROJECT_ROOT}/.venv"
    if [[ "$VIRTUAL_ENV" != "$expected_venv" ]]; then
        add_misalignment "venv_path" "Wrong virtual environment" "$VIRTUAL_ENV" "$expected_venv" "medium"
    fi

    # Check if required packages are installed
    local missing_packages=()

    # Check for key DevOnboarder dependencies
    if ! python -c "import fastapi" 2>/dev/null; then
        missing_packages+=("fastapi")
    fi

    if ! python -c "import pytest" 2>/dev/null; then
        missing_packages+=("pytest")
    fi

    if ! python -c "import ruff" 2>/dev/null; then
        missing_packages+=("ruff")
    fi

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        local missing_str
        missing_str=$(IFS=,; echo "${missing_packages[*]}")
        add_misalignment "dependencies" "Missing Python packages" "$missing_str" "all required packages installed" "high"
    fi
}

# Run quality control checks and measure timing
run_qc_checks() {
    log "Running quality control checks with timing..."

    if [[ ! -x "./scripts/qc_pre_push.sh" ]]; then
        add_misalignment "qc_script" "QC script not executable" "missing/non-executable" "executable" "high"
        return
    fi

    # Time the QC execution
    local start_time end_time duration
    start_time=$(date +%s.%N)

    local qc_exit_code=0
    local qc_output

    # Run QC with timeout to detect hangs
    if qc_output=$(timeout 300 ./scripts/qc_pre_push.sh 2>&1); then
        log "QC checks passed"
        update_report "quality_checks.status" '"passed"'
    else
        qc_exit_code=$?
        log "QC checks failed with exit code: $qc_exit_code"
        update_report "quality_checks.status" '"failed"'
        update_report "quality_checks.exit_code" "$qc_exit_code"

        # Check if it was a timeout
        if [[ $qc_exit_code -eq 124 ]]; then
            add_misalignment "qc_timeout" "QC script timed out (>300s)" "timeout" "completes quickly" "high"
        else
            add_misalignment "qc_failure" "QC script failed" "exit_code_$qc_exit_code" "exit_code_0" "high"
        fi
    fi

    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "unknown")

    update_report "quality_checks.duration_seconds" "$duration"
    log "QC execution took: ${duration}s"

    # Detect unusual timing (CI should be reasonably fast)
    if command -v bc >/dev/null 2>&1 && [[ "$duration" != "unknown" ]]; then
        if (( $(echo "$duration > 120" | bc -l) )); then
            add_misalignment "qc_performance" "QC script running slowly" "${duration}s" "<120s" "medium"
        fi
    fi

    # Store QC output for analysis
    echo "$qc_output" > "${LOG_DIR}/qc_output_${TIMESTAMP}.log"
}

# Check CI-specific issues
check_ci_specific_issues() {
    if [[ "${CI:-}" != "true" ]]; then
        return  # Skip if not in CI
    fi

    log "Checking CI-specific issues..."

    # Check GitHub Actions specific environment variables
    local required_ci_vars=("GITHUB_WORKSPACE" "GITHUB_REPOSITORY" "RUNNER_OS")
    for var in "${required_ci_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            add_misalignment "ci_env_var" "Missing CI environment variable: $var" "unset" "set" "medium"
        fi
    done

    # Check runner capacity
    if [[ -n "${RUNNER_OS:-}" ]]; then
        local runner_info="${RUNNER_OS}"
        update_report "system_info.runner_os" "\"$runner_info\""
    fi

    # Check if artifacts directory exists and is writable
    local artifacts_dir="logs"
    if [[ ! -d "$artifacts_dir" ]]; then
        mkdir -p "$artifacts_dir" || {
            add_misalignment "artifacts_dir" "Cannot create artifacts directory" "permission_denied" "writable" "medium"
        }
    fi
}

# Generate recommendations
generate_recommendations() {
    log "Generating recommendations..."

    local misalignment_count
    misalignment_count=$(python3 -c "
import json
with open('$REPORT_FILE', 'r') as f:
    data = json.load(f)
print(len(data.get('misalignments', [])))
")

    if [[ "$misalignment_count" -eq 0 ]]; then
        update_report "severity" '"none"'
        python3 -c "
import json
with open('$REPORT_FILE', 'r') as f:
    data = json.load(f)
data['recommendations'] = ['No misalignments detected - system appears properly aligned']
with open('$REPORT_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
        return
    fi

    # Determine overall severity
    local high_count medium_count
    high_count=$(python3 -c "
import json
with open('$REPORT_FILE', 'r') as f:
    data = json.load(f)
print(len([m for m in data.get('misalignments', []) if m.get('severity') == 'high']))
")

    medium_count=$(python3 -c "
import json
with open('$REPORT_FILE', 'r') as f:
    data = json.load(f)
print(len([m for m in data.get('misalignments', []) if m.get('severity') == 'medium']))
")

    local overall_severity="low"
    if [[ "$high_count" -gt 0 ]]; then
        overall_severity="high"
    elif [[ "$medium_count" -gt 0 ]]; then
        overall_severity="medium"
    fi

    update_report "severity" "\"$overall_severity\""

    # Generate specific recommendations
    python3 -c "
import json
with open('$REPORT_FILE', 'r') as f:
    data = json.load(f)

recommendations = []

for m in data.get('misalignments', []):
    category = m.get('category', '')
    if category == 'python_version':
        recommendations.append('Update Python to version specified in .tool-versions')
    elif category == 'node_version':
        recommendations.append('Update Node.js to version specified in .tool-versions')
    elif category == 'venv':
        recommendations.append('Activate virtual environment: source .venv/bin/activate')
    elif category == 'dependencies':
        recommendations.append('Install missing dependencies: pip install -e .[test]')
    elif category == 'qc_timeout':
        recommendations.append('Investigate QC script performance - may need optimization')
    elif category == 'qc_failure':
        recommendations.append('Debug QC script failure - check logs for specific errors')

# Add general recommendations
if len(data.get('misalignments', [])) > 0:
    recommendations.append('Run: make deps && source .venv/bin/activate')
    recommendations.append('Verify: ./scripts/qc_pre_push.sh')

data['recommendations'] = recommendations
with open('$REPORT_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
}

# Print summary report
print_summary() {
    log "System Misalignment Detection Complete"
    echo
    echo "=== SYSTEM MISALIGNMENT DETECTION SUMMARY ==="

    python3 -c '
import json
import sys

with open("'"$REPORT_FILE"'", "r") as f:
    data = json.load(f)

env = data.get("environment", {})
print("Environment: " + env.get("detected", "unknown"))
print("Timestamp: " + data.get("timestamp", "unknown"))

misalignments = data.get("misalignments", [])
severity = data.get("severity", "unknown")

print("Severity: " + severity.upper())
print("Misalignments Found: " + str(len(misalignments)))

if misalignments:
    print("\nMISALIGNMENTS:")
    for i, m in enumerate(misalignments, 1):
        severity_icon = "🔴" if m.get("severity") == "high" else "🟡" if m.get("severity") == "medium" else "🟢"
        print("  " + str(i) + ". " + severity_icon + " [" + m.get("category", "unknown") + "] " + m.get("description", "No description"))
        print("     Local: " + str(m.get("local_value", "unknown")))
        print("     Expected: " + str(m.get("expected_value", "unknown")))

recommendations = data.get("recommendations", [])
if recommendations:
    print("\nRECOMMENDATIONS:")
    for i, rec in enumerate(recommendations, 1):
        print("  " + str(i) + ". " + rec)

qc = data.get("quality_checks", {})
if "status" in qc:
    print("\nQUALITY CHECKS: " + qc["status"].upper())
    if "duration_seconds" in qc:
        print("Duration: " + str(qc["duration_seconds"]) + "s")
'

    echo
    echo "Full report: $REPORT_FILE"
    echo "Execution log: $LOG_FILE"

    # Return appropriate exit code
    local severity
    severity=$(python3 -c '
import json
with open("'"$REPORT_FILE"'", "r") as f:
    data = json.load(f)
print(data.get("severity", "unknown"))
')

    case "$severity" in
        high) return 2 ;;
        medium) return 1 ;;
        *) return 0 ;;
    esac
}

# Main execution
main() {
    log "Starting DevOnboarder System Misalignment Detection"

    # Ensure we're in project root
    cd "$PROJECT_ROOT"

    init_report
    detect_environment
    collect_system_info
    check_tool_versions
    check_venv_alignment
    check_ci_specific_issues
    run_qc_checks
    generate_recommendations
    print_summary
}

# Execute main function
main "$@"
