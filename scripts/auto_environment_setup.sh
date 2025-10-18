#!/bin/bash
# Automatic DevOnboarder environment setup with consistency validation

set -euo pipefail

echo " DevOnboarder Auto-Environment Setup"
echo "======================================"

# Function to check if we're in DevOnboarder root
check_devonboarder_root() {
    if [[ ! -f "pyproject.toml" ]] || ! grep -q "devonboarder" pyproject.toml; then
        echo " Not in DevOnboarder root directory"
        echo "   Navigate to DevOnboarder project root first"
        exit 1
    fi
}

# Function to setup virtual environment
setup_venv() {
    echo "🐍 Setting up Python virtual environment..."

    if [[ ! -d ".venv" ]]; then
        echo "   Creating .venv directory..."
        python -m venv .venv
    fi

    echo "   Activating virtual environment..."
    # shellcheck disable=SC1091
    source .venv/bin/activate

    echo "   Upgrading pip..."
    pip install --upgrade pip

    echo "   Installing DevOnboarder with test dependencies..."
    pip install -e ".[test]"

    echo " Virtual environment setup complete"
    echo "  Note: Virtual environment activation is only active within this script"
    echo "   You'll need to activate it manually: source .venv/bin/activate"
}

# Function to setup Node.js dependencies
setup_node() {
    echo "📦 Setting up Node.js dependencies..."

    if [[ -d "bot" ]]; then
        echo "   Installing bot dependencies..."
        cd bot && npm ci && cd ..
    fi

    if [[ -d "frontend" ]]; then
        echo "   Installing frontend dependencies..."
        cd frontend && npm ci && cd ..
    fi

    echo " Node.js dependencies setup complete"
}

# Function to validate environment
validate_environment() {
    echo " Validating environment setup..."

    if [[ -f "scripts/check_environment_consistency.sh" ]]; then
        bash scripts/check_environment_consistency.sh
    else
        echo "  Environment consistency checker not found"
    fi
}

# Main execution
main() {
    check_devonboarder_root
    setup_venv
    setup_node
    validate_environment

    echo "======================================"
    echo "🎉 DevOnboarder environment ready!"
    echo ""
    echo " IMPORTANT: Activate virtual environment manually:"
    echo "   source .venv/bin/activate"
    echo ""
    echo " Then run quality validation:"
    echo "   ./scripts/qc_pre_push.sh"
    echo ""
    echo " Tip: Virtual environment must be activated in each terminal session"
}

main "$@"
