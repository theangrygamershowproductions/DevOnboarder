# Offline Setup

Some environments block direct access to package registries. Use another
machine with internet access to download the files and copy them to your
development system.

## Python wheels

1. On a machine with internet access, download the required wheels:

   ```bash
   mkdir -p ~/devonboarder-offline/python
   pip download -r requirements-dev.txt -d ~/devonboarder-offline/python
   ```

2. Transfer the `devonboarder-offline` folder to your offline machine (USB drive or internal share).

3. Install the packages locally:

   ```bash
   pip install --no-index --find-links=/path/to/devonboarder-offline/python -r requirements-dev.txt
   ```

## npm packages

1. On the online machine, prime an npm cache:

   ```bash
   mkdir -p ~/devonboarder-offline/npm
   cd frontend
   npm ci --cache ~/devonboarder-offline/npm
   ```

2. Copy the `devonboarder-offline` folder to your offline machine.

3. Install dependencies from the cache:

   ```bash
   cd frontend
   npm ci --offline --cache /path/to/devonboarder-offline/npm
   ```

## Bot npm packages

1. On the online machine, cache the bot dependencies:

   ```bash
   mkdir -p ~/devonboarder-offline/npm
   cd bot
   npm ci --cache ~/devonboarder-offline/npm
   ```

2. Copy the `devonboarder-offline` folder to your offline machine.

3. Install the bot dependencies from the cache:

   ```bash
   cd bot
   npm ci --offline --cache /path/to/devonboarder-offline/npm
   ```

After installing dependencies, run the usual setup commands such as `make deps` or `pre-commit install`.

## Documentation tooling (markdownlint-cli2)

`scripts/check_docs.sh` calls `npx -y markdownlint-cli2`. Cache this package so the
command works offline:

1. On the online machine, prime the npm cache from the repository root:

   ```bash
   mkdir -p ~/devonboarder-offline/npm
   npm ci --cache ~/devonboarder-offline/npm
   ```

2. Copy the `devonboarder-offline` folder to your offline machine.

3. Install the package from the cache and run the linter offline:

   ```bash
   npm ci --offline --cache /path/to/devonboarder-offline/npm
   npx --offline -y markdownlint-cli2
   ```

## Trivy

1. On a machine with internet access, download the Trivy binary:

   ```bash
 mkdir -p ~/devonboarder-offline/trivy
 curl -L -o ~/devonboarder-offline/trivy/trivy.tar.gz \
   https://github.com/aquasecurity/trivy/releases/download/v0.47.0/trivy_0.47.0_Linux-64bit.tar.gz
 tar -xzf ~/devonboarder-offline/trivy/trivy.tar.gz -C ~/devonboarder-offline/trivy
  # `scripts/trivy_scan.sh` fetches this tarball automatically when network access is available
   ```

2. Copy the `devonboarder-offline` folder to your offline machine.

3. Install the binary in your `PATH`:

   ```bash
   sudo install -m 755 /path/to/devonboarder-offline/trivy/trivy /usr/local/bin/trivy
   ```

Use `scripts/trivy_scan.sh` to scan the images built with `docker-compose.ci.yaml`.

## Pre-commit hooks

1. On the online machine, generate an offline bundle of hook environments:

   ```bash
   ./scripts/cache_precommit_hooks.sh
   ```

   This writes all hook dependencies to `~/devonboarder-offline/precommit`.

2. Copy the `devonboarder-offline` folder to your offline machine.

3. Point `pre-commit` at the cached hooks before installing:

   ```bash
   export PRE_COMMIT_HOME=/path/to/devonboarder-offline/precommit
   pre-commit install
   ```

The hooks will run without needing network access.

## Coverage badge

`scripts/update_coverage_badge.py` contacts `img.shields.io` to generate the
coverage badge. Set `OFFLINE_BADGE=1` before running the script to skip the
request. When the variable is set, the script uses `scripts/offline_badge_template.svg`
if present or prints a message that badge generation was skipped.
