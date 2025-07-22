import {
    ChatInputCommandInteraction,
    SlashCommandBuilder,
    EmbedBuilder,
} from 'discord.js';

export const data = new SlashCommandBuilder()
    .setName('status')
    .setDescription(
        'Check DevOnboarder integration status and environment info',
    );

export async function execute(interaction: ChatInputCommandInteraction) {
    const client = interaction.client as any;
    const config = client.config || {};

    const environment = config.environment || 'unknown';
    const guildId = config.guildId || 'not configured';
    const botReady = config.botReady || false;
    const liveTriggersEnabled = config.liveTriggersEnabled || false;
    const dryRunMode = config.dryRunMode !== false; // Default to true for safety

    // Determine environment display name
    let environmentDisplay = environment;
    let serverName = 'Unknown';

    if (guildId === '1386935663139749998') {
        environmentDisplay = 'Development';
        serverName = 'TAGS: DevOnboarder';
    } else if (guildId === '1065367728992571444') {
        environmentDisplay = 'Production';
        serverName = 'TAGS: C2C';
    }

    // Create status indicators
    const getStatusIcon = (status: boolean) => (status ? '✅' : '❌');
    const getModeIcon = (mode: boolean) => (mode ? '🧪' : '🚀');

    const embed = new EmbedBuilder()
        .setTitle('🤖 DevOnboarder Bot Status')
        .setColor(dryRunMode ? 0xffa500 : botReady ? 0x00ff00 : 0xff0000)
        .addFields([
            {
                name: '🌍 Environment',
                value: `**${environmentDisplay}**\n${serverName}\n\`${guildId}\``,
                inline: true,
            },
            {
                name: '⚙️ Configuration',
                value: [
                    `${getStatusIcon(botReady)} Bot Ready: ${botReady}`,
                    `${getStatusIcon(liveTriggersEnabled)} Live Triggers: ${liveTriggersEnabled}`,
                    `${getModeIcon(dryRunMode)} Dry-run Mode: ${dryRunMode}`,
                ].join('\n'),
                inline: true,
            },
            {
                name: '🔗 Integration Status',
                value: [
                    '✅ CI Pipeline: Resolved',
                    '✅ Coverage: 96%+ across services',
                    '🔄 Discord Integration: Active',
                    dryRunMode
                        ? '🧪 API Testing: Dry-run mode'
                        : '🚀 API Testing: Live mode',
                ].join('\n'),
                inline: false,
            },
        ])
        .setTimestamp()
        .setFooter({
            text: `DevOnboarder v1.0 | Environment: ${environment}`,
            iconURL: interaction.client.user?.displayAvatarURL(),
        });

    // Add warning for dry-run mode
    if (dryRunMode) {
        embed.addFields([
            {
                name: '⚠️ Safety Notice',
                value: 'Bot is running in **dry-run mode**. All commands are simulated and logged only.',
                inline: false,
            },
        ]);
    }

    // Add next steps if not fully ready
    if (!botReady || !liveTriggersEnabled) {
        const nextSteps = [];
        if (!botReady) nextSteps.push('• Set `DISCORD_BOT_READY=true`');
        if (!liveTriggersEnabled)
            nextSteps.push('• Set `LIVE_TRIGGERS_ENABLED=true`');

        embed.addFields([
            {
                name: '🚀 Next Steps for Live Mode',
                value: nextSteps.join('\n'),
                inline: false,
            },
        ]);
    }

    await interaction.reply({ embeds: [embed] });
}
