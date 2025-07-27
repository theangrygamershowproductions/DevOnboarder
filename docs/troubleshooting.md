# Troubleshooting Guide

Development setups and CI runs sometimes fail in surprising ways.
This page collects quick fixes for the most common problems.

## Failed pre-commit hooks

-   Ensure you have run `pre-commit install` so git hooks execute automatically.
-   If the Node.js download fails during the Prettier hook, see
    [Network troubleshooting](network-troubleshooting.md#pre-commit-nodeenv-ssl-errors).
-   Missing Python packages? Install dev requirements with:

    ```bash
    pip install -r requirements-dev.txt
    ```

## Docker services won't start

-   Run `docker compose -f ../archive/docker-compose.dev.yaml --env-file .env.dev up -d` to rebuild containers.
-   Check container logs with `docker compose logs` for details.
-   If services exit immediately, verify secrets with `./scripts/generate-secrets.sh`.

## CI pipeline failures

-   Use `bash scripts/run_tests.sh` locally to reproduce lint and test failures.
-   For network-restricted environments, follow [Offline setup](offline-setup.md) to cache dependencies.
-   If CI cannot download tools or packages, review [Network troubleshooting](network-troubleshooting.md) for proxy tips.
