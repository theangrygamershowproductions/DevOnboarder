// PATCHED v1.0.0 auth-server/vitest.config.ts — vitest config
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
  },
});
