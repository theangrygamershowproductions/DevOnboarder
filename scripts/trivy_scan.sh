#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE=${1:-docker-compose.ci.yaml}
TRIVY_VERSION=${TRIVY_VERSION:-0.47.0}
TRIVY_CMD=${TRIVY_CMD:-trivy}

cleanup() { [ -n "${TMP_DIR:-}" ] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT

if ! command -v "$TRIVY_CMD" >/dev/null 2>&1; then
  echo "Trivy not found; downloading version $TRIVY_VERSION..."
  TMP_DIR=$(mktemp -d)
  tarball="trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"
  url="https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/${tarball}"
  curl -sSL "$url" -o "$TMP_DIR/$tarball"
  tar -xzf "$TMP_DIR/$tarball" -C "$TMP_DIR"
  TRIVY_CMD="$TMP_DIR/trivy"
fi

# Scan each built image referenced by the compose file
for image in $(docker compose -f "$COMPOSE_FILE" images -q); do
  echo "Scanning $image"
  "$TRIVY_CMD" image --exit-code 1 --severity HIGH,CRITICAL "$image"
  echo
done
