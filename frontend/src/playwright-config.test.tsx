import config from '../playwright.config';
import { expect, describe, it } from 'vitest';

describe('playwright config', () => {
  it('exports config object', () => {
    expect(config).toBeDefined();
  });
});
