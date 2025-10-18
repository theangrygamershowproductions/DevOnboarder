#!/usr/bin/env bash
# check_long_running_scripts.sh - detect long-running processes referencing files under scripts/
#
# Usage:
#   ./scripts/check_long_running_scripts.sh [--threshold-seconds N] [--ignore-pid PID] [--json]
#
# By default it reports processes whose elapsed time (in seconds) is greater than 60.
# It looks for processes whose command line contains the substring "scripts/" so it flags any
# tools in this repo that may have hung (e.g., long-running grep/cat/timeout problems).
#
# Exit codes:
#   0 - no matching long-running processes
#   1 - found one or more long-running script processes
#
# This script is intentionally simple and uses only POSIX-friendly utilities available in CI.

set -euo pipefail

THRESHOLD=${THRESHOLD_SECONDS:-60}
OUTPUT_JSON=0
declare -a IGNORE_PIDS=()

print_help() {
  sed -n '1,120p' "$0"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --threshold-seconds)
      shift; THRESHOLD="$1"; shift;;
    --ignore-pid)
      shift; IGNORE_PIDS=("$1"); shift;;
    --json)
      OUTPUT_JSON=1; shift;;
    -h|--help)
      print_help; exit 0;;
    *)
      echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

if ! command -v ps >/dev/null 2>&1; then
  echo "ps not available; cannot inspect processes" >&2
  exit 2
fi

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

# Gather processes with commandline containing 'scripts/' (exclude this script itself)
# Use pgrep to find PIDs, then ps to get details
SCRIPT_PIDS=$(pgrep -f 'scripts/' || true)
LINES=()
if [ -n "$SCRIPT_PIDS" ]; then
  # Get process details for the found PIDs using ps
  PS_OUTPUT=$(echo "$SCRIPT_PIDS" | xargs ps -o pid=,etimes=,cmd= 2>/dev/null || true)
  while IFS= read -r line; do
    [ -n "$line" ] && LINES=("$line")
  done <<< "$PS_OUTPUT"
fi

for ln in "${LINES[@]}"; do
  pid=$(printf '%s' "$ln" | awk '{print $1}')
  etimes=$(printf '%s' "$ln" | awk '{print $2}')
  cmd=$(printf '%s' "$ln" | cut -d' ' -f3-)

  # skip ourself
  if [ "$pid" = "$$" ]; then
    continue
  fi

  skip=0
  for ip in "${IGNORE_PIDS[@]:-}"; do
    if [ "$pid" = "$ip" ]; then skip=1; break; fi
  done
  if [ "$skip" -eq 1 ]; then continue; fi

  # ensure etimes looks numeric
  if ! printf '%s' "$etimes" | grep -qE '^[0-9]$'; then
    continue
  fi

  if [ "$etimes" -ge "$THRESHOLD" ]; then
    printf '%s|%s|%s\n' "$pid" "$etimes" "$cmd" >> "$TMPFILE"
  fi
done

FOUND_COUNT=$(wc -l < "$TMPFILE" | tr -d ' ')
if [ "$FOUND_COUNT" -eq 0 ]; then
  if [ "$OUTPUT_JSON" -eq 1 ]; then
    echo '{"long_running": []}'
  else
    echo " no long-running script processes (threshold=${THRESHOLD}s)"
  fi
  exit 0
fi

if [ "$OUTPUT_JSON" -eq 1 ]; then
  printf '{"long_running": ['
  first=1
  while IFS='|' read -r pid et cmd; do
    if [ "$first" -eq 1 ]; then first=0; else printf ','; fi
    esc_cmd=$(printf '%s' "$cmd" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))')
    printf '{"pid":%s,"etimes":%s,"cmd":%s}' "$pid" "$et" "$esc_cmd"
  done < "$TMPFILE"
  printf ']}'
else
  echo "FOUND ${FOUND_COUNT} long-running script processes (threshold=${THRESHOLD}s):"
  while IFS='|' read -r pid et cmd; do
    printf '  PID: %s  ELAPSED: %ss  CMD: %s\n' "$pid" "$et" "$cmd"
  done < "$TMPFILE"
fi

exit 1
