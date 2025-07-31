# Quickstart

Follow these steps to get the DevOnboarder stack running in minutes.

1. **Clone the repo**

   ```bash
   git clone https://github.com/theangrygamershowproductions/DevOnboarder.git && cd DevOnboarder
   ```

2. **Copy example environment variables**

   ```bash
   cp .env.example .env
   cp auth/.env.example auth/.env
   cp bot/.env.example bot/.env
   cp frontend/src/.env.example frontend/src/.env
   ```

3. **Start the services**

   ```bash
   docker compose up -d
   ```

4. **Run tests to verify the setup**

   ```bash
   ./scripts/run_tests.sh
   ```

If the tests pass, you're ready to develop. See [docs/README.md](docs/README.md) and [CONTRIBUTING.md](CONTRIBUTING.md) for full documentation.
