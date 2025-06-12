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
<!-- Version: v1.2.0 -->

# 💻 Oh My Posh Terminal Setup Guide (with Hack Nerd Font Propo)

This guide helps developers install and configure Oh My Posh with full icon and theme support using the Hack Nerd Font Propo.

---

## 📦 1. Install Oh My Posh

### ✅ Windows:
```powershell
winget install JanDeDobbeleer.OhMyPosh -s winget
```

### ✅ Linux/macOS (Homebrew):
```bash
brew install jandedobbeleer/oh-my-posh/oh-my-posh
```

### 🔧 Advanced Installation (No root / No APT access on Debian/Ubuntu):
If you do **not** have access to `apt` or `sudo`, install Oh My Posh manually in your user space:

```bash
mkdir -p ~/.local/bin
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
```

Ensure `~/.local/bin` is in your `PATH`. Add to your `~/.zshrc` or `~/.bashrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```
Apply with:
```bash
source ~/.zshrc  # or ~/.bashrc
```

---

## 🔤 2. Install Hack Nerd Font Propo

### Manual Install:
1. Download [Hack.zip](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip)
2. Extract files
3. Install the following:
   - `HackNerdFontPropo-Regular.ttf`
   - `HackNerdFontPropo-Bold.ttf`
   - `HackNerdFontPropo-Italic.ttf`
   - `HackNerdFontPropo-BoldItalic.ttf`

📝 On Linux, place fonts in `~/.local/share/fonts` and run:
```bash
fc-cache -fv
```

---

## 🛠️ 3. Configure Terminal Font

### ✅ VS Code:
Open `settings.json` and add:
```json
"terminal.integrated.fontFamily": "Hack Nerd Font Propo"
```

### ✅ Windows Terminal:
- Settings → Defaults → Appearance → Font face → `Hack Nerd Font Propo`

### ✅ GNOME Terminal:
- Preferences → Profile → Text → Uncheck “Use system font” → Choose `Hack Nerd Font Propo`

---

## 🐚 4. Set Up Zsh Shell

### 🔹 Install Zsh (Debian/Ubuntu):
```bash
sudo apt update
sudo apt install zsh
```

### 🔹 Set Zsh as Default Shell (Optional):
```bash
chsh -s $(which zsh)
```
Log out and log back in for changes to take effect.

---

## 🎨 5. Configure Oh My Posh Theme

### 🔹 Local User Setup (`~/.zshrc`):
```bash
eval "$(oh-my-posh init zsh --config ~/.poshthemes/jandedobbeleer.omp.json)"
```
Then apply it:
```bash
source ~/.zshrc
```

### 🔹 Global Setup for All Users:
1. Copy your desired theme to a shared path like `/etc/oh-my-posh/themes/`
2. Edit `/etc/zsh/zshrc`:
```bash
echo 'eval "$(oh-my-posh init zsh --config /etc/oh-my-posh/themes/jandedobbeleer.omp.json)"' | sudo tee -a /etc/zsh/zshrc
```

---

## 🧢 6. Bash Shell Setup

### 🔹 Local User Setup (`~/.bashrc`):
```bash
eval "$(oh-my-posh init bash --config ~/.poshthemes/jandedobbeleer.omp.json)"
```
Apply it with:
```bash
source ~/.bashrc
```

> 🔍 Note: Bash is often the default on many Debian/Ubuntu-based systems. You can also add this to `/etc/bash.bashrc` for global use.

---

## 💡 7. WSL (Windows Subsystem for Linux) Tips

- Make sure your **Windows Terminal font** is set to `Hack Nerd Font Propo`
- Configure your `.bashrc` or `.zshrc` inside the WSL distribution
- Fonts are rendered by the **Windows host**, not the WSL instance

📌 Example for WSL with Zsh:
```bash
# Inside ~/.zshrc in WSL
export PATH="$HOME/.local/bin:$PATH"
eval "$(oh-my-posh init zsh --config ~/.poshthemes/jandedobbeleer.omp.json)"
```

---

## 📦 8. Container-Specific Configuration

If you're inside a Docker container or LXC environment:

- Fonts still render on the **host** (your terminal), not inside the container
- You can install Oh My Posh inside the container and run:
```bash
oh-my-posh print primary --config /path/to/theme.json
```
- Use bind mounts to inject config files and themes

📦 Example Dockerfile snippet:
```dockerfile
RUN curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin
```

📌 Mount your theme into the container:
```bash
docker run -v ~/.poshthemes:/etc/oh-my-posh/themes mycontainer
```

---

## ✅ 9. Verify Icon Rendering

Run:
```bash
echo -e "\uE0B0 \uF120 \uF0FC \uF815"
oh-my-posh print primary --config ~/.poshthemes/jandedobbeleer.omp.json
```

If icons show up correctly, setup is complete!

---

## 🧪 Troubleshooting

| Issue | Cause | Fix |
|-------|-------|------|
| Boxes instead of icons | Terminal font is not a Nerd Font | Install and configure Hack Nerd Font Propo |
| Theme not loading | Shell not sourcing `oh-my-posh` | Add eval line to your shell's rc file |
| Font installer GUI not working | You're in a headless environment (e.g. SSH) | Manually install the font on your local machine |
| oh-my-posh: command not found | User-space install path not in `PATH` | Export path to `~/.local/bin` in `.zshrc` or `.bashrc` |

---

*Last updated: 22 April 2025 17:53 (EST)*

