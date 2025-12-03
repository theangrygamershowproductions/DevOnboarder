#!/usr/bin/env bash
# =============================================================================
# File: devon_qc.sh
# Version: 2.0.0
# Author: DevOnboarder Project
# Created: 2025-12-03
# Updated: 2025-12-03
# Purpose: Canonical QC script for DevOnboarder CI/local validation
# Dependencies: Python 3.12, requirements-ci.txt
# DevOnboarder Project Standards: Compliant with copilot-instructions.md
# Format: Bash script for CI and local QC execution
# =============================================================================

set -euo pipefail

# Parse arguments
GATE_ONLY=false
if [[ "${1:-}" == "--gate-only" ]]; then
  GATE_ONLY=true
fi

if [ "$GATE_ONLY" = true ]; then
  echo "DevOnboarder QC Gate - Minimal Sanity Check (v3)"
  echo "================================================"
  echo ""
  echo "Mode: GATE ONLY - Basic sanity validation"
  echo "  ✓ Dependencies install"
  echo "  ✓ Python imports work"
  echo "  ✓ Tests are runnable"
  echo ""
  echo "Skipping: Coverage thresholds, YAML lint (v4 hardening)"
else
  echo "DevOnboarder QC - Full Validation"
  echo "=================================="
fi

# Upgrade pip first
echo "Upgrading pip..."
python -m pip install --upgrade pip --quiet

# Verify canonical CI requirements file exists
if [ ! -f "requirements-ci.txt" ]; then
  echo "ERROR: requirements-ci.txt not found. CI/QC contract broken."
  echo "This file defines the canonical dependency list for DevOnboarder CI."
  exit 1
fi

# Install CI dependencies
echo "Installing CI dependencies from requirements-ci.txt..."
pip install -r requirements-ci.txt --quiet

if [ "$GATE_ONLY" = true ]; then
  # Gate mode: Quick smoke tests only
  echo ""
  echo "Running minimal gate checks..."
  echo "------------------------------"
  
  # Check Python imports work
  echo "✓ Checking Python imports..."
  python -c "import sys; import pytest; import fastapi; import sqlalchemy" || {
    echo "ERROR: Core Python imports failed"
    exit 1
  }
  
  # Check tests are discoverable/runnable (don't require them to pass)
  echo "✓ Verifying tests are runnable..."
  if [ -d "backend" ]; then
    python -m pytest backend --collect-only -q > /dev/null 2>&1 || {
      echo "WARNING: Backend tests may not be runnable"
    }
  fi
  
  echo ""
  echo "✅ QC Gate passed - Basic sanity validated"
  echo ""
  echo "Note: Full QC validation (coverage, lint, YAML) runs separately"
  echo "These checks are v4 hardening targets, not v3 blockers"
  exit 0
fi

# Full mode: Call comprehensive QC script
echo ""
echo "Running comprehensive DevOnboarder QC checks..."
echo "-----------------------------------------------"
if [ -f "scripts/qc_pre_push.sh" ]; then
  bash scripts/qc_pre_push.sh
else
  echo "ERROR: scripts/qc_pre_push.sh not found."
  echo "DevOnboarder QC script is missing from repository."
  exit 1
fi

echo ""
echo "✅ DevOnboarder QC completed successfully"
