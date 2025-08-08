#!/bin/bash

# Tech Debt Attribution Tracker
# Tracks quality violations by source (Human, AI Agent, Bulk Import)

set -euo pipefail

LOG_FILE="logs/tech_debt_attribution_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs

echo "🔍 Tech Debt Attribution Analysis" | tee "$LOG_FILE"
echo "===============================" | tee -a "$LOG_FILE"
echo "Generated: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Initialize counters
MARKDOWN_VIOLATIONS=0
SHELL_VIOLATIONS=0
YAML_VIOLATIONS=0
AGENT_VIOLATIONS=0
DOCUMENTATION_VIOLATIONS=0

# Track violations by source
HUMAN_VIOLATIONS=0
AI_VIOLATIONS=0
BULK_VIOLATIONS=0
UNKNOWN_VIOLATIONS=0

echo "📋 SCANNING FOR QUALITY VIOLATIONS..." | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Function to determine source attribution based on git history and patterns
determine_source() {
    local file="$1"
    local violation="$2"

    # Check git history for clues
    local last_author
    last_author=$(git log -1 --format="%an" "$file" 2>/dev/null || echo "unknown")
    local last_commit_msg
    last_commit_msg=$(git log -1 --format="%s" "$file" 2>/dev/null || echo "unknown")

    # AI Agent patterns
    if echo "$last_commit_msg" | grep -qi "claude\|copilot\|ai\|agent\|auto-fix\|automated"; then
        echo "🤖 AI Agent"
        ((AI_VIOLATIONS++))
    # Bulk import patterns
    elif echo "$last_commit_msg" | grep -qi "bulk\|import\|migrate\|batch\|scaffold"; then
        echo "🗂️ Bulk Import"
        ((BULK_VIOLATIONS++))
    # Human patterns
    elif echo "$last_author" | grep -qi "potato\|human\|manual"; then
        echo "🧑 Human"
        ((HUMAN_VIOLATIONS++))
    else
        echo "❓ Unknown"
        ((UNKNOWN_VIOLATIONS++))
    fi
}

# 1. Markdown Linting Violations
echo "1. MARKDOWN LINTING VIOLATIONS" | tee -a "$LOG_FILE"
echo "================================" | tee -a "$LOG_FILE"

if command -v markdownlint-cli2 >/dev/null 2>&1; then
    markdown_errors=$(npx markdownlint-cli2 "**/*.md" "!**/node_modules/**" 2>&1 || true)

    if [ -n "$markdown_errors" ]; then
        echo "$markdown_errors" | while IFS= read -r line; do
            if [[ "$line" =~ ^.*\.md:.* ]]; then
                file=$(echo "$line" | cut -d: -f1)
                violation=$(echo "$line" | cut -d: -f2-)
                source=$(determine_source "$file" "$violation")
                echo "❌ $file: $violation [$source]" | tee -a "$LOG_FILE"
                ((MARKDOWN_VIOLATIONS++))
            fi
        done
    else
        echo "✅ No markdown violations found" | tee -a "$LOG_FILE"
    fi
else
    echo "⚠️ markdownlint-cli2 not available" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"

# 2. Shell Script Violations
echo "2. SHELL SCRIPT VIOLATIONS" | tee -a "$LOG_FILE"
echo "===========================" | tee -a "$LOG_FILE"

if command -v shellcheck >/dev/null 2>&1; then
    shell_files=$(find scripts/ -name "*.sh" -type f 2>/dev/null || true)

    if [ -n "$shell_files" ]; then
        echo "$shell_files" | while IFS= read -r file; do
            shell_errors=$(shellcheck "$file" 2>&1 || true)
            if [ -n "$shell_errors" ]; then
                source=$(determine_source "$file" "shellcheck violations")
                echo "❌ $file [$source]:" | tee -a "$LOG_FILE"
                echo "$shell_errors" | sed 's/^/    /' | tee -a "$LOG_FILE"
                ((SHELL_VIOLATIONS++))
            fi
        done
    fi

    if [ "$SHELL_VIOLATIONS" -eq 0 ]; then
        echo "✅ No shell script violations found" | tee -a "$LOG_FILE"
    fi
else
    echo "⚠️ shellcheck not available" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"

# 3. YAML Violations
echo "3. YAML SYNTAX VIOLATIONS" | tee -a "$LOG_FILE"
echo "==========================" | tee -a "$LOG_FILE"

if command -v yamllint >/dev/null 2>&1; then
    yaml_errors=$(yamllint .github/workflows/ config/ docker-compose*.yaml 2>&1 || true)

    if [ -n "$yaml_errors" ]; then
        echo "$yaml_errors" | while IFS= read -r line; do
            if [[ "$line" =~ ^.*\.ya?ml:.* ]]; then
                file=$(echo "$line" | cut -d: -f1)
                violation=$(echo "$line" | cut -d: -f2-)
                source=$(determine_source "$file" "$violation")
                echo "❌ $file: $violation [$source]" | tee -a "$LOG_FILE"
                ((YAML_VIOLATIONS++))
            fi
        done
    else
        echo "✅ No YAML violations found" | tee -a "$LOG_FILE"
    fi
else
    echo "⚠️ yamllint not available" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"

# 4. Agent Schema Violations
echo "4. AGENT SCHEMA VIOLATIONS" | tee -a "$LOG_FILE"
echo "===========================" | tee -a "$LOG_FILE"

if [ -f scripts/validate_agents.py ]; then
    # shellcheck disable=SC1091 # Runtime source operation
    source .venv/bin/activate 2>/dev/null || true
    agent_errors=$(python scripts/validate_agents.py 2>&1 || true)

    if echo "$agent_errors" | grep -q "ERROR\|FAIL"; then
        echo "$agent_errors" | grep "ERROR\|FAIL" | while IFS= read -r line; do
            # Extract filename from validation error
            if [[ "$line" =~ agents/.*\.md ]]; then
                file=$(echo "$line" | grep -o 'agents/[^[:space:]]*\.md')
                source=$(determine_source "$file" "schema violation")
                echo "❌ $file: Agent schema violation [$source]" | tee -a "$LOG_FILE"
                ((AGENT_VIOLATIONS++))
            fi
        done
    else
        echo "✅ No agent schema violations found" | tee -a "$LOG_FILE"
    fi
else
    echo "⚠️ Agent validation script not available" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"

# 5. Documentation Quality Violations
echo "5. DOCUMENTATION QUALITY VIOLATIONS" | tee -a "$LOG_FILE"
echo "====================================" | tee -a "$LOG_FILE"

if command -v vale >/dev/null 2>&1; then
    # shellcheck disable=SC1091 # Runtime source operation
    source .venv/bin/activate 2>/dev/null || true
    doc_errors=$(python -m vale docs/ 2>&1 || true)

    if echo "$doc_errors" | grep -q "✖\|Error"; then
        echo "$doc_errors" | grep "✖\|Error" | while IFS= read -r line; do
            if [[ "$line" =~ docs/.*\.md ]]; then
                file=$(echo "$line" | cut -d: -f1)
                violation=$(echo "$line" | cut -d: -f2-)
                source=$(determine_source "$file" "$violation")
                echo "❌ $file: $violation [$source]" | tee -a "$LOG_FILE"
                ((DOCUMENTATION_VIOLATIONS++))
            fi
        done
    else
        echo "✅ No documentation quality violations found" | tee -a "$LOG_FILE"
    fi
else
    echo "⚠️ Vale documentation linter not available" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"

# Summary Report
echo "📊 TECH DEBT ATTRIBUTION SUMMARY" | tee -a "$LOG_FILE"
echo "=================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "📋 Violation Types:" | tee -a "$LOG_FILE"
echo "  • Markdown Linting: $MARKDOWN_VIOLATIONS" | tee -a "$LOG_FILE"
echo "  • Shell Scripts: $SHELL_VIOLATIONS" | tee -a "$LOG_FILE"
echo "  • YAML Syntax: $YAML_VIOLATIONS" | tee -a "$LOG_FILE"
echo "  • Agent Schema: $AGENT_VIOLATIONS" | tee -a "$LOG_FILE"
echo "  • Documentation Quality: $DOCUMENTATION_VIOLATIONS" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

TOTAL_VIOLATIONS=$((MARKDOWN_VIOLATIONS + SHELL_VIOLATIONS + YAML_VIOLATIONS + AGENT_VIOLATIONS + DOCUMENTATION_VIOLATIONS))

echo "🔍 Attribution by Source:" | tee -a "$LOG_FILE"
echo "  • 🧑 Human: $HUMAN_VIOLATIONS" | tee -a "$LOG_FILE"
echo "  • 🤖 AI Agent: $AI_VIOLATIONS" | tee -a "$LOG_FILE"
echo "  • 🗂️ Bulk Import: $BULK_VIOLATIONS" | tee -a "$LOG_FILE"
echo "  • ❓ Unknown: $UNKNOWN_VIOLATIONS" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "📈 Total Quality Violations: $TOTAL_VIOLATIONS" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Recommendations
echo "🎯 RECOMMENDED ACTIONS" | tee -a "$LOG_FILE"
echo "======================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

if [ "$AI_VIOLATIONS" -gt 0 ]; then
    echo "🤖 AI Agent Training Needed:" | tee -a "$LOG_FILE"
    echo "  • Review NO_SHORTCUTS_POLICY.md with AI agents" | tee -a "$LOG_FILE"
    echo "  • Enhance agent guidelines with quality standards" | tee -a "$LOG_FILE"
    echo "  • Implement stricter AI agent validation" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
fi

if [ "$HUMAN_VIOLATIONS" -gt 0 ]; then
    echo "🧑 Human Process Improvement:" | tee -a "$LOG_FILE"
    echo "  • Enable pre-commit hooks for local validation" | tee -a "$LOG_FILE"
    echo "  • Training on quality standards and tooling" | tee -a "$LOG_FILE"
    echo "  • Documentation of proper development workflow" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
fi

if [ "$BULK_VIOLATIONS" -gt 0 ]; then
    echo "🗂️ Bulk Import Cleanup:" | tee -a "$LOG_FILE"
    echo "  • Schedule tech debt cleanup sprint" | tee -a "$LOG_FILE"
    echo "  • Implement validation in import scripts" | tee -a "$LOG_FILE"
    echo "  • Review and update legacy content" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
fi

if [ "$TOTAL_VIOLATIONS" -eq 0 ]; then
    echo "🎉 EXCELLENT: No quality violations detected!" | tee -a "$LOG_FILE"
    echo "✅ All files meet NO_SHORTCUTS_POLICY standards" | tee -a "$LOG_FILE"
else
    echo "🚨 ACTION REQUIRED: Quality violations need attention" | tee -a "$LOG_FILE"
    echo "📖 Reference: docs/policies/NO_SHORTCUTS_POLICY.md" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "📄 Full report saved to: $LOG_FILE" | tee -a "$LOG_FILE"

# Exit with failure if violations found (for CI integration)
exit "$TOTAL_VIOLATIONS"
