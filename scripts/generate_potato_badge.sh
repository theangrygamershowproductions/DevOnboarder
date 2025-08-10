#!/usr/bin/env bash
# Generate Potato Policy status badge
# This script generates a simple status badge for the Potato Policy

set -euo pipefail

echo "POTATO Generating Potato Policy Status Badge"
echo "======================================="

# Check if potato policy is enforced
if bash scripts/potato_policy_enforce.sh > /dev/null 2>&1; then
    if ! git diff --quiet; then
        # Changes were made, policy was not compliant
        echo "Status: FAILED NON-COMPLIANT"
        echo "Badge: ![Potato Policy](https://img.shields.io/badge/POTATO%20Potato%20Policy-FAILED%20Violations%20Detected-red)"
        exit 1
    else
        # No changes needed, policy is compliant
        echo "Status: SUCCESS COMPLIANT"
        echo "Badge: ![Potato Policy](https://img.shields.io/badge/POTATO%20Potato%20Policy-SUCCESS%20Enforced-green)"
        exit 0
    fi
else
    echo "Status: WARNING ERROR"
    echo "Badge: ![Potato Policy](https://img.shields.io/badge/POTATO%20Potato%20Policy-WARNING%20Error-yellow)"
    exit 2
fi
