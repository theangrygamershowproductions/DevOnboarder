import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
    testDir: './e2e',
    fullyParallel: true,
    webServer: {
        command: 'npm run dev',
        port: 3000,
        reuseExistingServer: !process.env.CI,
    },
    use: {
        baseURL: 'http://localhost:3000',
    },
    projects: [
        {
            name: 'chromium',
            use: { ...devices['Desktop Chrome'] },
        },
    ],
});
