# Offline Setup

Some environments block direct access to package registries. Use another machine with internet access to download the files and copy them to your development system.

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
