import { Client, Collection } from 'discord.js';
import { readdirSync } from 'fs';
import path from 'path';

export type CommandModule = {
    data: { name: string };
    execute: (interaction: any) => Promise<void>;
};

export type Commands = Collection<string, CommandModule>;

export async function loadCommands(dir: string): Promise<Commands> {
    const commands: Commands = new Collection();
    const files = readdirSync(dir).filter(
        (f) => f.endsWith('.js') || f.endsWith('.ts'),
    );
    for (const file of files) {
        const mod = await import(path.join(dir, file));
        commands.set(mod.data.name, mod as CommandModule);
    }
    return commands;
}

export async function loadEvents(
    client: Client,
    dir: string,
    commands: Commands,
) {
    const files = readdirSync(dir).filter((f) => f.endsWith('.js'));
    for (const file of files) {
        const event = await import(path.join(dir, file));
        if (event.once) {
            client.once(event.name, (...args) =>
                event.execute(...args, commands),
            );
        } else {
            client.on(event.name, (...args) =>
                event.execute(...args, commands),
            );
        }
    }
}
