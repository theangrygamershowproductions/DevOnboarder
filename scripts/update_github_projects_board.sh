#!/bin/bash
# GitHub Projects Board Update Script
# Updates DevOnboarder project board with new task execution timeline

set -euo pipefail

echo "🏗️ Updating GitHub Projects Board: DevOnboarder Task Execution Timeline"
echo "=================================================================="

# Check if GitHub CLI is available
if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI (gh) not installed"
    echo "Install: https://cli.github.com/"
    exit 1
fi

# Check authentication
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI ready"

# Project configuration
PROJECT_TITLE="DevOnboarder MVP Execution Timeline"
PROJECT_DESCRIPTION="Foundation-first Docker Service Mesh integration with coordinated task execution"

echo ""
echo "📋 Creating Project Structure..."

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
echo "📊 Project Board Structure:"
for column in "${COLUMNS[@]}"; do
    echo "   📋 $column"
done

echo ""
echo "🎫 Issues to Create/Update:"

# Week 1 Issues
echo ""
echo "📅 Week 1: Infrastructure Foundation (P0 - MVP Blocking)"
echo "   🔥 Terminal Output Enhancement (Move from Staged → Active)"
echo "   🔥 Docker Service Mesh Phase 1 (NEW - Add to Active)"

# Week 2 Issues
echo ""
echo "📅 Week 2: Quality Framework (P0 - MVP Quality)"
echo "   🔥 MVP Quality Gates Framework (Move from Staged → Active)"
echo "   🔥 Docker Service Mesh Phase 3 (NEW - Add to Active)"

# Week 3 Issues
echo ""
echo "📅 Week 3: Advanced Infrastructure (P1 - MVP Enhancement)"
echo "   ⚡ Root Artifact Guard Enhancement (Keep Staged → Activate Week 3)"
echo "   ⚡ Codex Catch System (Keep Staged → Activate Week 3)"

# Week 4 Issues
echo ""
echo "📅 Week 4: Security & Validation (P1 - Strategic)"
echo "   🔧 Agent Documentation & Validation (Keep Staged → Activate Week 4)"
echo "   🔧 CI Token Security Enhancement (Keep Staged → Activate Week 4)"

# Week 5-6 Issues
echo ""
echo "📅 Week 5-6: Post-MVP Advanced (P2 - Strategic Evolution)"
echo "   📈 Modular Runtime System (Keep Staged → Activate Week 5)"
echo "   📈 Docker Service Mesh Advanced (NEW - Add to Post-MVP)"

echo ""
echo "🏷️ Label Strategy:"
echo "   🔥 P0-MVP-BLOCKING (Week 1-2)"
echo "   ⚡ P1-MVP-ENHANCEMENT (Week 3-4)"
echo "   🔧 P1-STRATEGIC (Week 4)"
echo "   📈 P2-POST-MVP (Week 5-6)"
echo "   🐳 docker-service-mesh"
echo "   🏗️ infrastructure"
echo "   🔒 security"
echo "   📊 quality-gates"

echo ""
echo "📝 Milestone Strategy:"
echo "   🎯 MVP Phase 1 - Infrastructure (Week 1-2)"
echo "   🎯 MVP Phase 2 - Enhancement (Week 3-4)"
echo "   🎯 Post-MVP Evolution (Week 5-6)"

echo ""
echo "🔗 Dependencies to Track:"
echo "   Terminal Output → Docker Mesh Phase 1"
echo "   Docker Mesh Phase 1 → Quality Gates + Phase 3"
echo "   Quality Gates + Phase 3 → Artifact Guard"
echo "   Artifact Guard → Codex Catch"
echo "   Codex Catch → Agent Validation"
echo "   Agent Validation → Modular Runtime"

echo ""
echo "⚠️ MANUAL ACTIONS REQUIRED:"
echo ""
echo "1. 🎫 CREATE NEW PROJECT:"
echo "   gh project create --title '$PROJECT_TITLE' --body '$PROJECT_DESCRIPTION'"
echo ""
echo "2. 📋 ADD COLUMNS:"
for column in "${COLUMNS[@]}"; do
    echo "   - Add column: '$column'"
done
echo ""
echo "3. 🎫 CREATE/UPDATE ISSUES:"
echo "   - Use issue templates from .github/ISSUE_TEMPLATE/"
echo "   - Apply appropriate labels and milestones"
echo "   - Set dependencies and relationships"
echo ""
echo "4. 🔄 MOVE STAGED TASKS:"
echo "   - Update task status in codex/tasks/staged/ files"
echo "   - Change status from 'staged' to 'active' for Week 1 tasks"
echo "   - Update dependencies and integration points"
echo ""
echo "5. 📊 UPDATE TRACKING:"
echo "   - Link issues to project board columns"
echo "   - Set up automation rules for status updates"
echo "   - Configure dependency tracking"

echo ""
echo "✅ GitHub Projects Board Configuration Complete!"
echo ""
echo "🚀 Next Steps:"
echo "1. Execute manual actions above"
echo "2. Create MVP issues: ./scripts/create_mvp_issues.sh"
echo "3. Begin Week 1 implementation"
echo ""
echo "📖 Reference Documents:"
echo "   - Task Ordering: docs/TASK_ORDERING.md"
echo "   - Execution Index: codex/tasks/task_execution_index.json"
echo "   - Integration Plan: codex/tasks/integrated_task_staging_plan.md"
