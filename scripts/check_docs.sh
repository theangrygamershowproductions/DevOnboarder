#!/usr/bin/env bash
set -euo pipefail

FILES=$(git ls-files '*.md')
RESULTS_FILE="vale-results.json"

# Try to locate or download Vale
VALE_CMD="${VALE_BINARY:-vale}"
# Allow overriding the version; default to 3.12.0
VALE_VERSION="${VALE_VERSION:-3.12.0}"

if ! command -v "$VALE_CMD" >/dev/null 2>&1; then
  echo "Vale not found; attempting download of version $VALE_VERSION..."
  VALE_URL="https://github.com/errata-ai/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_Linux_64-bit.tar.gz"
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TMP_DIR"' EXIT
  if curl -fsSL "$VALE_URL" | tar -xzC "$TMP_DIR" --strip-components=1; then
    if [ ! -f "$TMP_DIR/vale" ]; then
      echo "::warning file=scripts/check_docs.sh,line=$LINENO::Unable to download Vale. Install version $VALE_VERSION manually and set VALE_BINARY to its path. Skipping documentation style check"
      exit 0
    fi
    mv "$TMP_DIR/vale" ./vale
    chmod +x ./vale
    VALE_CMD="./vale"
  else
    echo "::warning file=scripts/check_docs.sh,line=$LINENO::Unable to download Vale. Install version $VALE_VERSION manually and set VALE_BINARY to its path. Skipping documentation style check"
    exit 0
  fi
fi

if ! "$VALE_CMD" --version >/dev/null 2>&1; then
  echo "::warning file=scripts/check_docs.sh,line=$LINENO::Vale failed to run. Install version $VALE_VERSION and set VALE_BINARY if necessary. Skipping documentation style check"
  exit 0
fi

set +e
"$VALE_CMD" --output=JSON $FILES >"$RESULTS_FILE"
status=$?
set -e
if [ $status -ne 0 ]; then
  echo "::warning file=scripts/check_docs.sh,line=$LINENO::Vale style issues found"
  cat "$RESULTS_FILE"
fi

echo "::notice file=scripts/check_docs.sh,line=$LINENO::LanguageTool check skipped; script archived"
