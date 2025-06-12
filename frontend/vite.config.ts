// PATCHED v0.1.37 frontend/vite.config.ts — Load dev env file

import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { config } from 'dotenv';

// Load environment variables for local development
config({ path: '.env.frontend.dev' });

export default defineConfig({
  plugins: [react()],
  envPrefix: 'VITE_',
});
