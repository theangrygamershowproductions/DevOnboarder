import { execute } from '../src/commands/dependency_inventory';
import fs from 'fs';
import path from 'path';

const interaction = { reply: jest.fn() } as any;

test('dependency_inventory generates CSV file', async () => {
    await execute(interaction);
    const filePath = path.resolve(
        __dirname,
        '..',
        '..',
        'dependency_inventory.csv',
    );
    expect(fs.existsSync(filePath)).toBe(true);
    const csvContent = fs.readFileSync(filePath, 'utf8');
    const lines = csvContent.split('\n');
    const header = lines[0];
    expect(header).toBe('Type,File,Package,Version');

    // Check that the CSV contains expected packages
    expect(csvContent).toContain('httpx');
    expect(csvContent).toContain('react');

    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
});
