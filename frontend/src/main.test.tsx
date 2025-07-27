import { describe, it, expect } from 'vitest';

// Verify that importing the entry point does not throw

describe('main entry', () => {
    it('loads without throwing', async () => {
        document.body.innerHTML = '<div id="root"></div>';
        await expect(import('./main')).resolves.toBeDefined();
    });
});
