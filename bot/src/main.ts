import { Client, GatewayIntentBits } from 'discord.js';
import dotenv from 'dotenv';
import path from 'path';
import { loadCommands, loadEvents } from './utils/loadFiles';

dotenv.config();

const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMembers],
});

async function start() {
  const commands = await loadCommands(path.join(__dirname, 'commands'));
  await loadEvents(client, path.join(__dirname, 'events'), commands);
  await client.login(process.env.DISCORD_BOT_TOKEN);
}

start();
