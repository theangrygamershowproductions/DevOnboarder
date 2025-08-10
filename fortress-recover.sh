#!/usr/bin/env bash
# fortress-recover.sh — zero-knowledge archaeology for the CI fortress
# Read-only utility: discovers the fortress commit/tag and helps operators inspect it.

set -Eeuo pipefail

# Ensure we're in a git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Not a git repository. Run this from inside a repo clone."; exit 1;
}

# TTY-aware colors
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
  BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; PURPLE=''; CYAN=''; NC=''
fi

printf "%b\n" "${PURPLE}🏛️  FORTRESS ARCHAEOLOGY SYSTEM${NC}"

# Prefer the latest fortress tag; fall back to grep if needed
FORTRESS_TAG="$(git tag -l 'fortress-v*' --sort=-v:refname | head -n1 || true)"
if [[ -n "${FORTRESS_TAG}" ]]; then
  TARGET="${FORTRESS_TAG}"
  printf "%b %s%b\n" "${GREEN}✔${NC}" "Found tag: " "${CYAN}${FORTRESS_TAG}${NC}"
  git show -s --format="%h %ad %s" --date=iso-strict "${FORTRESS_TAG}" || true
else
  printf "%b %s\n" "${YELLOW}…${NC}" "No fortress tag found, searching commit history…"
  FORTRESS_HASH="$(git log --grep='autonomous CI governance fortress\|FORTRESS_COMPLETE_PR_BODY.md' --format='%H' -n 1 || true)"
  if [[ -n "${FORTRESS_HASH}" ]]; then
    TARGET="${FORTRESS_HASH}"
    printf "%b %s%b\n" "${GREEN}✔${NC}" "Found fortress commit: " "${CYAN}${FORTRESS_HASH}${NC}"
    git show -s --format="%h %ad %s" --date=iso-strict "${FORTRESS_HASH}" || true
  else
    printf "%b %s\n" "${RED}✖${NC}" "Couldn't locate fortress tag or commit."
    printf "Try:\n  - Ensure the repo contains the capstone commit/tag\n  - Run: git fetch --tags --all\n"
    exit 2
  fi
fi

# Helpers
has() { command -v "$1" >/dev/null 2>&1; }

quick_health_check() {
  printf "%b\n" "${BLUE}⏱  Running quick health check…${NC}"

  # 1) Branch protection vs file
  if [[ -x "./scripts/verify-branch-protection.sh" ]]; then
    ./scripts/verify-branch-protection.sh || true
  else
    printf "%b %s\n" "${YELLOW}•${NC}" "scripts/verify-branch-protection.sh not found"
  fi

  # 2) Required checks vs live PR (needs gh)
  if has gh && [[ -x "./scripts/assert_required_checks.sh" ]]; then
    PR_NUM="$(gh pr list --limit 1 --json number -q '.[0].number' 2>/dev/null || echo "")"
    if [[ -n "${PR_NUM}" ]]; then
      ./scripts/assert_required_checks.sh "${PR_NUM}" || true
    else
      printf "%b %s\n" "${YELLOW}•${NC}" "No PRs found to validate required checks"
    fi
  else
    printf "%b %s\n" "${YELLOW}•${NC}" "GitHub CLI or script missing for required-checks assertion"
  fi

  # 3) Workflow headers audit
  if [[ -x "./scripts/audit-workflow-headers.sh" ]]; then
    ./scripts/audit-workflow-headers.sh || true
  else
    printf "%b %s\n" "${YELLOW}•${NC}" "scripts/audit-workflow-headers.sh not found"
  fi

  printf "%b\n" "${GREEN}✔ Health check finished.${NC}"
}

show_condensed() {
  printf "%b\n\n" "${BLUE}📜 Condensed legend (commit header + message):${NC}"
  git show -s --format=medium "${TARGET}"
}

show_full() {
  printf "%b\n\n" "${BLUE}🎬 Full cinematic narrative (commit diff disabled):${NC}"
  # Show full commit message/body only
  git show --no-patch "${TARGET}"
}

menu() {
  printf "\n%b\n" "${CYAN}Select an option:${NC}"
  printf "  0) Run quick health check now\n"
  printf "  1) Show condensed legend\n"
  printf "  2) Show full cinematic narrative\n"
  printf "  3) Show tag/commit header again\n"
  printf "  4) Exit\n"
  printf "\n"
  read -r -p "Select option (0-4): " choice
  case "${choice}" in
    0) quick_health_check ;;
    1) show_condensed ;;
    2) show_full ;;
    3) git show -s --format="%H%n%h %ad %s" --date=iso-strict "${TARGET}" ;;
    4) printf "%b\n" "${GREEN}Bye!${NC}"; exit 0 ;;
    *) printf "%b %s\n" "${YELLOW}!${NC}" "Invalid choice";;
  esac
}

# Loop until exit
while true; do menu; done
