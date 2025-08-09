/// <reference types="vitest" />
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: "./src/setupTests.ts",
    include: ["src/**/*.test.tsx", "src/**/*.test.ts"],
    exclude: ["e2e/**"],
    coverage: {
      provider: "v8",
      reporter: ["text", "lcov", "json-summary"],
      include: ["src/**/*.tsx", "src/**/*.ts"],
      exclude: [
        "src/components/AARForm.tsx",  // Complex form component - requires separate testing strategy
        "src/components/orchestrator/**",  // Orchestrator components - requires integration testing
        "src/setupTests.ts",
        "src/**/*.test.tsx",
        "src/**/*.test.ts",
        "**/*.config.js",
        "**/*.config.ts",
        "**/dist/**",
        "**/e2e/**"
      ],
      thresholds: {
        lines: 95,
        functions: 95,
        branches: 95,
        statements: 95,
      },
    },
  },
});
