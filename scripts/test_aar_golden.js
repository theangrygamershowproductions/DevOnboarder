#!/usr/bin/env node
/**
 * AAR Golden File Test Suite
 *
 * Snapshot testing for AAR rendering to detect template changes and regressions
 * Usage: npm run aar:test-golden
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const crypto = require('crypto');

class AARGoldenTester {
    constructor() {
        this.testDir = path.join(__dirname, '../tests/golden/aar');
        this.outputDir = path.join(__dirname, '../tests/golden/aar/output');
        this.snapshotDir = path.join(__dirname, '../tests/golden/aar/snapshots');

        // Ensure output directories exist
        [this.outputDir, this.snapshotDir].forEach(dir => {
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }
        });
    }

    async runTests() {
        console.log('🧪 Running AAR Golden File Tests...\n');

        const testFiles = fs.readdirSync(this.testDir)
            .filter(file => file.endsWith('.aar.json'));

        if (testFiles.length === 0) {
            console.log('❌ No golden test files found');
            return false;
        }

        let allPassed = true;
        const results = [];

        for (const testFile of testFiles) {
            const result = await this.runTest(testFile);
            results.push(result);
            if (!result.passed) {
                allPassed = false;
            }
        }

        this.printSummary(results);
        return allPassed;
    }

    async runTest(testFile) {
        const testName = path.basename(testFile, '.aar.json');
        console.log(`Testing: ${testName}`);

        const inputPath = path.join(this.testDir, testFile);
        const snapshotPath = path.join(this.snapshotDir, `${testName}.md`);

        try {
            // Generate current output
            await this.renderAAR(inputPath, this.outputDir);

            // Find the generated output file (renderer creates filename based on AAR content)
            const outputFiles = fs.readdirSync(this.outputDir)
                .filter(file => file.endsWith('.md') && file !== '_index.md');

            if (outputFiles.length === 0) {
                console.log(`  ❌ Failed to generate output for ${testName}`);
                return { testName, passed: false, error: 'Output generation failed' };
            }

            // Use the first (and likely only) generated file
            const outputPath = path.join(this.outputDir, outputFiles[0]);
            const currentOutput = fs.readFileSync(outputPath, 'utf8');
            const currentHash = this.hashContent(currentOutput);

            // Check if snapshot exists
            if (!fs.existsSync(snapshotPath)) {
                // Create initial snapshot
                fs.writeFileSync(snapshotPath, currentOutput);
                console.log(`  📸 Created initial snapshot for ${testName}`);
                return { testName, passed: true, created: true };
            }

            // Compare with snapshot
            const snapshotOutput = fs.readFileSync(snapshotPath, 'utf8');
            const snapshotHash = this.hashContent(snapshotOutput);

            if (currentHash === snapshotHash) {
                console.log(`  ✅ ${testName} matches snapshot`);
                return { testName, passed: true };
            } else {
                console.log(`  ❌ ${testName} differs from snapshot`);

                // Generate diff for debugging
                const diffPath = path.join(this.outputDir, `${testName}.diff`);
                await this.generateDiff(snapshotPath, outputPath, diffPath);

                return {
                    testName,
                    passed: false,
                    error: 'Output differs from snapshot',
                    diffPath: diffPath
                };
            }

        } catch (error) {
            console.log(`  ❌ Error testing ${testName}: ${error.message}`);
            return { testName, passed: false, error: error.message };
        }
    }

    async renderAAR(inputPath, outputDir) {
        return new Promise((resolve, reject) => {
            const renderScript = path.join(__dirname, '../scripts/render_aar.js');

            exec(`node "${renderScript}" "${inputPath}" "${outputDir}"`, (error, stdout, stderr) => {
                if (error) {
                    reject(new Error(`Render failed: ${stderr || error.message}`));
                } else {
                    resolve(stdout);
                }
            });
        });
    }

    async generateDiff(file1, file2, outputPath) {
        return new Promise((resolve) => {
            exec(`diff -u "${file1}" "${file2}"`, (error, stdout, stderr) => {
                // diff returns non-zero exit code when files differ, which is expected
                fs.writeFileSync(outputPath, stdout || stderr || 'No diff available');
                resolve();
            });
        });
    }

    hashContent(content) {
        // Normalize content before hashing (remove timestamps, etc.)
        const normalized = content
            .replace(/\*Generated by DevOnboarder AAR System v[\d.]+ on [\d\-T:.Z]+\*/g, '*Generated by DevOnboarder AAR System v[VERSION] on [TIMESTAMP]*')
            .replace(/Generated on: .+\n/g, 'Generated on: [TIMESTAMP]\n')
            .replace(/Rendered by: .+ at .+\n/g, 'Rendered by: [RENDERER] at [TIMESTAMP]\n');

        return crypto.createHash('sha256').update(normalized).digest('hex');
    }

    printSummary(results) {
        console.log('\n📊 Test Summary:');

        const passed = results.filter(r => r.passed).length;
        const failed = results.filter(r => !r.passed).length;
        const created = results.filter(r => r.created).length;

        console.log(`  ✅ Passed: ${passed}`);
        console.log(`  ❌ Failed: ${failed}`);
        console.log(`  📸 Created: ${created}`);

        if (failed > 0) {
            console.log('\n❌ Failed Tests:');
            results.filter(r => !r.passed).forEach(result => {
                console.log(`  ${result.testName}: ${result.error}`);
                if (result.diffPath) {
                    console.log(`    Diff: ${result.diffPath}`);
                }
            });
        }

        console.log(`\n${failed === 0 ? '✅' : '❌'} Overall: ${passed}/${results.length} tests passed`);
    }

    async updateSnapshots() {
        console.log('🔄 Updating all snapshots...\n');

        const testFiles = fs.readdirSync(this.testDir)
            .filter(file => file.endsWith('.aar.json'));

        for (const testFile of testFiles) {
            const testName = path.basename(testFile, '.aar.json');
            const inputPath = path.join(this.testDir, testFile);
            const snapshotPath = path.join(this.snapshotDir, `${testName}.md`);

            try {
                await this.renderAAR(inputPath, this.outputDir);

                // Find the generated output file
                const outputFiles = fs.readdirSync(this.outputDir)
                    .filter(file => file.endsWith('.md') && file !== '_index.md');

                if (outputFiles.length > 0) {
                    const outputPath = path.join(this.outputDir, outputFiles[0]);
                    fs.copyFileSync(outputPath, snapshotPath);
                    console.log(`  📸 Updated snapshot: ${testName}`);
                } else {
                    console.log(`  ❌ No output generated for ${testName}`);
                }
            } catch (error) {
                console.log(`  ❌ Failed to update ${testName}: ${error.message}`);
            }
        }
    }
}

// CLI Interface
if (require.main === module) {
    const tester = new AARGoldenTester();
    const updateMode = process.argv.includes('--update');

    if (updateMode) {
        tester.updateSnapshots()
            .then(() => console.log('\n✅ Snapshot update complete'))
            .catch(error => {
                console.error('❌ Snapshot update failed:', error);
                process.exit(1);
            });
    } else {
        tester.runTests()
            .then(passed => {
                if (!passed) {
                    console.log('\n💡 Run with --update to update snapshots');
                    process.exit(1);
                }
            })
            .catch(error => {
                console.error('❌ Golden tests failed:', error);
                process.exit(1);
            });
    }
}

module.exports = AARGoldenTester;
