#!/usr/bin/env bash
# Poll a URL until it returns success or retry limit is reached
set -euo pipefail

URL=${1:?"usage: $0 URL [retries] [sleep]"}
RETRIES=${2:-30}
SLEEP=${3:-2}

for ((i=1; i<=RETRIES; i++)); do
  if curl -fs "$URL" >/dev/null; then
    echo "Service is up!"
    exit 0
  fi
  echo "Waiting for service... ($i/$RETRIES)"
  sleep "$SLEEP"
done

echo "Service failed to start: $URL" >&2
docker compose ps >&2
docker compose logs auth >&2
exit 1
