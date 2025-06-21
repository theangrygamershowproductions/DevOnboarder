import { execute } from '../src/events/interactionCreate';
import { CommandModule, Commands } from '../src/utils/loadFiles';

function makeInteraction(commandName: string) {
  return {
    isChatInputCommand: () => true,
    commandName,
  } as any;
}

test('interaction handler executes matching command', async () => {
  const cmd: CommandModule = {
    data: { name: 'verify' },
    execute: jest.fn(),
  };
  const commands = new Map([[cmd.data.name, cmd]]) as unknown as Commands;
  const interaction = makeInteraction('verify');
  await execute(interaction, commands);
  expect(cmd.execute).toHaveBeenCalledWith(interaction);
});
