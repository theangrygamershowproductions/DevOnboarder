// PATCHED v0.1.1 codex/src/tasks/copyPolicies.ts — inject owner and summary
import fs from "node:fs";
import path from "node:path";

export interface CopySummary {
    added: number;
    skipped: number;
}

function copyDir(src: string, dest: string, overwrite = false): CopySummary {
    if (!fs.existsSync(src)) {
        throw new Error(`Source not found: ${src}`);
    }
    fs.mkdirSync(dest, { recursive: true });
    let summary: CopySummary = { added: 0, skipped: 0 };
    for (const entry of fs.readdirSync(src)) {
        const srcPath = path.join(src, entry);
        const destPath = path.join(dest, entry);
        const stats = fs.statSync(srcPath);
        if (stats.isDirectory()) {
            const sub = copyDir(srcPath, destPath, overwrite);
            summary.added += sub.added;
            summary.skipped += sub.skipped;
        } else if (overwrite || !fs.existsSync(destPath)) {
            fs.copyFileSync(srcPath, destPath);
            summary.added += 1;
        } else {
            summary.skipped += 1;
        }
    }
    return summary;
}

export function updateOwner(target: string, owner: string): string | void {
    if (fs.existsSync(target)) {
        const files = ["LICENSE", "NOTICE", "CLA"];
        for (const file of files) {
            const filePath = path.join(target, file);
            if (!fs.existsSync(filePath)) continue;
            const data = fs.readFileSync(filePath, "utf8");
            const updated = data.replace(/<<COPYRIGHT_OWNER>>/g, owner);
            fs.writeFileSync(filePath, updated);
        }
        return;
    }
    return target.replace(/<<COPYRIGHT_OWNER>>/g, owner);
}

export function injectPolicies(targetRepoRoot: string, owner?: string): CopySummary {
    const templateRoot = path.join(
        process.cwd(),
        "codex",
        "src",
        "templates",
        "shared-policies"
    );
    const stats = copyDir(templateRoot, targetRepoRoot, false);
    if (owner) {
        updateOwner(targetRepoRoot, owner);
    }
    return stats;
}

export const copyPolicies = injectPolicies;
