#!/usr/bin/env bash
set -euo pipefail

# Standardized artifact detection rules
ARTIFACT_RULES=(
    ".coverage*"
    "test-results"
    "pytest_cache"
    "__pycache__"
    "node_modules"
    "test.db*"
    "vale-results.json"
    ".pytest_cache"
    "Thumbs.db"
    ".DS_Store"
)

# Check for root artifacts using standardized patterns
violations_found=0

for pattern in "${ARTIFACT_RULES[@]}"; do
    if find . -maxdepth 1 -name "$pattern" \
        -not -path "./.venv/*" \
        -not -path "./.git/*" \
        -not -path "./logs/*" | head -1 | grep -q .; then
        violations_found=1
        break
    fi
done

exit $violations_found
