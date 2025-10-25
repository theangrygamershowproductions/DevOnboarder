#!/usr/bin/env bash
# Commit message guide and examples for DevOnboarder
# Helps developers understand proper commit message conventions

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}📝 DevOnboarder Commit Message Guide${NC}"
echo "===================================="
echo ""
echo -e "${YELLOW}This guide helps you write proper commit messages following DevOnboarder conventions.${NC}"
echo ""

show_examples() {
    echo -e "${BLUE}🎯 Commit Type Examples${NC}"
    echo "======================"
    echo ""

    echo -e "${CYAN}FEAT: New features or functionality${NC}"
    echo "  FEAT(auth): add JWT token validation middleware"
    echo "  FEAT(bot): implement new /onboard command with role assignment"
    echo "  FEAT(api): add user profile endpoints with validation"
    echo "  FEAT(scripts): add comprehensive branch cleanup utilities"
    echo ""

    echo -e "${CYAN}FIX: Bug fixes${NC}"
    echo "  FIX(auth): resolve token expiration handling"
    echo "  FIX(bot): correct Discord permission validation logic"
    echo "  FIX(ci): resolve shellcheck Unicode character corruption"
    echo "  FIX(frontend): fix React component state management"
    echo ""

    echo -e "${CYAN}DOCS: Documentation changes${NC}"
    echo "  DOCS: update README with new git workflow utilities"
    echo "  DOCS: add comprehensive API documentation for auth service"
    echo "  DOCS: update branch cleanup analysis and procedures"
    echo "  DOCS(setup): enhance environment configuration guide"
    echo ""

    echo -e "${CYAN}CHORE: Maintenance and tooling${NC}"
    echo "  CHORE(scripts): update automation utilities with error handling"
    echo "  CHORE(ci): enhance GitHub Actions workflow reliability"
    echo "  CHORE(deps): update Python dependencies to latest versions"
    echo "  CHORE: clean up temporary files and organize repository"
    echo ""

    echo -e "${CYAN}REFACTOR: Code restructuring${NC}"
    echo "  REFACTOR(auth): extract JWT utility functions to separate module"
    echo "  REFACTOR(bot): reorganize command handlers for better maintainability"
    echo "  REFACTOR: consolidate error handling patterns across services"
    echo ""

    echo -e "${CYAN}TEST: Testing related changes${NC}"
    echo "  TEST(auth): add comprehensive JWT validation test coverage"
    echo "  TEST(bot): increase Discord command testing to 100% coverage"
    echo "  TEST: enhance integration test suite for API endpoints"
    echo ""

    echo -e "${CYAN}CI: Continuous Integration changes${NC}"
    echo "  CI: add automated branch cleanup workflow"
    echo "  CI: enhance pre-commit hooks with additional validation"
    echo "  CI(security): add dependency vulnerability scanning"
    echo ""

    echo -e "${CYAN}STYLE: Code formatting${NC}"
    echo "  STYLE: apply black formatting to Python files"
    echo "  STYLE(scripts): fix shellcheck violations across automation"
    echo "  STYLE: resolve markdownlint issues in documentation"
    echo ""
}

show_scope_guide() {
    echo -e "${BLUE}🎯 Scope Guidelines${NC}"
    echo "=================="
    echo ""
    echo -e "${CYAN}Common scopes in DevOnboarder:${NC}"
    echo "  auth      - Authentication service changes"
    echo "  bot       - Discord bot related changes"
    echo "  frontend  - React frontend changes"
    echo "  api       - Backend API changes"
    echo "  scripts   - Automation script changes"
    echo "  ci        - CI/CD pipeline changes"
    echo "  docs      - Documentation changes (can be omitted for DOCS type)"
    echo "  config    - Configuration file changes"
    echo "  deps      - Dependency updates"
    echo "  security  - Security-related changes"
    echo ""
}

show_message_structure() {
    echo -e "${BLUE}📐 Message Structure${NC}"
    echo "==================="
    echo ""
    echo -e "${CYAN}Format:${NC} TYPE(scope): subject"
    echo ""
    echo -e "${CYAN}Rules:${NC}"
    echo "  ✅ TYPE must be UPPERCASE (FEAT, FIX, DOCS, etc.)"
    echo "  ✅ scope is optional but recommended (lowercase)"
    echo "  ✅ subject should be imperative mood (\"add\" not \"added\")"
    echo "  ✅ subject should be descriptive and concise"
    echo "  ✅ no period at the end of subject"
    echo "  ✅ keep under 72 characters for better git log display"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  ✅ FEAT(auth): add JWT token validation middleware"
    echo "  ✅ FIX(bot): resolve Discord connection timeout handling"
    echo "  ✅ DOCS: update git workflow utilities documentation"
    echo ""
    echo -e "${CYAN}Avoid:${NC}"
    echo "  ❌ fix bug (too vague)"
    echo "  ❌ Updated documentation (wrong tense)"
    echo "  ❌ feat: add feature (wrong case)"
    echo "  ❌ FEAT(auth): Added JWT validation. (wrong tense, has period)"
    echo ""
}

show_interactive_helper() {
    echo -e "${BLUE}🤖 Interactive Commit Helper${NC}"
    echo "============================="
    echo ""
    echo "Let's build a commit message step by step!"
    echo ""

    # Step 1: Choose type
    echo -e "${CYAN}Step 1: What type of change is this?${NC}"
    echo "1. FEAT - New feature or functionality"
    echo "2. FIX - Bug fix"
    echo "3. DOCS - Documentation change"
    echo "4. CHORE - Maintenance/tooling"
    echo "5. REFACTOR - Code restructuring"
    echo "6. TEST - Testing related"
    echo "7. CI - CI/CD changes"
    echo "8. STYLE - Code formatting"
    echo ""
    read -r -p "Select type (1-8): " type_choice

    case $type_choice in
        1) commit_type="FEAT" ;;
        2) commit_type="FIX" ;;
        3) commit_type="DOCS" ;;
        4) commit_type="CHORE" ;;
        5) commit_type="REFACTOR" ;;
        6) commit_type="TEST" ;;
        7) commit_type="CI" ;;
        8) commit_type="STYLE" ;;
        *) commit_type="CHORE" ;;
    esac

    echo "Selected: $commit_type"
    echo ""

    # Step 2: Choose scope
    echo -e "${CYAN}Step 2: What component does this affect?${NC}"
    echo "1. auth - Authentication service"
    echo "2. bot - Discord bot"
    echo "3. frontend - React frontend"
    echo "4. api - Backend API"
    echo "5. scripts - Automation scripts"
    echo "6. ci - CI/CD pipelines"
    echo "7. config - Configuration"
    echo "8. No scope (just the type)"
    echo ""
    read -r -p "Select scope (1-8): " scope_choice

    case $scope_choice in
        1) scope="(auth)" ;;
        2) scope="(bot)" ;;
        3) scope="(frontend)" ;;
        4) scope="(api)" ;;
        5) scope="(scripts)" ;;
        6) scope="(ci)" ;;
        7) scope="(config)" ;;
        8) scope="" ;;
        *) scope="" ;;
    esac

    echo ""

    # Step 3: Subject
    echo -e "${CYAN}Step 3: Describe what you did (imperative mood):${NC}"
    echo "Examples: \"add user validation\", \"fix timeout handling\", \"update documentation\""
    read -r -p "Subject: " subject

    # Build the message
    if [ -n "$scope" ]; then
        commit_msg="${commit_type}${scope}: ${subject}"
    else
        commit_msg="${commit_type}: ${subject}"
    fi

    echo ""
    echo -e "${GREEN}🎉 Generated commit message:${NC}"
    echo "  $commit_msg"
    echo ""
    echo -e "${YELLOW}💡 Copy this message and use it with git commit -m \"$commit_msg\"${NC}"
    echo "   Or use ./scripts/commit_changes.sh and select the custom message option."
    echo ""
}

show_current_changes() {
    echo -e "${BLUE}🔍 Current Changes Analysis${NC}"
    echo "=========================="
    echo ""

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ Not in a git repository"
        return
    fi

    # Check for staged changes
    if git diff --staged --quiet; then
        echo "No staged changes found."

        # Check for unstaged changes
        if ! git diff --quiet; then
            echo ""
            echo -e "${YELLOW}Unstaged changes found:${NC}"
            git diff --name-only | head -10
            echo ""
            echo "💡 Run 'git add .' to stage changes, then use this guide again."
        else
            echo "Working directory is clean."
        fi
        return
    fi

    # Analyze staged changes
    changed_files=$(git diff --staged --name-only)
    changed_count=$(echo "$changed_files" | wc -l)

    echo "Staged files ($changed_count total):"
    echo "$changed_files" | head -10
    if [ "$changed_count" -gt 10 ]; then
        echo "... and $((changed_count - 10)) more files"
    fi
    echo ""

    # Suggest commit types based on files
    echo -e "${CYAN}Suggested commit types based on your changes:${NC}"

    if echo "$changed_files" | grep -q "\.md$"; then
        echo "  📝 DOCS - You have documentation files"
    fi

    if echo "$changed_files" | grep -q "scripts/"; then
        echo "  🔧 CHORE(scripts) or FEAT(scripts) - You have script changes"
    fi

    if echo "$changed_files" | grep -q "\.py$"; then
        echo "  🐍 FEAT, FIX, or REFACTOR - You have Python changes"
    fi

    if echo "$changed_files" | grep -q "\.(js|ts)$"; then
        echo "  ⚡ FEAT, FIX, or REFACTOR - You have JavaScript/TypeScript changes"
    fi

    if echo "$changed_files" | grep -q "\.(yml|yaml)$"; then
        echo "  ⚙️ CI or CONFIG - You have YAML configuration changes"
    fi

    echo ""
}

# Main menu
main_menu() {
    echo -e "${GREEN}📚 What would you like to learn about?${NC}"
    echo "====================================="
    echo "1. Show commit message examples"
    echo "2. Show scope guidelines"
    echo "3. Show message structure rules"
    echo "4. Interactive commit message builder"
    echo "5. Analyze my current changes"
    echo "6. Exit"
    echo ""

    read -r -p "Select option (1-6): " choice

    case $choice in
        1)
            show_examples
            echo ""
            main_menu
            ;;
        2)
            show_scope_guide
            echo ""
            main_menu
            ;;
        3)
            show_message_structure
            echo ""
            main_menu
            ;;
        4)
            show_interactive_helper
            echo ""
            main_menu
            ;;
        5)
            show_current_changes
            echo ""
            main_menu
            ;;
        6)
            echo "👋 Happy committing!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            main_menu
            ;;
    esac
}

# Start the guide
main_menu
