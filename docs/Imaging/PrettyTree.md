---
project: "TAGS"
module: "Documentation Tools"
phase: "Maintenance Automation"
tags: ["metadata", "markdown", "indexing", "automation"]
updated: "12 June 2025 09:33 (EST)"
version: "v1.2.6"
author: "Chad Allan Reesey (Mr. Potato)"
email: "education@thenagrygamershow.com"
description: "Manages indexing and metadata injection for project documentation."
---

# Documentation Tools – Maintenance Automation
<!-- PATCHED v0.1.46 docs/Imaging/PrettyTree.md — Update Node version -->

# 📁 PrettyTree: Generate a Project Tree Image from Terminal

This script (`prettytree.sh`) creates a **PNG image of your project's directory structure** using the `tree` command and [carbon-now-cli](https://github.com/mixn/carbon-now-cli), a CLI wrapper around Carbon.

---

## 🛠️ Prerequisites

Make sure the following are installed:

### On Ubuntu/WSL2/macOS:

```bash
sudo apt update
sudo apt install tree -y      # Generates directory structure
npm install -g carbon-now-cli # Renders terminal output to PNG
```

📎 **See also:** [../node/README.md](../node/README.md) for Node.js and npm installation instructions.

### Confirm Node version is ≥ 22 (for compatibility)

```bash
node -v
```

---

## 📦 Script Location

Save the following script to `~/scripts/prettytree.sh`:

```bash
#!/bin/bash

OUTFILE="project-tree.png"
SNAPSHOT="tree-snapshot.txt"

tree --dirsfirst -I "node_modules|.git|.venv|dist|build" --charset=ascii > "$SNAPSHOT"
carbon-now "$SNAPSHOT" --headless --theme "One Dark" --output .
NEWFILE=$(ls -t tree-snapshot-*.png | head -n 1)
mv "$NEWFILE" "$OUTFILE"
echo "✅ Saved pretty tree image to: $PWD/$OUTFILE"
```

Then make it executable:

```bash
chmod +x ~/scripts/prettytree.sh
```

---

## 📎 Add Alias to `.zshrc`

Open your `.zshrc` and add:

```bash
alias prettytree="~/scripts/prettytree.sh"
```

Then reload:

```bash
source ~/.zshrc
```

---

## ✅ Usage

From any project folder:

```bash
cd /path/to/my-project
prettytree
```

You’ll get:

- `tree-snapshot.txt` → plain text tree structure
- `project-tree.png` → beautiful PNG image of your folder layout

Example:

```
/my-project/
├── tree-snapshot.txt
└── project-tree.png
```

---

## 🧠 Notes

- The image is saved **in the current working directory**.
- No GUI apps are launched.
- You can change the Carbon theme by editing the script:
  ```bash
  --theme "Dracula"  # or "Night Owl", "One Dark", etc.
  ```

---

## 🗑 Optional Cleanup

If you want to automatically delete the `tree-snapshot.txt` afterward, add this to the end of the script:

```bash
rm "$SNAPSHOT"
```

---

## 🎉 Credits

- [carbon-now-cli](https://github.com/mixn/carbon-now-cli)
- [tree](https://man7.org/linux/man-pages/man1/tree.1.html)

