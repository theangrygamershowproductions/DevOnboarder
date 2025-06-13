#!/usr/bin/env bash
# PATCHED v0.2.32 scripts/setup-dev.sh — detect nested root, clean bootstrap, debug

set -euo pipefail
# Enable debug tracing if needed
[[ "${DEBUG:-}" == "1" ]] && set -x

# Detect nested project root (one directory containing all project files)
shopt -s nullglob
dirs=(*/)
if [ ${#dirs[@]} -eq 1 ]; then
  nested="${dirs[0]%/}"
  echo "[INFO] Detected nested directory '$nested', entering it"
  cd "$nested"
fi

# Load version variables
source "$(dirname "$0")/versions.sh"

# Ensure CODEX_ENV_PNPM_VERSION is defined
: "${CODEX_ENV_PNPM_VERSION:?versions.sh must set CODEX_ENV_PNPM_VERSION}"

# Remove existing venv to avoid issues
if [ -d "venv" ]; then
  echo "[INFO] Removing existing venv for clean rebuild"
  rm -rf venv
fi

# Create or upgrade the venv
echo "[INFO] Creating virtual environment"
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

# Set PYTHONPATH
echo "[INFO] Setting PYTHONPATH to repository root"
export PYTHONPATH="$(pwd):${PYTHONPATH:-}"

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
  corepack prepare pnpm@"${CODEX_ENV_PNPM_VERSION}" --activate
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
