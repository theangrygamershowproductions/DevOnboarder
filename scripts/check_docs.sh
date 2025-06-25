#!/usr/bin/env bash
set -euo pipefail

FILES=$(git ls-files '*.md')
RESULTS_FILE="vale-results.json"

# Try to locate or download Vale
VALE_CMD="vale"
# Allow overriding the version; default to 3.4.2
VALE_VERSION="${VALE_VERSION:-3.4.2}"

if ! command -v vale >/dev/null 2>&1; then
  echo "Vale not found; attempting download of version $VALE_VERSION..."
  VALE_URL="https://github.com/errata-ai/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_Linux_64-bit.tar.gz"
  if curl -fsSL "$VALE_URL" | tar xz >/dev/null 2>&1; then
    chmod +x vale
    VALE_CMD="./vale"
  else
    echo "::warning file=scripts/check_docs.sh,line=$LINENO::Vale unavailable; skipping documentation style check"
    exit 0
  fi
fi

if ! "$VALE_CMD" --version >/dev/null 2>&1; then
  echo "::warning file=scripts/check_docs.sh,line=$LINENO::Vale failed to run; skipping documentation style check"
  exit 0
fi

set +e
"$VALE_CMD" --output=JSON $FILES > "$RESULTS_FILE"
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
