import { describe, it, expect } from 'vitest';
import fs from 'fs';
import path from 'path';

describe('Vite Configuration', () => {
  it('should have a valid configuration file', () => {
    const configPath = path.resolve(process.cwd(), 'vite.config.ts');
    expect(fs.existsSync(configPath)).toBe(true);
  });

  it('should contain test environment configuration', () => {
    const configPath = path.resolve(process.cwd(), 'vite.config.ts');
    const configContent = fs.readFileSync(configPath, 'utf-8');
    expect(configContent).toContain("environment: 'jsdom'");
  });

  it('should include coverage thresholds', () => {
    const configPath = path.resolve(process.cwd(), 'vite.config.ts');
    const configContent = fs.readFileSync(configPath, 'utf-8');
    expect(configContent).toContain('thresholds');
    expect(configContent).toContain('95');
  });

  it('should configure React plugin', () => {
    const configPath = path.resolve(process.cwd(), 'vite.config.ts');
    const configContent = fs.readFileSync(configPath, 'utf-8');
    expect(configContent).toContain('react()');
  });

  it('should have proper server configuration', () => {
    const configPath = path.resolve(process.cwd(), 'vite.config.ts');
    const configContent = fs.readFileSync(configPath, 'utf-8');
    expect(configContent).toContain('port: 3000');
    expect(configContent).toContain("host: '0.0.0.0'");
  });
});
