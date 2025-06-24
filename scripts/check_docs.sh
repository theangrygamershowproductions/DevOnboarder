#!/usr/bin/env bash
set -euo pipefail

FILES=$(git ls-files '*.md')

if ! command -v vale >/dev/null 2>&1; then
  echo "::error file=scripts/check_docs.sh,line=$LINENO::Vale not installed"
  exit 1
fi

if ! vale $FILES; then
  echo "::error file=scripts/check_docs.sh,line=$LINENO::Vale issues found"
  exit 1
fi

if ! python scripts/languagetool_check.py $FILES; then
  echo "::error file=scripts/check_docs.sh,line=$LINENO::LanguageTool issues found"
  exit 1
fi
