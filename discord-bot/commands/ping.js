// PATCHED v0.1.0 discord-bot/commands/ping.js — Responds with Pong

export const data = {
  name: 'ping',
  description: 'Replies with Pong!',
};

export async function execute(interaction) {
  await interaction.reply('Pong!');
}
