import { execute } from '../src/commands/dependency_inventory';
import fs from 'fs';
import path from 'path';
import * as XLSX from 'xlsx';


const interaction = { reply: jest.fn() } as any;

test('dependency_inventory generates spreadsheet', async () => {
  await execute(interaction);
  const filePath = path.resolve(__dirname, '..', '..', 'dependency_inventory.xlsx');
  expect(fs.existsSync(filePath)).toBe(true);
  const wb = XLSX.readFile(filePath);
  const sheet = wb.Sheets[wb.SheetNames[0]];
  const rows = XLSX.utils.sheet_to_json<{ Package: string }>(sheet);
  const packages = rows.map(r => r.Package);
  expect(packages).toContain('httpx');
  expect(packages).toContain('react');
  if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
});
