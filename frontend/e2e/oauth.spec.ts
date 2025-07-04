import { test, expect } from '@playwright/test';

const AUTH = process.env.AUTH_URL ?? 'http://localhost:8002';

test('login flow shows user info', async ({ page }) => {
  await page.route(`${AUTH}/login/discord/callback*`, route =>
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ token: 'test-token' })
    })
  );
  await page.route(`${AUTH}/api/user`, route =>
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ id: '1', username: 'tester', avatar: null })
    })
  );
  await page.route(`${AUTH}/api/user/level`, route =>
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ level: 7 })
    })
  );
  await page.route(`${AUTH}/api/user/onboarding-status`, route =>
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ status: 'intro' })
    })
  );

  // Ensure the Vite dev server is ready before hitting the callback route
  await page.goto('/', { waitUntil: 'networkidle' });
  await page.goto('/login/discord/callback?code=abc');

  await expect(page.getByTestId('user-welcome')).toContainText('tester');
  await expect(page.getByTestId('user-level')).toContainText('7');
  await expect(page.getByTestId('onboarding-status')).toContainText('intro');
});
