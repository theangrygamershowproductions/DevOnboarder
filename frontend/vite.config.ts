import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";

export default defineConfig({
    server: {
        port: 3000,
    },
    plugins: [react()],
    test: {
        environment: "jsdom",
        globals: true,
        setupFiles: "./src/setupTests.ts",
        include: ["src/**/*.test.tsx"],
        exclude: ["e2e/**"],
        coverage: {
            provider: "v8",
            reporter: ["text", "lcov", "json-summary"],
            all: true,
            thresholds: {
                lines: 95,
                functions: 95,
                branches: 95,
                statements: 95,
            },
        },
    },
});
