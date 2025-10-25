#!/usr/bin/env bash
# CI Failure Fix Script - Addresses common CI environment and setup issues
set -euo pipefail

echo "🔧 DevOnboarder CI Failure Fix"
echo "============================="

# 1. Fix Environment Variables
echo "📝 Fixing environment variables..."

# Ensure .env.dev has all required values from .env.example
if [ ! -f .env.dev ]; then
    echo "❌ .env.dev not found. Creating from .env.example..."
    cp .env.example .env.dev
fi

# Run the secret generation script
echo "🔑 Generating missing secrets..."
bash scripts/generate-secrets.sh

# 2. Install missing dependencies that often cause CI failures
echo "📦 Installing missing Python tools..."
# shellcheck source=/dev/null
source .venv/bin/activate

# Install tools commonly missing in CI
pip install pip-audit black openapi-spec-validator mypy ruff 2>/dev/null || {
    echo "⚠️  Some tools failed to install - this is often expected in offline mode"
}

# 3. Setup Node.js dependencies
echo "📦 Installing Node.js dependencies..."
if [ -d "bot" ] && [ -f "bot/package.json" ]; then
    npm ci --prefix bot --silent || {
        echo "⚠️  Bot npm install failed - may be offline"
    }
fi

if [ -d "frontend" ] && [ -f "frontend/package.json" ]; then
    npm ci --prefix frontend --silent || {
        echo "⚠️  Frontend npm install failed - may be offline"
    }
fi

# 4. Fix common Docker issues
echo "🐳 Checking Docker setup..."
if command -v docker >/dev/null 2>&1; then
    if docker compose -f docker-compose.ci.yaml config >/dev/null 2>&1; then
        echo "✅ Docker compose configuration valid"
    else
        echo "❌ Docker compose configuration has issues"
    fi
else
    echo "⚠️  Docker not available - some CI steps will be skipped"
fi

# 5. Run diagnostics in different modes
echo "🔍 Running diagnostics..."

# Test without services (like early CI stages)
export TAGS_MODE=false
echo "Testing with TAGS_MODE=false (no services expected):"
python -m diagnostics 2>&1 | head -n 10 || echo "⚠️  Some diagnostics failed (expected without running services)"

# 6. Check for common file issues
echo "📁 Checking file permissions and existence..."

# Ensure scripts are executable
chmod +x scripts/*.sh 2>/dev/null || true

# Check for required files
required_files=(
    "pyproject.toml"
    "pytest.ini"
    ".env.example"
    "docker-compose.ci.yaml"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
    fi
done

# 7. Test core functionality
echo "🧪 Testing core functionality..."

# Run a minimal test suite
pytest tests/test_smoke.py -v --tb=short 2>/dev/null || echo "⚠️  Smoke tests failed - may need services running"

echo "============================="
echo "🎯 CI Fix Summary:"
echo "- Environment variables: Generated/updated"
echo "- Dependencies: Installed where possible"
echo "- Docker: Configuration checked"
echo "- Files: Permissions and existence verified"
echo "- Tests: Smoke test attempted"
echo ""
echo "💡 Next steps:"
echo "1. Commit these changes if they resolve issues"
echo "2. Check GitHub Actions secrets match .env.example variables"
echo "3. Ensure CI has required tokens (GH_TOKEN, etc.)"
echo "4. Run './scripts/coverage_monitor.sh' to verify coverage"
