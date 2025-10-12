#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Simple git sync - pull then push

sync "Syncing with remote..."

# Step 1: Pull latest changes
echo "📥 Pulling latest changes..."
git pull origin main

echo "🔍 Checking status..."
git status --short

# Step 2: Push our changes
echo "📤 Pushing changes..."
git push origin main

success "Sync complete!"
git log --oneline -3
