#!/usr/bin/env bash
# PATCHED v0.1.43 /opt/codeql/run-codeql.sh — Cron wrapper for CodeQL

set -euo pipefail

cd /opt/repos/DevOnboarder && git pull origin main

docker-compose \
  -f /opt/repos/DevOnboarder/docker-compose.yml \
  build codeql-scanner

docker-compose -f /opt/repos/DevOnboarder/docker-compose.yml run --rm \
  -e GITHUB_TOKEN="${DEVONBOARDER_CODEQL_UPLOAD_TOKEN}" \
  codeql-scanner \
  database create /db/python-db --language=python --source-root=/workspace

docker-compose -f /opt/repos/DevOnboarder/docker-compose.yml run --rm \
  -e GITHUB_TOKEN="${DEVONBOARDER_CODEQL_UPLOAD_TOKEN}" \
  codeql-scanner \
  database analyze /db/python-db \
    --format=sarifv2 \
    --output=/results/python.sarif

docker-compose -f /opt/repos/DevOnboarder/docker-compose.yml run --rm \
  -e GITHUB_TOKEN="${DEVONBOARDER_CODEQL_UPLOAD_TOKEN}" \
  codeql-scanner \
  github upload-sarif \
    --repo theangrygamershowproductions/DevOnboarder \
    --sarif=/results/python.sarif

docker-compose -f /opt/repos/DevOnboarder/docker-compose.yml run --rm \
  -e GITHUB_TOKEN="${DEVONBOARDER_CODEQL_UPLOAD_TOKEN}" \
  codeql-scanner \
  database create /db/js-db \
    --language=javascript \
    --source-root=/workspace

docker-compose -f /opt/repos/DevOnboarder/docker-compose.yml run --rm \
  -e GITHUB_TOKEN="${DEVONBOARDER_CODEQL_UPLOAD_TOKEN}" \
  codeql-scanner \
  database analyze /db/js-db \
    --format=sarifv2 \
    --output=/results/js.sarif

docker-compose -f /opt/repos/DevOnboarder/docker-compose.yml run --rm \
  -e GITHUB_TOKEN="${DEVONBOARDER_CODEQL_UPLOAD_TOKEN}" \
  codeql-scanner \
  github upload-sarif \
    --repo theangrygamershowproductions/DevOnboarder \
    --sarif=/results/js.sarif

docker run --rm \
  -v "/opt/repos/DevOnboarder":/workspace \
  -e DEVONBOARDER_ETHEREUM_RPC_URL="${DEVONBOARDER_ETHEREUM_RPC_URL}" \
  -e DEVONBOARDER_ANCHOR_CONTRACT_ADDRESS="${DEVONBOARDER_ANCHOR_CONTRACT_\
ADDRESS}" \
  -e DEVONBOARDER_REPO_ANCHOR_KEY="${DEVONBOARDER_REPO_ANCHOR_KEY}" \
  node:22-alpine sh -c \
    "npm install ethers@^6.0 && node /workspace/scripts/verify-on-chain.js"

echo "CI + CodeQL + On-Chain scan completed at $(date)"
