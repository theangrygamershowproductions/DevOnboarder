#!/usr/bin/env bash
# Install Python dependencies required for running tests

# Centralized logging for troubleshooting and repository health
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date %Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

set -euo pipefail

pip install -e ".[test]"
pip check

echo "Test dependencies installed"
