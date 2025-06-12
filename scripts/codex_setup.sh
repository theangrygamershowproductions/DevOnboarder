#!/usr/bin/env bash
# PATCHED v0.5.9 scripts/codex_setup.sh — Docker-aware setup wrapper

#
# Sources versions.sh for runtime versions, then runs the Codex universal
# container when Docker is available. Falls back to the local setup script
# otherwise.

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/versions.sh"

if command -v docker >/dev/null 2>&1; then
  echo "[INFO] Docker detected. Running universal setup container..."
  docker pull ghcr.io/openai/codex-universal
  docker run --rm -v "$(pwd)":/workspace -w /workspace \
    ghcr.io/openai/codex-universal /opt/codex/setup_universal.sh
else
  echo "[WARN] Docker not available. Running local setup-dev.sh."
  "${SCRIPT_DIR}/setup-dev.sh" "$@"
fi
