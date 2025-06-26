# End-to-End Tests

The React frontend includes a small suite of Playwright tests.
These tests exercise the OAuth login flow and assume the dev services are running.

## Running Locally

1. Install dependencies and browsers from the `frontend/` directory:

   ```bash
   cd frontend
   npm ci
   npx playwright install --with-deps
   ```

2. Start the services:

   ```bash
   docker compose -f docker-compose.dev.yaml --env-file .env.dev up -d
   ```

3. Execute the tests:

   ```bash
   npm run test:e2e
   ```

   The tests read the auth service URL from the `AUTH_URL` environment variable,
   defaulting to `http://localhost:8002` when unset.

The configuration at `frontend/playwright.config.ts` automatically launches the Vite dev server before running the tests.

User details rendered by `Login.tsx` expose `data-testid` attributes
(`user-welcome`, `user-level`, and `onboarding-status`) so tests can
select elements reliably.

## Troubleshooting

If the tests fail with a timeout on `toContainText`, the Vite dev server may not
be fully compiled before Playwright navigates to the page. Ensure the dev server
responds on <http://localhost:3000> by loading it in a browser or hitting the
root URL with `curl` before running the tests. Re-running `npx playwright
install` can also fix missing browser errors.
