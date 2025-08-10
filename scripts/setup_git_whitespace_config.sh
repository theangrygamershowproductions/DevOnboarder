#!/usr/bin/env bash
# =============================================================================
# File: scripts/setup_git_whitespace_config.sh
# Purpose: Configure Git whitespace handling for Universal Development Experience
# Usage: bash scripts/setup_git_whitespace_config.sh
# =============================================================================

set -euo pipefail

echo "CONFIG Setting up Git whitespace configuration..."

# Configure core whitespace handling
git config core.whitespace trailing-space,space-before-tab,blank-at-eol
git config apply.whitespace warn

# Enable git blame ignore file for better code archaeology
git config blame.ignoreRevsFile .git-blame-ignore-revs

echo "SUCCESS Git whitespace configuration complete!"
echo ""
echo "SYMBOL Configured settings:"
echo "  - core.whitespace: $(git config core.whitespace)"
echo "  - apply.whitespace: $(git config apply.whitespace)"
echo "  - blame.ignoreRevsFile: $(git config blame.ignoreRevsFile)"
echo ""
echo "IDEA These settings will:"
echo "  - Warn about whitespace issues when applying patches"
echo "  - Ignore formatting commits in git blame for better code archaeology"
echo "  - Help maintain consistent whitespace standards"
