#!/bin/bash
# Framework Phase 2 - Friction Prevention Framework
# Integration script for DevOnboarder workflows

set -euo pipefail

# Source framework configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${FRAMEWORK_ROOT}/config/framework.conf"

if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
else
    echo "Error: Framework configuration not found at ${CONFIG_FILE}"
    exit 1
fi

# Create logs directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Function to log messages
log_message() {
    local level="${1}"
    local message="${2}"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${EXECUTION_LOG}"
}

# Function to validate environment
validate_environment() {
    log_message "INFO" "Validating framework environment..."

    # Check virtual environment
    if [[ "${VIRTUAL_ENV_REQUIRED}" == "true" ]] && [[ -z "${VIRTUAL_ENV:-}" ]]; then
        log_message "ERROR" "Virtual environment required but not activated"
        return 1
    fi

    # Check feature branch requirement
    if [[ "${FEATURE_BRANCH_REQUIRED}" == "true" ]]; then
        local current_branch
        current_branch="$(git branch --show-current)"
        if [[ "${current_branch}" == "main" ]] && [[ "${MAIN_BRANCH_PROTECTION}" == "true" ]]; then
            log_message "ERROR" "Direct work on main branch not allowed"
            return 1
        fi
    fi

    log_message "INFO" "Environment validation passed"
    return 0
}

# Function to execute framework script
execute_script() {
    local script_category="${1}"
    local script_name="${2}"
    shift 2
    local script_args=("$@")

    local script_path
    case "${script_category}" in
        "automation")
            script_path="${AUTOMATION_PATH}/${script_name}"
            ;;
        "workflow")
            script_path="${WORKFLOW_PATH}/${script_name}"
            ;;
        "productivity")
            script_path="${PRODUCTIVITY_PATH}/${script_name}"
            ;;
        "developer_experience")
            script_path="${DEVELOPER_EXPERIENCE_PATH}/${script_name}"
            ;;
        *)
            log_message "ERROR" "Unknown script category: ${script_category}"
            return 1
            ;;
    esac

    if [[ ! -f "${script_path}" ]]; then
        log_message "ERROR" "Script not found: ${script_path}"
        return 1
    fi

    if [[ ! -x "${script_path}" ]]; then
        log_message "WARN" "Making script executable: ${script_path}"
        chmod +x "${script_path}"
    fi

    log_message "INFO" "Executing: ${script_category}/${script_name}"

    # Execute with timeout if configured
    if command -v timeout >/dev/null 2>&1 && [[ -n "${SCRIPT_TIMEOUT}" ]]; then
        timeout "${SCRIPT_TIMEOUT}" "${script_path}" "${script_args[@]}"
    else
        "${script_path}" "${script_args[@]}"
    fi

    local exit_code=$?
    if [[ ${exit_code} -eq 0 ]]; then
        log_message "INFO" "Script executed successfully: ${script_category}/${script_name}"
    else
        log_message "ERROR" "Script failed with exit code ${exit_code}: ${script_category}/${script_name}"
    fi

    return ${exit_code}
}

# Function to list available scripts
list_scripts() {
    local category="${1:-all}"

    echo "Framework Phase 2 - Available Scripts:"
    echo "======================================"

    if [[ "${category}" == "all" || "${category}" == "automation" ]]; then
        echo "Automation Scripts (${AUTOMATION_PATH}):"
        if [[ -d "${AUTOMATION_PATH}" ]]; then
            find "${AUTOMATION_PATH}" -name "*.sh" -o -name "*.py" | sort | sed 's|.*/||' | sed 's/^/  - /'
        fi
        echo
    fi

    if [[ "${category}" == "all" || "${category}" == "workflow" ]]; then
        echo "Workflow Scripts (${WORKFLOW_PATH}):"
        if [[ -d "${WORKFLOW_PATH}" ]]; then
            find "${WORKFLOW_PATH}" -name "*.sh" -o -name "*.py" | sort | sed 's|.*/||' | sed 's/^/  - /'
        fi
        echo
    fi

    if [[ "${category}" == "all" || "${category}" == "productivity" ]]; then
        echo "Productivity Scripts (${PRODUCTIVITY_PATH}):"
        if [[ -d "${PRODUCTIVITY_PATH}" ]]; then
            find "${PRODUCTIVITY_PATH}" -name "*.sh" -o -name "*.py" | sort | sed 's|.*/||' | sed 's/^/  - /'
        fi
        echo
    fi

    if [[ "${category}" == "all" || "${category}" == "developer_experience" ]]; then
        echo "Developer Experience Scripts (${DEVELOPER_EXPERIENCE_PATH}):"
        if [[ -d "${DEVELOPER_EXPERIENCE_PATH}" ]]; then
            find "${DEVELOPER_EXPERIENCE_PATH}" -name "*.sh" -o -name "*.py" | sort | sed 's|.*/||' | sed 's/^/  - /'
        fi
        echo
    fi
}

# Function to show framework status
show_status() {
    echo "Framework Phase 2 - Status"
    echo "=========================="
    echo "Framework Root: ${FRAMEWORK_ROOT}"
    echo "Configuration: ${CONFIG_FILE}"
    echo "Logs Directory: ${LOG_DIR}"
    echo

    echo "Script Counts:"
    echo "  Automation: $(find "${AUTOMATION_PATH}" -name "*.sh" -o -name "*.py" 2>/dev/null | wc -l)"
    echo "  Workflow: $(find "${WORKFLOW_PATH}" -name "*.sh" -o -name "*.py" 2>/dev/null | wc -l)"
    echo "  Productivity: $(find "${PRODUCTIVITY_PATH}" -name "*.sh" -o -name "*.py" 2>/dev/null | wc -l)"
    echo "  Developer Experience: $(find "${DEVELOPER_EXPERIENCE_PATH}" -name "*.sh" -o -name "*.py" 2>/dev/null | wc -l)"
    echo

    echo "Environment Status:"
    echo "  Virtual Environment: ${VIRTUAL_ENV:-"Not activated"}"
    echo "  Current Branch: $(git branch --show-current 2>/dev/null || echo "Not in git repository")"
    echo "  Quality Threshold: ${QC_THRESHOLD}%"
    echo
}

# Main execution logic
main() {
    case "${1:-help}" in
        "validate")
            validate_environment
            ;;
        "execute")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 execute <category> <script_name> [args...]"
                echo "Categories: automation, workflow, productivity, developer_experience"
                exit 1
            fi
            validate_environment || exit 1
            execute_script "$2" "$3" "${@:4}"
            ;;
        "list")
            list_scripts "${2:-all}"
            ;;
        "status")
            show_status
            ;;
        "help"|*)
            echo "Framework Phase 2 - Friction Prevention Framework"
            echo "Usage: $0 <command> [options]"
            echo
            echo "Commands:"
            echo "  validate              - Validate framework environment"
            echo "  execute <cat> <name>  - Execute a framework script"
            echo "  list [category]       - List available scripts"
            echo "  status                - Show framework status"
            echo "  help                  - Show this help message"
            echo
            echo "Examples:"
            echo "  $0 execute automation automate_pr_process.sh"
            echo "  $0 execute workflow smart_env_sync.sh --validate-only"
            echo "  $0 list automation"
            echo "  $0 status"
            ;;
    esac
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
