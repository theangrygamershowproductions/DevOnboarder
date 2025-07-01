#!/usr/bin/env bash
# Bootstrap project dependencies
set -euo pipefail

echo "Bootstrapping project..."

# Create a local environment file if it does not exist
if [ ! -f .env.dev ]; then
    cp .env.example .env.dev
    echo "Created .env.dev from .env.example"
fi

# Run the shared setup script to install all required tools and images
"$(dirname "$0")/setup-env.sh"

# Optionally check for optional tooling
"$(dirname "$0")/check_dependencies.sh" || true

echo "Bootstrap complete"
