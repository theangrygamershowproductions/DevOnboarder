#!/usr/bin/env bash
# PATCHED v0.1.44 scripts/run-codeql-docker.sh — Run CodeQL inside Docker

set -euo pipefail

LANG="$1"

echo "[INFO] Building CodeQL database for language=${LANG} …"
docker-compose run --rm codeql-scanner \
  database create /db/${LANG}-db \
    --language=${LANG} \
    --source-root=/workspace \
    --overwrite

echo "[INFO] Analyzing CodeQL database for language=${LANG} …"
docker-compose run --rm codeql-scanner \
  database analyze /db/${LANG}-db \
    --format=sarifv2 \
    --output=/results/${LANG}.sarif \
    --threads=0

echo "[INFO] Uploading SARIF results for ${LANG} to GitHub …"
docker-compose run --rm codeql-scanner \
  codeql github upload-sarif \
    --repo theangrygamershowproductions/DevOnboarder \
    --sarif=/results/${LANG}.sarif \
    --token="${GITHUB_TOKEN}"

echo "[INFO] CodeQL scan for ${LANG} complete. Results at" \
  "./codeql-results/${LANG}.sarif"
