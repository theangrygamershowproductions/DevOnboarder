#!/bin/bash

# scripts/verify_enhanced_capabilities.sh
# Quick verification steps for external toolkit integration

set -euo pipefail

echo " DevOnboarder Enhanced Capabilities Verification"
echo "================================================="

# 1. Check uvx availability and markitdown-mcp
echo "1. Checking uvx and MCP tools..."
if command -v uvx >/dev/null 2>&1; then
    UVX_VERSION="$(uvx --version 2>/dev/null)" || UVX_VERSION=""
    if [ -n "$UVX_VERSION" ]; then
        echo "    uvx available: $UVX_VERSION"
    else
        echo "    uvx available: version unknown"
    fi
    if uvx markitdown-mcp --help >/dev/null 2>&1; then
        echo "    markitdown-mcp available"
    else
        echo "    markitdown-mcp not available"
    fi
else
    echo "    uvx not available (needed for MCP servers)"
fi

# 2. Check Node.js/npm for MCP servers
echo ""
echo "2. Checking Node.js/npm availability..."
if command -v npm >/dev/null 2>&1; then
    echo "    npm available: $(npm --version)"
    echo "    npx available: $(npx --version)"
else
    echo "    npm/npx not available (needed for MCP servers)"
fi

# 3. Test deterministic detection
echo ""
echo "3. Testing deterministic capability detection..."
MODE="$(scripts/tooling/detect_enhanced.sh)"
echo "    Current mode: $MODE"

# 4. Test enhanced mode with feature flag
echo ""
echo "4. Testing enhanced mode via feature flag..."
ENHANCED_MODE="$(DEVONBOARDER_ENHANCED=1 scripts/tooling/detect_enhanced.sh)"
echo "    Enhanced mode test: $ENHANCED_MODE"

# 5. Check VS Code MCP configuration
echo ""
echo "5. Checking VS Code MCP configuration..."
if [ -f ".vscode/mcp.json" ]; then
    echo "    VS Code MCP config exists"
    echo "    Configured servers:"
    if command -v jq > /dev/null 2>&1; then
        jq -r 'keys[]' .vscode/mcp.json | sed 's/^/      - /'
    else
        grep -o '"[^"]*":\s*{' .vscode/mcp.json | sed 's/:.*//' | sed 's/"//g' | sed 's/^/      - /'
    fi
else
    echo "    VS Code MCP config missing"
fi

# 6. Security validation - check for proprietary references
echo ""
echo "6. Security validation..."
echo "   SECURE: Checking for secret tokens..."
if ! git grep -qE 'sk-[A-Za-z0-9]{20,}' -- . 2>/dev/null; then
    echo "       No secret tokens found"
else
    echo "       Secret-like tokens detected"
fi

echo "   SECURE: Checking for proprietary identifiers..."
if ! git grep -qE '(devonboarder[-_ ]?premium|internal[-_ ]?toolkit)' -- . 2>/dev/null; then
    echo "       No proprietary identifiers found"
else
    echo "        Proprietary identifiers detected"
fi

# 7. Check gitignore patterns
echo ""
echo "7. Checking security gitignore patterns..."
if grep -q "\.vscode/\*\.secrets\.json" .gitignore && grep -q "\*\*/\.local/\*\*" .gitignore; then
    echo "    Security gitignore patterns present"
else
    echo "    Missing security gitignore patterns"
fi

echo ""
echo "TARGET: Verification Summary"
echo "======================="
echo "Mode: $MODE"
echo "Enhanced Test: $ENHANCED_MODE"
echo "Security: $(git grep -qE '(sk-[A-Za-z0-9]{20,}|devonboarder[-_ ]?premium)' -- . 2>/dev/null && echo 'ISSUES DETECTED' || echo 'CLEAN')"
echo ""
echo " Verification complete"
