#!/bin/bash
# DevOnboarder Version Policy Pre-commit Hook Setup
# Run this to install the version policy pre-commit hook

HOOK_FILE=".git/hooks/pre-commit"

echo "Setting up DevOnboarder version policy pre-commit hook..."

cat > "$HOOK_FILE" << 'EOF'
#!/bin/bash
# DevOnboarder Version Policy Pre-commit Hook
# Prevents commits with incorrect Python/Node versions

echo "Checking DevOnboarder version policy compliance..."

# Check Python version
PYTHON_VERSION=$(python3 -V 2>&1 | cut -d' ' -f2)
if [[ ! "$PYTHON_VERSION" =~ ^3\.12\. ]]; then
    echo "ERROR: DevOnboarder requires Python 3.12.x, found $PYTHON_VERSION"
    echo "Please install Python 3.12.x and activate the proper environment"
    echo "  - With pyenv: pyenv local 3.12"
    echo "  - With mise: mise use python@3.12"
    echo "  - With virtual env: source .venv/bin/activate"
    exit 1
fi

# Check Node version
NODE_VERSION=$(node -v 2>&1)
if [[ ! "$NODE_VERSION" =~ ^v22\. ]]; then
    echo "ERROR: DevOnboarder requires Node.js 22.x, found $NODE_VERSION"
    echo "Please install Node.js 22.x and activate the proper environment"
    echo "  - With nvm: nvm use 22"
    echo "  - With mise: mise use node@22"
    echo "  - Direct install: cat .nvmrc and install that version"
    exit 1
fi

echo "PASS: Python $PYTHON_VERSION and Node $NODE_VERSION meet policy"
EOF

chmod +x "$HOOK_FILE"

echo "SUCCESS: Version policy pre-commit hook installed"
echo "Location: $HOOK_FILE"
echo ""
echo "This hook will now check Python 3.12.x + Node 22.x on every commit"
# POTATO: EMERGENCY APPROVED - documentation-example-violation-20250809
# REASON: Setup script documentation shows bypass option for user awareness
# IMPACT: Users need to know the option exists but with clear discouragement
# ROLLBACK: Keep for user education but strongly discourage usage
echo "To bypass temporarily (strongly discouraged): git commit --no-verify"
