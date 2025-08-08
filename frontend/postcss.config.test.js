/**
 * @fileoverview Tests for PostCSS configuration
 * Ensures PostCSS config loads properly and contains expected plugins
 */

import { describe, it, expect } from 'vitest';

describe('PostCSS Config', () => {
    it('should load postcss config without errors', async () => {
        // Dynamic import to test the config can be loaded
        const config = await import('./postcss.config.js');

        expect(config.default).toBeDefined();
        expect(typeof config.default).toBe('object');
    });

    it('should have plugins configuration', async () => {
        const config = await import('./postcss.config.js');

        expect(config.default.plugins).toBeDefined();
        expect(typeof config.default.plugins).toBe('object');
    });

    it('should include tailwindcss plugin', async () => {
        const config = await import('./postcss.config.js');

        expect(config.default.plugins.tailwindcss).toBeDefined();
    });

    it('should include autoprefixer plugin', async () => {
        const config = await import('./postcss.config.js');

        expect(config.default.plugins.autoprefixer).toBeDefined();
    });

    it('should match expected configuration schema', async () => {
        const config = await import('./postcss.config.js');

        expect(config.default).toMatchObject({
            plugins: expect.objectContaining({
                tailwindcss: expect.anything(),
                autoprefixer: expect.anything()
            })
        });
    });
});
