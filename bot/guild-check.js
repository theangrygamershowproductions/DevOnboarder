import { Client, GatewayIntentBits } from 'discord.js';
import dotenv from 'dotenv';

dotenv.config();

const client = new Client({
    intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMembers],
});

client.once('ready', () => {
    console.log(`🤖 Bot logged in as ${client.user?.tag}`);
    console.log('🏠 Available Guilds:');

    client.guilds.cache.forEach((guild) => {
        console.log(`   - ${guild.name} (ID: ${guild.id})`);
        console.log(`     Members: ${guild.memberCount}`);
        console.log(`     Owner: ${guild.ownerId}`);
        console.log('');
    });

    // Test with both possible guild IDs
    const targetGuilds = [
        { name: 'DevOnboarder', id: '1386935663139749998' },
        { name: 'C2C', id: '1065367728992571444' },
    ];

    console.log('🎯 Testing Target Guilds:');
    targetGuilds.forEach((target) => {
        const guild = client.guilds.cache.get(target.id);
        if (guild) {
            console.log(`   ✅ ${target.name}: Found - ${guild.name}`);
        } else {
            console.log(
                `   ❌ ${target.name}: Not accessible or bot not invited`,
            );
        }
    });

    process.exit(0);
});

client.login(process.env.DISCORD_BOT_TOKEN);
