#!/bin/bash
# Automated post-merge cleanup for DevOnboarder workflow

set -euo pipefail

echo "🧹 DevOnboarder Post-Merge Cleanup"
echo "================================="

# Helper function to get merged branches
get_merged_branches() {
    git branch --merged main | grep -v "main" | grep -v "\*" | xargs
}

# Function to detect merged branches
detect_merged_branches() {
    echo "🔍 Detecting merged branches..."

    # Get branches that have been merged to main
    local merged_branches
    merged_branches=$(get_merged_branches)

    if [[ -n "$merged_branches" ]]; then
        echo "📋 Merged branches found:"
        echo "$merged_branches" | tr ' ' '\n' | while read -r branch; do
            echo "  - $branch"
        done
        return 0
    else
        echo "✅ No merged branches to clean up"
        return 1
    fi
}

# Function to clean up local branches
cleanup_local_branches() {
    echo "🗑️  Cleaning up local merged branches..."

    local merged_branches
    merged_branches=$(get_merged_branches)

    if [[ -n "$merged_branches" ]]; then
        echo "$merged_branches" | tr ' ' '\n' | while read -r branch; do
            echo "   Deleting local branch: $branch"
            git branch -d "$branch"
        done
        echo "✅ Local branches cleaned up"
    fi
}

# Function to clean up remote tracking branches
cleanup_remote_branches() {
    echo "🌐 Cleaning up remote tracking branches..."

    echo "   Pruning remote tracking branches..."
    git remote prune origin

    echo "✅ Remote tracking branches cleaned up"
}

# Function to update main branch
update_main_branch() {
    echo "🔄 Updating main branch..."

    local current_branch
    current_branch=$(git branch --show-current)

    if [[ "$current_branch" != "main" ]]; then
        echo "   Switching to main..."
        git checkout main
    fi

    echo "   Pulling latest changes..."
    git pull origin main

    echo "✅ Main branch updated"
}

# Function to clean up logs and artifacts
cleanup_artifacts() {
    echo "🧽 Cleaning up artifacts..."

    if [[ -f "scripts/manage_logs.sh" ]]; then
        echo "   Running log cleanup..."
        bash scripts/manage_logs.sh clean --days 3
    fi

    if [[ -f "scripts/clean_pytest_artifacts.sh" ]]; then
        echo "   Cleaning pytest artifacts..."
        bash scripts/clean_pytest_artifacts.sh
    fi

    echo "✅ Artifacts cleaned up"
}

# Function to show cleanup summary
show_summary() {
    echo "================================="
    echo "📊 Cleanup Summary:"
    echo "   Current branch: $(git branch --show-current)"
    echo "   Local branches: $(git branch | wc -l) total"
    echo "   Working directory: $(git status --porcelain | wc -l) changes"
    echo "✅ Post-merge cleanup complete"
}

# Main execution
main() {
    local force_cleanup=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force|-f)
                force_cleanup=true
                shift
                ;;
            --help|-h)
                cat << 'EOF'
DevOnboarder Post-Merge Cleanup

Usage: cleanup_merged_branch.sh [options]

Options:
  --force, -f    Force cleanup without confirmation
  --help, -h     Show this help message

This script:
1. Updates main branch
2. Detects and removes merged local branches
3. Cleans up remote tracking branches
4. Removes old logs and artifacts
5. Shows cleanup summary
EOF
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    update_main_branch

    if detect_merged_branches; then
        if [[ "$force_cleanup" == "true" ]]; then
            cleanup_local_branches
        else
            read -r -p "Clean up merged branches? [Y/n]: " confirm_cleanup
            if [[ ! "$confirm_cleanup" =~ ^[Nn]$ ]]; then
                cleanup_local_branches
            fi
        fi
    fi

    cleanup_remote_branches
    cleanup_artifacts
    show_summary
}

main "$@"
