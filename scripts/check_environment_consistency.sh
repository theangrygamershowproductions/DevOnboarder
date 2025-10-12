#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# DevOnboarder Environment Consistency Checker

set -euo pipefail

echo "🔍 DevOnboarder Environment Consistency Check"
echo "=============================================="

# Check virtual environment activation
echo "📌 Virtual Environment Status:"
if [[ "${VIRTUAL_ENV:-}" != "" ]]; then
    echo "  SUCCESS: Virtual environment active: $VIRTUAL_ENV"
    echo "  📍 Python path: $(which python)"
    echo "  📦 Pip path: $(which pip)"
else
    echo "  ERROR: Virtual environment NOT active"
    if [[ -f ".venv/bin/activate" ]]; then
        echo "  💡 Solution: source .venv/bin/activate"
    else
        echo "  💡 Solution: python -m venv .venv && source .venv/bin/activate"
    fi
    exit 1
fi

# Check Python version
python "Python Version:"
PYTHON_VERSION=$(python --version | cut -d' ' -f2)
echo "  📍 Current: $PYTHON_VERSION"
if [[ -f ".tool-versions" ]]; then
    EXPECTED_VERSION=$(grep "python" .tool-versions | cut -d' ' -f2)
    echo "  CHECK: Expected: $EXPECTED_VERSION"
    if [[ "$PYTHON_VERSION" == "$EXPECTED_VERSION"* ]]; then
        echo "  SUCCESS: Version matches"
    else
        echo "  WARNING:  Version mismatch"
    fi
fi

# Check essential packages
echo "📦 Essential Package Check:"
REQUIRED_PACKAGES=("black" "ruff" "pytest" "mypy")
for package in "${REQUIRED_PACKAGES[@]}"; do
    if python -c "import $package" 2>/dev/null; then
        echo "  SUCCESS: $package available"
    else
        echo "  ERROR: $package missing"
        echo "     💡 Install with: pip install -e .[test]"
    fi
done

# Check DevOnboarder specific modules
build " DevOnboarder Module Check:"
DEVONBOARDER_MODULES=("devonboarder" "xp" "discord_integration")
for module in "${DEVONBOARDER_MODULES[@]}"; do
    if python -c "import src.$module" 2>/dev/null; then
        echo "  SUCCESS: src.$module available"
    else
        echo "  ERROR: src.$module missing"
        echo "     💡 Install with: pip install -e ."
    fi
done

echo "=============================================="
success "Environment consistency check complete"
