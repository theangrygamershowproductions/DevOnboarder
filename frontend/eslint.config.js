// ESLint flat configuration for React + TypeScript frontend
// Compatible with ESLint v9+ flat config format
// DevOnboarder Project Standards: Compliant with copilot-instructions.md

import js from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';
import tsparser from '@typescript-eslint/parser';

export default [
    // Base JavaScript recommended rules
    js.configs.recommended,

    // Configuration for JavaScript files
    {
        files: ['**/*.{js,mjs,cjs,jsx}'],
        languageOptions: {
            ecmaVersion: 'latest',
            sourceType: 'module',
            globals: {
                // Browser globals
                window: 'readonly',
                document: 'readonly',
                console: 'readonly',
                // Node.js globals for build scripts
                process: 'readonly',
                __dirname: 'readonly',
                __filename: 'readonly',
                Buffer: 'readonly',
                global: 'readonly',
            },
            parserOptions: {
                ecmaFeatures: {
                    jsx: true,
                },
            },
        },
        rules: {
            // General JavaScript rules
            'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
            'no-console': 'warn',
            'prefer-const': 'error',
            'no-var': 'error',

            // React-specific rules (basic)
            'no-undef': 'error',

            // Allow empty functions (common in React props)
            'no-empty-function': 'off',
        },
    },

    // TypeScript configuration
    {
        files: ['**/*.{ts,tsx}'],
        languageOptions: {
            parser: tsparser,
            parserOptions: {
                ecmaVersion: 'latest',
                sourceType: 'module',
                ecmaFeatures: {
                    jsx: true,
                },
            },
            globals: {
                // Browser globals
                window: 'readonly',
                document: 'readonly',
                console: 'readonly',
                // Node.js globals for build scripts
                process: 'readonly',
                __dirname: 'readonly',
                __filename: 'readonly',
                Buffer: 'readonly',
                global: 'readonly',
            },
        },
        plugins: {
            '@typescript-eslint': tseslint,
        },
        rules: {
            // TypeScript handles unused vars checking better
            'no-unused-vars': 'off',
            '@typescript-eslint/no-unused-vars': [
                'error',
                { argsIgnorePattern: '^_' },
            ],

            // TypeScript handles undef checking
            'no-undef': 'off',

            // General rules
            'no-console': 'warn',
            'prefer-const': 'error',
            'no-var': 'error',
            'no-empty-function': 'off',
        },
    },

    // Test files configuration
    {
        files: ['**/*.{test,spec}.{js,ts,tsx}', '**/__tests__/**/*'],
        languageOptions: {
            globals: {
                describe: 'readonly',
                it: 'readonly',
                expect: 'readonly',
                beforeEach: 'readonly',
                afterEach: 'readonly',
                beforeAll: 'readonly',
                afterAll: 'readonly',
                vi: 'readonly',
                test: 'readonly',
            },
        },
        rules: {
            'no-console': 'off',
        },
    },

    // Ignore patterns
    {
        ignores: [
            'dist/**',
            'build/**',
            'coverage/**',
            'node_modules/**',
            '*.config.js',
            '*.config.ts',
            '.vite/**',
            'test-results/**',
            'playwright-report/**',
        ],
    },
];
