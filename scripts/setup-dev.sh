#!/usr/bin/env bash
# PATCHED v0.2.30 scripts/setup-dev.sh — clean bootstrap and debug

set -euo pipefail
# Enable debug tracing if needed
[[ "${DEBUG:-}" == "1" ]] && set -x

# Load version variables
source "$(dirname "$0")/versions.sh"

# Ensure CODEX_ENV_PNPM_VERSION is defined
: "${CODEX_ENV_PNPM_VERSION:?versions.sh must set CODEX_ENV_PNPM_VERSION}"

# Handle stale or unwritable venv
if [ -d "venv" ] && { [ ! -w "venv" ] || [ ! -x "venv/bin/python3" ]; }; then
  echo "[WARN] stale or unwritable venv detected; removing"
  sudo rm -rf venv || true
fi

# Create or upgrade the venv
echo "[INFO] Creating/upgrading venv"
python3 -m venv --upgrade-deps venv
source venv/bin/activate

# Upgrade packaging tools
echo "[INFO] Upgrading pip, setuptools, wheel"
python -m pip install --upgrade pip setuptools wheel

# Install Python requirements
if [ -f requirements-dev.txt ]; then
  echo "[INFO] Installing dev requirements..."
  python -m pip install --requirement requirements-dev.txt
else
  if [ -f backend/requirements.txt ]; then
    echo "[INFO] Installing backend dependencies..."
    python -m pip install --requirement backend/requirements.txt
  else
    echo "[INFO] No backend requirements found; skipping"
  fi

  if [ -f auth/requirements.txt ]; then
    echo "[INFO] Installing auth dependencies..."
    python -m pip install --requirement auth/requirements.txt
  else
    echo "[INFO] No auth requirements found; skipping"
  fi
fi

# Install pre-commit
echo "[INFO] Installing pre-commit"
python -m pip install pre-commit

# Set PYTHONPATH to include repo root
export PYTHONPATH="$(pwd):${PYTHONPATH:-}"
echo "[INFO] PYTHONPATH set to repository root"

# Frontend setup
if [ -d frontend ]; then
  echo "[INFO] Setting up frontend"
  cd frontend
  command -v corepack >/dev/null 2>&1 || {
    echo "[WARN] corepack not found; installing"
    npm install -g corepack
  }
  mkdir -p "${HOME}/.local"
  corepack enable
  corepack prepare pnpm@${CODEX_ENV_PNPM_VERSION} --activate
  pnpm install || echo "[WARN] pnpm install failed in frontend"
  cd ..
fi

# Auth-server setup
if [ -d auth-server ]; then
  echo "[INFO] Setting up auth-server"
  cd auth-server
  pnpm install || echo "[WARN] pnpm install failed in auth-server"
  cd ..
fi

echo "[✅] Local dev setup complete"
echo "[INFO] Activate with 'source venv/bin/activate'"
