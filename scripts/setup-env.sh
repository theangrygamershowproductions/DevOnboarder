#!/usr/bin/env bash

echo ">> CODEx BOOTSTRAP v0.2.32 STARTING <<"
# ─── DEBUG SECTION (remove or comment once stable) ────────────────
export PS4='[\D{%H:%M:%S}] $? ➜  '
exec > >(tee /tmp/codex_setup.log) 2>&1
trap 'echo "💥 exit $?: line $LINENO → $BASH_COMMAND"' EXIT
set -xeuo pipefail
# ─────────────────────────────────────────────────────────────────

# PATCHED v0.5.12 scripts/setup-env.sh — Docker-aware environment bootstrap

# - Sources versions.sh and exports CODEX_ENV_* variables.
# - Uses the Codex universal container when Docker is available.
# - Falls back to local setup steps when Docker is absent.

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/versions.sh"

# Ensure all CODEX_ENV_* variables are exported in this shell
for var in $(
  grep -o 'CODEX_ENV_[A-Z0-9_]*' "${SCRIPT_DIR}/versions.sh" | sort -u
); do
  export "$var"
done

if command -v docker >/dev/null 2>&1; then
  echo "[INFO] Docker detected. Running universal setup container..."
  docker pull ghcr.io/openai/codex-universal
  docker run --rm -v "$(pwd)":/workspace -w /workspace \
    ghcr.io/openai/codex-universal /opt/codex/setup_universal.sh
else
  echo "[WARN] Docker not available. Running local setup steps."

  python3 -m venv venv
  source venv/bin/activate

  if [ -f requirements-dev.txt ]; then
    echo "[INFO] Installing dev requirements..."
    python -m pip install --upgrade pip
    python -m pip install --upgrade --requirement requirements-dev.txt
  else
    if [ -f backend/requirements.txt ]; then
      echo "[INFO] Installing backend requirements..."
      python -m pip install --upgrade pip
      python -m pip install --upgrade --requirement backend/requirements.txt
    fi

    if [ -f auth/requirements.txt ]; then
      echo "[INFO] Installing auth requirements..."
      python -m pip install --requirement auth/requirements.txt
    fi
  fi

  export PYTHONPATH="$(pwd):${PYTHONPATH:-}"

  if [ -d frontend ]; then
    cd frontend
    mkdir -p /home/node/.local
    corepack enable
    corepack prepare pnpm@${CODEX_ENV_PNPM_VERSION} --activate
    pnpm install
    cd ..
  fi
fi

echo "[✅] Environment bootstrap complete."
