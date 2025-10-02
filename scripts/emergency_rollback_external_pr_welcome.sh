#!/usr/bin/env bash
# Emergency rollback for external PR welcome system
# POTATO APPROVAL: emergency-rollback-20251002

set -euo pipefail

echo "🚨 Emergency Rollback: External PR Welcome System"
echo "================================================"

echo "This script will disable the external PR welcome system by commenting out the welcome step"
read -rp "Are you sure you want to proceed? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "❌ Rollback cancelled"
    exit 1
fi

# Comment out the welcome step in the workflow
sed -i.bak '
/- name: Welcome external contributors/,/printf.*contributor/ {
    /^[[:space:]]*[^#]/ s/^/# DISABLED: /
}
' .github/workflows/pr-automation.yml

# Commit the change
git add .github/workflows/pr-automation.yml
git commit -m "HOTFIX: Disable external PR welcome system pending investigation"
git push

echo "✅ External PR welcome system disabled"
echo "✅ Backup saved as .github/workflows/pr-automation.yml.bak"
echo ""
echo "To re-enable:"
echo "1. Fix any issues"
echo "2. git checkout .github/workflows/pr-automation.yml"
echo "3. Test and commit the fix"
