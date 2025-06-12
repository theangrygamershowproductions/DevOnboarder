// PATCHED v0.1.15 frontend/eslint.config.cjs — Enable JSX parsing

//
// Project: DevOnboarder
// File: frontend/eslint.config.cjs
// Purpose: ESLint configuration for the frontend
// Updated: 4 Jun 2025
// Version: v1.0.3
//

const js = require('@eslint/js');
const react = require('eslint-plugin-react');
const tsParser = require('@typescript-eslint/parser');
const tsPlugin = require('@typescript-eslint/eslint-plugin');

module.exports = [
  js.configs.recommended,
  {
    files: ['**/*.{ts,tsx}'],
    ignores: ['eslint.config.cjs'],
    plugins: { react, '@typescript-eslint': tsPlugin },
    languageOptions: {
      parser: tsParser,
      ecmaVersion: 'latest',
      sourceType: 'module',
      parserOptions: { ecmaFeatures: { jsx: true } },
      globals: {
        document: 'readonly',
        window: 'readonly',
      },
    },
    rules: {},
  },
];
