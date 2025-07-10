import { SlashCommandBuilder, ChatInputCommandInteraction } from 'discord.js';
import { promises as fs } from 'fs';
import path from 'path';

export const data = new SlashCommandBuilder()
  .setName('qa_checklist')
  .setDescription('Display the QA checklist');

export async function execute(interaction: ChatInputCommandInteraction) {
  const filePath = path.resolve(__dirname, '../../../docs/QA_CHECKLIST.md');
  const text = await fs.readFile(filePath, 'utf8');
  await interaction.reply(text);
}
