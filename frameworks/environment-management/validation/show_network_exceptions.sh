#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOC="$SCRIPT_DIR/../docs/network-exception-list.md"

awk '/^- /{gsub(/`/, ""); for(i=1;i<=NF;i++) if($i ~ /^[A-Za-z0-9.-]+\.(com|org|io|sh)$/) print $i}' "$DOC"
