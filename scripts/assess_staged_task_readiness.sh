#!/bin/bash
# scripts/assess_staged_task_readiness.sh
# Validates readiness to implement staged tasks safely

set -e

echo "DevOnboarder Staged Task Readiness Assessment"
echo "============================================"
echo "Timestamp: $(date)"
echo

# Assessment categories
declare -A ASSESSMENT_CATEGORIES=(
    ["PREREQUISITES"]="Critical dependencies and requirements"
    ["RESOURCES"]="Team capacity and system resources"
    ["RISK_FACTORS"]="Potential disruption to MVP timeline"
    ["INTEGRATION"]="Compatibility with existing systems"
    ["TIMING"]="Optimal implementation timing"
)

# Task readiness scoring
TOTAL_SCORE=0
MAX_SCORE=0

# Function to assess category
assess_category() {
    local category="$1"
    local description="$2"
    local score=0
    local max_score=0

    echo "Assessing: $category"
    echo "Description: $description"
    echo "----------------------------------------"

    case "$category" in
        "PREREQUISITES")
            # Check terminal output compliance
            if bash scripts/terminal_zero_tolerance_validator.sh >/dev/null 2>&1; then
                echo "  Terminal Output Policy: COMPLIANT (2 points)"
                score=$((score  2))
            else
                echo "  Terminal Output Policy: NON-COMPLIANT (0 points)"
            fi
            max_score=$((max_score  2))

            # Check MVP readiness
            if bash scripts/mvp_readiness_check.sh >/dev/null 2>&1; then
                echo "  MVP Readiness: READY (3 points)"
                score=$((score  3))
            else
                echo "  MVP Readiness: NOT READY (0 points)"
            fi
            max_score=$((max_score  3))

            # Check CI pipeline health
            if command -v gh >/dev/null 2>&1; then
                ci_success=$(gh run list --limit=10 --json conclusion | jq '[.[] | select(.conclusion=="success")] | length')
                if [[ $ci_success -ge 8 ]]; then
                    echo "  CI Pipeline Health: HEALTHY (2 points)"
                    score=$((score  2))
                else
                    echo "  CI Pipeline Health: DEGRADED (0 points)"
                fi
            else
                echo "  CI Pipeline Health: UNKNOWN - GitHub CLI not available (1 point)"
                score=$((score  1))
            fi
            max_score=$((max_score  2))
            ;;

        "RESOURCES")
            # Check system resources
            memory_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
            if (( $(echo "$memory_usage < 80.0" | bc -l) )); then
                echo "  System Memory: AVAILABLE ($memory_usage% used) (2 points)"
                score=$((score  2))
            else
                echo "  System Memory: CONSTRAINED ($memory_usage% used) (0 points)"
            fi
            max_score=$((max_score  2))

            # Check disk space
            disk_usage=$(df . | awk 'NR==2{print $5}' | sed 's/%//')
            if [[ $disk_usage -lt 80 ]]; then
                echo "  Disk Space: AVAILABLE ($disk_usage% used) (1 point)"
                score=$((score  1))
            else
                echo "  Disk Space: LIMITED ($disk_usage% used) (0 points)"
            fi
            max_score=$((max_score  1))

            # Check active processes
            active_tasks=$(pgrep -c "(npm|python|docker)" || echo "0")
            if [[ $active_tasks -lt 10 ]]; then
                echo "  Process Load: LIGHT ($active_tasks processes) (2 points)"
                score=$((score  2))
            else
                echo "  Process Load: HEAVY ($active_tasks processes) (1 point)"
                score=$((score  1))
            fi
            max_score=$((max_score  2))
            ;;

        "RISK_FACTORS")
            # Check for blocking issues
            if git status --porcelain | grep -q "^"; then
                echo "  Working Directory: UNCOMMITTED CHANGES (0 points)"
            else
                echo "  Working Directory: CLEAN (2 points)"
                score=$((score  2))
            fi
            max_score=$((max_score  2))

            # Check for failing tests
            if bash scripts/run_tests.sh >/dev/null 2>&1; then
                echo "  Test Suite: PASSING (3 points)"
                score=$((score  3))
            else
                echo "  Test Suite: FAILING (0 points)"
            fi
            max_score=$((max_score  3))

            # Check for open dependency PRs
            if command -v gh >/dev/null 2>&1; then
                open_deps=$(gh pr list --state=open --label=dependencies --json number | jq length)
                if [[ $open_deps -eq 0 ]]; then
                    echo "  Dependency PRs: NONE (2 points)"
                    score=$((score  2))
                elif [[ $open_deps -le 3 ]]; then
                    echo "  Dependency PRs: MANAGEABLE ($open_deps open) (1 point)"
                    score=$((score  1))
                else
                    echo "  Dependency PRs: HIGH VOLUME ($open_deps open) (0 points)"
                fi
            else
                echo "  Dependency PRs: UNKNOWN (1 point)"
                score=$((score  1))
            fi
            max_score=$((max_score  2))
            ;;

        "INTEGRATION")
            # Check virtual environment
            if [[ -f ".venv/bin/python" ]] && [[ -f ".venv/bin/pip" ]]; then
                echo "  Virtual Environment: READY (2 points)"
                score=$((score  2))
            else
                echo "  Virtual Environment: NOT READY (0 points)"
            fi
            max_score=$((max_score  2))

            # Check service health
            services_healthy=0
            total_services=3

            if curl -sf http://localhost:8001/health >/dev/null 2>&1; then
                services_healthy=$((services_healthy  1))
            fi
            if curl -sf http://localhost:8002/health >/dev/null 2>&1; then
                services_healthy=$((services_healthy  1))
            fi
            if curl -sf http://localhost:8081 >/dev/null 2>&1; then
                services_healthy=$((services_healthy  1))
            fi

            if [[ $services_healthy -eq $total_services ]]; then
                echo "  Service Health: ALL HEALTHY ($services_healthy/$total_services) (3 points)"
                score=$((score  3))
            elif [[ $services_healthy -ge 2 ]]; then
                echo "  Service Health: MOSTLY HEALTHY ($services_healthy/$total_services) (2 points)"
                score=$((score  2))
            else
                echo "  Service Health: DEGRADED ($services_healthy/$total_services) (0 points)"
            fi
            max_score=$((max_score  3))
            ;;

        "TIMING")
            # Check current phase
            current_week=$(date %U)
            mvp_start_week=31  # Approximate MVP start (week 31 of 2025)
            weeks_into_mvp=$((current_week - mvp_start_week))

            if [[ $weeks_into_mvp -le 2 ]]; then
                echo "  MVP Phase: FOUNDATION (Week $weeks_into_mvp) (3 points)"
                score=$((score  3))
            elif [[ $weeks_into_mvp -le 4 ]]; then
                echo "  MVP Phase: FEATURE COMPLETION (Week $weeks_into_mvp) (2 points)"
                score=$((score  2))
            elif [[ $weeks_into_mvp -le 6 ]]; then
                echo "  MVP Phase: FINALIZATION (Week $weeks_into_mvp) (1 point)"
                score=$((score  1))
            else
                echo "  MVP Phase: POST-MVP (Week $weeks_into_mvp) (3 points)"
                score=$((score  3))
            fi
            max_score=$((max_score  3))

            # Check time of day (avoid peak hours)
            current_hour=$(date %H)
            if [[ $current_hour -ge 9 ]] && [[ $current_hour -le 17 ]]; then
                echo "  Time of Day: BUSINESS HOURS ($current_hour:00) (1 point)"
                score=$((score  1))
            else
                echo "  Time of Day: OFF HOURS ($current_hour:00) (2 points)"
                score=$((score  2))
            fi
            max_score=$((max_score  2))
            ;;
    esac

    echo "Category Score: $score/$max_score"
    echo

    TOTAL_SCORE=$((TOTAL_SCORE  score))
    MAX_SCORE=$((MAX_SCORE  max_score))
}

# Run assessments
for category in "${!ASSESSMENT_CATEGORIES[@]}"; do
    assess_category "$category" "${ASSESSMENT_CATEGORIES[$category]}"
done

# Calculate readiness percentage
READINESS_PERCENTAGE=$(echo "scale=1; $TOTAL_SCORE * 100 / $MAX_SCORE" | bc)

echo "Staged Task Readiness Assessment Results"
echo "======================================="
echo "Total Score: $TOTAL_SCORE/$MAX_SCORE"
echo "Readiness Percentage: $READINESS_PERCENTAGE%"
echo

# Determine readiness level
if (( $(echo "$READINESS_PERCENTAGE >= 90" | bc -l) )); then
    echo "READY: High readiness - safe to implement staged tasks"
    echo "Recommendation: Proceed with task implementation"
    exit 0
elif (( $(echo "$READINESS_PERCENTAGE >= 70" | bc -l) )); then
    echo "CONDITIONAL: Moderate readiness - implementation with caution"
    echo "Recommendation: Address medium-risk factors before proceeding"
    exit 1
elif (( $(echo "$READINESS_PERCENTAGE >= 50" | bc -l) )); then
    echo "NOT READY: Low readiness - high risk of disruption"
    echo "Recommendation: Resolve critical issues before task implementation"
    exit 2
else
    echo "BLOCKED: Critical readiness failure - implementation not recommended"
    echo "Recommendation: Focus on MVP foundation stabilization first"
    exit 3
fi
