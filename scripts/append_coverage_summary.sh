#!/usr/bin/env sh
# Append coverage summary and link to summary.md
# Uses environment variables set by coverage tools or CI.

COVERED_LINES=${COVERED_LINES:-}
TOTAL_LINES=${TOTAL_LINES:-}
COVERAGE_PERCENT=${COVERAGE_PERCENT:-}
COVERED_BRANCHES=${COVERED_BRANCHES:-}
TOTAL_BRANCHES=${TOTAL_BRANCHES:-}
BRANCH_PERCENT=${BRANCH_PERCENT:-}
OUTPUT_FILE=${1:-summary.md}

{
  echo ""
  echo "### 📊 Coverage Summary"
  echo ""
  if [ -n "$COVERED_LINES" ] && [ -n "$TOTAL_LINES" ]; then
    echo "- **Lines:** ${COVERED_LINES}/${TOTAL_LINES} (${COVERAGE_PERCENT}%)"
  fi
  if [ -n "$COVERED_BRANCHES" ] && [ -n "$TOTAL_BRANCHES" ]; then
    echo "- **Branches:** ${COVERED_BRANCHES}/${TOTAL_BRANCHES} (${BRANCH_PERCENT}%)"
  fi
  printf "\n[Full coverage reports](%s/%s/actions/runs/%s)\n" \
    "${GITHUB_SERVER_URL:-https://github.com}" \
    "${GITHUB_REPOSITORY:-}" \
    "${GITHUB_RUN_ID:-}"
} >> "$OUTPUT_FILE"
