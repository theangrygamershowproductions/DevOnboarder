#!/bin/bash
# Interactive script to set up real tokens in .tokens file

set -e

echo "🔐 DevOnboarder Token Setup Script"
echo "=================================="
echo ""
echo "This script will help you replace placeholder tokens with real values."
echo "You'll need to have created the tokens in their respective services first."
echo ""

# Backup current tokens file
cp .tokens .tokens.backup.$(date +%Y%m%d_%H%M%S)
echo "✅ Backup created: .tokens.backup.$(date +%Y%m%d_%H%M%S)"

# Function to update a token
update_token() {
    local token_name="$1"
    local description="$2"
    
    echo ""
    echo "📝 $token_name - $description"
    echo "Current value: $(grep "^$token_name=" .tokens | cut -d'=' -f2)"
    read -p "Enter new $token_name (or press Enter to skip): " token_value
    
    if [[ -n "$token_value" ]]; then
        # Update the token in .tokens file
        sed -i "s|^$token_name=.*|$token_name=$token_value|" .tokens
        echo "✅ Updated $token_name"
    else
        echo "⏭️  Skipped $token_name"
    fi
}

echo "🔑 GitHub Personal Access Tokens (PATs):"
echo "=========================================="
update_token "AAR_TOKEN" "Automated After Action Reports"
update_token "CI_ISSUE_AUTOMATION_TOKEN" "CI Issue Management"  
update_token "CI_BOT_TOKEN" "General CI Operations"
update_token "DEV_ORCHESTRATION_BOT_KEY" "Development Environment Orchestration"
update_token "PROD_ORCHESTRATION_BOT_KEY" "Production Environment Orchestration"
update_token "STAGING_ORCHESTRATION_BOT_KEY" "Staging Environment Orchestration"

echo ""
echo "🤖 Discord Bot Tokens:"
echo "======================"
update_token "DISCORD_BOT_TOKEN" "Discord Bot Authentication"
update_token "DISCORD_CLIENT_SECRET" "Discord OAuth Client Secret"

echo ""
echo "🔧 Service & Infrastructure Tokens:"
echo "===================================="
update_token "BOT_JWT" "Bot JSON Web Token"
update_token "TUNNEL_TOKEN" "Cloudflare Tunnel Token"
update_token "CF_DNS_API_TOKEN" "Cloudflare DNS API Token"

echo ""
echo "🔒 Security & Maintainer Tokens:"
echo "================================="
update_token "EXTERNAL_PR_MAINTAINER_TOKEN" "External PR Maintenance"
update_token "SECURITY_AUDIT_TOKEN" "Security Audit Operations"
update_token "EMERGENCY_OVERRIDE_TOKEN" "Emergency Override Access"

echo ""
echo "🎯 Token Setup Complete!"
echo "========================"
echo ""
echo "Next steps:"
echo "1. Test tokens: python3 scripts/token_loader.py load"
echo "2. Monitor expiry: ./scripts/token_expiry_monitor.sh monitor-all"
echo "3. Validate setup: python3 scripts/token_expiry_integrator.py monitor"
echo ""
echo "⚠️  Remember: Never commit the .tokens file to version control!"
