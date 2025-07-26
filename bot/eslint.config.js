// ESLint flat configuration for Discord Bot (TypeScript/Node.js)
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
        files: ['**/*.{js,mjs,cjs}'],
        languageOptions: {
            ecmaVersion: 'latest',
            sourceType: 'module',
            globals: {
                // Node.js globals
                process: 'readonly',
                __dirname: 'readonly',
                __filename: 'readonly',
                Buffer: 'readonly',
                global: 'readonly',
                module: 'readonly',
                require: 'readonly',
                exports: 'readonly',
                console: 'readonly',
            },
        },
        rules: {
            // General JavaScript rules
            'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
            'no-console': 'off', // Allow console for Discord bot logging
            'prefer-const': 'error',
            'no-var': 'error',
            'no-undef': 'error',
            'no-empty-function': 'off', // Allow empty functions for Discord.js handlers
        },
    },

    // TypeScript configuration
    {
        files: ['**/*.ts'],
        languageOptions: {
            parser: tsparser,
            parserOptions: {
                ecmaVersion: 'latest',
                sourceType: 'module',
            },
            globals: {
                // Node.js globals
                process: 'readonly',
                __dirname: 'readonly',
                __filename: 'readonly',
                Buffer: 'readonly',
                global: 'readonly',
                module: 'readonly',
                require: 'readonly',
                exports: 'readonly',
                console: 'readonly',
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
            'no-console': 'off', // Allow console for Discord bot logging
            'prefer-const': 'error',
            'no-var': 'error',
            'no-empty-function': 'off', // Allow empty functions for Discord.js handlers
        },
    },

    // Test files configuration
    {
        files: [
            '**/*.{test,spec}.{js,ts}',
            '**/__tests__/**/*',
            '**/tests/**/*',
        ],
        languageOptions: {
            globals: {
                describe: 'readonly',
                it: 'readonly',
                expect: 'readonly',
                beforeEach: 'readonly',
                afterEach: 'readonly',
                beforeAll: 'readonly',
                afterAll: 'readonly',
                jest: 'readonly',
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
            'coverage/**',
            'node_modules/**',
            '*.config.js',
            '*.config.ts',
            'test-results/**',
        ],
    },
];
