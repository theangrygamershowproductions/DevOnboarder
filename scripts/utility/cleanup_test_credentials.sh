#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# cleanup_test_credentials.sh - Safe removal of test Discord credentials
# This script removes test credentials and restores original configuration

set -e  # Exit on any error

echo "Cleaning up test Discord credentials..."

# 1. Check if backup exists
if [ ! -f .env.backup ]; then
    error "No .env.backup found. Cannot restore original configuration."
    echo "Please manually review and update .env file."
    exit 1
fi

# 2. Remove test credentials marker from main .env
echo "Removing test credentials from .env..."
sed -i '/# TEST DISCORD CREDENTIALS - TEMPORARY FOR TESTING/d' .env

# 3. Restore original .env configuration
echo "Restoring original .env configuration..."
cp .env.backup .env
rm .env.backup

# 4. Remove test credentials marker from bot/.env
echo "Cleaning up bot/.env..."
sed -i '/# TEST DISCORD CREDENTIALS - TEMPORARY FOR TESTING/d' bot/.env

# 5. Restart services to use original config
echo "Restarting services with original configuration..."
docker compose -f docker-compose.tags.dev.yaml restart auth discord-integration bot

# 6. Verify no test credentials remain
echo "Verifying cleanup..."
if grep -q "8385e5715bf0e379d8249ce0a0c3e50f78d47f8b14fc86d907ee1c6d842e546b" .env bot/.env 2>/dev/null; then
    warning "Test credentials may still be present. Please review manually."
    exit 1
fi

success "Test credentials removed successfully!"
success "Original configuration restored"
success "Services restarted with original config"

# 7. Show current git status to verify no staged changes
echo ""
echo "Git status check:"
git status --porcelain | grep -E "\.env" || echo "No .env files in git staging area - GOOD!"

echo ""
echo "Cleanup completed successfully!"
