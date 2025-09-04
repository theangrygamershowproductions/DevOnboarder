import { defineConfig } from 'vitest/config';

export default defineConfig({
    test: {
        environment: 'node',
        include: ['config-tests/**/*.test.{js,ts}'],
        // No coverage requirements for config validation tests
        coverage: {
            enabled: false,
        },
    },
});
