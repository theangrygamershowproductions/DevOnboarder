import { Client, EmbedBuilder } from 'discord.js';

export const name = 'ready';
export const once = true;

export async function execute(client: Client) {
    const config = (client as any).config || {};
    const environment = config.environment || 'unknown';
    const guildId = config.guildId;
    const dryRunMode = config.dryRunMode !== false;

    console.log(`🤖 Logged in as ${client.user?.tag}`);
    console.log(`🌍 Environment: ${environment}`);
    console.log(`🏠 Target Guild ID: ${guildId}`);
    console.log(`🧪 Dry-run Mode: ${dryRunMode}`);
    console.log('');

    // Display all connected guilds
    console.log('🏠 Connected Guilds:');
    if (client.guilds.cache.size === 0) {
        console.log(
            '   ❌ No guilds found! Bot may not be invited to any servers.',
        );
        console.log('   ');
        console.log('   🔗 Generate invite link: npm run invite');
        console.log('   📋 Required servers:');
        console.log('      • TAGS: DevOnboarder (1386935663139749998)');
        console.log('      • TAGS: C2C (1065367728992571444)');
    } else {
        client.guilds.cache.forEach((guild) => {
            console.log(
                `   • ${guild.name} (ID: ${guild.id}) - ${guild.memberCount} members`,
            );
        });
    }

    // Check for target guilds
    const targetGuilds = {
        dev: '1386935663139749998',
        prod: '1065367728992571444',
    };

    console.log('');
    console.log('🎯 Target Guild Status:');

    let connectedToTarget = false;
    for (const [env, targetGuildId] of Object.entries(targetGuilds)) {
        const guild = client.guilds.cache.get(targetGuildId);
        if (guild) {
            console.log(
                `   ✅ ${env.toUpperCase()}: ${guild.name} (${
                    guild.memberCount
                } members)`,
            );
            connectedToTarget = true;
        } else {
            console.log(
                `   ❌ ${env.toUpperCase()}: Guild ${targetGuildId} not accessible`,
            );
            console.log(
                `      Invite bot: https://discord.com/api/oauth2/authorize?client_id=${
                    config.clientId || 'CLIENT_ID'
                }&permissions=1342565456&scope=bot%20applications.commands`,
            );
        }
    }

    // Set bot status
    const statusText = dryRunMode
        ? `🧪 Dry-run | ${environment.toUpperCase()}`
        : `🚀 Live | ${environment.toUpperCase()}`;

    client.user?.setActivity(statusText, { type: 3 }); // Type 3 = Watching

    // Get target guild for notifications
    const targetGuild = client.guilds.cache.get(guildId);

    if (targetGuild) {
        console.log(`✅ Connected to target guild: ${targetGuild.name}`);

        // Send startup notification to general channel (if in live mode and enabled)
        if (!dryRunMode && config.liveTriggersEnabled && config.webhookUrl) {
            try {
                // Find a general channel for startup notification
                const channel = targetGuild.channels.cache.find(
                    (ch) =>
                        ch.name.includes('general') ||
                        ch.name.includes('bot') ||
                        ch.name.includes('dev'),
                );

                if (channel && channel.isTextBased()) {
                    const embed = new EmbedBuilder()
                        .setTitle('🤖 DevOnboarder Bot Online')
                        .setDescription(
                            `Connected to **${targetGuild.name}** in **${environment}** mode`,
                        )
                        .setColor(0x00ff00)
                        .addFields([
                            {
                                name: '🌍 Environment',
                                value: environment.toUpperCase(),
                                inline: true,
                            },
                            {
                                name: '⚙️ Mode',
                                value: dryRunMode ? '🧪 Dry-run' : '🚀 Live',
                                inline: true,
                            },
                            {
                                name: '📊 Status',
                                value: '✅ All systems operational',
                                inline: true,
                            },
                        ])
                        .setTimestamp()
                        .setFooter({
                            text: 'DevOnboarder Integration Bot',
                            iconURL: client.user?.displayAvatarURL(),
                        });

                    await channel.send({ embeds: [embed] });
                    console.log(
                        '📡 Startup notification sent to channel:',
                        channel.name,
                    );
                }
            } catch (error) {
                console.error('⚠️ Could not send startup notification:', error);
            }
        } else {
            console.log(
                '🧪 Startup notification skipped (dry-run mode or notifications disabled)',
            );
        }
    } else {
        console.log(`❌ Could not find target guild with ID: ${guildId}`);
        if (!connectedToTarget) {
            console.log('');
            console.log('⚠️  Bot is not connected to any target servers!');
            console.log('   🔗 Generate invite link: npm run invite');
            console.log('   📋 Add bot to servers using the invite link');
        }
    }

    // Log startup completion
    console.log('');
    console.log('✅ DevOnboarder Discord Bot is ready!');
    console.log('=====================================');
    console.log(`   Bot: ${client.user?.tag}`);
    console.log(`   Guilds: ${client.guilds.cache.size} connected`);
    console.log(`   Environment: ${environment}`);
    console.log(`   Mode: ${dryRunMode ? 'Dry-run (Safe)' : 'Live'}`);
    console.log(`   Commands: Loading...`);
    console.log('');

    // Show available commands
    if (connectedToTarget) {
        console.log('🎮 Available Commands:');
        console.log('   /status - Check bot and integration status');
        console.log('   /deploy - Deploy services (admin only)');
        console.log('   /ping - Test bot responsiveness');
        console.log('');
    }
}
