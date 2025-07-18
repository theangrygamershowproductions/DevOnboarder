#!/usr/bin/env bash
set -euo pipefail

DRY_RUN="${DRY_RUN:-true}"
BASE_BRANCH="${BASE_BRANCH:-main}"
DAYS_STALE="${DAYS_STALE:-30}"

if ! command -v git >/dev/null 2>&1; then
  echo "git not found" >&2
  exit 1
fi

echo "Fetching remote branches..."
# prune deleted remote refs
git fetch origin --prune

cutoff=$(date -d "${DAYS_STALE} days ago" +%s)

# List merged branches
while read -r branch; do
  b=${branch#origin/}
  [[ "$b" == "$BASE_BRANCH" ]] && continue
  [[ "$b" == "HEAD" ]] && continue
  [[ "$b" == "dev" ]] && continue
  [[ "$b" == release/* ]] && continue
  if git merge-base --is-ancestor "origin/$b" "origin/$BASE_BRANCH"; then
    ts=$(git show -s --format=%ct "origin/$b")
    if [ "$ts" -lt "$cutoff" ]; then
      if [ "$DRY_RUN" = "true" ]; then
        echo "Would delete $b"
      else
        git push origin --delete "$b" && echo "Deleted $b"
      fi
    fi
  fi
done < <(git branch -r --merged "origin/$BASE_BRANCH")
