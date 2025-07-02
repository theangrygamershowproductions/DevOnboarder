import path from 'path';
import { promises as fs } from 'fs';
import { tmpdir } from 'os';
import { loadCommands, loadEvents } from '../src/utils/loadFiles';
import { Client, Collection } from 'discord.js';

describe('loadCommands', () => {
  test('loads available command modules', async () => {
    const commands = await loadCommands(path.join(__dirname, '..', 'src', 'commands'));
    expect(commands.size).toBeGreaterThan(0);
    expect(commands.get('ping')).toBeDefined();
  });
});

describe('loadEvents', () => {
  test('registers event handlers on the client', async () => {
    const dir = await fs.mkdtemp(path.join(tmpdir(), 'events-'));
    await fs.writeFile(
      path.join(dir, 'ready.js'),
      "module.exports = {name: 'ready', once: true, execute() {}};"
    );
    await fs.writeFile(
      path.join(dir, 'interactionCreate.js'),
      "module.exports = {name: 'interactionCreate', once: false, execute() {}};"
    );
    const client = { once: jest.fn(), on: jest.fn(), user: { tag: 'test' } } as unknown as Client;
    await loadEvents(client, dir, new Collection());
    expect(client.once).toHaveBeenCalledWith('ready', expect.any(Function));
    expect(client.on).toHaveBeenCalledWith('interactionCreate', expect.any(Function));
  });
});
