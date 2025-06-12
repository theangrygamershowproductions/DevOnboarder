// PATCHED v0.1.0 discord-bot/index.js — Basic Discord bot entrypoint

import { Client, Collection, GatewayIntentBits } from 'discord.js';
import fs from 'fs';
import 'dotenv/config';

const client = new Client({ intents: [GatewayIntentBits.Guilds] });
client.commands = new Collection();

for (const file of fs.readdirSync('./discord-bot/commands')) {
  if (file.endsWith('.js')) {
    const command = await import(`./commands/${file}`);
    client.commands.set(command.data.name, command);
  }
}

client.once('ready', () => {
  console.log(`Logged in as ${client.user.tag}`);
});

client.on('interactionCreate', async (interaction) => {
  if (!interaction.isChatInputCommand()) return;
  const command = client.commands.get(interaction.commandName);
  if (!command) return;
  try {
    await command.execute(interaction);
  } catch (err) {
    console.error(err);
    if (interaction.replied || interaction.deferred) {
        await interaction.followUp({
          content: 'Command failed.',
          ephemeral: true,
        });
      } else {
        await interaction.reply({
          content: 'Command failed.',
          ephemeral: true,
        });
    }
  }
});

client.login(process.env.DISCORD_BOT_TOKEN);
