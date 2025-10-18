#!/bin/bash

# DevOnboarder Agent Context Loader
# Quick context loading for AI agents starting new conversations

set -euo pipefail

echo "DevOnboarder Agent Context Loading..."
echo "====================================="
echo ""

echo "1. Project Identity & Current Status:"
echo "   Repository: DevOnboarder (theangrygamershowproductions)"
echo "   Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
echo "   Last commit: $(git log -1 --pretty=format:'%h %s' 2>/dev/null || echo 'git not available')"
echo "   Philosophy: Built to work quietly and reliably"
echo ""

echo "2. CRITICAL Policy Compliance Check:"
if [[ -f "./scripts/devonboarder_policy_check.sh" ]]; then
    ./scripts/devonboarder_policy_check.sh violations
else
    echo "   Policy check script not found - ensure you're in DevOnboarder repository"
fi
echo ""

echo "3. Key Context Documents:"
echo "   - .github/copilot-instructions.md (1929 lines - MASTER POLICIES)"
echo "   - PHASE_INDEX.md (navigation hub for all active systems)"
echo "   - docs/PRIORITY_STACK_FRAMEWORK_UPDATE.md (decision framework)"
echo "   - docs/ISSUE_DISCOVERY_TRIAGE_SOP.md (process guidelines)"
echo "   - scripts/devonboarder_policy_check.sh (policy quick access)"
echo ""

echo "4. Architecture Quick Reference:"
echo "   - Backend: Python 3.12  FastAPI (Port 8001)"
echo "   - Auth Service: FastAPI  JWT  Discord OAuth (Port 8002)"
echo "   - Discord Bot: TypeScript  Discord.js (Port 8002)"
echo "   - Frontend: React  Vite  TypeScript (Port 8081)"
echo "   - Database: PostgreSQL (production), SQLite (development)"
echo ""

echo "5. CRITICAL POLICIES TO REMEMBER:"
echo "   - ZERO TOLERANCE: Terminal output (no emojis/Unicode - causes hanging)"
echo "   - Virtual environment: ALWAYS use .venv (NEVER system install)"
echo "   - Quality gates: 95% threshold via ./scripts/qc_pre_push.sh"
echo "   - Commit safety: Use ./scripts/safe_commit.sh (NEVER --no-verify)"
echo "   - Enhanced Potato Policy: Protects sensitive files"
echo ""

echo "6. Quick Navigation Commands:"
echo "   - Policy check: ./scripts/devonboarder_policy_check.sh [area]"
echo "   - Quality validation: ./scripts/qc_pre_push.sh"
echo "   - Environment check: source .venv/bin/activate"
echo "   - Current violations: ./scripts/devonboarder_policy_check.sh violations"
echo ""

echo "Context loading complete! Ready for DevOnboarder work."
echo ""
echo "REMEMBER: When in doubt, check policies first and use existing patterns."
