import {
    ChatInputCommandInteraction,
    SlashCommandBuilder,
    EmbedBuilder,
} from 'discord.js';

export const data = new SlashCommandBuilder()
    .setName('deploy')
    .setDescription('Deploy DevOnboarder services (admin only)')
    .addStringOption((option) =>
        option
            .setName('service')
            .setDescription('Service to deploy')
            .setRequired(true)
            .addChoices(
                { name: 'Backend (Port 8001)', value: 'backend' },
                { name: 'Bot (Port 8002)', value: 'bot' },
                { name: 'Frontend (Port 8081)', value: 'frontend' },
                { name: 'All Services', value: 'all' },
            ),
    )
    .addStringOption((option) =>
        option
            .setName('environment')
            .setDescription('Target environment')
            .setRequired(false)
            .addChoices(
                { name: 'Development', value: 'dev' },
                { name: 'Staging', value: 'staging' },
                { name: 'Production', value: 'prod' },
            ),
    );

export async function execute(interaction: ChatInputCommandInteraction) {
    const client = interaction.client as any;
    const config = client.config || {};

    const service = interaction.options.getString('service', true);
    const targetEnv =
        interaction.options.getString('environment') ||
        config.environment ||
        'dev';
    const dryRunMode = config.dryRunMode !== false; // Default to true for safety
    const liveTriggersEnabled = config.liveTriggersEnabled || false;

    // Role-based access control (simplified for now)
    const member = interaction.member;
    const hasAdminRole =
        member &&
        (member as any).roles?.cache?.some((role: any) =>
            ['CTO', 'CEO', 'Admin', 'Developer'].includes(role.name),
        );

    if (!hasAdminRole && !dryRunMode) {
        const embed = new EmbedBuilder()
            .setTitle('❌ Access Denied')
            .setDescription(
                'You need admin or developer role to use deploy commands.',
            )
            .setColor(0xff0000);

        await interaction.reply({ embeds: [embed], ephemeral: true });
        return;
    }

    // Create deployment embed
    const embed = new EmbedBuilder()
        .setTitle(`🚀 DevOnboarder Deployment`)
        .setColor(dryRunMode ? 0xffa500 : 0x00ff00)
        .addFields([
            {
                name: '📦 Service',
                value:
                    service === 'all'
                        ? 'All Services'
                        : service.charAt(0).toUpperCase() + service.slice(1),
                inline: true,
            },
            {
                name: '🌍 Environment',
                value: targetEnv.toUpperCase(),
                inline: true,
            },
            {
                name: '👤 Initiated By',
                value: interaction.user.displayName,
                inline: true,
            },
        ])
        .setTimestamp();

    if (dryRunMode) {
        // Dry-run simulation
        embed
            .setDescription('🧪 **DRY-RUN MODE**: Deployment simulated only')
            .addFields([
                {
                    name: '🎭 Simulated Actions',
                    value: [
                        '• Service health check passed',
                        '• Environment validation completed',
                        '• Deployment pipeline triggered',
                        '• Post-deployment tests scheduled',
                        '• Webhook notifications prepared',
                    ].join('\n'),
                    inline: false,
                },
                {
                    name: '📊 Expected Results',
                    value: [
                        `• ${service} service would be deployed to ${targetEnv}`,
                        '• CI/CD pipeline would execute',
                        '• Integration tests would run',
                        '• Service would restart with new configuration',
                    ].join('\n'),
                    inline: false,
                },
            ]);

        // Log dry-run action
        console.log(`🧪 DRY-RUN: Deploy command executed`, {
            user: interaction.user.username,
            service,
            environment: targetEnv,
            guild: interaction.guildId,
            timestamp: new Date().toISOString(),
        });
    } else if (liveTriggersEnabled) {
        // Live deployment (would integrate with actual deployment system)
        embed
            .setDescription('🚀 **LIVE MODE**: Initiating deployment...')
            .addFields([
                {
                    name: '⏳ Deployment Status',
                    value: 'Initiating deployment pipeline...',
                    inline: false,
                },
            ]);

        // Integrate with actual deployment API
        try {
            const backendUrl = config.backendUrl || 'http://localhost:8001';
            const deploymentEndpoint = `${backendUrl}/api/deploy`;

            const deploymentPayload = {
                service,
                environment: targetEnv,
                initiatedBy: interaction.user.username,
                guildId: interaction.guildId,
                timestamp: new Date().toISOString(),
            };

            console.log(
                `🚀 LIVE: Initiating deployment via API`,
                deploymentPayload,
            );

            const response = await fetch(deploymentEndpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: `Bearer ${config.botJwt || ''}`,
                },
                body: JSON.stringify(deploymentPayload),
            });

            if (response.ok) {
                const result = await response.json();
                console.log('✅ Deployment API call successful:', result);

                // Update embed with deployment ID if provided
                if (result.deploymentId) {
                    embed.addFields([
                        {
                            name: '🆔 Deployment ID',
                            value: result.deploymentId,
                            inline: true,
                        },
                    ]);
                }
            } else {
                console.error(
                    '❌ Deployment API call failed:',
                    response.status,
                    response.statusText,
                );

                // Update embed to indicate API failure
                embed.setColor(0xff8800).addFields([
                    {
                        name: '⚠️ API Status',
                        value: 'Deployment API unavailable - logged for manual processing',
                        inline: false,
                    },
                ]);
            }
        } catch (error) {
            console.error('❌ Error calling deployment API:', error);

            // Fallback to logging when API is unavailable
            embed.setColor(0xff8800).addFields([
                {
                    name: '⚠️ Fallback Mode',
                    value: 'Deployment logged for manual processing',
                    inline: false,
                },
            ]);
        }

        // Send webhook notification if configured
        if (config.webhookUrl) {
            try {
                const webhookPayload = {
                    content: '🚀 DevOnboarder Deployment Notification',
                    embeds: [
                        {
                            title: 'Deployment Initiated',
                            description: `${service} service deployment to ${targetEnv} environment`,
                            color: 0x00ff00,
                            fields: [
                                {
                                    name: 'Service',
                                    value: service,
                                    inline: true,
                                },
                                {
                                    name: 'Environment',
                                    value: targetEnv,
                                    inline: true,
                                },
                                {
                                    name: 'Initiated By',
                                    value: interaction.user.displayName,
                                    inline: true,
                                },
                            ],
                            timestamp: new Date().toISOString(),
                        },
                    ],
                };

                const response = await fetch(config.webhookUrl, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(webhookPayload),
                });

                if (response.ok) {
                    console.log('📡 Webhook notification sent successfully');
                } else {
                    console.error(
                        '❌ Webhook notification failed:',
                        response.status,
                        response.statusText,
                    );
                }
            } catch (error) {
                console.error('❌ Error sending webhook notification:', error);
            }
        }
    } else {
        // Safety mode - triggers not enabled
        embed
            .setDescription('⚠️ **SAFETY MODE**: Live triggers not enabled')
            .addFields([
                {
                    name: '🛡️ Safety Notice',
                    value: 'Live deployment triggers are disabled. Enable with `LIVE_TRIGGERS_ENABLED=true`',
                    inline: false,
                },
            ]);
    }

    await interaction.reply({ embeds: [embed] });
}
