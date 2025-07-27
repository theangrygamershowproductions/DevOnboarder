import { SlashCommandBuilder, ChatInputCommandInteraction } from 'discord.js';
import { getOnboardingStatus } from '../api';

export const data = new SlashCommandBuilder()
    .setName('verify')
    .setDescription('Check your onboarding status');

export async function execute(interaction: ChatInputCommandInteraction) {
    const username = interaction.user?.username ?? interaction.user.id;
    const status = await getOnboardingStatus(username);
    await interaction.reply(`Onboarding status: ${status}`);
}
