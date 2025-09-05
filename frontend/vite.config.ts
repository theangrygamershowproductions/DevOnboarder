import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
    server: {
        port: 3000,
        host: '0.0.0.0',
        allowedHosts:
            process.env.NODE_ENV === 'production'
                ? [
                      process.env.VITE_ALLOWED_HOST_DEV ||
                          'dev.theangrygamershow.com',
                      process.env.VITE_ALLOWED_HOST_PROD ||
                          'theangrygamershow.com',
                      'localhost',
                  ]
                : true, // Allow all hosts in development for Traefik compatibility
    },
    plugins: [react()],
    test: {
        environment: 'jsdom',
        globals: true,
        setupFiles: './src/setupTests.ts',
        include: ['src/**/*.test.{js,tsx}'],
        exclude: ['e2e/**', 'config-tests/**'],
        coverage: {
            provider: 'v8',
            reporter: ['text', 'lcov', 'json-summary'],
            all: true,
            thresholds: {
                lines: 95,
                functions: 95,
                branches: 95,
                statements: 95,
            },
        },
    },
});
