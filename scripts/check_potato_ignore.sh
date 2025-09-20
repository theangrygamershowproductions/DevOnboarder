#!/usr/bin/env bash
set -euo pipefail
FILES=(.gitignore .dockerignore .codespell-ignore)
REQUIRED=("Potato" "Potato.md" "*[Pp]otato*" "HEY_POTATO_*" "*_POTATO_*")
missing=0
for f in "${FILES[@]}"; do
  for r in "${REQUIRED[@]}"; do
    if ! grep -Fq "$r" "$f"; then
      echo "$f missing '$r'" >&2
      missing=1
    fi
  done
done
if [ "$missing" -ne 0 ]; then
  echo "Required Potato entries not found in all ignore files." >&2
  echo "Add Enhanced Potato Policy v3.0 patterns to .gitignore, .dockerignore, and .codespell-ignore." >&2
  echo "Patterns: Potato, Potato.md, *[Pp]otato*, HEY_POTATO_*, *_POTATO_*" >&2
  echo "See .github/copilot-instructions.md for the policy or document an approved exception in docs/CHANGELOG.md." >&2
  exit 1
fi
