#!/bin/bash
# Enhanced Token Environment Loader v2.1 with Developer Guidance
# Provides clear error messages and token file guidance

# Function to provide clear guidance on missing tokens
provide_token_guidance() {
    local missing_token="$1"
    local script_name="${0##*/}"

    echo "❌ Missing Token: $missing_token"
    echo
    echo "🔧 Quick Fix Guide:"
    echo

    # Determine which file based on token type
    case "$missing_token" in
        "AAR_TOKEN"|"CI_BOT_TOKEN"|"CI_ISSUE_AUTOMATION_TOKEN"|"DEV_ORCHESTRATION_BOT_KEY"|"PROD_ORCHESTRATION_BOT_KEY"|"STAGING_ORCHESTRATION_BOT_KEY")
            echo "📁 CI/CD Token - Add to: .tokens file"
            echo "   Example: echo '${missing_token}=your_token_here' >> .tokens"
            echo "   Location: /home/potato/DevOnboarder/.tokens"
            echo
            echo "🔐 Get token from: https://github.com/settings/personal-access-tokens/fine-grained"
            ;;
        "DISCORD_BOT_TOKEN"|"DISCORD_CLIENT_SECRET"|"BOT_JWT"|"CF_DNS_API_TOKEN"|"TUNNEL_TOKEN")
            echo "📁 Runtime Token - Add to: .env file"
            echo "   Example: echo '${missing_token}=your_token_here' >> .env"
            echo "   Location: /home/potato/DevOnboarder/.env"
            echo
            echo "🔐 Get token from: Discord Developer Portal or service provider"
            ;;
        *)
            echo "📁 Token file location depends on token type"
            echo "   CI/CD tokens → .tokens file"
            echo "   Runtime tokens → .env file"
            ;;
    esac

    echo
    echo "📖 Full Documentation:"
    echo "   docs/TOKEN_ARCHITECTURE_V2.1.md"
    echo "   LOCAL_TOKEN_SETUP_COMPLETE.md"
    echo
    echo "🧪 Validate after adding:"
    echo "   python3 scripts/token_loader.py validate $missing_token"
    echo
    echo "🚀 Then re-run: $script_name"
}

# Function to check for specific required tokens
require_tokens() {
    local script_name="${0##*/}"
    local missing_tokens=()

    # Check each required token
    for token in "$@"; do
        if [ -z "${!token:-}" ]; then
            missing_tokens+=("$token")
        fi
    done

    # If any tokens are missing, provide guidance
    if [ ${#missing_tokens[@]} -gt 0 ]; then
        echo "🔍 Script: $script_name"
        echo "❌ Missing ${#missing_tokens[@]} required token(s)"
        echo

        for token in "${missing_tokens[@]}"; do
            provide_token_guidance "$token"
            echo "────────────────────────────────────────"
        done

        return 1
    fi

    return 0
}

# Load tokens if this script is sourced
if [ -f "scripts/token_loader.py" ]; then
    # Create temporary file for token export
    TOKEN_EXPORT_FILE=$(mktemp)

    # Use Python to safely export tokens
    if python3 -c "
import sys
sys.path.insert(0, '.')
try:
    from scripts.token_loader import TokenLoader
    loader = TokenLoader()
    tokens = loader.load_tokens_by_type(loader.TOKEN_TYPE_ALL)

    with open('$TOKEN_EXPORT_FILE', 'w') as f:
        for key, value in tokens.items():
            # Safely escape token values for shell
            escaped_value = value.replace('\\\\', '\\\\\\\\').replace('\"', '\\\\\"').replace('\$', '\\\\\$').replace('\`', '\\\\\`')
            f.write(f'export {key}=\"{escaped_value}\"\\n')

    print(f'Loaded {len(tokens)} tokens from Token Architecture v2.1')
except Exception as e:
    print(f'Error loading tokens: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null; then
        # Source the exported tokens if successful
        if [ -f "$TOKEN_EXPORT_FILE" ]; then
            # shellcheck disable=SC1090
            source "$TOKEN_EXPORT_FILE"
            rm -f "$TOKEN_EXPORT_FILE"
            echo "Token environment loaded successfully"
        fi
    else
        rm -f "$TOKEN_EXPORT_FILE" 2>/dev/null
        echo "Failed to load token environment"
        # shellcheck disable=SC2317 # Defensive programming pattern
        return 1 2>/dev/null || exit 1
    fi
else
    echo "Error: Not in DevOnboarder project root"
    # shellcheck disable=SC2317 # Defensive programming pattern
    return 1 2>/dev/null || exit 1
fi
