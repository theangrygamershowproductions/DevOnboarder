import { handleCommand } from '../src/index';
import * as api from '../src/api';
import { Interaction } from 'discord.js';

jest.mock('discord.js', () => {
  return {
    Client: jest.fn().mockImplementation(() => ({
      once: jest.fn(),
      on: jest.fn(),
      login: jest.fn(),
      user: { tag: 'test' },
    })),
    GatewayIntentBits: { Guilds: 0 },
    Interaction: class {},
  };
});

jest.mock('../src/api');

function makeInteraction(commandName: string) {
  return {
    isChatInputCommand: () => true,
    commandName,
    reply: jest.fn(),
  } as unknown as Interaction & { reply: jest.Mock };
}

const mockedStatus = api.getOnboardingStatus as jest.Mock;
const mockedLevel = api.getUserLevel as jest.Mock;
const mockedContrib = api.getUserContributions as jest.Mock;

test('verify command replies with onboarding status', async () => {
  mockedStatus.mockResolvedValue('pending');
  const interaction = makeInteraction('verify');
  await handleCommand(interaction);
  expect(mockedStatus).toHaveBeenCalled();
  expect(interaction.reply).toHaveBeenCalledWith('Onboarding status: pending');
});

test('profile command replies with user level', async () => {
  mockedLevel.mockResolvedValue(5);
  const interaction = makeInteraction('profile');
  await handleCommand(interaction);
  expect(mockedLevel).toHaveBeenCalled();
  expect(interaction.reply).toHaveBeenCalledWith('Your level is 5');
});

test('contribute command replies with contributions list', async () => {
  mockedContrib.mockResolvedValue(['fix1', 'doc']);
  const interaction = makeInteraction('contribute');
  await handleCommand(interaction);
  expect(mockedContrib).toHaveBeenCalled();
  expect(interaction.reply).toHaveBeenCalledWith('Contributions: fix1, doc');
});
