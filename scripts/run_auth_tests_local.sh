#!/usr/bin/env bash
set -euo pipefail
# Runs the Auth service tests in the project virtualenv using the per-service coverage config
# Usage: ./scripts/run_auth_tests_local.sh

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

cd "$REPO_ROOT"

if [ ! -d ".venv" ]; then
  echo "Virtual environment not found - creating .venv"
  python -m venv .venv
fi

source .venv/bin/activate

echo "Running Auth tests with per-service coverage (src/devonboarder)"
mkdir -p logs
mkdir -p test-results

pytest \
  -o cache_dir=logs/.pytest_cache \
  --cov --cov-config=config/.coveragerc.auth \
  --cov-report=term-missing \
  --cov-report=xml:logs/coverage_auth.xml \
  --cov-fail-under=95 \
  --junitxml=test-results/pytest-auth.xml \
  tests/test_auth_service.py 2>&1 | tee logs/pytest_auth_local.log

EXIT_CODE=${PIPESTATUS[0]:-0}
if [ "${EXIT_CODE}" -ne 0 ]; then
  echo "Auth tests failed or coverage below threshold (exit code: ${EXIT_CODE})"
  exit "${EXIT_CODE}"
fi

echo "Auth tests passed and coverage meets threshold"
exit 0
