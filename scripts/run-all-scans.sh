#!/usr/bin/env bash
# PATCHED v0.2.2 scripts/run-all-scans.sh — Build CodeQL container

set -euo pipefail

# ---------------------------------------------------------------------------
# scripts/run-all-scans.sh
# 1) Run backend tests (pytest)
# 2) Run frontend lint + unit tests
# 3) Build and run CodeQL scanner container for Python & JS
# 4) Perform on-chain verification
# ---------------------------------------------------------------------------

echo "[INFO] Starting full CI scan..."

# 1) Backend tests
if [ -d "venv" ]; then
  echo "[INFO] Activating Python venv..."
  source venv/bin/activate
else
  echo "[ERROR] Python venv not found. Run setup script first." >&2
  exit 1
fi

cd backend
echo "[INFO] Installing/Updating backend requirements..."
pip install -r requirements.txt
cd ..
echo "[INFO] Running pytest..."
pytest -q

# 2) Frontend lint + unit tests
pnpm --dir frontend lint
pnpm --dir frontend test:unit

# 3) Dockerized CodeQL scans
cd "$(git rev-parse --show-toplevel)"
docker-compose build codeql-scanner
./scripts/run-codeql-docker.sh python
./scripts/run-codeql-docker.sh javascript

# 4) On-chain verification
if [ -n "${DEVONBOARDER_ETHEREUM_RPC_URL:-}" ] \
   && [ -n "${DEVONBOARDER_ANCHOR_CONTRACT_ADDRESS:-}" ] \
   && [ -n "${DEVONBOARDER_REPO_ANCHOR_KEY:-}" ]; then
  docker-compose run --rm codeql-scanner \
    node /workspace/scripts/verify-on-chain.js
else
  echo "[WARN] Skipping on-chain verification (missing env vars)."
fi

echo "[OK] All scans completed successfully."
