#!/usr/bin/env bash
set -euo pipefail

FILE=".codex/bot-permissions.yaml"

if [ ! -f "$FILE" ]; then
  echo "$FILE not found" >&2
  exit 1
fi

if ! command -v yamllint >/dev/null 2>&1; then
  echo "yamllint not installed" >&2
  exit 1
fi

yamllint -c .github/.yamllint-config "$FILE"

echo "Bot permissions lint passed"
