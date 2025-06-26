# End-to-End Tests

The React frontend includes a small suite of Playwright tests.
These tests exercise the OAuth login flow and assume the dev services are running.

## Running Locally

1. Install dependencies and browsers:

   ```bash
   cd frontend
   npm ci
   npx playwright install
   ```

2. Start the services:

   ```bash
   docker compose -f docker-compose.dev.yaml --env-file .env.dev up -d
   ```

3. Execute the tests:

   ```bash
   npm run test:e2e
   ```

The configuration at `frontend/playwright.config.ts` automatically launches the Vite dev server before running the tests.
