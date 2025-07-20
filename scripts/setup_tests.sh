#!/usr/bin/env bash
# Install Python dependencies required for running tests
set -euo pipefail

pip install -e .
pip install -r requirements-dev.txt
pip check

echo "Test dependencies installed ✅"

