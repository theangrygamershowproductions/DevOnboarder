#!/bin/bash
# Terminal Policy Violation Issue Creator
# Creates GitHub issues for terminal output policy violations
# Part of DevOnboarder Zero Tolerance Terminal Output Policy

set -euo pipefail

# Colors for output formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_NAME
SCRIPT_NAME=$(basename "$0")
readonly LOG_FILE
LOG_FILE="logs/${SCRIPT_NAME%.*}_$(date +%Y%m%d_%H%M%S).log"

# Create logs directory and setup logging
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Terminal Policy Violation Issue Creator starting at $(date)"
echo "Log file: $LOG_FILE"

# Input validation
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <commit_sha>"
    echo "Example: $0 abc123def456"
    exit 1
fi

readonly COMMIT_SHA="$1"

# Validate commit SHA format
if [[ ! "$COMMIT_SHA" =~ ^[a-f0-9]{40}$ ]] && [[ ! "$COMMIT_SHA" =~ ^[a-f0-9]{7,}$ ]]; then
    echo "Error: Invalid commit SHA format: $COMMIT_SHA"
    exit 1
fi

echo "Creating issue for terminal policy violations in commit: $COMMIT_SHA"

# Create issue body
readonly ISSUE_BODY
ISSUE_BODY=$(cat << 'EOF'
# CRITICAL: Terminal Output Policy Violations Detected

## Summary

The Zero Tolerance Terminal Output Policy has detected violations that will cause immediate terminal hanging in the DevOnboarder environment.

## Policy Background

DevOnboarder enforces a **ZERO TOLERANCE POLICY** for terminal output violations due to critical infrastructure hanging issues. These violations cause immediate system hanging and are blocked by comprehensive validation.

## Violation Details

**Commit:** {{ COMMIT_SHA }}

**Critical Issues:**
- Terminal output violations detected by validation framework
- These patterns cause immediate hanging in DevOnboarder CI environment
- Zero tolerance policy requires immediate resolution

## Required Actions

1. **Immediate Fix Required:**
   ```bash
   # Activate virtual environment
   source .venv/bin/activate

   # Run validation to identify violations
   bash scripts/validate_terminal_output_simple.sh

   # Fix violations using safe patterns:
   # SUCCESS SAFE: echo "Task completed successfully"
   # FAILED FORBIDDEN: echo "SUCCESS Task completed" (emojis cause hanging)
   # FAILED FORBIDDEN: echo -e "Line1\nLine2" (multi-line causes hanging)
   ```

2. **Validation Requirements:**
   - Use only plain ASCII text in echo commands
   - Never use emojis or Unicode characters
   - Never use multi-line echo or here-doc syntax
   - Never use variable expansion in echo statements

3. **Testing:**
   ```bash
   bash scripts/validate_terminal_output_simple.sh
   ```

## Documentation

- **Policy Guide:** `docs/TERMINAL_OUTPUT_VIOLATIONS.md`
- **AI Instructions:** `docs/AI_AGENT_TERMINAL_OVERRIDE.md`
- **Validation Script:** `scripts/validate_terminal_output_simple.sh`

## Enforcement

This issue was created automatically by the Terminal Output Policy Enforcement framework as part of DevOnboarder's Zero Tolerance Policy for terminal hanging prevention.

**Priority:** CRITICAL
**Impact:** System Hanging Prevention
**Policy:** Zero Tolerance Enforcement
**Framework:** DevOnboarder Terminal Output Policy v2.0
EOF
)

# Replace placeholder with actual commit SHA
readonly FINAL_ISSUE_BODY="${ISSUE_BODY//\{\{ COMMIT_SHA \}\}/$COMMIT_SHA}"

# Create the issue
echo "Creating GitHub issue for terminal policy violations..."

if issue_url=$(gh issue create \
    --title "CRITICAL: Terminal Output Policy Violations - $COMMIT_SHA" \
    --body "$FINAL_ISSUE_BODY" \
    --label "terminal-policy-violation,critical,zero-tolerance" \
    --assignee "@me" 2>&1); then

    echo -e "${GREEN}SUCCESS GitHub issue created successfully${NC}"
    echo -e "${BLUE}LINK Issue URL: $issue_url${NC}"

    # Log success
    echo "ISSUE_CREATED: $(date -Iseconds)"
    echo "URL: $issue_url"
    echo "COMMIT: $COMMIT_SHA"
    echo "Terminal policy violation issue creation completed successfully"

    exit 0
else
    echo -e "${RED}FAILED Failed to create GitHub issue${NC}"
    echo "Error output: $issue_url"
    exit 1
fi
