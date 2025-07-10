# DevOnboarder Discord Bot

This service implements a simple Discord bot using `discord.js` v14.
It loads slash commands and events dynamically on startup and authenticates
using the token provided in `.env`.

Node.js 20 is required. Run `nvm install` to use the version defined in `.nvmrc`.
## Setup

1. Use Node.js 20 as specified in `.nvmrc` (run `nvm install`).
2. Copy the example environment file and add your credentials:
   ```bash
   cp .env.example .env
   ```
   Fill in `DISCORD_BOT_TOKEN`, `DISCORD_CLIENT_ID`, `DISCORD_GUILD_IDS`,
   and `BOT_JWT`. The bot sends this token in an `Authorization` header
   when calling the API. See [docs/env.md](../docs/env.md) for details
   about this variable.
3. Install dependencies and build the bot:
   ```bash
   npm install
   npm run build
   ```
4. Lint and format the code:
   ```bash
   npm run lint
   npm run format
   ```
5. Run the bot locally:
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

## Tests

Generate a coverage report with:

```bash
npm run coverage
```

The CI workflow requires every suite to maintain **95%** coverage.

## Adding Commands

Place new command modules in `src/commands`. Each module exports
`data` (a `SlashCommandBuilder`) and an `execute` function. They are
loaded automatically when the bot starts.

The repository provides the following built-in commands:

- `/ping` – simple health check returning `Pong!`.
- `/verify` – show your onboarding status from the XP API.
- `/profile` – display your current XP level.
- `/contribute` – record a contribution description.
- `/qa_checklist` – show the documentation and QA checklist.

## Future Work

- Sync verified roles back to the auth database.
- Award XP for community participation.
- Log quiz completion via slash commands.
