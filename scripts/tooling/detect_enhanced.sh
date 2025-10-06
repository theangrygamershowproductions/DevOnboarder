#!/bin/bash

# scripts/tooling/detect_enhanced.sh
# Deterministic enhanced capability detection without exposing proprietary names
# Returns: ENHANCED or STANDARD

set -euo pipefail

# 1) Feature flag (explicit)
if [[ "${DEVONBOARDER_ENHANCED:-0}" == "1" ]]; then
  echo "ENHANCED"
  exit 0
fi

# 2) Sentinel file (provisioned by private installer)
SENTINEL="${XDG_STATE_HOME:-$HOME/.local/state}/devonboarder/enhanced/.ok"
if [[ -f "$SENTINEL" ]]; then
  echo "ENHANCED"
  exit 0
fi

# 3) Feature-probe (non-identifying capability check)
if [[ -n "${ENHANCED_PROBE_CMD:-}" ]]; then
  if command -v "${ENHANCED_PROBE_CMD}" > /dev/null 2>&1; then
    "${ENHANCED_PROBE_CMD}" > /dev/null 2>&1 && { echo "ENHANCED"; exit 0; }
  fi
fi

echo "STANDARD"
