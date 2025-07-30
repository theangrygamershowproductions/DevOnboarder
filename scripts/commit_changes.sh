#!/usr/bin/env bash
# Quick commit script to handle staged and unstaged changes

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔍 Checking Git Status${NC}"
echo "======================="

# Check if we're in a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
echo ""

# Show current status
echo -e "${YELLOW}Git Status:${NC}"
git status --short

echo ""
echo -e "${YELLOW}Staged Changes:${NC}"
git diff --staged --name-status

echo ""
echo -e "${YELLOW}Unstaged Changes:${NC}"
git diff --name-status

echo ""

# Check if there are any changes to commit
if git diff --staged --quiet; then
    echo -e "${YELLOW}⚠️  No staged changes to commit${NC}"

    # Check if there are unstaged changes that could be staged
    if ! git diff --quiet; then
        echo -e "${YELLOW}Found unstaged changes. Stage them?${NC}"
        read -p "Stage all changes? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git add .
            echo -e "${GREEN}✅ Staged all changes${NC}"
        fi
    else
        echo -e "${GREEN}✅ Working directory is clean${NC}"
        exit 0
    fi
fi

# Show what will be committed
echo -e "${YELLOW}Changes to be committed:${NC}"
git diff --staged --name-status

echo ""

# Ask for commit message
read -r -p "Enter commit message (or press Enter for default): " commit_msg

if [ -z "$commit_msg" ]; then
    # Generate a default commit message based on changed files
    changed_files=$(git diff --staged --name-only | head -5)
    if echo "$changed_files" | grep -q "\.md$"; then
        commit_msg="DOCS: update documentation files"
    elif echo "$changed_files" | grep -q "scripts/"; then
        commit_msg="CHORE(scripts): update automation scripts"
    else
        commit_msg="CHORE: update project files"
    fi
    echo "Using default commit message: $commit_msg"
fi

# Commit the changes
echo ""
echo -e "${GREEN}📝 Committing changes...${NC}"
git commit -m "$commit_msg"

echo -e "${GREEN}✅ Commit successful!${NC}"

# Show the latest commit
echo ""
echo -e "${YELLOW}Latest commit:${NC}"
git log --oneline -1

echo ""
echo -e "${GREEN}🎉 All changes committed successfully!${NC}"
