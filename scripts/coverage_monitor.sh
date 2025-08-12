#!/usr/bin/env bash
# Coverage monitoring script to ensure 95% threshold is maintained
set -euo pipefail

echo "SEARCH DevOnboarder Coverage Monitor"
echo "================================"

# Activate virtual environment
# shellcheck source=/dev/null
source .venv/bin/activate

# Run Python backend coverage
echo "STATS Python Backend Coverage:"
pytest --cov=src --cov-report=term --cov-fail-under=95 --tb=short -q
PYTHON_EXIT=$?

# Run Bot coverage
echo "STATS Bot Coverage:"
cd bot
npm run coverage --silent
BOT_EXIT=$?
cd ..

# Run Frontend coverage
echo "STATS Frontend Coverage:"
cd frontend
npm run coverage --silent
FRONTEND_EXIT=$?
cd ..

# Summary
echo "================================"
if [ $PYTHON_EXIT -eq 0 ] && [ $BOT_EXIT -eq 0 ] && [ $FRONTEND_EXIT -eq 0 ]; then
    echo "SUCCESS All services maintain 95%+ coverage!"
    exit 0
else
    echo "FAILED Coverage below threshold detected!"
    exit 1
fi
