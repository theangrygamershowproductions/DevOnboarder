---
project: "TAGS"
module: "Documentation"
phase: "Internal Tooling"
tags: ["docs", "internal"]
updated: "26 May 2025 18:01 (EST)"
version: "v1.0.0"
-----------------

# TAGS: VSCode Integrations

---

## Purpose

Define a standardized Visual Studio Code environment across all TAGS developers to ensure consistent behavior, formatting, testing, and dev tooling across the project lifecycle.

---

## 📂 Folder: `.vscode/`

Recommended contents:

```markdown
.vscode/
├── extensions.json      # Recommended extensions
├── settings.json        # Workspace-specific preferences
├── launch.json          # Debug configurations
├── tasks.json           # Custom command runners
```

---

## 🔌 Recommended Extensions (`extensions.json`)

```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "streetsidesoftware.code-spell-checker",
    "gruntfuggly.todo-tree",
    "aaron-bond.better-comments",
    "ms-azuretools.vscode-docker",
    "humao.rest-client"
  ]
}
```

---

## ⚙️ Workspace Settings (`settings.json`)

```json
{
  "editor.tabSize": 2,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "typescript.tsdk": "node_modules/typescript/lib"
}
```

---

## 🐞 Debug Config (`launch.json`)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch Backend",
      "program": "${workspaceFolder}/src/index.ts",
      "preLaunchTask": "tsc: build - tsconfig.json",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"]
    },
    {
      "type": "chrome",
      "request": "launch",
      "name": "Launch Frontend",
      "url": "http://localhost:5173",
      "webRoot": "${workspaceFolder}/src"
    }
  ]
}
```

---

## 🧪 Task Runner (`tasks.json`)

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run Backend Dev Server",
      "type": "shell",
      "command": "npm run dev",
      "group": "build",
      "problemMatcher": []
    },
    {
      "label": "Run Frontend Dev Server",
      "type": "shell",
      "command": "npm run dev",
      "options": {
        "cwd": "frontend"
      },
      "group": "build",
      "problemMatcher": []
    }
  ]
}
```

---

## 📎 Notes

* Ensure all VSCode `.vscode/` folders are excluded in `.gitignore`, **except** `extensions.json`
* Add dev onboarding references to this doc in project `README.md` files

---

**Maintainer:** Chad Reesey
