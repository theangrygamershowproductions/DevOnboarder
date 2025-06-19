import { execute } from '../src/commands/ping';

const interaction = {
  reply: jest.fn(),
};

test('ping command replies with pong', async () => {
  await execute(interaction as any);
  expect(interaction.reply).toHaveBeenCalledWith('🏓 Pong!');
});
