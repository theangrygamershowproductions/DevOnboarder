// PATCHED v0.1.0 discord-bot/commands/modules.js — Sync devonboarder modules
import { SlashCommandBuilder } from 'discord.js';

export const data = new SlashCommandBuilder()
  .setName('modules')
  .setDescription('Manage project modules')
  .addSubcommand(sub =>
    sub
      .setName('sync')
      .setDescription('Sync devonboarder modules')
  );

export async function execute(interaction) {
  if (interaction.options.getSubcommand() !== 'sync') {
    await interaction.reply({ content: 'Unknown subcommand.', ephemeral: true });
    return;
  }

  const member = await interaction.guild.members.fetch(interaction.user.id);
  const allowed = member.roles.cache.some(r => r.name === 'DevOps Admin');
  if (!allowed) {
    await interaction.reply({ content: 'Only DevOps Admins may run this.', ephemeral: true });
    return;
  }

  await interaction.reply({ content: 'Syncing modules…', ephemeral: true });

  const { GITHUB_TOKEN, GITHUB_REPOSITORY } = process.env;
  if (!GITHUB_TOKEN || !GITHUB_REPOSITORY) {
    await interaction.followUp({ content: 'Server misconfigured.', ephemeral: true });
    return;
  }

  try {
    await fetch(`https://api.github.com/repos/${GITHUB_REPOSITORY}/dispatches`, {
      method: 'POST',
      headers: {
        'Authorization': `token ${GITHUB_TOKEN}`,
        'Accept': 'application/vnd.github+json',
      },
      body: JSON.stringify({
        event_type: 'modules-sync',
        client_payload: { repo: 'devonboarder' },
      }),
    });
    await interaction.followUp({ content: 'Dispatch event sent.', ephemeral: true });
  } catch (err) {
    console.error(err);
    await interaction.followUp({ content: 'Failed to trigger dispatch.', ephemeral: true });
  }
}
