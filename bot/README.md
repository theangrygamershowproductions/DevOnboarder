# DevOnboarder Discord Bot

This service implements a simple Discord bot using `discord.js` v14.
It loads slash commands and events dynamically on startup and authenticates
using the token provided in `.env`.

## Setup

1. Copy the example environment file and add your credentials:
   ```bash
   cp .env.example .env
   ```
   Fill in `DISCORD_BOT_TOKEN`, `DISCORD_CLIENT_ID`, `DISCORD_GUILD_IDS`,
   and `BOT_JWT`. The bot sends this token in an `Authorization` header
   when calling the API. See [docs/env.md](../docs/env.md) for details
   about this variable.
2. Install dependencies and build the bot:
   ```bash
   npm install
   npm run build
   ```
3. Lint and format the code:
   ```bash
   npm run lint
   npm run format
   ```
4. Run the bot locally:
   ```bash
   npm start
   ```

## Docker

The `Dockerfile` builds the TypeScript source and runs `dist/main.js`.
The development compose file mounts the source for hot reload:

```yaml
bot:
  build: ./bot
  env_file:
    - ./bot/.env
  volumes:
    - ./bot:/usr/src/app
  command: ["npm", "start"]
```

## Adding Commands

Place new command modules in `src/commands`. Each module exports
`data` (a `SlashCommandBuilder`) and an `execute` function. They are
loaded automatically when the bot starts.

The repository provides the following built-in commands:

- `/ping` – simple health check returning `Pong!`.
- `/verify` – show your onboarding status from the XP API.
- `/profile` – display your current XP level.
- `/contribute` – record a contribution description.

## Future Work

- Sync verified roles back to the auth database.
- Award XP for community participation.
- Log quiz completion via slash commands.
