#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Git sync script to handle pull/push conflicts safely

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}SYNC: Git Sync Utility"
echo "==================="

# Check if we're in a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    error_msg " Not in a git repository"
    exit 1
fi

# Get current branch
current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "Current branch: $current_branch"

# Fetch latest changes
echo -e "${YELLOW}📥 Fetching latest changes..."
if git fetch origin; then
    success "Fetch successful"
else
    error_msg " Fetch failed"
    exit 1
fi

# Check if we're behind remote
if git status --porcelain=v1 2>/dev/null | grep -q '^##.*behind'; then
    debug_msg "  Local branch is behind remote"

    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --staged --quiet; then
        error_msg " You have uncommitted changes. Please commit or stash them first."
        git status --short
        exit 1
    fi

    echo -e "${YELLOW}📥 Pulling latest changes..."
    if git pull origin "$current_branch"; then
        success_msg " Pull successful"
    else
        error_msg " Pull failed - there may be conflicts"
        echo "Please resolve conflicts manually and try again."
        exit 1
    fi
fi

# Check if we have commits to push
if git status --porcelain=v1 2>/dev/null | grep -q '^##.*ahead'; then
    echo -e "${YELLOW}📤 Local branch has commits to push"

    echo -e "${YELLOW}DEPLOY: Pushing to remote..."
    if git push origin "$current_branch"; then
        success_msg " Push successful"
    else
        error_msg " Push failed"
        exit 1
    fi
else
    success_msg " Repository is in sync with remote"
fi

echo ""
echo -e "${GREEN}🎉 Git sync complete!"

# Show current status
echo ""
echo -e "${YELLOW}Current status:"
git status --short
git log --oneline -3
