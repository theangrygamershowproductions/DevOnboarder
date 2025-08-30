#!/usr/bin/env bash
set -euo pipefail

# Conventional commit gate:
# <TYPE>(<scope>): <subject>
# TYPES: FEAT|FIX|DOCS|STYLE|REFACTOR|TEST|CHORE|SECURITY|BUILD|REVERT|PERF|CI|OPS|WIP|INIT|TAG|POLICY|HOTFIX|CLEANUP
# Extras: Build (Title case) + build (lowercase) for Dependabot
regex='^(FEAT|FIX|DOCS|STYLE|REFACTOR|TEST|CHORE|SECURITY|BUILD|Build|build|REVERT|PERF|CI|OPS|WIP|INIT|TAG|POLICY|HOTFIX|CLEANUP)(\([^)]+\))?: .+'

# Determine base ref (PRs vs pushes)
BASE_BRANCH="${GITHUB_BASE_REF:-main}"
BASE_REF="origin/${BASE_BRANCH}"

# Ensure we have the base ref (checkout often uses shallow clones)
if ! git rev-parse -q --verify "$BASE_REF" >/dev/null 2>&1; then
  # Try to fetch base branch; don't fail pipeline if network hiccups
  git fetch --no-tags --depth=50 origin "${BASE_BRANCH}:${BASE_BRANCH}" 2>/dev/null || \
  git fetch --unshallow 2>/dev/null || true
fi

# Collect commit subjects between base and HEAD; skip merge commits at the source
messages="$(git log --format=%s --no-merges "${BASE_REF}..HEAD" || true)"

if [ -z "${messages}" ]; then
  printf 'No new commits to lint\n'
  exit 0
fi

# Temp file to avoid subshell while-read pitfalls
temp_file="$(mktemp)"
printf '%s\n' "${messages}" > "${temp_file}"

errors=0
while IFS= read -r msg || [ -n "${msg:-}" ]; do
  # Skip empty lines (defensive)
  [ -z "${msg}" ] && continue

  # Legacy exceptions during transition
  if [[ "${msg}" =~ ^Merge ]]; then
    printf 'Skipping merge commit: %s\n' "${msg}"
    continue
  fi
  if [[ "${msg}" =~ ^(RESOLVE:|Revert) ]]; then
    printf 'Skipping legacy commit format: %s\n' "${msg}"
    continue
  fi

  if ! printf '%s' "${msg}" | grep -Eq "${regex}"; then
    printf '::error ::Commit message %s does not follow <TYPE>(<scope>): <subject> format\n' "${msg}"
    printf '::error ::Expected: FEAT|FIX|DOCS|STYLE|REFACTOR|TEST|CHORE|SECURITY|BUILD|REVERT|PERF|CI|OPS|WIP|INIT|TAG|POLICY|HOTFIX|CLEANUP (scope optional)\n'
    printf '::error ::Also allowed: Build|build (deps) for Dependabot\n'
    errors=$((errors+1))
  fi
done < "${temp_file}"

rm -f "${temp_file}"

if [ "${errors}" -ne 0 ]; then
  printf '::error ::Found %d commit message(s) that do not follow the required format.\n' "${errors}"
  printf '::error ::See scripts/commit-msg for the enforced standard\n'
  exit 1
fi

printf 'SUCCESS: All commit messages pass validation!\n'
