#!/usr/bin/env bash
# DevOnboarder Filesystem Scanner Audit
# Ensures scripts don't accidentally traverse dependency directories
# Created: 2025-12-24 | Source: TAGS-META governance pattern

set -euo pipefail

echo "=== DevOnboarder Filesystem Scanner Audit ==="
echo ""

ERRORS=0

# 1) Check for tracked dependency directories
echo "1) Checking for policy violations (tracked forbidden dirs)..."
FORBIDDEN_TRACKED=$(git ls-files | grep -E "^(node_modules/|\.venv/|venv/|__pycache__/)" || true)
if [ -n "$FORBIDDEN_TRACKED" ]; then
    echo "CRITICAL: Dependency directories tracked in git!"
    echo "$FORBIDDEN_TRACKED" | head -20
    ERRORS=$((ERRORS + 1))
else
    echo "OK: No dependency directories tracked"
fi
echo ""

# 2) Check for unprotected 'find .' patterns
echo "2) Checking for unprotected 'find .' patterns..."
# Find scripts with 'find .' that don't use -prune or -not -path for common excludes
UNPROTECTED=""
while IFS= read -r script; do
    if grep -q "find \." "$script" 2>/dev/null; then
        # Check each find line
        while IFS= read -r line; do
            # Skip if line has -prune, -not -path for node_modules/.venv, or -maxdepth 1
            if ! echo "$line" | grep -qE "(-prune|-not -path.*node_modules|-not -path.*\.venv|-maxdepth 1|find \.github)"; then
                # Allowlist: xargs grep patterns (pipe-based, not traversal)
                if ! echo "$line" | grep -qE "\| *xargs"; then
                    UNPROTECTED="${UNPROTECTED}${script}: ${line}\n"
                fi
            fi
        done < <(grep "find \." "$script" 2>/dev/null || true)
    fi
done < <(find scripts -name "*.sh" -type f 2>/dev/null || true)

if [ -n "$UNPROTECTED" ]; then
    echo "WARNING: Potentially unprotected 'find .' patterns found:"
    echo -e "$UNPROTECTED" | head -30
    echo ""
    echo "Consider using: -not -path '*/node_modules/*' -not -path '*/.venv/*'"
    echo "Or: -maxdepth N for scoped searches"
    # Note: Not failing, just warning - DevOnboarder has many legacy patterns
else
    echo "OK: All 'find .' patterns appear protected or scoped"
fi
echo ""

# 3) Check pre-commit global exclude pattern
echo "3) Checking pre-commit global exclude pattern..."
if [ -f ".pre-commit-config.yaml" ]; then
    if grep -q "exclude:.*node_modules\|exclude:.*\.venv" .pre-commit-config.yaml; then
        echo "OK: Pre-commit has dependency excludes"
    else
        echo "WARNING: Pre-commit may be missing global exclude for node_modules/.venv"
    fi
else
    echo "INFO: No .pre-commit-config.yaml found"
fi
echo ""

# 4) Check .gitignore for proper excludes
echo "4) Checking .gitignore dependency excludes..."
if [ -f ".gitignore" ]; then
    MISSING=""
    for pattern in "node_modules" ".venv" "venv" "__pycache__"; do
        if ! grep -q "^${pattern}" .gitignore 2>/dev/null; then
            MISSING="${MISSING} ${pattern}"
        fi
    done
    if [ -n "$MISSING" ]; then
        echo "WARNING: .gitignore may be missing:${MISSING}"
    else
        echo "OK: .gitignore has standard dependency excludes"
    fi
else
    echo "WARNING: No .gitignore found"
fi
echo ""

# 5) Check safe_commit.sh uses repo-root anchoring
echo "5) Checking safe_commit.sh for repo-root anchoring..."
if [ -f "scripts/safe_commit.sh" ]; then
    if grep -q 'git rev-parse --show-toplevel' scripts/safe_commit.sh; then
        echo "OK: safe_commit.sh uses repo-root anchoring"
    else
        echo "WARNING: safe_commit.sh should use 'git rev-parse --show-toplevel' for path resolution"
    fi
else
    echo "INFO: No scripts/safe_commit.sh found"
fi
echo ""

echo "=== Audit Summary ==="
if [ $ERRORS -gt 0 ]; then
    echo "FAIL: $ERRORS critical policy violation(s) found"
    exit 1
else
    echo "PASS: No critical policy violations (warnings may exist)"
    exit 0
fi
