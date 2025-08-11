module.exports = {
    preset: "ts-jest",
    testEnvironment: "node",
    collectCoverage: true,
    testTimeout: 30000,
    transform: {
        "^.+\\.ts$": "ts-jest"
    },
    coverageReporters: [
        "text",
        "lcov",
        "json-summary"
    ],
    coveragePathIgnorePatterns: [
        "<rootDir>/src/commands",
        "<rootDir>/src/utils/loadFiles.ts"
    ],
    coverageThreshold: {
        global: {
            branches: 92,
            functions: 95,
            lines: 95,
            statements: 95
        }
    }
};
