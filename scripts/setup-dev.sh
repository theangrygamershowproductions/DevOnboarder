#!/usr/bin/env bash
# PATCHED v0.2.31 scripts/setup-dev.sh — remove sudo and force clean for Codex env

set -euo pipefail
# Enable debug tracing if needed
[[ "${DEBUG:-}" == "1" ]] && set -x

# Load version variables
source "$(dirname "$0")/versions.sh"
# Ensure CODEX_ENV_PNPM_VERSION is defined
: "${CODEX_ENV_PNPM_VERSION:?versions.sh must set CODEX_ENV_PNPM_VERSION}"

# Remove any existing venv to avoid permission/sudo issues
if [ -d "venv" ]; then
  echo "[INFO] Removing existing venv for clean rebuild"
  rm -rf venv
fi

# Create or upgrade the virtual environment
echo "[INFO] Creating virtual environment"
python3 -m venv --upgrade-deps venv
source venv/bin/activate

# Upgrade core packaging tools
echo "[INFO] Upgrading pip, setuptools, wheel"
python -m pip install --upgrade pip setuptools wheel

# Install Python requirements
if [ -f requirements-dev.txt ]; then
  echo "[INFO] Installing dev requirements..."
  python -m pip install --requirement requirements-dev.txt
else
  echo "[INFO] Installing backend requirements if present"
  [ -f backend/requirements.txt ] && python -m pip install --requirement backend/requirements.txt
  echo "[INFO] Installing auth requirements if present"
  [ -f auth/requirements.txt ] && python -m pip install --requirement auth/requirements.txt
fi

# Install pre-commit
echo "[INFO] Installing pre-commit"
python -m pip install pre-commit

# Set PYTHONPATH to include repo root
export PYTHONPATH="$(pwd):${PYTHONPATH:-}"
echo "[INFO] PYTHONPATH set to repository root"

# Frontend dependencies setup
if [ -d frontend ]; then
  echo "[INFO] Setting up frontend dependencies"
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

# Auth-server dependencies setup
if [ -d auth-server ]; then
  echo "[INFO] Setting up auth-server dependencies"
  cd auth-server
  pnpm install || echo "[WARN] pnpm install failed in auth-server"
  cd ..
fi

# Bootstrap complete
echo "[✅] Local dev setup complete"
echo "[INFO] Activate with 'source venv/bin/activate'"
