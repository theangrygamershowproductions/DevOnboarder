#!/bin/bash
# DevOnboarder Project Navigator - Minimum Viable Navigator (MVN)
# Phase 1: Constrained experiment for Issue Management  CI Troubleshooting
#
# Purpose: Provide focused, context-aware entry points to reduce conversation overhead
# Scope: Bounded experiment to prove value before universal expansion

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="${SCRIPT_DIR}/../logs"

# Create logs directory if it doesn't exist
mkdir -p "${LOGS_DIR}"
chmod 755 "${LOGS_DIR}"

# Navigation session logging
SESSION_LOG="${LOGS_DIR}/navigation_session_$(date %Y%m%d_%H%M%S).log"

log_action() {
    echo "[$(date '%Y-%m-%d %H:%M:%S')] $1" | tee -a "${SESSION_LOG}"
}

# CRITICAL: Branch workflow validation to prevent main branch work
check_branch_workflow() {
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")

    if [[ "$current_branch" == "main" ]]; then
        echo
        echo "🚨 CRITICAL WORKFLOW VIOLATION DETECTED!"
        echo "========================================"
        echo
        echo " You are on the 'main' branch"
        echo " DevOnboarder requires feature branch workflow"
        echo
        echo " Proper DevOnboarder workflow:"
        echo "   1. git checkout main"
        echo "   2. git pull origin main"
        echo "   3. git checkout -b feat/descriptive-name"
        echo "   4. Then start work"
        echo
        echo " Auto-fix options:"
        echo "   [1] Create feature branch now (recommended)"
        echo "   [2] Continue on main (VIOLATION - not recommended)"
        echo "   [3] Exit and fix manually"
        echo
        read -r -p "Choose option [1-3]: " branch_choice

        case $branch_choice in
            1)
                echo
                read -r -p "Enter feature branch name (feat/): " branch_name
                if [[ -n "$branch_name" ]]; then
                    full_branch_name="feat/$branch_name"
                    if git checkout -b "$full_branch_name" 2>/dev/null; then
                        echo " Created and switched to branch: $full_branch_name"
                        log_action "Branch workflow violation corrected: created $full_branch_name"
                    else
                        echo " Failed to create branch. Exiting for manual fix."
                        exit 1
                    fi
                else
                    echo " No branch name provided. Exiting for manual fix."
                    exit 1
                fi
                ;;
            2)
                echo
                echo "   Continuing on main branch violates DevOnboarder workflow"
                echo "   This should only be used for emergency fixes"
                log_action "Branch workflow violation: user chose to continue on main"
                ;;
            3)
                echo "Exiting for manual branch creation..."
                exit 0
                ;;
            *)
                echo "Invalid option. Exiting for manual fix."
                exit 1
                ;;
        esac
        echo
    else
        echo " Branch workflow compliance: Working on '$current_branch'"
        log_action "Branch workflow check passed: on branch $current_branch"
    fi
}

# Display main navigation menu
show_main_menu() {
    clear
    echo "=================================="
    echo "HOME: DevOnboarder Navigator (MVN)"
    echo "=================================="
    echo
    echo "Phase 1 Experiment: Issue Management  CI Focus"
    echo
    echo "Select your focus area:"
    echo
    echo "  [1]  Issue Management"
    echo "      Sprint operations, triage, GitHub issues"
    echo
    echo "  [2]  CI/CD Troubleshooting"
    echo "      Pipeline failures, quality gates, service issues"
    echo
    echo "  [9]  Navigation Metrics"
    echo "      View MVN experiment results"
    echo
    echo "  [0] Exit"
    echo
    echo "=================================="
}

# Load context for Issue Management
load_issue_management_context() {
    log_action "Loading Issue Management context"
    echo
    echo "TARGET: ISSUE MANAGEMENT CONTEXT LOADED"
    echo "=================================="
    echo
    echo " Current State:"
    echo "• 63 total issues analyzed and organized"
    echo "• 100% priority labeling complete (18 High, 32 Medium, 13 Low)"
    echo "• Strategic milestones: 5 milestones with 37 issue assignments"
    echo "• Sprint 1: COMPLETE (Issues #1437, #1315 resolved)"
    echo
    echo "TARGET: Active Framework:"
    echo "• Strategic Planning Framework v1.0.0"
    echo "• Issue Management Initiative - Administrative Triage COMPLETE"
    echo
    echo " Common Tasks:"
    echo "• Sprint execution and monitoring"
    echo "• Issue triage operations"
    echo "• Priority labeling and milestone assignment"
    echo "• Administrative reporting"
    echo
    echo "LINK: Key Files:"
    echo "• docs/initiatives/github-issue-management/administrative_triage_summary.md"
    echo "• scripts/analyze_issue_triage.py"
    echo "• logs/administrative_triage_analysis.md"
    echo
    echo "▶️ Ready for focused Issue Management conversation"
    echo "   Context pre-loaded - no need to re-explain project structure"
    echo
    read -r -p "Press Enter to continue with AI conversation..."
}

# Load context for CI Troubleshooting
load_ci_troubleshooting_context() {
    log_action "Loading CI/CD Troubleshooting context"
    echo
    echo " CI/CD TROUBLESHOOTING CONTEXT LOADED"
    echo "======================================="
    echo
    echo " Quality Standards:"
    echo "• 95% quality threshold across 8 metrics"
    echo "• Test Coverage: Backend 96%, Bot 100%, Frontend 100%"
    echo "• Virtual environment MANDATORY for all operations"
    echo
    echo "BUILD: Service Architecture:"
    echo "• 8 services: DevOnboarder (8000), XP API (8001), Auth (8002),"
    echo "  Dashboard (8003), Integration (8081), PostgreSQL (5432)"
    echo "• Docker-based multi-service environment"
    echo "• Environment: .venv required, Node.js 22, Python 3.12"
    echo
    echo " Common Issues:"
    echo "• CI pipeline failures and GitHub Actions debugging"
    echo "• Test coverage validation and quality gate failures"
    echo "• Service connectivity and Docker environment issues"
    echo "• Terminal output compliance (ZERO TOLERANCE for violations)"
    echo
    echo " Key Tools:"
    echo "• scripts/qc_pre_push.sh - 95% quality validation"
    echo "• scripts/run_tests.sh - comprehensive test runner"
    echo "• scripts/safe_commit.sh - NEVER use git commit directly"
    echo
    echo "▶️ Ready for focused CI/CD troubleshooting conversation"
    echo "   Architecture and standards pre-loaded"
    echo
    read -r -p "Press Enter to continue with AI conversation..."
}

# Show navigation metrics for MVN experiment
show_navigation_metrics() {
    log_action "Viewing navigation metrics"
    echo
    echo " MVN EXPERIMENT METRICS"
    echo "========================"
    echo
    echo "🧪 Phase 1 Results:"
    echo "• Navigation sessions: $(find "${LOGS_DIR}" -name "navigation_session_*.log" | wc -l)"
    echo "• Issue Management focus sessions: $(grep -l "Issue Management" "${LOGS_DIR}"/navigation_session_*.log 2>/dev/null | wc -l)"
    echo "• CI Troubleshooting focus sessions: $(grep -l "CI/CD Troubleshooting" "${LOGS_DIR}"/navigation_session_*.log 2>/dev/null | wc -l)"
    echo
    echo " Success Indicators:"
    echo "• Reduced context-building conversations"
    echo "• Faster task focus and resolution"
    echo "• Consistent use of pre-loaded context"
    echo
    echo "TARGET: Next Phase Readiness:"
    echo "• If 5 successful sessions  Expand to more domains"
    echo "• If clear efficiency gains  Extract as universal template"
    echo "• If minimal usage  Refine or discontinue"
    echo
    read -r -p "Press Enter to return to main menu..."
}

# Main navigation loop
main() {
    log_action "Starting DevOnboarder Navigator MVN session"

    # CRITICAL: Branch workflow validation
    check_branch_workflow

    while true; do
        show_main_menu
        read -r -p "Choose option [0-2,9]: " choice

        case $choice in
            1)
                log_action "User selected: Issue Management"
                load_issue_management_context
                log_action "Issue Management context session completed"
                break
                ;;
            2)
                log_action "User selected: CI/CD Troubleshooting"
                load_ci_troubleshooting_context
                log_action "CI/CD Troubleshooting context session completed"
                break
                ;;
            9)
                show_navigation_metrics
                ;;
            0)
                log_action "User exited navigation"
                echo "Goodbye! 👋"
                exit 0
                ;;
            *)
                echo
                echo " Invalid option. Please choose 0, 1, 2, or 9."
                echo
                read -r -p "Press Enter to continue..."
                ;;
        esac
    done

    log_action "Navigation session ended - transitioning to AI conversation"
}

# Run the navigator
main "$@"
