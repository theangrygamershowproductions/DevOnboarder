#!/usr/bin/env bash
# Simple git sync - pull then push

echo "SYMBOL Syncing with remote..."

# Step 1: Pull latest changes
echo "SYMBOL Pulling latest changes..."
git pull origin main

echo "SEARCH Checking status..."
git status --short

# Step 2: Push our changes
echo "SYMBOL Pushing changes..."
git push origin main

echo "SUCCESS Sync complete!"
git log --oneline -3
