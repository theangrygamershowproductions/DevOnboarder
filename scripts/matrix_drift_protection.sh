#!/bin/bash
# Matrix Drift Protection - Detects changes in required status checks
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Configuration
REQUIRED_CHECKS_DOC="docs/ci/required-checks.md"
PROTECTION_CONFIG="protection.json"
LOG_FILE="logs/matrix_drift_$(date +%Y%m%d_%H%M%S).log"

# Ensure logs directory exists
mkdir -p logs

# Logging setup
exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== Matrix Drift Protection Check ====="
echo "Timestamp: $(date)"
echo "Checking for drift between documentation and actual protection config..."

# Verify required files exist
if [[ ! -f "$REQUIRED_CHECKS_DOC" ]]; then
    echo "ERROR: Documentation file not found: $REQUIRED_CHECKS_DOC"
    echo "Creating documentation file from current protection config..."

    mkdir -p "$(dirname "$REQUIRED_CHECKS_DOC")"

    cat > "$REQUIRED_CHECKS_DOC" << 'EOF'
# Required Status Checks

This document lists all required status checks for the `main` branch protection.

**CRITICAL**: This list must stay synchronized with `protection.json`. Any changes require updating both files.

## Current Required Checks

1. **Version Policy Audit/Verify Node 22.x + Python 3.12.x Policy (pull_request)**
   - Ensures language version compliance

2. **Validate Permissions/check (pull_request)**
   - Validates workflow permissions against token policies

3. **Pre-commit Validation/Validate pre-commit hooks (pull_request)**
   - Ensures pre-commit hooks are properly configured

4. **CI/test (3.12, 22) (pull_request)**
   - Main test suite with Python 3.12 and Node.js 22

5. **AAR System Validation/Validate AAR System (pull_request)**
   - Validates After Action Report system integrity

6. **Orchestrator/orchestrate (pull_request)**
   - Multi-service orchestration validation

7. **CodeQL/Analyze (python) (dynamic)**
   - Python security analysis

8. **CodeQL/Analyze (javascript-typescript) (dynamic)**
   - TypeScript/JavaScript security analysis

9. **Root Artifact Monitor/Root Artifact Guard (pull_request)**
   - Prevents repository pollution

10. **Terminal Output Policy Enforcement/Enforce Terminal Output Policy (pull_request)**
    - Validates terminal output compliance

11. **Enhanced Potato Policy Enforcement/enhanced-potato-policy (pull_request)**
    - Security file protection validation

12. **Documentation Quality/validate-docs (pull_request)**
    - Documentation linting and validation

## Maintenance Notes

- **Check Names**: Must match GitHub check runs exactly (case-sensitive)
- **Matrix Updates**: When changing CI matrix, update this list and `protection.json`
- **Drift Detection**: Run `scripts/matrix_drift_protection.sh` to detect inconsistencies
- **Skip Behavior**: Conditional jobs that legitimately skip must not block required checks

## Validation Commands

```bash
# Check for drift between docs and config
bash scripts/matrix_drift_protection.sh

# Validate current branch protection
bash scripts/validate_branch_protection.sh

# Apply protection updates
bash scripts/apply-branch-protection.sh
```
EOF

    echo "Documentation file created: $REQUIRED_CHECKS_DOC"
fi

if [[ ! -f "$PROTECTION_CONFIG" ]]; then
    echo "ERROR: Protection config not found: $PROTECTION_CONFIG"
    exit 1
fi

# Extract check names from protection.json
echo "Extracting checks from protection.json..."
PROTECTION_CHECKS=$(jq -r '.required_status_checks.contexts[]' "$PROTECTION_CONFIG" | sort)

echo "Found checks in protection.json:"
echo "$PROTECTION_CHECKS" | while read -r line; do echo "  - $line"; done

# Extract check names from documentation
echo "Extracting checks from documentation..."
DOC_CHECKS=$(grep -o '`[^`]*` ✅ VERIFIED' "$REQUIRED_CHECKS_DOC" | sed 's/`//g; s/ ✅ VERIFIED$//' | sort)

echo "Found checks in documentation:"
echo "$DOC_CHECKS" | while read -r line; do echo "  - $line"; done

# Compare the lists
echo "Checking for drift..."

# Convert to arrays for comparison
mapfile -t protection_array <<< "$PROTECTION_CHECKS"
mapfile -t doc_array <<< "$DOC_CHECKS"

# Check for items in protection but not in docs
echo "Checks in protection.json but missing from documentation:"
drift_found=false
for check in "${protection_array[@]}"; do
    if [[ -n "$check" ]] && ! printf '%s\n' "${doc_array[@]}" | grep -Fxq "$check"; then
        echo "  + $check"
        drift_found=true
    fi
done

# Check for items in docs but not in protection
echo "Checks in documentation but missing from protection.json:"
for check in "${doc_array[@]}"; do
    if [[ -n "$check" ]] && ! printf '%s\n' "${protection_array[@]}" | grep -Fxq "$check"; then
        echo "  - $check"
        drift_found=true
    fi
done

if [[ "$drift_found" == "true" ]]; then
    echo "❌ DRIFT DETECTED: Documentation and protection config are out of sync!"
    echo "Manual intervention required to resolve inconsistencies."
    echo "Log saved to: $LOG_FILE"
    exit 1
else
    echo "✅ NO DRIFT: Documentation and protection config are synchronized"
    echo "All $(echo "$PROTECTION_CHECKS" | wc -l | tr -d ' ') required checks are properly documented"
fi

echo "Matrix drift protection check completed"
echo "Log saved to: $LOG_FILE"
