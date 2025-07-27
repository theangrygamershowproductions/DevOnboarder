import { SlashCommandBuilder, ChatInputCommandInteraction } from 'discord.js';
import { submitContribution } from '../api';

export const data = new SlashCommandBuilder()
    .setName('contribute')
    .setDescription('Record a contribution')
    .addStringOption((opt) =>
        opt
            .setName('description')
            .setDescription('What did you do?')
            .setRequired(true),
    );

export async function execute(interaction: ChatInputCommandInteraction) {
    const username = interaction.user?.username ?? interaction.user.id;
    const description = interaction.options.getString('description', true);
    await submitContribution(username, description);
    await interaction.reply(`Recorded contribution: ${description}`);
}
