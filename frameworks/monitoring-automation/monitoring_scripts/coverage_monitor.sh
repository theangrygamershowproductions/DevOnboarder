#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Coverage monitoring script to ensure 95% threshold is maintained

# Centralized logging for troubleshooting and repository health
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

set -euo pipefail

echo "INFO: DevOnboarder Coverage Monitor"
echo "================================"

# Activate virtual environment
# shellcheck source=/dev/null
source .venv/bin/activate

# Run Python backend coverage
echo "STATS: Python Backend Coverage:"
pytest --cov=src --cov-report=term --cov-fail-under=95 --tb=short -q
PYTHON_EXIT=$?

# Run Bot coverage
echo "STATS: Bot Coverage:"
cd bot
npm run coverage --silent
BOT_EXIT=$?
cd ..

# Run Frontend coverage
echo "STATS: Frontend Coverage:"
cd frontend
npm run coverage --silent
FRONTEND_EXIT=$?
cd ..

# Summary
echo "================================"
if [ $PYTHON_EXIT -eq 0 ] && [ $BOT_EXIT -eq 0 ] && [ $FRONTEND_EXIT -eq 0 ]; then
    success "All services maintain 95%+ coverage!"
    exit 0
else
    error "Coverage below threshold detected!"
    exit 1
fi
