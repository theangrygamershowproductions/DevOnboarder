// PATCHED v0.1.4 sanity.test.ts — Basic Vitest check

import { describe, it, expect } from 'vitest';

describe('sanity test', () => {
  it('verifies test runner works', () => {
    expect(true).toBe(true);
  });
});
