#!/bin/bash
# rapid_ci_cleanup.sh - Clean up temporary files and Docker containers after CI run

set -e

# Centralized logging setup
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date %Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting CI cleanup..."

# Remove temporary files in /tmp/ci-*
if ls /tmp/ci-* 1> /dev/null 2>&1; then
  echo "Removing temporary files in /tmp/ci-*"
  rm -rf /tmp/ci-*
fi

# Remove all stopped Docker containers (if Docker is available)
if command -v docker &> /dev/null; then
  echo "Removing stopped Docker containers"
  docker container prune -f
fi

echo "CI cleanup complete."
