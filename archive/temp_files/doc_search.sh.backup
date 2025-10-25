#!/usr/bin/env bash
# DevOnboarder Smart Documentation Search
# Provides keyword-based module discovery with contextual suggestions

set -euo pipefail

# Logging setup
mkdir -p logs
LOG_FILE="logs/doc_search_$(date +%Y%m%d_%H%M%S).log"

# Function for smart documentation search
devonboarder-search() {
    local query="$1"
    local verbose="${2:-false}"

    echo "🔍 DevOnboarder Documentation Search"
    echo "Query: '$query'"
    echo "======================================"

    # Convert to lowercase for matching
    local query_lower
    query_lower=$(echo "$query" | tr '[:upper:]' '[:lower:]')

    # Primary keyword mapping (ordered from most specific to least specific)
    case "$query_lower" in
        *"modulenotfounderror"*|*"virtual environment"*|*"venv"*)
            echo "📚 Primary Match: Virtual Environment Issues"
            echo "   → docs/policies/virtual-environment-policy.md"
            echo "   → docs/troubleshooting/common-issues-resolution.md"
            echo ""
            echo "Quick Fix Commands:"
            echo "   source .venv/bin/activate"
            echo "   pip install -e .[test]"
            ;;

        *"terminal hanging"*|*"emoji"*|*"unicode"*)
            echo "📚 Primary Match: Terminal Output Issues"
            echo "   → docs/policies/terminal-output-policy.md"
            echo ""
            echo "Critical Rules:"
            echo "   ❌ Never use emojis in echo commands"
            echo "   ❌ Never use multi-line echo"
            echo "   ✅ Use individual echo commands with plain text"
            ;;

        *"commit message"*|*"safe commit"*)
            echo "📚 Primary Match: Git & Commit Standards"
            echo "   → docs/development/commit-message-standards.md"
            echo "   → docs/development/development-workflow.md"
            echo ""
            echo "Quick Fix Commands:"
            echo "   ./scripts/safe_commit.sh 'TYPE(scope): description'"
            echo "   # Never use git commit directly"
            ;;

        *"potato policy"*|*"secret"*|*".env"*)
            echo "📚 Primary Match: Security & File Protection"
            echo "   → docs/policies/enhanced-potato-policy.md"
            echo "   → docs/policies/environment-variable-management.md"
            echo ""
            echo "Key Points:"
            echo "   - Potato.md contains SSH keys and setup"
            echo "   - All .env files are protected"
            echo "   - Security violations block CI"
            ;;

        *"ci failure"*|*"quality control"*|*"pre-commit"*)
            echo "📚 Primary Match: CI/CD & Quality Control"
            echo "   → docs/policies/quality-control-policy.md"
            echo "   → docs/troubleshooting/ci-troubleshooting-framework.md"
            echo "   → docs/policies/ci-hygiene-artifact-management.md"
            echo ""
            echo "Quick Fix Commands:"
            echo "   ./scripts/qc_pre_push.sh"
            echo "   ./scripts/run_tests.sh"
            ;;

        *"discord"*|*"bot"*)
            echo "📚 Primary Match: Discord Bot Development"
            echo "   → docs/development/discord-bot-patterns.md"
            echo "   → docs/development/service-integration-patterns.md"
            echo ""
            echo "Key Info:"
            echo "   - Multi-guild support (dev/prod)"
            echo "   - Commands: /verify, /dependency_inventory, /qa_checklist"
            echo "   - Environment detection via Guild ID"
            ;;

        *"fastapi"*|*"api"*|*"cors"*)
            echo "📚 Primary Match: API & Service Integration"
            echo "   → docs/development/api-conventions.md"
            echo "   → docs/development/service-integration-patterns.md"
            echo ""
            echo "Service Ports:"
            echo "   - Auth Service: 8002"
            echo "   - XP Service: 8001"
            echo "   - Discord Integration: 8081"
            echo "   - Dashboard: 8003"
            ;;

        *"database"*|*"alembic"*|*"sqlalchemy"*)
            echo "📚 Primary Match: Database Management"
            echo "   → docs/development/database-patterns.md"
            echo "   → docs/development/service-integration-patterns.md"
            echo ""
            echo "Common Commands:"
            echo "   - Migrations: Alembic for schema changes"
            echo "   - Models: SQLAlchemy with relationships"
            ;;

        *"testing"*|*"pytest"*|*"coverage"*)
            echo "📚 Primary Match: Testing & Coverage"
            echo "   → docs/development/testing-requirements.md"
            echo "   → docs/policies/quality-control-policy.md"
            echo ""
            echo "Coverage Thresholds:"
            echo "   - Python backend: 96%+"
            echo "   - TypeScript bot: 100%"
            echo "   - React frontend: 100% statements"
            ;;

        *"linting"*|*"black"*|*"ruff"*)
            echo "📚 Primary Match: Code Quality & Linting"
            echo "   → docs/development/code-quality-requirements.md"
            echo "   → docs/policies/quality-control-policy.md"
            echo ""
            echo "Tools:"
            echo "   - Python: ruff (linting), black (formatting)"
            echo "   - TypeScript: ESLint + Prettier"
            ;;

        *)
            echo "🔍 No direct keyword match found. Searching content..."

            # Full-text search across documentation
            local search_results=""
            if [ -d "docs/" ]; then
                search_results=$(grep -r -i "$query" docs/ --include="*.md" 2>/dev/null || true)
            fi

            if [ -n "$search_results" ]; then
                echo ""
                echo "📄 Content Matches Found:"
                echo "$search_results" | head -10 | while IFS= read -r line; do
                    echo "   $line"
                done

                local line_count
                line_count=$(echo "$search_results" | wc -l)
                if [ "$line_count" -gt 10 ]; then
                    echo "   ... and $((line_count - 10)) more matches"
                fi
            else
                echo ""
                echo "❌ No matches found for '$query'"
                echo ""
                echo "💡 Try these common searches:"
                echo "   devonboarder-search 'virtual environment'"
                echo "   devonboarder-search 'ci failure'"
                echo "   devonboarder-search 'terminal hanging'"
                echo "   devonboarder-search 'commit message'"
                echo "   devonboarder-search 'discord bot'"
                echo ""
                echo "📚 Or browse: docs/quick-reference/MODULE_OVERVIEW.md"
            fi
            ;;
    esac

    # Context-aware suggestions based on current situation
    echo ""
    echo "🎯 Context-Aware Suggestions:"

    # Check git status for context
    if git status --porcelain 2>/dev/null | grep -q .; then
        echo "   📝 Uncommitted changes detected"
        echo "      Consider: devonboarder-search 'commit message'"
    fi

    # Check if in virtual environment
    if [ -z "${VIRTUAL_ENV:-}" ]; then
        echo "   ⚠️  Virtual environment not active"
        echo "      Consider: devonboarder-search 'virtual environment'"
    fi

    # Check current directory for context
    if [ "$(basename "$PWD")" = "DevOnboarder" ]; then
        local current_branch
        current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        echo "   🌿 Current branch: $current_branch"
        if [ "$current_branch" != "main" ]; then
            echo "      Consider: devonboarder-search 'development workflow'"
        fi
    fi

    echo ""
    echo "📖 Quick Reference: docs/quick-reference/"
    echo "   - MODULE_OVERVIEW.md - Complete module navigation"
    echo "   - NEW_DEVELOPER.md - New developer onboarding"
    echo "   - CI_CD_SPECIALIST.md - CI/CD troubleshooting"

    # Log search for analytics
    if [ "$verbose" = "true" ]; then
        echo "$(date): Search query '$query'" >> "$LOG_FILE"
    fi
}

# Interactive search mode
interactive-doc-search() {
    echo "🔍 DevOnboarder Interactive Documentation Search"
    echo "=============================================="
    echo ""
    echo "Type your search query or 'quit' to exit:"

    while true; do
        echo -n "search> "
        read -r query

        if [ "$query" = "quit" ] || [ "$query" = "exit" ] || [ "$query" = "q" ]; then
            echo "👋 Search session ended"
            break
        fi

        if [ -n "$query" ]; then
            echo ""
            devonboarder-search "$query" true
            echo ""
            echo "----------------------------------------"
        fi
    done
}

# CLI mode
if [ $# -eq 0 ]; then
    echo "Usage: $0 '<search-query>'"
    echo "   or: $0 --interactive"
    echo ""
    echo "Examples:"
    echo "   $0 'virtual environment'"
    echo "   $0 'ci failure'"
    echo "   $0 'terminal hanging'"
    exit 1
fi

if [ "$1" = "--interactive" ] || [ "$1" = "-i" ]; then
    interactive-doc-search
else
    devonboarder-search "$*"
fi
