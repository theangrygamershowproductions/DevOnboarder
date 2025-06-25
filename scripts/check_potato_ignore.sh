#!/usr/bin/env bash
set -euo pipefail
FILES=(.gitignore .dockerignore .codespell-ignore)
REQUIRED=("Potato" "Potato.md")
missing=0
for f in "${FILES[@]}"; do
  for r in "${REQUIRED[@]}"; do
    if ! grep -Fxq "$r" "$f"; then
      echo "$f missing '$r'" >&2
      missing=1
    fi
  done
done
if [ "$missing" -ne 0 ]; then
  echo "Required Potato entries not found in all ignore files." >&2
  echo "Add 'Potato' and 'Potato.md' to .gitignore, .dockerignore, and .codespell-ignore." >&2
  echo "See AGENTS.md for the policy or document an approved exception in docs/CHANGELOG.md." >&2
  exit 1
fi

