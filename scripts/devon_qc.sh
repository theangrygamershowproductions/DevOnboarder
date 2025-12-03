#!/usr/bin/env bash
# =============================================================================
# File: devon_qc.sh
# Version: 1.0.0
# Author: DevOnboarder Project
# Created: 2025-12-03
# Updated: 2025-12-03
# Purpose: Canonical QC script for DevOnboarder CI/local validation
# Dependencies: Python 3.12, requirements-ci.txt
# DevOnboarder Project Standards: Compliant with copilot-instructions.md
# Format: Bash script for CI and local QC execution
# =============================================================================

set -euo pipefail

echo "DevOnboarder QC - Canonical CI/Local Validation"
echo "================================================"

# Upgrade pip first
echo "Upgrading pip..."
python -m pip install --upgrade pip

# Verify canonical CI requirements file exists
if [ ! -f "requirements-ci.txt" ]; then
  echo "ERROR: requirements-ci.txt not found. CI/QC contract broken."
  echo "This file defines the canonical dependency list for DevOnboarder CI."
  exit 1
fi

# Install CI dependencies
echo "Installing CI dependencies from requirements-ci.txt..."
pip install -r requirements-ci.txt

# Call the existing comprehensive QC script
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
