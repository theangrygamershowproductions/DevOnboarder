import { describe, it, expect } from 'vitest';

describe('Playwright Configuration', () => {
  it('should load and validate Playwright configuration', async () => {
    const config = await import('./playwright.config.ts');
    expect(config.default).toBeDefined();
    expect(typeof config.default).toBe('object');
  });

  it('should include test directory configuration', async () => {
    const config = await import('./playwright.config.ts');
    expect(config.default.testDir).toBeDefined();
    expect(typeof config.default.testDir).toBe('string');
  });

  it('should include browser projects', async () => {
    const config = await import('./playwright.config.ts');
    expect(config.default.projects).toBeDefined();
    expect(Array.isArray(config.default.projects)).toBe(true);
    expect(config.default.projects.length).toBeGreaterThan(0);
  });

  it('should include webServer configuration', async () => {
    const config = await import('./playwright.config.ts');
    expect(config.default.webServer).toBeDefined();
    expect(config.default.webServer.command).toContain('dev');
  });

  it('should have proper configuration structure', async () => {
    const config = await import('./playwright.config.ts');
    expect(config.default.testDir).toBeDefined();
    expect(config.default.fullyParallel).toBeDefined();
    expect(config.default.webServer).toBeDefined();
  });
});
