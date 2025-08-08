#!/usr/bin/env node
/**
 * AAR Schema Migration Script
 *
 * Migrates AAR data files between schema versions with rollback support
 * Usage: node scripts/migrate_aar.js <files> --to <version> [--dry-run] [--rollback]
 */

const fs = require('fs');
const path = require('path');
const glob = require('glob');
const Ajv = require('ajv');
const addFormats = require('ajv-formats');

class AARMigrator {
    constructor() {
        this.ajv = new Ajv({ allErrors: true });
        addFormats(this.ajv);
        this.migrations = new Map();
        this.backups = new Map();

        // Register migration functions
        this.registerMigrations();
    }

    registerMigrations() {
        // Migration from implicit v1.0.0 to explicit v1.0.0
        this.migrations.set('0.0.0->1.0.0', (data) => {
            if (!data.schema_version) {
                data.schema_version = '1.0.0';
            }
            return data;
        });

        // Future migration example: v1.0.0 -> v1.1.0
        this.migrations.set('1.0.0->1.1.0', (data) => {
            // Add auto-linking metadata if not present
            if (!data.metadata) {
                data.metadata = {
                    auto_linked: false,
                    github_refs: []
                };
            }
            data.schema_version = '1.1.0';
            return data;
        });

        // Future migration example: v1.1.0 -> v2.0.0
        this.migrations.set('1.1.0->2.0.0', (data) => {
            // Breaking change: restructure executive_summary
            if (data.executive_summary && typeof data.executive_summary === 'object') {
                data.summary = {
                    problem_statement: data.executive_summary.problem,
                    solution_approach: data.executive_summary.solution,
                    impact_achieved: data.executive_summary.outcome
                };
                delete data.executive_summary;
            }
            data.schema_version = '2.0.0';
            return data;
        });
    }

    loadSchema(version) {
        const schemaPath = version === 'latest'
            ? path.join(__dirname, '../docs/AAR/schema/aar.schema.json')
            : path.join(__dirname, `../docs/AAR/schemas/aar.v${version}.json`);

        if (!fs.existsSync(schemaPath)) {
            throw new Error(`Schema version ${version} not found at ${schemaPath}`);
        }

        return JSON.parse(fs.readFileSync(schemaPath, 'utf8'));
    }

    validateData(data, schema) {
        const validate = this.ajv.compile(schema);
        const isValid = validate(data);

        return {
            valid: isValid,
            errors: validate.errors ? this.formatErrors(validate.errors) : []
        };
    }

    formatErrors(ajvErrors) {
        return ajvErrors.map(error => ({
            field: error.instancePath?.substring(1) || error.dataPath?.substring(1) || 'root',
            rule: error.keyword,
            message: error.message,
            suggestion: this.getErrorSuggestion(error)
        }));
    }

    getErrorSuggestion(error) {
        const suggestions = {
            'required': `Add the required field: ${error.params?.missingProperty}`,
            'minLength': `Provide at least ${error.params?.limit} characters`,
            'enum': `Use one of: ${error.params?.allowedValues?.join(', ')}`,
            'format': `Use the correct format (e.g., YYYY-MM-DD for dates)`,
            'const': `Value must be exactly: ${error.params?.allowedValue}`
        };
        return suggestions[error.keyword] || 'Check the field value and format';
    }

    getCurrentVersion(data) {
        // Determine current version from data
        if (data.schema_version) {
            return data.schema_version;
        }

        // Legacy detection - if no schema_version, assume pre-1.0.0
        return '0.0.0';
    }

    getMigrationPath(fromVersion, toVersion) {
        // Simple version comparison and path determination
        const versions = ['0.0.0', '1.0.0', '1.1.0', '2.0.0'];
        const fromIndex = versions.indexOf(fromVersion);
        const toIndex = versions.indexOf(toVersion);

        if (fromIndex === -1 || toIndex === -1) {
            throw new Error(`Unknown version: ${fromVersion} or ${toVersion}`);
        }

        if (fromIndex === toIndex) {
            return []; // No migration needed
        }

        if (fromIndex > toIndex) {
            throw new Error(`Downgrade not supported: ${fromVersion} -> ${toVersion}`);
        }

        const path = [];
        for (let i = fromIndex; i < toIndex; i++) {
            path.push(`${versions[i]}->${versions[i + 1]}`);
        }

        return path;
    }

    migrateData(data, fromVersion, toVersion) {
        const migrationPath = this.getMigrationPath(fromVersion, toVersion);
        let migratedData = JSON.parse(JSON.stringify(data)); // Deep clone

        for (const migration of migrationPath) {
            if (!this.migrations.has(migration)) {
                throw new Error(`Migration ${migration} not implemented`);
            }

            console.log(`  Applying migration: ${migration}`);
            migratedData = this.migrations.get(migration)(migratedData);
        }

        return migratedData;
    }

    async migrateFile(filePath, targetVersion, options = {}) {
        const { dryRun = false, createBackup = true } = options;

        console.log(`Processing: ${filePath}`);

        // Load and parse AAR data
        const rawData = fs.readFileSync(filePath, 'utf8');
        const data = JSON.parse(rawData);

        // Determine current version
        const currentVersion = this.getCurrentVersion(data);
        console.log(`  Current version: ${currentVersion}`);

        if (currentVersion === targetVersion) {
            console.log(`  Already at target version ${targetVersion}`);
            return { success: true, migrated: false };
        }

        // Create backup if not dry run
        if (createBackup && !dryRun) {
            const backupPath = `${filePath}.backup.${Date.now()}`;
            fs.writeFileSync(backupPath, rawData);
            this.backups.set(filePath, backupPath);
            console.log(`  Backup created: ${backupPath}`);
        }

        try {
            // Perform migration
            const migratedData = this.migrateData(data, currentVersion, targetVersion);

            // Validate migrated data against target schema
            const targetSchema = this.loadSchema(targetVersion);
            const validation = this.validateData(migratedData, targetSchema);

            if (!validation.valid) {
                console.error(`  Migration validation failed:`);
                validation.errors.forEach(error => {
                    console.error(`    ${error.field}: ${error.message} (${error.suggestion})`);
                });
                return { success: false, errors: validation.errors };
            }

            if (!dryRun) {
                // Write migrated data
                fs.writeFileSync(filePath, JSON.stringify(migratedData, null, 2));
                console.log(`  ✅ Migrated to version ${targetVersion}`);
            } else {
                console.log(`  ✅ Migration validated (dry run)`);
            }

            return { success: true, migrated: true, data: migratedData };

        } catch (error) {
            console.error(`  ❌ Migration failed: ${error.message}`);
            return { success: false, error: error.message };
        }
    }

    async rollback(filePaths) {
        console.log('Starting rollback process...');

        for (const filePath of filePaths) {
            if (this.backups.has(filePath)) {
                const backupPath = this.backups.get(filePath);
                if (fs.existsSync(backupPath)) {
                    fs.copyFileSync(backupPath, filePath);
                    fs.unlinkSync(backupPath);
                    console.log(`✅ Rolled back: ${filePath}`);
                } else {
                    console.log(`⚠️  Backup not found: ${backupPath}`);
                }
            } else {
                console.log(`⚠️  No backup recorded for: ${filePath}`);
            }
        }
    }

    async migrateFiles(patterns, targetVersion, options = {}) {
        const { dryRun = false, rollback = false } = options;

        // Expand glob patterns
        const filePaths = [];
        for (const pattern of patterns) {
            if (pattern.includes('*')) {
                filePaths.push(...glob.sync(pattern));
            } else {
                filePaths.push(pattern);
            }
        }

        if (filePaths.length === 0) {
            console.log('No AAR files found matching patterns');
            return;
        }

        if (rollback) {
            await this.rollback(filePaths);
            return;
        }

        console.log(`${dryRun ? 'DRY RUN: ' : ''}Migrating ${filePaths.length} files to version ${targetVersion}`);

        const results = {
            success: 0,
            failed: 0,
            skipped: 0,
            errors: []
        };

        for (const filePath of filePaths) {
            const result = await this.migrateFile(filePath, targetVersion, options);

            if (result.success) {
                if (result.migrated) {
                    results.success++;
                } else {
                    results.skipped++;
                }
            } else {
                results.failed++;
                results.errors.push({ file: filePath, error: result.error || result.errors });
            }
        }

        // Summary
        console.log('\nMigration Summary:');
        console.log(`  ✅ Successful: ${results.success}`);
        console.log(`  ⏭️  Skipped: ${results.skipped}`);
        console.log(`  ❌ Failed: ${results.failed}`);

        if (results.errors.length > 0) {
            console.log('\nErrors:');
            results.errors.forEach(({ file, error }) => {
                console.log(`  ${file}: ${typeof error === 'string' ? error : JSON.stringify(error, null, 2)}`);
            });
        }

        return results;
    }
}

// CLI Interface
if (require.main === module) {
    const args = process.argv.slice(2);

    if (args.length === 0 || args.includes('--help')) {
        console.log(`
AAR Schema Migration Tool

Usage:
  node scripts/migrate_aar.js <files...> --to <version> [options]

Arguments:
  <files...>      File paths or glob patterns (e.g., docs/AAR/data/*.json)

Options:
  --to <version>  Target schema version (e.g., 1.1.0)
  --dry-run       Preview changes without modifying files
  --rollback      Restore files from backups
  --help          Show this help message

Examples:
  # Migrate single file
  node scripts/migrate_aar.js docs/AAR/data/example.aar.json --to 1.1.0

  # Migrate all AAR files
  node scripts/migrate_aar.js "docs/AAR/data/*.aar.json" --to 1.1.0

  # Preview migration
  node scripts/migrate_aar.js "docs/AAR/data/*.aar.json" --to 1.1.0 --dry-run

  # Rollback changes
  node scripts/migrate_aar.js "docs/AAR/data/*.aar.json" --rollback
        `);
        process.exit(0);
    }

    const toIndex = args.indexOf('--to');
    const targetVersion = toIndex !== -1 ? args[toIndex + 1] : null;
    const dryRun = args.includes('--dry-run');
    const rollback = args.includes('--rollback');

    const filePatterns = args.filter(arg =>
        !arg.startsWith('--') &&
        arg !== targetVersion
    );

    if (!rollback && !targetVersion) {
        console.error('Error: --to <version> is required for migration');
        process.exit(1);
    }

    if (filePatterns.length === 0) {
        console.error('Error: No file patterns specified');
        process.exit(1);
    }

    const migrator = new AARMigrator();
    migrator.migrateFiles(filePatterns, targetVersion, { dryRun, rollback })
        .then(results => {
            if (results && results.failed > 0) {
                process.exit(1);
            }
        })
        .catch(error => {
            console.error('Migration failed:', error.message);
            process.exit(1);
        });
}

module.exports = AARMigrator;
