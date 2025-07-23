#!/usr/bin/env bash
# Enhanced Potato Policy Enforcement
# Prevents any modification to Potato.md content and ensures ignore entries exist

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🥔 Enhanced Potato Policy Enforcement"
echo "====================================="

# 1. Check ignore files (existing functionality)
FILES=(.gitignore .dockerignore .codespell-ignore)
REQUIRED=("Potato" "Potato.md")
missing=0

for f in "${FILES[@]}"; do
  for r in "${REQUIRED[@]}"; do
    if ! grep -Fxq "$r" "$f"; then
      echo -e "${RED}$f missing '$r'${NC}" >&2
      missing=1
    fi
  done
done

# 2. Check if Potato.md is being modified in this commit
if git diff --cached --name-only | grep -q "^Potato\.md$" 2>/dev/null; then
    echo -e "${RED}❌ VIOLATION: Potato.md is being modified!${NC}" >&2
    echo -e "${RED}🚫 The Potato Ignore Policy PROHIBITS editing Potato.md${NC}" >&2
    echo -e "${YELLOW}📋 Policy: AGENTS.md - Potato Ignore Policy${NC}" >&2
    echo -e "${YELLOW}📝 Required: Project lead approval + CHANGELOG.md entry${NC}" >&2
    echo -e "${RED}🛑 Commit BLOCKED${NC}" >&2
    exit 1
fi

# 3. Check if any scripts or automation are trying to process Potato.md
if git diff --cached --name-only | xargs grep -l "Potato\.md" 2>/dev/null | grep -v -E "(check_potato_ignore|about-potato)" | head -1; then
    echo -e "${YELLOW}⚠️  WARNING: Files referencing Potato.md detected${NC}" >&2
    echo -e "${YELLOW}📋 Ensure they respect the Potato Ignore Policy${NC}" >&2
fi

# 4. Verify Potato.md is in .markdownlint-ignore
if [ -f ".markdownlint-ignore" ]; then
    if ! grep -Fq "Potato.md" .markdownlint-ignore; then
        echo -e "${YELLOW}⚠️  Adding Potato.md to .markdownlint-ignore${NC}" >&2
        echo "Potato.md" >> .markdownlint-ignore
    fi
fi

if [ "$missing" -ne 0 ]; then
  echo -e "${RED}Required Potato entries not found in all ignore files.${NC}" >&2
  echo -e "${RED}Add 'Potato' and 'Potato.md' to .gitignore, .dockerignore, and .codespell-ignore.${NC}" >&2
  echo -e "${YELLOW}See AGENTS.md for the policy or document an approved exception in docs/CHANGELOG.md.${NC}" >&2
  exit 1
fi

echo -e "${GREEN}✅ Potato Policy compliance verified${NC}"
