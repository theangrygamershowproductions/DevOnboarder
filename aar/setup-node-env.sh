#!/bin/bash

# AAR System Node.js Environment Setup
# Ensures proper Node.js version (22) before any npm operations

set -euo pipefail

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Function to check and setup Node.js environment
setup_node_environment() {
    log_message "$BLUE" "🔧 AAR System: Setting up Node.js environment..."

    # Check if nvm is available
    if ! command -v nvm &> /dev/null; then
        # Try to source nvm from common locations
        if [[ -f "$HOME/.nvm/nvm.sh" ]]; then
            source "$HOME/.nvm/nvm.sh"
        elif [[ -f "/usr/local/share/nvm/nvm.sh" ]]; then
            source "/usr/local/share/nvm/nvm.sh"
        else
            log_message "$RED" "❌ ERROR: nvm not found. Please install nvm first."
            log_message "$YELLOW" "   Installation: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
            exit 1
        fi
    fi

    # Check current Node.js version
    CURRENT_NODE_VERSION=$(node --version 2>/dev/null || echo "none")
    REQUIRED_NODE_VERSION="22"

    if [[ "$CURRENT_NODE_VERSION" != v22* ]]; then
        log_message "$YELLOW" "⚠️  Current Node.js version: $CURRENT_NODE_VERSION"
        log_message "$BLUE" "🔄 Switching to Node.js $REQUIRED_NODE_VERSION..."

        # Install Node.js 22 if not available
        if ! nvm list | grep -q "v$REQUIRED_NODE_VERSION"; then
            log_message "$BLUE" "📦 Installing Node.js $REQUIRED_NODE_VERSION..."
            nvm install "$REQUIRED_NODE_VERSION"
        fi

        # Use Node.js 22
        nvm use "$REQUIRED_NODE_VERSION"

        # Verify the switch
        NEW_NODE_VERSION=$(node --version)
        log_message "$GREEN" "✅ Node.js version switched to: $NEW_NODE_VERSION"
    else
        log_message "$GREEN" "✅ Node.js version is correct: $CURRENT_NODE_VERSION"
    fi

    # Verify npm is available
    if ! command -v npm &> /dev/null; then
        log_message "$RED" "❌ ERROR: npm not found after Node.js setup"
        exit 1
    fi

    log_message "$GREEN" "✅ Node.js environment ready for AAR operations"
}

# Function to check if we're in the correct directory
check_aar_directory() {
    if [[ ! -f "package.json" ]]; then
        log_message "$RED" "❌ ERROR: package.json not found in current directory"
        log_message "$YELLOW" "   Please run this script from the aar/ directory"
        exit 1
    fi

    # Verify this is the AAR package.json
    if ! grep -q "devonboarder-aar-system" package.json; then
        log_message "$RED" "❌ ERROR: This doesn't appear to be the AAR system package.json"
        log_message "$YELLOW" "   Please run this script from the aar/ directory"
        exit 1
    fi

    log_message "$GREEN" "✅ Confirmed: Running in AAR system directory"
}

# Function to run npm command with environment check
run_npm_command() {
    local npm_cmd="$*"

    log_message "$BLUE" "🚀 Running: npm $npm_cmd"
    log_message "$BLUE" "   Node.js version: $(node --version)"
    log_message "$BLUE" "   npm version: $(npm --version)"
    log_message "$BLUE" "   Working directory: $(pwd)"

    # Execute the npm command
    npm "$@"

    local exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        log_message "$GREEN" "✅ npm $npm_cmd completed successfully"
    else
        log_message "$RED" "❌ npm $npm_cmd failed with exit code: $exit_code"
        exit $exit_code
    fi
}

# Main execution
main() {
    log_message "$BLUE" "🔧 DevOnboarder AAR System - Node.js Environment Manager"
    echo ""

    # Check if we're in the AAR directory
    check_aar_directory

    # Setup Node.js environment
    setup_node_environment

    echo ""
    log_message "$GREEN" "🎯 Environment ready! You can now run npm commands safely."
    log_message "$BLUE" "   Examples:"
    log_message "$BLUE" "   • npm install"
    log_message "$BLUE" "   • npm run aar:test"
    log_message "$BLUE" "   • npm run aar:full-test"
    echo ""

    # If arguments provided, run the npm command
    if [[ $# -gt 0 ]]; then
        run_npm_command "$@"
    fi
}

# Allow direct npm command execution with environment check
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
