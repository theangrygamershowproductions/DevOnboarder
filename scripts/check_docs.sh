#!/usr/bin/env bash
set -e

FILES=$(git ls-files '*.md')

if ! command -v vale >/dev/null 2>&1; then
  echo "Vale not installed. Install it with 'brew install vale' or see docs/README.md."
  exit 1
fi

vale $FILES
python scripts/languagetool_check.py $FILES
