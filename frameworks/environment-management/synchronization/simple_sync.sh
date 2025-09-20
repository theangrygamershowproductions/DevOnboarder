#!/usr/bin/env bash
# Simple git sync - pull then push

echo "🔄 Syncing with remote..."

# Step 1: Pull latest changes
echo "📥 Pulling latest changes..."
git pull origin main

echo "🔍 Checking status..."
git status --short

# Step 2: Push our changes
echo "📤 Pushing changes..."
git push origin main

echo "✅ Sync complete!"
git log --oneline -3
