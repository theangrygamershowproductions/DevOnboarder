import { SlashCommandBuilder, ChatInputCommandInteraction } from 'discord.js';
import { getUserContributions } from '../api';

export const data = new SlashCommandBuilder()
  .setName('contribute')
  .setDescription('List your contributions');

export async function execute(interaction: ChatInputCommandInteraction) {
  const username = interaction.user?.username ?? interaction.user.id;
  const contribs = await getUserContributions(username);
  const message = contribs.length
    ? contribs.join(', ')
    : 'No contributions yet.';
  await interaction.reply(message);
}
