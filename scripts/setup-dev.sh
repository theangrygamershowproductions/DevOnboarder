#!/usr/bin/env bash
# PATCHED v0.2.29 scripts/setup-dev.sh — install optional dev requirements and auth packages

set -euo pipefail
source "$(dirname "$0")/versions.sh"

if [ -d "venv" ] && [ ! -w "venv" ]; then
  echo "[WARN] fixing venv ownership"
  if sudo chown -R $(id -u):$(id -g) venv; then
    echo "[INFO] venv ownership fixed"
  else
    echo "[WARN] unable to fix ownership; removing venv"
    sudo rm -rf venv
  fi
fi

if [ -d "venv" ] && [ ! -x "venv/bin/python3" ]; then
  echo "[WARN] stale venv detected; recreating"
  rm -rf venv
fi

python3 -m venv venv
source venv/bin/activate

if [ -f requirements-dev.txt ]; then
  echo "[INFO] Installing dev requirements..."
  python -m pip install --upgrade pip
  python -m pip install --upgrade --requirement requirements-dev.txt
else
  if [ -f backend/requirements.txt ]; then
    echo "[INFO] Installing backend dependencies..."
    python -m pip install --upgrade pip
    python -m pip install --upgrade --requirement backend/requirements.txt
  else
    echo "[INFO] Skipping pip install – backend/requirements.txt not found."
  fi

  if [ -f auth/requirements.txt ]; then
    echo "[INFO] Installing auth dependencies..."
    python -m pip install --requirement auth/requirements.txt
  else
    echo "[INFO] Skipping pip install – auth/requirements.txt not found."
  fi
fi

echo "[INFO] Installing pre-commit..."
python -m pip install pre-commit

export PYTHONPATH="$(pwd):${PYTHONPATH:-}"
echo "[INFO] PYTHONPATH set to include repo root."

if [ -d frontend ]; then
  cd frontend
  if ! command -v corepack >/dev/null 2>&1; then
    echo "[WARN] corepack not found; installing via npm..."
    npm install -g corepack
  fi
  mkdir -p "${HOME}/.local"
  corepack enable
  corepack prepare pnpm@${CODEX_ENV_PNPM_VERSION} --activate
  pnpm install
  cd ..
  if [ -d auth-server ]; then
    cd auth-server
    pnpm install
    cd ..
  else
    echo "[WARN] auth-server directory not found."
  fi
else
  echo "[WARN] frontend directory not found."
  if [ -d auth-server ]; then
    cd auth-server
    pnpm install
    cd ..
  else
    echo "[WARN] auth-server directory not found."
  fi
fi

echo "[✅] Local dev setup complete."
echo "[INFO] Activate with 'source venv/bin/activate' before running tests"
