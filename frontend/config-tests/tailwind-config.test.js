/**
 * @fileoverview Tests for Tailwind CSS configuration
 * Ensures config loads properly and contains expected settings
 */

import { describe, it, expect } from 'vitest';

describe('Tailwind Config', () => {
    it('should load tailwind config without errors', async () => {
        // Dynamic import to test the config can be loaded
        const config = await import('./tailwind.config.js');

        expect(config.default).toBeDefined();
        expect(typeof config.default).toBe('object');
    });

    it('should have correct content configuration', async () => {
        const config = await import('./tailwind.config.js');

        expect(config.default.content).toBeDefined();
        expect(Array.isArray(config.default.content)).toBe(true);
        expect(config.default.content).toContain('./index.html');
        expect(config.default.content).toContain('./src/**/*.{js,ts,jsx,tsx}');
    });

    it('should have plugins configured', async () => {
        const config = await import('./tailwind.config.js');

        expect(config.default.plugins).toBeDefined();
        expect(Array.isArray(config.default.plugins)).toBe(true);
        expect(config.default.plugins.length).toBeGreaterThan(0);
    });

    it('should have theme configuration', async () => {
        const config = await import('./tailwind.config.js');

        expect(config.default.theme).toBeDefined();
        expect(typeof config.default.theme).toBe('object');
    });

    it('should match expected configuration schema', async () => {
        const config = await import('./tailwind.config.js');

        expect(config.default).toMatchObject({
            content: expect.any(Array),
            theme: expect.any(Object),
            plugins: expect.any(Array)
        });
    });
});
