#!/usr/bin/env bash
# Cache pre-commit hook environments for offline use
set -euo pipefail

cache_dir="${1:-$HOME/devonboarder-offline/precommit}"

mkdir -p "$cache_dir"

# Use the repository's config to install all hook environments
PRE_COMMIT_HOME="$cache_dir" pre-commit install-hooks

echo "Cached pre-commit hooks at $cache_dir"
