import { execute } from '../src/commands/qa_checklist';
import { readFile } from 'fs/promises';

jest.mock('fs/promises', () => ({ readFile: jest.fn() }));

const interaction = {
    reply: jest.fn(),
    followUp: jest.fn(),
} as any;

const mockedReadFile = readFile as jest.MockedFunction<typeof readFile>;

beforeEach(() => {
    mockedReadFile.mockReset();
    mockedReadFile.mockResolvedValue('list');
    interaction.reply.mockReset();
    interaction.followUp.mockReset();
});

test('qa_checklist command replies with file contents', async () => {
    await execute(interaction);
    expect(mockedReadFile).toHaveBeenCalled();
    expect(interaction.reply).toHaveBeenCalledWith({
        content: 'list',
        ephemeral: true,
    });
    expect(interaction.followUp).not.toHaveBeenCalled();
});

test('qa_checklist command splits long content', async () => {
    const long = 'a'.repeat(3000);
    mockedReadFile.mockResolvedValueOnce(long);
    await execute(interaction);
    expect(interaction.reply).toHaveBeenCalledWith({
        content: long.slice(0, 2000),
        ephemeral: true,
    });
    expect(interaction.followUp).toHaveBeenCalledWith({
        content: long.slice(2000),
        ephemeral: true,
    });
});
