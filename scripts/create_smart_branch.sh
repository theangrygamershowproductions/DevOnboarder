#!/bin/bash
# Smart branch creation with DevOnboarder patterns

set -euo pipefail

# Function to suggest branch name based on context
suggest_branch_name() {
    local context="$1"
    local timestamp
    timestamp=$(date +%Y%m%d)

    case "$context" in
        "fix")
            echo "fix/$(echo "$2" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')-$timestamp"
            ;;
        "feat")
            echo "feat/$(echo "$2" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')-$timestamp"
            ;;
        "docs")
            echo "docs/$(echo "$2" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')-$timestamp"
            ;;
        "refactor")
            echo "refactor/$(echo "$2" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')-$timestamp"
            ;;
        *)
            echo "feat/$(echo "$context" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')-$timestamp"
            ;;
    esac
}

# Function to create branch with GPG signing setup
create_clean_branch() {
    local branch_name="$1"

    echo "🌿 Creating clean branch: $branch_name"

    # Ensure we're on main and up to date
    echo "   Switching to main..."
    git checkout main

    echo "   Pulling latest changes..."
    git pull origin main

    echo "   Creating new branch..."
    git checkout -b "$branch_name"

    # Configure branch for clean signatures
    echo "   Configuring branch for clean commits..."
    git config --local commit.gpgsign true

    # Allow configurable signing key path via GIT_SIGNING_KEY, fallback to default
    SIGNING_KEY_PATH="${GIT_SIGNING_KEY:-$HOME/.ssh/ci_signing_key}"
    if [[ -f "$SIGNING_KEY_PATH" ]]; then
        git config --local user.signingkey "$SIGNING_KEY_PATH"
    else
        echo "⚠️  Signing key not found at $SIGNING_KEY_PATH; skipping user.signingkey config."
    fi

    echo "✅ Branch $branch_name created and ready"
    echo "   Current branch: $(git branch --show-current)"
}

# Function to display DevOnboarder branch workflow
show_workflow() {
    cat << 'EOF'
🌊 DevOnboarder Branch Workflow
==============================

1. Work on feature branch (never main)
2. Use safe commit: scripts/safe_commit.sh "TYPE(scope): message"
3. Push and create PR
4. Address Copilot comments with explicit resolution notes
5. Clean up after merge: scripts/cleanup_merged_branch.sh

Branch Naming Patterns:
- feat/feature-description-YYYYMMDD
- fix/bug-description-YYYYMMDD
- docs/doc-update-YYYYMMDD
- refactor/component-YYYYMMDD

EOF
}

# Main script logic
main() {
    if [[ $# -eq 0 ]]; then
        show_workflow
        echo "Usage: $0 <type> <description>"
        echo "       $0 workflow  # Show workflow guide"
        echo ""
        echo "Examples:"
        echo "  $0 feat 'Issue Closure Template System'"
        echo "  $0 fix 'Copilot Comment Resolution'"
        echo "  $0 docs 'Update README'"
        exit 1
    fi

    if [[ "$1" == "workflow" ]]; then
        show_workflow
        exit 0
    fi

    local type="$1"
    shift
    local description="$*"

    if [[ -z "$description" ]]; then
        echo "❌ Description required"
        echo "Usage: $0 $type 'your description here'"
        exit 1
    fi

    local branch_name
    branch_name=$(suggest_branch_name "$type" "$description")

    echo "Suggested branch name: $branch_name"
    read -r -p "Use this name? [Y/n]: " confirm

    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        read -r -p "Enter custom branch name: " branch_name
    fi

    create_clean_branch "$branch_name"
}

main "$@"
