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
<!-- PATCHED v0.1.14 docs/commander/README.md — Document bot directory -->

# 📘 TAGS Commander – Documentation

This is the primary documentation hub for the **TAGS Commander Bot**,
the automation and moderation system used across all official
TAGS Discord servers.

---

## 🤖 Bot Overview

TAGS Commander integrates both legacy prefix commands and Discord-native
slash commands to provide:

- Role assignment and removal
- Server-wide timezone display and configuration
- User verification and identity tagging (v3.0.0+)
- Scheduled tasks for status/utility channel updates

---

## 🚀 Getting Started

-### Prerequisites

- Python 3.13+
- Discord bot token with privileged intents enabled
- Discord developer portal access to register slash commands

### Configuration

Set up your `.env` or `auth.py` to include the bot token:

```python
# auth.py
import os

def get_token():
    return os.getenv("DISCORD_BOT_TOKEN")
```

### Running the Bot

The source code resides in the `discord-bot/` directory at the project root.
Run it locally with Node.js:

```bash
npm --prefix discord-bot install
npm --prefix discord-bot start
```

Or start it using Docker Compose:

```bash
docker compose up discord-bot
```

---

## 📦 Commands

### 🔹 Prefix Commands

- `!hello` – Simple heartbeat check
- `!serverinfo` – Shows current server info
- `!roles` – Lists all server roles
- `!assign_role` / `!remove_role` – Grant or revoke a role
- `!set_timezone` – Store a member's timezone
- `!show_time` – View all users' current local times

### 🔹 Slash Commands

- `/ping` – Response check (for Active Dev Badge)
- `/verifyme` – Verification status (stub)
- `/roles` – List official TAGS role catalog

---

## 🧭 Roadmap

| Version | Feature                                             |
|---------|-----------------------------------------------------|
| v1.0.1  | Slash command support (ping, verifyme, roles)       |
| v2.0.0  | Logging, channel-based automation                   |
| v3.0.0  | ID.me/Login.gov verification system                 |
| v4.0.0  | Auto role/bootstrap on server join (partner guilds) |

---

## 📜 Changelog

See [CHANGELOG.md](./CHANGELOG.md) for full version history.

---

### Last updated: 08 Jun 2025 09:50 (EDT)
