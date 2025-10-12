#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# AAR Token Setup Guide for DevOnboarder
# This script demonstrates proper token configuration for the AAR system

# Load tokens using Token Architecture v2.1 with developer guidance
if [ -f "scripts/enhanced_token_loader.sh" ]; then
    # shellcheck source=scripts/enhanced_token_loader.sh disable=SC1091
    source scripts/enhanced_token_loader.sh
elif [ -f "scripts/load_token_environment.sh" ]; then
    # shellcheck source=scripts/load_token_environment.sh disable=SC1091
    source scripts/load_token_environment.sh
fi

# Legacy fallback: Load environment if available
if [ -f .env ]; then
    # shellcheck disable=SC1091
    source .env
fi

echo "AAR Token Setup Guide"
echo "===================="
echo ""
echo "The AAR system requires finely-scoped tokens following DevOnboarder"
echo "No Default Token Policy v1.0. Your system correctly refused to use"
echo "unauthorized tokens, which is the expected security behavior."
echo ""

echo "Required Tokens (in priority order):"
echo "1. CI_ISSUE_AUTOMATION_TOKEN (Primary - for issue creation)"
echo "2. CI_BOT_TOKEN (Secondary - for bot operations)"
echo ""

echo "Policy-Compliant Configuration:"
echo "Success: GITHUB_TOKEN should NOT be set (broad permissions not needed)"
echo ""

echo "Additional Available Tokens:"
echo "3. CI_ISSUE_TOKEN (Alternative issue management)"
echo "4. GH_TOKEN (GitHub CLI token)"
echo ""

echo "Active Token Status:"
echo "==================="

# Check primary token hierarchy (tokens we want to be present)
if [ -n "$CI_ISSUE_AUTOMATION_TOKEN" ]; then
    echo "Status: CI_ISSUE_AUTOMATION_TOKEN: Available"
else
    echo "Error: CI_ISSUE_AUTOMATION_TOKEN: Not set"
fi

if [ -n "$CI_BOT_TOKEN" ]; then
    echo "Status: CI_BOT_TOKEN: Available"
else
    echo "Error: CI_BOT_TOKEN: Not set"
fi

# Check additional tokens
echo ""
echo "Additional Token Status:"
echo "======================="

if [ -n "$CI_ISSUE_TOKEN" ]; then
    echo "Status: CI_ISSUE_TOKEN: Available"
else
    echo "Error: CI_ISSUE_TOKEN: Not set"
fi

if [ -n "$GH_TOKEN" ]; then
    echo "Status: GH_TOKEN: Available"
    # Check if it's actually an OpenAI token
    if [[ "$GH_TOKEN" == sk-proj-* ]]; then
        echo "   Warning:  WARNING: This appears to be an OpenAI token, not a GitHub token"
    fi
else
    echo "Error: GH_TOKEN: Not set"
fi

echo ""
echo "Fallback Token Status (Policy Compliance Check):"
echo "================================================"

if [ -n "$GITHUB_TOKEN" ]; then
    echo "Warning: GITHUB_TOKEN: Present - Consider removing for optimal security"
    echo "   Note: This broad-permissions token is not needed when fine-grained alternatives exist"
else
    echo "Success: GITHUB_TOKEN: Not set - Excellent! Following No Default Token Policy v1.0"
    echo "   Note: Using fine-grained tokens instead of broad-permissions fallback"
fi

# Check orchestration tokens for completeness
echo ""
echo "Orchestration Bot Tokens:"
echo "========================"

if [ -n "$DEV_ORCHESTRATION_BOT_KEY" ]; then
    printf "Length: %d\n" "${#DEV_ORCHESTRATION_BOT_KEY}"
else
    echo "Error: DEV_ORCHESTRATION_BOT_KEY: Not set"
fi

if [ -n "$STAGING_ORCHESTRATION_BOT_KEY" ]; then
    printf "Length: %d\n" "${#STAGING_ORCHESTRATION_BOT_KEY}"
else
    echo "Error: STAGING_ORCHESTRATION_BOT_KEY: Not set"
fi

if [ -n "$PROD_ORCHESTRATION_BOT_KEY" ]; then
    printf "Length: %d\n" "${#PROD_ORCHESTRATION_BOT_KEY}"
else
    echo "Error: PROD_ORCHESTRATION_BOT_KEY: Not set"
fi

echo ""
echo "Token Analysis:"
echo "=============="

# Count available GitHub tokens
github_token_count=0
if [ -n "$CI_ISSUE_AUTOMATION_TOKEN" ]; then
    github_token_count=$((github_token_count + 1))
fi
if [ -n "$CI_BOT_TOKEN" ]; then
    github_token_count=$((github_token_count + 1))
fi
if [ -n "$GITHUB_TOKEN" ]; then
    github_token_count=$((github_token_count + 1))
fi
if [ -n "$CI_ISSUE_TOKEN" ]; then
    github_token_count=$((github_token_count + 1))
fi

printf "Value: %s\n" "$"

# Orchestration token count
orchestration_token_count=0
if [ -n "$DEV_ORCHESTRATION_BOT_KEY" ]; then
    orchestration_token_count=$((orchestration_token_count + 1))
fi
if [ -n "$STAGING_ORCHESTRATION_BOT_KEY" ]; then
    orchestration_token_count=$((orchestration_token_count + 1))
fi
if [ -n "$PROD_ORCHESTRATION_BOT_KEY" ]; then
    orchestration_token_count=$((orchestration_token_count + 1))
fi

printf "Value: %s\n" "$"

echo ""
echo "AAR Token Hierarchy Compliance:"
echo "==============================="

if [ -n "$CI_ISSUE_AUTOMATION_TOKEN" ]; then
    echo "Success: Primary token available - Full AAR functionality enabled"
    echo "   AAR will use CI_ISSUE_AUTOMATION_TOKEN for issue creation"
elif [ -n "$CI_BOT_TOKEN" ]; then
    echo "Warning:  Secondary token available - Limited AAR functionality"
    echo "   AAR will use CI_BOT_TOKEN for operations"
elif [ -n "$GITHUB_TOKEN" ]; then
    echo "Warning:  Fallback token only - Policy violation risk"
    echo "   AAR will warn about using broad permissions token"
else
    echo "Error: No GitHub tokens available - AAR will run in offline mode"
    echo "   Reports can be generated but no GitHub integration"
fi

echo ""
echo "To enable full AAR functionality with GitHub integration:"
echo ""
echo "Option 1: Use GitHub CLI authentication (Recommended for development)"
echo "  gh auth login"
printf "Value: %s\n" "$"
echo ""
echo "Option 2: Set environment variables manually"
echo "  export CI_ISSUE_AUTOMATION_TOKEN=\"your_token_here\""
echo "  export CI_BOT_TOKEN=\"your_token_here\""
echo ""
echo "Option 3: Create .env file (for local development only)"
echo "  make aar-env-template  # Creates/updates .env with AAR variables"
echo "  # Edit .env to uncomment and set your tokens"
echo "  source .env"
echo ""

echo "Quick Setup:"
if [ ! -f .env ]; then
    echo "  make aar-env-template  # Create .env template first"
else
    echo "  Success: .env file found - edit to set your tokens"
fi
echo "  make aar-setup         # Run full setup with token validation"
echo ""

echo "Token Permissions Required:"
echo "- issues:write (for creating AAR issues)"
echo "- actions:read (for reading workflow data)"
echo "- contents:read (for repository access)"
echo ""

echo "Security Note:"
echo "The AAR system correctly prevented token policy violations by"
echo "refusing to use GITHUB_TOKEN when finely-scoped alternatives"
echo "should be preferred. This is the intended security behavior."
echo ""

echo "Offline Mode:"
echo "Success: AAR reports can be generated without tokens (as demonstrated)"
echo "Success: File version tracking works without tokens"
echo "Success: Local analysis and reporting fully functional"
echo "Error: GitHub issue creation requires authentication"
echo "Error: Workflow data collection requires authentication"

echo ""
echo "Available Commands:"
echo "=================="
echo "  bash scripts/setup_aar_tokens.sh status    # Show this token status"
echo "  bash scripts/setup_aar_tokens.sh analysis  # Run comprehensive token analysis"
echo "  make aar-setup                              # Complete AAR system setup"
echo ""

# Process command line arguments
if [ "$1" = "analysis" ]; then
    echo "Running Comprehensive Token Analysis..."
    echo "======================================="

    # Activate virtual environment if needed
    if [ -z "$VIRTUAL_ENV" ]; then
        if [ -f .venv/bin/activate ]; then
            echo "Activating virtual environment..."
            # shellcheck disable=SC1091
            source .venv/bin/activate
        else
            echo "Warning:  Warning: No virtual environment detected"
            echo "   Run: python -m venv .venv && source .venv/bin/activate"
        fi
    fi

    # Run comprehensive Python analysis
    if command -v python >/dev/null 2>&1; then
        echo ""
        python scripts/aar_security.py
        echo ""
        echo "Comprehensive analysis complete."
        echo "Check logs/token-audit/ for detailed reports."
    else
        echo "Error: Python not available for comprehensive analysis"
        echo "   Ensure virtual environment is activated"
    fi
elif [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "AAR Token Setup Help"
    echo "==================="
    echo ""
    echo "Usage: bash scripts/setup_aar_tokens.sh [command]"
    echo ""
    echo "Commands:"
    echo "  status     Show current token status (default)"
    echo "  analysis   Run comprehensive Python-based token analysis"
    echo "  help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  bash scripts/setup_aar_tokens.sh"
    echo "  bash scripts/setup_aar_tokens.sh analysis"
    echo "  make aar-setup"
elif [ -n "$1" ] && [ "$1" != "status" ]; then
    printf "Value: %s\n" "$"
    echo "   Available: status, analysis, help"
    echo "   Run: bash scripts/setup_aar_tokens.sh help"
fi
