#!/usr/bin/env bash
set -euo pipefail

# Verifies access to required domains listed in docs/network-exception-list.md
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOC="$SCRIPT_DIR/../docs/network-exception-list.md"

readarray -t DOMAINS < <(awk '/^- /{gsub(/`/, ""); for(i=1;i<=NF;i++) if($i ~ /^[A-Za-z0-9.-]+\.(com|org|io|sh)$/) print $i}' "$DOC")

failed=0
for host in "${DOMAINS[@]}"; do
  echo -n "Checking $host ... "
  if curl -I --connect-timeout 5 "https://$host" >/dev/null 2>&1; then
    echo "ok"
  else
    echo "unreachable"
    failed=1
  fi
done

if [ "$failed" -ne 0 ]; then
  echo "One or more required domains are unreachable. See docs/network-exception-list.md" >&2
  exit 1
fi

echo "All required domains are reachable ✅"
