#!/usr/bin/env bash
set -euo pipefail

# Verifies access to required domains listed in docs/network-exception-list.md
DOMAINS=(
  github.com
  cli.github.com
  download.docker.com
  deb.nodesource.com
  nodejs.org
  vale.sh
  api.languagetool.org
  languagetool.org
  dev.languagetool.org
  quay.io
  ghcr.io
  img.shields.io
)

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
