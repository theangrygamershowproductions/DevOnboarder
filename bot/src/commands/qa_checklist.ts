import { SlashCommandBuilder, ChatInputCommandInteraction } from 'discord.js';
import { readFile } from 'fs/promises';
import path from 'path';

export const data = new SlashCommandBuilder()
    .setName('qa_checklist')
    .setDescription('Display the QA checklist');

export async function execute(interaction: ChatInputCommandInteraction) {
    const filePath = path.resolve(__dirname, '../../../docs/QA_CHECKLIST.md');
    try {
        const text = await readFile(filePath, 'utf8');
        const chunks = text.match(/([\s\S]{1,2000})/g) || [];
        if (chunks.length === 0) {
            await interaction.reply({
                content: 'QA checklist is empty.',
                ephemeral: true,
            });
            return;
        }
        await interaction.reply({ content: chunks[0], ephemeral: true });
        for (const chunk of chunks.slice(1)) {
            await interaction.followUp({ content: chunk, ephemeral: true });
        }
    } catch {
        await interaction.reply({
            content: 'Unable to read QA checklist.',
            ephemeral: true,
        });
    }
}
