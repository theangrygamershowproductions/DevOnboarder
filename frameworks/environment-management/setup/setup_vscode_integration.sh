#!/bin/bash
# DevOnboarder VS Code Integration Setup
# Creates standardized VS Code workspace configuration for team consistency

set -e

echo "🔧 Setting up DevOnboarder VS Code Integration..."

# Create .vscode directory if it doesn't exist
mkdir -p .vscode

# Create settings.json with DevOnboarder-specific configuration
cat > .vscode/settings.json << 'EOF'
{
    "postman.settings.dotenv-detection-notification-visibility": false,
    "editor.indentSize": "tabSize",
    "terminal.integrated.defaultProfile.linux": "zsh",
    "python.formatting.provider": "black",
    "python.formatting.blackArgs": ["--line-length=88", "--target-version=py312"],
    "python.defaultInterpreterPath": "./.venv/bin/python",
    "editor.formatOnSave": false,
    "[python]": {
        "editor.formatOnSave": false,
        "editor.codeActionsOnSave": {
            "source.organizeImports": "never"
        }
    },
    "yaml.customTags": ["!reference"],
    "yaml.validate": true,
    "yaml.completion": true,
    "yaml.hover": true,
    "yaml.format.enable": true,
    "yaml.format.singleQuote": false,
    "yaml.format.bracketSpacing": true,
    "yaml.schemaStore.enable": true,
    "files.associations": {
        "*.yml": "yaml",
        "*.yaml": "yaml"
    },
    "python.terminal.activateEnvironment": true,
    "python.testing.pytestEnabled": true,
    "python.testing.pytestArgs": ["--cov=src", "--cov-fail-under=95"],
    "python.linting.enabled": true,
    "python.linting.ruffEnabled": true,
    "typescript.preferences.importModuleSpecifier": "relative",
    "jest.autoRun": "off",
    "vitest.enable": true,
    "terminal.integrated.env.linux": {
        "VIRTUAL_ENV": "${workspaceFolder}/.venv",
        "PATH": "${workspaceFolder}/.venv/bin:${env:PATH}"
    }
}
EOF

# Create tasks.json for DevOnboarder validation commands
cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "DevOnboarder: Quick Validation",
            "type": "shell",
            "command": "./scripts/quick_validate.sh",
            "args": ["${input:validationType}"],
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "DevOnboarder: Full CI Validation",
            "type": "shell",
            "command": "source .venv/bin/activate && ./scripts/validate_ci_locally.sh",
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "DevOnboarder: YAML Lint Fix",
            "type": "shell",
            "command": "source .venv/bin/activate && yamllint .github/workflows/*.yml",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "DevOnboarder: Setup Environment",
            "type": "shell",
            "command": "python -m venv .venv && source .venv/bin/activate && pip install -e .[test]",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        }
    ],
    "inputs": [
        {
            "id": "validationType",
            "description": "Select validation type",
            "type": "pickString",
            "options": [
                "lint",
                "frontend",
                "security",
                "build",
                "test",
                "all"
            ]
        }
    ]
}
EOF

# Create extensions.json for team standardization
cat > .vscode/extensions.json << 'EOF'
{
    "recommendations": [
        "ms-python.python",
        "ms-python.black-formatter",
        "charliermarsh.ruff",
        "redhat.vscode-yaml",
        "bradlc.vscode-tailwindcss",
        "esbenp.prettier-vscode",
        "ms-vscode.vscode-typescript-next",
        "timonwong.shellcheck",
        "davidanson.vscode-markdownlint",
        "vitest.explorer",
        "ms-vscode.test-adapter-converter",
        "postman.postman-for-vscode"
    ]
}
EOF

echo "✅ VS Code integration setup complete!"
echo "📋 Files created:"
echo "   • .vscode/settings.json - Enhanced workspace settings"
echo "   • .vscode/tasks.json - DevOnboarder validation commands"
echo "   • .vscode/extensions.json - Recommended extensions"
echo ""
echo "🎯 Usage:"
echo "   • Ctrl+Shift+P → 'Tasks: Run Task' → Select DevOnboarder validation"
echo "   • Install recommended extensions when prompted"
echo "   • YAML files now have consistent linting with CI"
echo ""
echo "🚀 VS Code now matches CI validation exactly!"
