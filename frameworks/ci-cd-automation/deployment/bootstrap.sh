#!/usr/bin/env bash
# Bootstrap project dependencies
set -euo pipefail

echo "Bootstrapping project..."

# Create a local environment file if it does not exist
if [ ! -f .env.dev ]; then
    cp .env.example .env.dev
    echo "Created .env.dev from .env.example"
fi

# Warn if .env.dev is missing new variables
example_vars=$(grep -oE '^[A-Za-z0-9_]+=' .env.example | cut -d= -f1 | sort -u)
dev_vars=$(grep -oE '^[A-Za-z0-9_]+=' .env.dev | cut -d= -f1 | sort -u)
missing_vars=$(comm -23 <(printf '%s\n' "$example_vars") <(printf '%s\n' "$dev_vars"))
if [ -n "$missing_vars" ]; then
    echo "Warning: .env.dev is missing the following variables:"
    echo "$missing_vars"
fi

# Run the shared setup script to install all required tools and images
"$(dirname "$0")/setup-env.sh"

# Optionally check for optional tooling
"$(dirname "$0")/check_dependencies.sh" || true

echo "Bootstrap complete"
