import { SlashCommandBuilder, ChatInputCommandInteraction } from 'discord.js';
import { getUserLevel } from '../api';

export const data = new SlashCommandBuilder()
    .setName('profile')
    .setDescription('Show your XP level');

export async function execute(interaction: ChatInputCommandInteraction) {
    const username = interaction.user?.username ?? interaction.user.id;
    const level = await getUserLevel(username);
    await interaction.reply(`Current level: ${level}`);
}
