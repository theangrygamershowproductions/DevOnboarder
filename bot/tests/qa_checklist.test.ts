import { execute } from '../src/commands/qa_checklist';
import { promises as fs } from 'fs';

jest.mock('fs', () => ({ promises: { readFile: jest.fn() } }));

const interaction = {
  reply: jest.fn(),
} as any;

const mockedReadFile = fs.readFile as jest.MockedFunction<typeof fs.readFile>;

beforeEach(() => {
  mockedReadFile.mockResolvedValue('list');
  interaction.reply.mockReset();
});

test('qa_checklist command replies with file contents', async () => {
  await execute(interaction);
  expect(mockedReadFile).toHaveBeenCalled();
  expect(interaction.reply).toHaveBeenCalledWith('list');
});
