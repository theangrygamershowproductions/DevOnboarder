import { Interaction } from 'discord.js';
import { Commands } from '../utils/loadFiles';

export const name = 'interactionCreate';
export const once = false;

export async function execute(interaction: Interaction, commands: Commands) {
  if (!interaction.isChatInputCommand()) return;
  const command = commands.get(interaction.commandName);
  if (!command) return;
  await command.execute(interaction);
}
