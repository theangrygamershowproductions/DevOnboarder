#!/usr/bin/env bash
# Coverage monitoring script to ensure 95% threshold is maintained
set -euo pipefail

echo "🔍 DevOnboarder Coverage Monitor"
echo "================================"

# Activate virtual environment
source .venv/bin/activate

# Run Python backend coverage
echo "📊 Python Backend Coverage:"
pytest --cov=src --cov-report=term --cov-fail-under=95 --tb=short -q
PYTHON_EXIT=$?

# Run Bot coverage
echo "📊 Bot Coverage:"
cd bot
npm run coverage --silent
BOT_EXIT=$?
cd ..

# Run Frontend coverage
echo "📊 Frontend Coverage:"
cd frontend
npm run coverage --silent
FRONTEND_EXIT=$?
cd ..

# Summary
echo "================================"
if [ $PYTHON_EXIT -eq 0 ] && [ $BOT_EXIT -eq 0 ] && [ $FRONTEND_EXIT -eq 0 ]; then
    echo "✅ All services maintain 95%+ coverage!"
    exit 0
else
    echo "❌ Coverage below threshold detected!"
    exit 1
fi
