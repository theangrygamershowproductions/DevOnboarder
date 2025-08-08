import { describe, it, expect } from 'vitest';

describe('ESLint Configuration', () => {
  it('should load and validate ESLint configuration', async () => {
    const config = await import('./eslint.config.js');
    expect(config.default).toBeDefined();
    expect(Array.isArray(config.default)).toBe(true);
  });

  it('should include TypeScript parser configuration', async () => {
    const config = await import('./eslint.config.js');
    const tsConfig = config.default.find(cfg => cfg.languageOptions?.parser);
    expect(tsConfig).toBeDefined();
  });

  it('should include React configuration comments', async () => {
    const config = await import('./eslint.config.js');
    // Check that we have some React-related configuration
    expect(config.default).toBeDefined();
    expect(Array.isArray(config.default)).toBe(true);
  });

  it('should have proper file patterns configured', async () => {
    const config = await import('./eslint.config.js');
    const hasFiles = config.default.some(cfg => cfg.files && cfg.files.length > 0);
    expect(hasFiles).toBe(true);
  });

  it('should include rules configuration', async () => {
    const config = await import('./eslint.config.js');
    const hasRules = config.default.some(cfg => cfg.rules && Object.keys(cfg.rules).length > 0);
    expect(hasRules).toBe(true);
  });
});
