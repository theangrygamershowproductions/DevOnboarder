#!/usr/bin/env bash
# Git sync script to handle pull/push conflicts safely

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔄 Git Sync Utility${NC}"
echo "==================="

# Check if we're in a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

# Get current branch
current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "Current branch: $current_branch"

# Fetch latest changes
echo -e "${YELLOW}📥 Fetching latest changes...${NC}"
if git fetch origin; then
    echo "✅ Fetch successful"
else
    echo -e "${RED}❌ Fetch failed${NC}"
    exit 1
fi

# Check if we're behind remote
if git status --porcelain=v1 2>/dev/null | grep -q '^##.*behind'; then
    echo -e "${YELLOW}⚠️  Local branch is behind remote${NC}"

    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --staged --quiet; then
        echo -e "${RED}❌ You have uncommitted changes. Please commit or stash them first.${NC}"
        git status --short
        exit 1
    fi

    echo -e "${YELLOW}📥 Pulling latest changes...${NC}"
    if git pull origin "$current_branch"; then
        echo -e "${GREEN}✅ Pull successful${NC}"
    else
        echo -e "${RED}❌ Pull failed - there may be conflicts${NC}"
        echo "Please resolve conflicts manually and try again."
        exit 1
    fi
fi

# Check if we have commits to push
if git status --porcelain=v1 2>/dev/null | grep -q '^##.*ahead'; then
    echo -e "${YELLOW}📤 Local branch has commits to push${NC}"

    echo -e "${YELLOW}🚀 Pushing to remote...${NC}"
    if git push origin "$current_branch"; then
        echo -e "${GREEN}✅ Push successful${NC}"
    else
        echo -e "${RED}❌ Push failed${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Repository is in sync with remote${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Git sync complete!${NC}"

# Show current status
echo ""
echo -e "${YELLOW}Current status:${NC}"
git status --short
git log --oneline -3
