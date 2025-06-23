#!/usr/bin/env bash
set -e

FILES=$(git ls-files '*.md')

vale $FILES
python scripts/languagetool_check.py $FILES
