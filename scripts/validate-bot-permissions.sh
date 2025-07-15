#!/usr/bin/env bash
set -euo pipefail

FILE=".codex/bot-permissions.yaml"
REQUIRED=("orchestration_bot")

if [ ! -f "$FILE" ]; then
  echo "$FILE not found" >&2
  exit 1
fi

if ! command -v yamllint >/dev/null 2>&1; then
  echo "yamllint not installed" >&2
  exit 1
fi

yamllint -c .github/.yamllint-config "$FILE"

missing=$(python - "$FILE" "${REQUIRED[@]}" <<'PY'
import sys, yaml
path = sys.argv[1]
required = sys.argv[2:]
data = yaml.safe_load(open(path)) or {}
missing = [r for r in required if r not in data]
print(",".join(missing))
PY
)

if [ -n "$missing" ]; then
  echo "Missing required bot entries: $missing" >&2
  exit 1
fi

echo "Bot permissions file valid ✅"
