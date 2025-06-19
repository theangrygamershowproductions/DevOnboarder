import { Client, GatewayIntentBits, Interaction } from 'discord.js';
import * as dotenv from 'dotenv';
import { getOnboardingStatus, getUserLevel, getUserContributions } from './api';

dotenv.config({ path: '.env.bot' });

const client = new Client({ intents: [GatewayIntentBits.Guilds] });

client.once('ready', () => {
  console.log(`Logged in as ${client.user?.tag}`);
});

async function handleCommand(interaction: Interaction) {
  if (!interaction.isChatInputCommand()) return;

  switch (interaction.commandName) {
    case 'verify': {
      const status = await getOnboardingStatus();
      await interaction.reply(`Onboarding status: ${status}`);
      break;
    }
    case 'profile': {
      const level = await getUserLevel();
      await interaction.reply(`Your level is ${level}`);
      break;
    }
    case 'contribute': {
      const contributions = await getUserContributions();
      await interaction.reply(`Contributions: ${contributions.join(', ')}`);
      break;
    }
    default:
      break;
  }
}

client.on('interactionCreate', handleCommand);

client.login(process.env.DISCORD_TOKEN);

export { handleCommand };
