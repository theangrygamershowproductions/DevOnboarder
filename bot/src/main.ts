import { Client, GatewayIntentBits } from 'discord.js';
import dotenv from 'dotenv';
import path from 'path';
import { loadCommands, loadEvents } from './utils/loadFiles';

dotenv.config();

// Environment configuration
const ENVIRONMENT = process.env.ENVIRONMENT || 'dev';
const DISCORD_BOT_READY = process.env.DISCORD_BOT_READY === 'true';
const LIVE_TRIGGERS_ENABLED = process.env.LIVE_TRIGGERS_ENABLED === 'true';
const CODEX_DRY_RUN = process.env.CODEX_DRY_RUN === 'true';

console.log('🤖 DevOnboarder Discord Bot Starting...');
console.log('==========================================');
console.log(`   Environment: ${ENVIRONMENT}`);
console.log(`   Guild ID: ${process.env.DISCORD_GUILD_ID}`);
console.log(`   Bot Ready: ${DISCORD_BOT_READY}`);
console.log(`   Live Triggers: ${LIVE_TRIGGERS_ENABLED}`);
console.log(`   Dry-run Mode: ${CODEX_DRY_RUN}`);
console.log('');

// Safety checks
if (
    !process.env.DISCORD_BOT_TOKEN ||
    process.env.DISCORD_BOT_TOKEN === 'changeme'
) {
    console.error('❌ DISCORD_BOT_TOKEN not configured');
    console.error(
        '   Please set your Discord bot token in the environment variables',
    );
    process.exit(1);
}

if (!process.env.DISCORD_GUILD_ID) {
    console.error('❌ DISCORD_GUILD_ID not configured');
    console.error('   Please run: bash ../scripts/setup_discord_env.sh');
    process.exit(1);
}

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMembers,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
    ],
});

// Add environment context to client
(client as any).config = {
    environment: ENVIRONMENT,
    guildId: process.env.DISCORD_GUILD_ID,
    botReady: DISCORD_BOT_READY,
    liveTriggersEnabled: LIVE_TRIGGERS_ENABLED,
    dryRunMode: CODEX_DRY_RUN,
    apiBaseUrl: process.env.API_BASE_URL || 'http://localhost:8001',
    webhookUrl: process.env.DISCORD_WEBHOOK_URL,
};

async function start() {
    try {
        console.log('📚 Loading commands and events...');
        const commands = await loadCommands(path.join(__dirname, 'commands'));
        await loadEvents(client, path.join(__dirname, 'events'), commands);

        console.log('🔐 Logging in to Discord...');
        await client.login(process.env.DISCORD_BOT_TOKEN);

        console.log('✅ Bot startup complete!');
    } catch (error) {
        console.error('❌ Failed to start bot:', error);
        process.exit(1);
    }
}

// Graceful shutdown handling
process.on('SIGINT', () => {
    console.log('🛑 Received SIGINT, shutting down gracefully...');
    client.destroy();
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('🛑 Received SIGTERM, shutting down gracefully...');
    client.destroy();
    process.exit(0);
});

start();
