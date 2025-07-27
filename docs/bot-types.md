# Bot Types

This document explains the difference between **Codex Agents** and the **Discord Bot** used in this repository.

## Codex Agents

Codex agents are small automation services orchestrated by Codex for project maintenance and monitoring.

-   **Purpose** – Perform focused tasks like closing stale issues or validating environment variables.
-   **Location** – Documentation lives under the top‑level [`agents/`](../agents/) folder.
-   **Execution** – Agents usually run within GitHub Actions or other CI jobs using Python scripts.
-   **Naming** – Agent documents begin with a `codex-agent` YAML header and each agent is listed in [`.codex/agents/index.json`](../.codex/agents/index.json).

## Discord Bot

The `bot/` directory contains a stand‑alone TypeScript bot built with `discord.js`.

-   **Purpose** – Provide interactive slash commands for the community, such as `/verify`, `/dependency_inventory`, and `/qa_checklist`.
-   **Location** – Source code and tests live entirely under [`bot/`](../bot/).
-   **Execution** – The bot runs independently of Codex and is not part of CI workflows. It can be started locally with `npm start` or via Docker.
-   **Naming** – Command files are named after their slash command and reside in `bot/src/commands`.

Use this file as a reference when deciding whether a script should be a Codex agent or part of the Discord bot.
