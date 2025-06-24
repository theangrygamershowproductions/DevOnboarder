#!/usr/bin/env bash
set -euo pipefail

FILES=$(git ls-files '*.md')
RESULTS_FILE="vale-results.json"

if ! command -v vale >/dev/null 2>&1; then
  echo "::error file=scripts/check_docs.sh,line=$LINENO::Vale not installed"
  exit 1
fi

set +e
vale --output=JSON $FILES > "$RESULTS_FILE"
status=$?
set -e
if [ $status -ne 0 ]; then
  echo "::error file=scripts/check_docs.sh,line=$LINENO::Vale issues found"
  cat "$RESULTS_FILE"
  exit $status
fi

if ! python scripts/languagetool_check.py $FILES; then
  echo "::error file=scripts/check_docs.sh,line=$LINENO::LanguageTool issues found"
  exit 1
fi
