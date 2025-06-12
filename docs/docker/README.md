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
# 🐳 Docker Command Shortcuts – ZSH Profile Integration

This guide explains how to set up and use custom Docker Compose commands via shell functions in your `.zshrc` file, allowing flexible usage of different `docker-compose.yaml` and `.env` files.

---

## ⚙️ Setup Instructions

### 1. Edit `.zshrc`

Open your `.zshrc` (usually located at `~/.zshrc`) and add the following functions:

```zsh
# 🐳 Docker Compose Helper Functions

docker-rc() {
  local compose_file="${1:-docker-compose.yaml}"
  local env_file="${2:-.env}"
  docker compose --env-file "$env_file" -f "$compose_file" up -d --build --force-recreate
}

docker-rm() {
  local compose_file="${1:-docker-compose.yaml}"
  local env_file="${2:-.env}"
  docker compose --env-file "$env_file" -f "$compose_file" down --remove-orphans
}

docker-logs() {
  local compose_file="${1:-docker-compose.yaml}"
  local env_file="${2:-.env}"
  docker compose --env-file "$env_file" -f "$compose_file" logs -f
}
```

### 2. Reload `.zshrc`

After saving the changes, run:

```bash
source ~/.zshrc
```

---

## 🚀 Usage Guide

### 🔧 Run a Compose Stack

```bash
docker-rc [docker-compose-file] [env-file]
```

- `docker-compose-file`: (Optional) Defaults to `docker-compose.yaml`
- `env-file`: (Optional) Defaults to `.env`

#### Examples

```bash
docker-rc                         # Uses docker-compose.yaml and .env
docker-rc docker-compose.vpn.yaml .env.vpn
```

---

### 🩹 Tear Down a Stack

```bash
docker-rm [docker-compose-file] [env-file]
```

```bash
docker compose -f docker-compose-dev.yaml up -d --build --force-recreate
```

#### Examples1

```bash
docker-rm                         # Defaults to docker-compose.yaml and .env
docker-rm docker-compose.vpn.yaml .env.vpn
```

---

### 📜 View Logs

```bash
docker-logs [docker-compose-file] [env-file]
```

#### Examples2

```bash
docker-logs
docker-logs docker-compose.prod.yaml .env.prod
```

---

## 🗘️ Notes

- If no arguments are passed, the functions fall back to default files.
- You can override the environment file at any time by supplying a second argument.
- These functions always run from the current working directory (`$PWD`) to ensure `.env` files and relative paths work correctly.

---

## 📁 Recommended Project Structure

```markdown
project-root/
├── docker-compose.yaml
├── docker-compose.prod.yaml
├── .env
├── .env.vpn
├── .env.prod
└── README.md
```

---

## 🧠 Pro Tip

You can add more Docker helper functions (like for building images or exec-ing into containers) to expand this setup.

---

Last updated: 22 April 2025 13:47 (EST)

##

Run docker stack in Dev mode

```bash
docker compose -f docker-compose.prod.yaml -f docker-compose.dev.yaml up
```
