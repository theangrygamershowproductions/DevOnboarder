#!/bin/bash
# rapid_ci_cleanup.sh - Clean up temporary files and Docker containers after CI run

set -e

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
