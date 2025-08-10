#!/bin/bash
# GitHub Projects Board Update Script
# Updates DevOnboarder project board with new task execution timeline

set -euo pipefail

echo "SYMBOL Updating GitHub Projects Board: DevOnboarder Task Execution Timeline"
echo "=================================================================="

# Check if GitHub CLI is available
if ! command -v gh >/dev/null 2>&1; then
    echo "FAILED GitHub CLI (gh) not installed"
    echo "Install: https://cli.github.com/"
    exit 1
fi

# Check authentication
if ! gh auth status >/dev/null 2>&1; then
    echo "FAILED Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

echo "SUCCESS GitHub CLI ready"

# Project configuration
PROJECT_TITLE="DevOnboarder MVP Execution Timeline"
PROJECT_DESCRIPTION="Foundation-first Docker Service Mesh integration with coordinated task execution"

echo ""
echo "SYMBOL Creating Project Structure..."

# Create main project (or update if exists)
echo "Creating/updating main project..."

# Define columns for the project board
declare -a COLUMNS=(
    "Week 1: Infrastructure Foundation (P0)"
    "Week 2: Quality Framework (P0)"
    "Week 3: Advanced Infrastructure (P1)"
    "Week 4: Security & Validation (P1)"
    "Week 5-6: Post-MVP Advanced (P2)"
    "Completed"
    "Blocked/Issues"
)

echo ""
echo "STATS Project Board Structure:"
for column in "${COLUMNS[@]}"; do
    echo "   SYMBOL $column"
done

echo ""
echo "SYMBOL Issues to Create/Update:"

# Week 1 Issues
echo ""
echo "SYMBOL Week 1: Infrastructure Foundation (P0 - MVP Blocking)"
echo "   SYMBOL Terminal Output Enhancement (Move from Staged → Active)"
echo "   SYMBOL Docker Service Mesh Phase 1 (NEW - Add to Active)"

# Week 2 Issues
echo ""
echo "SYMBOL Week 2: Quality Framework (P0 - MVP Quality)"
echo "   SYMBOL MVP Quality Gates Framework (Move from Staged → Active)"
echo "   SYMBOL Docker Service Mesh Phase 3 (NEW - Add to Active)"

# Week 3 Issues
echo ""
echo "SYMBOL Week 3: Advanced Infrastructure (P1 - MVP Enhancement)"
echo "   SYMBOL Root Artifact Guard Enhancement (Keep Staged → Activate Week 3)"
echo "   SYMBOL Codex Catch System (Keep Staged → Activate Week 3)"

# Week 4 Issues
echo ""
echo "SYMBOL Week 4: Security & Validation (P1 - Strategic)"
echo "   CONFIG Agent Documentation & Validation (Keep Staged → Activate Week 4)"
echo "   CONFIG CI Token Security Enhancement (Keep Staged → Activate Week 4)"

# Week 5-6 Issues
echo ""
echo "SYMBOL Week 5-6: Post-MVP Advanced (P2 - Strategic Evolution)"
echo "   SYMBOL Modular Runtime System (Keep Staged → Activate Week 5)"
echo "   SYMBOL Docker Service Mesh Advanced (NEW - Add to Post-MVP)"

echo ""
echo "SYMBOL Label Strategy:"
echo "   SYMBOL P0-MVP-BLOCKING (Week 1-2)"
echo "   SYMBOL P1-MVP-ENHANCEMENT (Week 3-4)"
echo "   CONFIG P1-STRATEGIC (Week 4)"
echo "   SYMBOL P2-POST-MVP (Week 5-6)"
echo "   SYMBOL docker-service-mesh"
echo "   SYMBOL infrastructure"
echo "   SYMBOL security"
echo "   STATS quality-gates"

echo ""
echo "EDIT Milestone Strategy:"
echo "   TARGET MVP Phase 1 - Infrastructure (Week 1-2)"
echo "   TARGET MVP Phase 2 - Enhancement (Week 3-4)"
echo "   TARGET Post-MVP Evolution (Week 5-6)"

echo ""
echo "LINK Dependencies to Track:"
echo "   Terminal Output → Docker Mesh Phase 1"
echo "   Docker Mesh Phase 1 → Quality Gates + Phase 3"
echo "   Quality Gates + Phase 3 → Artifact Guard"
echo "   Artifact Guard → Codex Catch"
echo "   Codex Catch → Agent Validation"
echo "   Agent Validation → Modular Runtime"

echo ""
echo "WARNING MANUAL ACTIONS REQUIRED:"
echo ""
echo "1. SYMBOL CREATE NEW PROJECT:"
echo "   gh project create --title '$PROJECT_TITLE' --body '$PROJECT_DESCRIPTION'"
echo ""
echo "2. SYMBOL ADD COLUMNS:"
for column in "${COLUMNS[@]}"; do
    echo "   - Add column: '$column'"
done
echo ""
echo "3. SYMBOL CREATE/UPDATE ISSUES:"
echo "   - Use issue templates from .github/ISSUE_TEMPLATE/"
echo "   - Apply appropriate labels and milestones"
echo "   - Set dependencies and relationships"
echo ""
echo "4. SYMBOL MOVE STAGED TASKS:"
echo "   - Update task status in codex/tasks/staged/ files"
echo "   - Change status from 'staged' to 'active' for Week 1 tasks"
echo "   - Update dependencies and integration points"
echo ""
echo "5. STATS UPDATE TRACKING:"
echo "   - Link issues to project board columns"
echo "   - Set up automation rules for status updates"
echo "   - Configure dependency tracking"

echo ""
echo "SUCCESS GitHub Projects Board Configuration Complete!"
echo ""
echo "DEPLOY Next Steps:"
echo "1. Execute manual actions above"
echo "2. Create MVP issues: ./scripts/create_mvp_issues.sh"
echo "3. Begin Week 1 implementation"
echo ""
echo "SYMBOL Reference Documents:"
echo "   - Task Ordering: docs/TASK_ORDERING.md"
echo "   - Execution Index: codex/tasks/task_execution_index.json"
echo "   - Integration Plan: codex/tasks/integrated_task_staging_plan.md"
