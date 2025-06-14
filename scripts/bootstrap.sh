#!/usr/bin/env bash
# Bootstrap project dependencies
set -euo pipefail

echo "Bootstrapping project..."

# Run the shared setup script to install all required tools and images
"$(dirname "$0")/setup-env.sh"

echo "Bootstrap complete"
