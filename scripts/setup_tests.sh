#!/usr/bin/env bash
# Install Python dependencies required for running tests
set -euo pipefail

pip install -e ".[test]"
pip check

echo "Test dependencies installed ✅"

