#!/usr/bin/env bash
# DevOnboarder Universal Version Enforcement Script
# Validates that local environment matches required Python 3.12.x + Node 22.x

set -euo pipefail

# Required versions per DevOnboarder policy
REQUIRED_PYTHON="3.12"
REQUIRED_NODE="22"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "DevOnboarder Version Policy Validation"
echo "=========================================="

# Check Python version
echo "Checking Python version..."
if command -v python3 >/dev/null 2>&1; then
    PYTHON_VER=$(python3 --version | awk '{print $2}')
    PYTHON_MAJOR_MINOR=$(echo "$PYTHON_VER" | cut -d'.' -f1,2)

    if [[ "$PYTHON_MAJOR_MINOR" == "$REQUIRED_PYTHON" ]]; then
        echo -e "${GREEN}PASS: Python: $PYTHON_VER (meets $REQUIRED_PYTHON.x requirement)${NC}"
        PYTHON_OK=true
    else
        echo -e "${RED}FAIL: Python: $PYTHON_VER (requires $REQUIRED_PYTHON.x)${NC}"
        PYTHON_OK=false
    fi
else
    echo -e "${RED}FAIL: Python: python3 not found${NC}"
    PYTHON_OK=false
fi

# Check Node version
echo "Checking Node.js version..."
if command -v node >/dev/null 2>&1; then
    NODE_VER=$(node --version | sed 's/v//')
    NODE_MAJOR=$(echo "$NODE_VER" | cut -d'.' -f1)

    if [[ "$NODE_MAJOR" == "$REQUIRED_NODE" ]]; then
        echo -e "${GREEN}PASS: Node.js: v$NODE_VER (meets $REQUIRED_NODE.x requirement)${NC}"
        NODE_OK=true
    else
        echo -e "${RED}FAIL: Node.js: v$NODE_VER (requires $REQUIRED_NODE.x)${NC}"
        NODE_OK=false
    fi
else
    echo -e "${RED}FAIL: Node.js: node not found${NC}"
    NODE_OK=false
fi

# Check npm version (ships with Node)
echo "Checking npm version..."
if command -v npm >/dev/null 2>&1; then
    NPM_VER=$(npm --version)
    echo -e "${GREEN}PASS: npm: v$NPM_VER${NC}"
else
    echo -e "${YELLOW}WARNING: npm: not found (should ship with Node.js)${NC}"
fi

# Summary
echo ""
echo "Version Policy Compliance Summary"
echo "====================================="

if [[ "$PYTHON_OK" == true && "$NODE_OK" == true ]]; then
    echo -e "${GREEN}SUCCESS: Environment meets DevOnboarder version policy${NC}"
    echo ""
    echo "You're ready to develop with:"
    echo "   • Python $REQUIRED_PYTHON.x for backend development"
    echo "   • Node.js $REQUIRED_NODE.x for frontend/bot development"
    echo "   • Virtual environment: source .venv/bin/activate"
    echo ""
    exit 0
else
    echo -e "${RED}FAILURE: Version policy violations detected${NC}"
    echo ""
    echo "Resolution Steps:"

    if [[ "$PYTHON_OK" == false ]]; then
        echo "   Python:"
        echo "     • Install Python $REQUIRED_PYTHON.x from python.org"
        echo "     • Or use pyenv: pyenv install $REQUIRED_PYTHON && pyenv local $REQUIRED_PYTHON"
        echo "     • Verify: python3 --version"
    fi

    if [[ "$NODE_OK" == false ]]; then
        echo "   Node.js:"
        echo "     • Install Node.js $REQUIRED_NODE.x from nodejs.org"
        echo "     • Or use nvm: nvm install $REQUIRED_NODE && nvm use $REQUIRED_NODE"
        echo "     • Verify: node --version"
    fi

    echo ""
    echo "Reference: .nvmrc and .python-version files enforce these versions"
    echo "Goal: Consistent development environment across all contributors"
    exit 1
fi
