#!/usr/bin/env bash
set -euo pipefail

# Usage: check-bot-permissions.sh <bot> <permission>
# Verifies <bot> is allowed the given <permission> according to .codex/bot-permissions.yaml

BOT="${1:-}"
PERM="${2:-}"
FILE=".codex/bot-permissions.yaml"

if [ -z "$BOT" ] || [ -z "$PERM" ]; then
  echo "Usage: $0 <bot> <permission>" >&2
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "$FILE not found" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not installed" >&2
  exit 1
fi

has_perm=$(python3 - "$FILE" "$BOT" "$PERM" <<'PY'
import sys, yaml
path, bot, perm = sys.argv[1:]
data = yaml.safe_load(open(path)) or {}
perms = data.get(bot, {}).get('permissions', [])
print('true' if perm in perms else 'false')
PY
)

if [ "$has_perm" != "true" ]; then
  echo "Bot '$BOT' is not authorized for '$PERM'" >&2
  exit 1
fi

echo "Bot '$BOT' authorized for '$PERM'"
