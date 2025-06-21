import path from 'path';
import { execute } from '../src/events/interactionCreate';
import { loadCommands } from '../src/utils/loadFiles';

jest.mock('../src/api', () => ({
  getOnboardingStatus: jest.fn().mockResolvedValue('complete'),
  getUserLevel: jest.fn().mockResolvedValue(42),
  submitContribution: jest.fn().mockResolvedValue(undefined),
}));

function makeInteraction(commandName: string) {
  return {
    isChatInputCommand: () => true,
    commandName,
    reply: jest.fn(),
    options: { getString: jest.fn().mockReturnValue('fix bug') },
    user: { id: '1', username: 'alice' },
  } as any;
}

test('interaction handler executes commands loaded from disk', async () => {
  const commands = await loadCommands(path.join(__dirname, '..', 'src', 'commands'));

  const ping = makeInteraction('ping');
  await execute(ping, commands);
  expect(ping.reply).toHaveBeenCalledWith('🏓 Pong!');

  const verify = makeInteraction('verify');
  await execute(verify, commands);
  expect(verify.reply).toHaveBeenCalledWith('Onboarding status: complete');

  const profile = makeInteraction('profile');
  await execute(profile, commands);
  expect(profile.reply).toHaveBeenCalledWith('Current level: 42');

  const contribute = makeInteraction('contribute');
  await execute(contribute, commands);
  expect(contribute.reply).toHaveBeenCalledWith('Recorded contribution: fix bug');
});
