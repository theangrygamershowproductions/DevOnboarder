// PATCHED v0.1.2 plugins/codex_scaffold/index.ts — Scaffold TAGS repo
import { promises as fs } from "fs";
import path from "path";
import yaml from "js-yaml";

export default async function run(): Promise<void> {
    const repoRoot = process.cwd();
    try {
        const templateDir = path.join(__dirname, "templates");

        // Copy template files into the repository
        try {
            const items = await fs.readdir(templateDir, {
                withFileTypes: true,
            });
            for (const item of items) {
                const src = path.join(templateDir, item.name);
                const dest = path.join(repoRoot, item.name);
                if (item.isDirectory()) {
                    await fs.mkdir(dest, { recursive: true });
                    const files = await fs.readdir(src);
                    for (const file of files) {
                        await fs.copyFile(
                            path.join(src, file),
                            path.join(dest, file)
                        );
                    }
                } else {
                    await fs.copyFile(src, dest);
                }
            }
        } catch {
            // no templates to copy
        }

        // Merge environment manifest
        const envPath = path.join(repoRoot, "env.manifest.yml");
        let base = {} as Record<string, unknown>;
        try {
            const text = await fs.readFile(envPath, "utf8");
            base = yaml.load(text) as Record<string, unknown>;
        } catch {
            // ignore missing file
        }
        const envFile = path.join(__dirname, "env.manifest.yml");
        const pluginEnv = yaml.load(
            await fs.readFile(envFile, "utf8")
        ) as Record<string, unknown>;
        const merged = { ...base, ...pluginEnv };
        await fs.writeFile(envPath, yaml.dump(merged));

        // Install git hooks
        const hooksDir = path.join(__dirname, "hooks");
        try {
            const hooks = await fs.readdir(hooksDir);
            for (const hook of hooks) {
                await fs.copyFile(
                    path.join(hooksDir, hook),
                    path.join(repoRoot, ".git", "hooks", hook)
                );
            }
        } catch {
            // optional
        }
    } catch (err) {
        await logError(repoRoot, err);
        throw err;
    }
}

async function logError(repoRoot: string, err: unknown): Promise<void> {
    const logDir = path.join(repoRoot, "logs");
    await fs.mkdir(logDir, { recursive: true });
    const stack =
        err instanceof Error ? err.stack ?? String(err) : String(err);
    const hint =
        "Run `npm ci` and ensure Node 22 + ts-node are installed.";
    const entry = `${new Date().toISOString()}\n${stack}\n${hint}\n`;
    await fs.appendFile(path.join(logDir, "scaffold-error.log"), entry);
}
