#!/usr/bin/env node
/**
 * Deploy Discord slash commands to the specified guild
 */

import dotenv from "dotenv";
import { REST, Routes } from "discord.js";
import { readdir } from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

dotenv.config();

const clientId = process.env.DISCORD_CLIENT_ID;
const guildId = process.env.DISCORD_GUILD_ID;
const token = process.env.DISCORD_BOT_TOKEN;

if (!clientId) {
    console.error(" DISCORD_CLIENT_ID not found in environment");
    process.exit(1);
}

if (!guildId) {
    console.error(" DISCORD_GUILD_ID not found in environment");
    process.exit(1);
}

if (!token) {
    console.error(" DISCORD_BOT_TOKEN not found in environment");
    process.exit(1);
}

console.log("🤖 DevOnboarder Command Deployment");
console.log("==================================");
console.log(` Client ID: ${clientId}`);
console.log(`HOME: Guild ID: ${guildId}`);
console.log("");

async function deployCommands() {
    const commands = [];
    const commandsPath = path.join(__dirname, "../dist/commands");

    try {
        const commandFiles = await readdir(commandsPath);
        const jsFiles = commandFiles.filter(file => file.endsWith(".js"));

        console.log(` Loading commands from: ${commandsPath}`);
        console.log(`FILE: Found ${jsFiles.length} command files:`);

        for (const file of jsFiles) {
            const filePath = path.join(commandsPath, file);
            const command = await import(`file://${filePath}`);

            if ('data' in command && 'execute' in command) {
                commands.push(command.data.toJSON());
                console.log(`    ${command.data.name} - ${command.data.description}`);
            } else {
                console.log(`     ${file}: Missing data or execute export`);
            }
        }

        const rest = new REST().setToken(token);

        console.log("");
        console.log(` Deploying ${commands.length} commands to guild ${guildId}...`);

        const data = await rest.put(
            Routes.applicationGuildCommands(clientId, guildId),
            { body: commands },
        );

        console.log(` Successfully registered ${data.length} application commands!`);

        console.log("");
        console.log(" Deployed Commands:");
        commands.forEach(cmd => {
            console.log(`   /${cmd.name} - ${cmd.description}`);
        });

    } catch (error) {
        console.error(" Error deploying commands:", error);
        process.exit(1);
    }
}

deployCommands();
