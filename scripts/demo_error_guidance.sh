#!/bin/bash
# Demo script showing enhanced error guidance (simulating missing token)

set -euo pipefail

echo "Demo: Missing Token Error Guidance"
echo "====================================="
echo

# Function to provide clear guidance on missing tokens
provide_token_guidance() {
    local missing_token="$1"
    local script_name="${0##*/}"

    echo "Missing Token: $missing_token"
    echo
    echo "Quick Fix Guide:"
    echo

    # Determine which file based on token type
    case "$missing_token" in
        "AAR_TOKEN"|"CI_BOT_TOKEN"|"CI_ISSUE_AUTOMATION_TOKEN"|"DEV_ORCHESTRATION_BOT_KEY"|"PROD_ORCHESTRATION_BOT_KEY"|"STAGING_ORCHESTRATION_BOT_KEY")
            echo "CI/CD Token - Add to: .tokens file"
            echo "   Example: echo '${missing_token}=your_token_here' >> .tokens"
            echo "   Location: $(pwd)/.tokens"
            echo
            echo "Get token from: https://github.com/settings/personal-access-tokens/fine-grained"
            ;;
        "DISCORD_BOT_TOKEN"|"DISCORD_CLIENT_SECRET"|"BOT_JWT"|"CF_DNS_API_TOKEN"|"TUNNEL_TOKEN")
            echo "Runtime Token - Add to: .env file"
            echo "   Example: echo '${missing_token}=your_token_here' >> .env"
            echo "   Location: $(pwd)/.env"
            echo
            echo "Get token from: Discord Developer Portal or service provider"
            ;;
    esac

    echo
    echo "📖 Full Documentation:"
    echo "   docs/TOKEN_ARCHITECTURE_V2.1.md"
    echo "   LOCAL_TOKEN_SETUP_COMPLETE.md"
    echo
    echo "Validate after adding:"
    echo "   python3 scripts/token_loader.py validate $missing_token"
    echo
    echo "Then re-run: $script_name"
}

# Simulate missing tokens
echo "Simulating missing CI_ISSUE_AUTOMATION_TOKEN..."
echo
provide_token_guidance "CI_ISSUE_AUTOMATION_TOKEN"
echo
echo "────────────────────────────────────────"
echo
echo "Simulating missing DISCORD_BOT_TOKEN..."
echo
provide_token_guidance "DISCORD_BOT_TOKEN"
