const { injectPolicies: copyPolicies } = require('../../codex/src/tasks/copyPolicies.ts');
const { promises: fs } = require('fs');
const path = require('path');
const os = require('os');
const assert = require('assert');

async function run(): Promise<void> {
  const tmp = await fs.mkdtemp(path.join(os.tmpdir(), 'policies-'));
  try {
    const summary1 = await copyPolicies(tmp, 'Test Owner');
    assert.strictEqual(summary1.added, 3);
    assert.strictEqual(summary1.skipped, 0);

    const license = await fs.readFile(path.join(tmp, 'LICENSE'), 'utf8');
    assert(!license.includes('<<COPYRIGHT_OWNER>>'));
    assert(license.includes('Test Owner'));

    const summary2 = await copyPolicies(tmp, 'Test Owner');
    assert.strictEqual(summary2.added, 0);
    assert.strictEqual(summary2.skipped, 3);
  } finally {
    await fs.rm(tmp, { recursive: true, force: true });
  }
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
