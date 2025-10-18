#!/usr/bin/env node
/**
 * Quick Guild Connection Test
 * Verifies bot can connect to both invited Discord servers
 */

import dotenv from "dotenv";
import { Client, GatewayIntentBits } from "discord.js";

dotenv.config();

// Configuration
const TARGET_GUILDS = {
    dev: {
        id: "1386935663139749998",
        name: "TAGS: DevOnboarder",
    },
    prod: {
        id: "1065367728992571444",
        name: "TAGS: Command & Control",
    },
};

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.GuildMembers,
    ],
});

console.log("LINK: Discord Bot Guild Connection Test");
console.log("===================================");
console.log("");

client.once("ready", async () => {
    console.log(` Bot logged in as: ${client.user.tag}`);
    console.log(`🆔 Bot ID: ${client.user.id}`);
    console.log("");

    // Check total guilds
    const totalGuilds = client.guilds.cache.size;
    console.log(`HOME: Total Connected Guilds: ${totalGuilds}`);
    console.log("");

    // Check target guilds specifically
    console.log("🎯 Target Server Connection Status:");
    console.log("=====================================");

    let connectedCount = 0;

    for (const [env, guild] of Object.entries(TARGET_GUILDS)) {
        const guildObj = client.guilds.cache.get(guild.id);

        if (guildObj) {
            console.log(` ${guild.name}`);
            console.log(`   ─ Environment: ${env.toUpperCase()}`);
            console.log(`   ─ Guild ID: ${guild.id}`);
            console.log(
                `   ─ Member Count: ${guildObj.memberCount || "Unknown"}`,
            );
            console.log(`   ─ Owner: ${guildObj.ownerId || "Unknown"}`);
            console.log(
                `   ─ Bot Permissions: ${
                    guildObj.members.me?.permissions.toArray().length || 0
                } permissions`,
            );
            connectedCount;
        } else {
            console.log(` ${guild.name}`);
            console.log(`   ─ Environment: ${env.toUpperCase()}`);
            console.log(`   ─ Guild ID: ${guild.id}`);
            console.log(`   ─ Status: NOT CONNECTED or NOT INVITED`);
        }
        console.log("");
    }

    // Summary
    console.log(" Connection Summary:");
    console.log("======================");
    console.log(
        `Connected Target Servers: ${connectedCount}/${
            Object.keys(TARGET_GUILDS).length
        }`,
    );
    console.log(`Total Connected Servers: ${totalGuilds}`);

    if (connectedCount === Object.keys(TARGET_GUILDS).length) {
        console.log("🎉  Bot connected to all target servers!");
    } else {
        console.log("   Bot not connected to all target servers");
        console.log("");
        console.log(" Troubleshooting:");
        console.log("   1. Verify bot was invited with proper permissions");
        console.log("   2. Check invite link was used for both servers");
        console.log('   3. Ensure bot has "View Server" permission');
        console.log("   4. Re-generate invite: npm run invite");
    }

    // List all connected guilds for reference
    if (totalGuilds > 0) {
        console.log("");
        console.log(" All Connected Guilds:");
        console.log("========================");
        client.guilds.cache.forEach((guild) => {
            const isTarget = Object.values(TARGET_GUILDS).some(
                (tg) => tg.id === guild.id,
            );
            const marker = isTarget ? "🎯" : "LOCATION:";
            console.log(`${marker} ${guild.name} (${guild.id})`);
        });
    }

    console.log("");
    console.log("SYNC: Test complete - Bot will disconnect in 3 seconds...");

    setTimeout(() => {
        client.destroy();
        process.exit(0);
    }, 3000);
});

client.on("error", (error) => {
    console.error(" Discord Client Error:", error.message);
    process.exit(1);
});

// Login with bot token
if (!process.env.DISCORD_BOT_TOKEN) {
    console.error(" DISCORD_BOT_TOKEN not found in environment variables");
    process.exit(1);
}

console.log(" Authenticating with Discord...");
client.login(process.env.DISCORD_BOT_TOKEN).catch((error) => {
    console.error(" Failed to login:", error.message);
    process.exit(1);
});
