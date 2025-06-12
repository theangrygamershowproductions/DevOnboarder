---
project: "TAGS"
module: "Documentation Tools"
phase: "Maintenance Automation"
tags: ["metadata", "markdown", "indexing", "automation"]
updated: "12 June 2025 09:33 (EST)"
version: "v1.2.6"
author: "Chad Allan Reesey (Mr. Potato)"
email: "education@thenagrygamershow.com"
description: "Manages indexing and metadata injection for project documentation."
---

# Documentation Tools – Maintenance Automation
<!-- PATCHED v0.1.44 docs/SETUP.md — DevOnboarder CI & Security Setup -->

# DevOnboarder CI & Security Setup

## Overview

This guide covers on-prem and GitHub Actions configurations for CodeQL
scanning and on-chain verification.

## Environment Variables & Secrets

- **DEVONBOARDER_CODEQL_UPLOAD_TOKEN**: GitHub PAT for SARIF uploads
- **DEVONBOARDER_ETHEREUM_RPC_URL**: EVM node endpoint
- **DEVONBOARDER_ANCHOR_CONTRACT_ADDRESS**: Deployed CodeAnchor address
- **DEVONBOARDER_REPO_ANCHOR_KEY**: Key used when anchoring the hash
- **SNYK_TOKEN**: Authentication token used by the Snyk CLI

Add them under GitHub **Settings → Secrets**, or export on a Linux host:

```bash
export DEVONBOARDER_CODEQL_UPLOAD_TOKEN=ghp_xxx
export DEVONBOARDER_ETHEREUM_RPC_URL=https://rpc.example
export DEVONBOARDER_ANCHOR_CONTRACT_ADDRESS=0x123...
export DEVONBOARDER_REPO_ANCHOR_KEY=DevOnboarder-main
export SNYK_TOKEN=xxxx
```

`SNYK_TOKEN` is consumed by `.github/workflows/security-scan.yml` to run
Snyk dependency checks. The other variables are used by
`scripts/verify-on-chain.js` to verify the repository's commit hash on chain.

## On-Prem Setup (Cron Job)

1. Clone the repo:

    ```bash
    git clone https://github.com/theangrygamershowproductions/DevOnboarder /opt/repos/DevOnboarder
    ```

2. Place `/opt/codeql/run-codeql.sh` on the server and make it executable.
3. Add a crontab entry:

    ```cron
    0 2 * * * /opt/codeql/run-codeql.sh >> /var/log/codeql-run.log 2>&1
    ```

4. Install Docker and Docker Compose on the host and ensure Ethereum RPC is
   reachable.

## GitHub Actions Setup (Self-Hosted Runner)

1. Download and register a runner under **Settings → Actions → Runners**.
   Label it `self-hosted`.
2. Review `.github/workflows/codeql-scan.yml`:
    - Builds the scanner image.
    - Runs Python and JavaScript scans.
    - Uploads results and verifies the on-chain hash.
3. Add the four secrets in GitHub.

## Pre-commit Hooks

The repository uses pre-commit to enforce formatting and run tests. Key hooks
are defined in `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.45.0
    hooks:
      - id: markdownlint
  - repo: local
    hooks:
      - id: ensure-env
        entry: bash -c 'test -d venv || ./scripts/setup-dev.sh'
      - id: black
      - id: frontend-lint
      - id: frontend-test
      - id: pytest
```

Run `pre-commit run --all-files` once to install hook environments.

## Anchoring a New Release Hash

```bash
GIT_COMMIT=$(git rev-parse HEAD)
BYTES32_HASH="0x$(printf '%064s' "$GIT_COMMIT")"
```

Use an Ethers.js script to call:

```js
anchor("DevOnboarder-vX.Y.Z", BYTES32_HASH);
```

Store the contract ABI and run the script with Node.js and ethers.

## Troubleshooting

- **Missing environment variable: DEVONBOARDER\_…** – ensure it is exported or
  in GitHub Secrets.
- **Anchor key not found** – the on-chain hash does not exist for the key.
- **CodeQL upload errors** – check the token scopes and value.
- **Docker image build failures** – verify Dockerfile versions.

## Appendix

- Contract interface for `CodeAnchor.sol`:

    ```solidity
    function anchor(string memory key, bytes32 hashValue) external
    function getHash(string memory key) external view returns (bytes32)
    ```

- See GitHub and Ethereum documentation for more details.
- See GitHub and Ethereum documentation for more details.
