#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE=${1:-docker-compose.ci.yaml}
TRIVY_VERSION=${TRIVY_VERSION:-0.47.0}
TRIVY_CMD=${TRIVY_CMD:-trivy}

if ! command -v "$TRIVY_CMD" >/dev/null 2>&1; then
  echo "Trivy not found; installing version $TRIVY_VERSION..."
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b . "$TRIVY_VERSION"
  TRIVY_CMD=./trivy
fi

# Scan each built image referenced by the compose file
for image in $(docker compose -f "$COMPOSE_FILE" images -q); do
  echo "Scanning $image"
  "$TRIVY_CMD" image --exit-code 1 --severity HIGH,CRITICAL "$image"
  echo
done
