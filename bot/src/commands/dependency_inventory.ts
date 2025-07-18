import { SlashCommandBuilder, ChatInputCommandInteraction, AttachmentBuilder } from 'discord.js';
import { readFile } from 'fs/promises';
import path from 'path';
import * as XLSX from 'xlsx';
import toml from 'toml';

interface InventoryItem {
  Type: string;
  File: string;
  Package: string;
  Version: string;
}

async function parsePyproject(root: string): Promise<InventoryItem[]> {
  const file = path.join(root, 'pyproject.toml');
  const text = await readFile(file, 'utf8');
  const data = toml.parse(text) as any;
  const items: InventoryItem[] = [];
  const deps: string[] = data?.project?.dependencies ?? [];
  for (const dep of deps) {
    const match = dep.match(/^([^\s<>=!]+)(.*)$/);
    const name = match ? match[1] : dep;
    const version = match && match[2] ? match[2] : '';
    items.push({ Type: 'Python', File: 'pyproject.toml', Package: name, Version: version });
  }
  return items;
}

async function parseRequirements(root: string): Promise<InventoryItem[]> {
  const file = path.join(root, 'requirements-dev.txt');
  const items: InventoryItem[] = [];
  const text = await readFile(file, 'utf8');
  for (const line of text.split(/\r?\n/)) {
    const trimmed = line.split('#')[0].trim();
    if (!trimmed) continue;
    const match = trimmed.match(/^([^=<>!]+)(.*)$/);
    if (!match) continue;
    const name = match[1];
    const version = match[2] || '';
    items.push({ Type: 'Python (dev)', File: 'requirements-dev.txt', Package: name, Version: version });
  }
  return items;
}

async function parsePackageJson(root: string, rel: string): Promise<InventoryItem[]> {
  const file = path.join(root, rel, 'package.json');
  const pkg = JSON.parse(await readFile(file, 'utf8'));
  const items: InventoryItem[] = [];
  for (const [name, version] of Object.entries(pkg.dependencies || {})) {
    items.push({ Type: 'Node.js', File: path.join(rel, 'package.json'), Package: name, Version: String(version) });
  }
  for (const [name, version] of Object.entries(pkg.devDependencies || {})) {
    items.push({ Type: 'Node.js (dev)', File: path.join(rel, 'package.json'), Package: name, Version: String(version) });
  }
  return items;
}

export const data = new SlashCommandBuilder()
  .setName('dependency_inventory')
  .setDescription('Generate a dependency inventory spreadsheet');

export async function execute(interaction: ChatInputCommandInteraction) {
  const root = path.resolve(__dirname, '../../..');
  const items: InventoryItem[] = [];
  items.push(...await parsePyproject(root));
  items.push(...await parseRequirements(root));
  items.push(...await parsePackageJson(root, '.'));
  items.push(...await parsePackageJson(root, 'frontend'));
  items.push(...await parsePackageJson(root, 'bot'));

  const wb = XLSX.utils.book_new();
  const sheet = XLSX.utils.json_to_sheet(items);
  XLSX.utils.book_append_sheet(wb, sheet, 'Inventory');
  const outPath = path.join(root, 'dependency_inventory.xlsx');
  XLSX.writeFile(wb, outPath);

  const attachment = new AttachmentBuilder(outPath);
  await interaction.reply({ files: [attachment] });
}
