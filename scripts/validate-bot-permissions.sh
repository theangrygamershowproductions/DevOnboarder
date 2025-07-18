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


# Capture agents missing permission entries
missing_permissions=$(python scripts/list-bots.py | python - <<'PY'
import json, sys
data = json.load(sys.stdin)
print(",".join(data.get("missing_permissions", [])))
PY
)

if [ -n "$missing_permissions" ]; then
  echo "Bots missing permission entries: $missing_permissions" >&2
  exit 1
fi

missing_required=$(python - "$FILE" "${REQUIRED[@]}" <<'PY'
import sys, yaml
path = sys.argv[1]
required = sys.argv[2:]
data = yaml.safe_load(open(path)) or {}
missing = [r for r in required if r not in data]
print(",".join(missing))
PY
)

if [ -n "$missing_required" ]; then
  echo "Missing required bot entries: $missing_required" >&2
  exit 1
fi

echo "Bot permissions file valid ✅"
