#!/usr/bin/env node
/**
 * AAR Renderer - JSON to Markdown generator for DevOnboarder
 *
 * Validates AAR data against JSON schema and generates markdown reports
 * using Handlebars templates for consistent output with security and provenance.
 */

const fs = require("fs");
const path = require("path");
const Handlebars = require("handlebars");
const Ajv = require("ajv");
const addFormats = require("ajv-formats");
const { exec } = require("child_process");

// Initialize AJV with format validation
const ajv = new Ajv({allErrors: true});
addFormats(ajv);

/**
 * Get current git SHA for provenance tracking
 * @returns {string} Git SHA or 'unknown'
 */
function getGitSHA() {
    try {
        return require('child_process').execSync('git rev-parse HEAD', { encoding: 'utf8' }).trim();
    } catch (error) {
        return 'unknown';
    }
}

/**
 * Sanitize URLs for security
 * @param {string} url - URL to validate
 * @returns {string} Sanitized URL or empty string if invalid
 */
function sanitizeURL(url) {
    if (!url || typeof url !== 'string') return '';

    // Allow only specific domains for security
    const allowedDomains = [
        'github.com',
        'docs.google.com',
        'grafana.company.com',
        'docs.company.com',
        /^[a-z0-9-]+\.devonboarder\.io$/
    ];

    try {
        const urlObj = new URL(url);
        const isAllowed = allowedDomains.some(domain => {
            if (typeof domain === 'string') {
                return urlObj.hostname === domain;
            } else {
                return domain.test(urlObj.hostname);
            }
        });

        return isAllowed ? url : '';
    } catch (error) {
        return '';
    }
}

/**
 * Get proper directory structure for AAR based on date and type
 * @param {Object} aarData - AAR data object
 * @param {string} baseOutputDir - Base output directory
 * @returns {string} Structured directory path
 */
function getStructuredOutputDir(aarData, baseOutputDir) {
    const date = new Date(aarData.date);
    const year = date.getFullYear();

    // Determine quarter from date
    const month = date.getMonth() + 1; // getMonth() returns 0-11
    const quarter = Math.ceil(month / 3);

    // Get type from AAR data (lowercase for directory name)
    const type = aarData.type.toLowerCase();

    // Create structured path: docs/AAR/reports/2025/Q3/infrastructure/
    return path.join(baseOutputDir, year.toString(), `Q${quarter}`, type);
}

/**
 * Sanitize HTML content in text fields
 * @param {string} text - Text content to sanitize
 * @returns {string} Sanitized text
 */
function sanitizeText(text) {
    if (!text || typeof text !== 'string') return '';

    // Basic HTML entity encoding
    return text
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;');
}

/**
 * Format validation errors for human readability
 * @param {Array} ajvErrors - AJV validation errors
 * @returns {Array} Formatted error objects
 */
function formatValidationErrors(ajvErrors) {
    return ajvErrors.map(error => {
        const suggestions = {
            'required': `Add the required field: ${error.params?.missingProperty}`,
            'minLength': `Provide at least ${error.params?.limit} characters`,
            'enum': `Use one of: ${error.params?.allowedValues?.join(', ')}`,
            'format': `Use the correct format (e.g., YYYY-MM-DD for dates)`,
            'const': `Value must be exactly: ${error.params?.allowedValue}`
        };

        return {
            field: error.instancePath?.substring(1) || 'root',
            rule: error.keyword,
            message: error.message,
            suggestion: suggestions[error.keyword] || 'Check the field value and format'
        };
    });
}

/**
 * Load and validate AAR data against schema
 * @param {string} dataPath - Path to AAR JSON data file
 * @returns {object} Validated AAR data
 */
function loadAndValidateAAR(dataPath) {
    console.log(`Loading AAR data from: ${dataPath}`);

    // Load schema
    const schemaPath = path.join(__dirname, "../docs/AAR/schema/aar.schema.json");
    const schema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
    const validate = ajv.compile(schema);

    // Load and validate data
    const data = JSON.parse(fs.readFileSync(dataPath, "utf8"));

    // Add provenance metadata
    if (!data.metadata) {
        data.metadata = {};
    }
    data.metadata.schema_version = schema.version || "1.0.0";
    data.metadata.generated_by = "DevOnboarder AAR System";
    data.metadata.created_at = new Date().toISOString();
    data.metadata.git_sha = getGitSHA();
    data.metadata.renderer_version = "1.0.0";

    // Security: Sanitize URLs and text content
    if (data.references) {
        data.references = data.references.map(ref => ({
            ...ref,
            url: sanitizeURL(ref.url),
            title: sanitizeText(ref.title)
        })).filter(ref => ref.url); // Remove invalid URLs
    }

    // Sanitize text fields
    if (data.executive_summary) {
        Object.keys(data.executive_summary).forEach(key => {
            data.executive_summary[key] = sanitizeText(data.executive_summary[key]);
        });
    }

    if (!validate(data)) {
        console.error("❌ AAR validation failed:");
        const formattedErrors = formatValidationErrors(validate.errors);
        formattedErrors.forEach(error => {
            console.error(`  Field: ${error.field}`);
            console.error(`  Rule: ${error.rule}`);
            console.error(`  Message: ${error.message}`);
            console.error(`  Suggestion: ${error.suggestion}`);
            console.error('');
        });
        process.exit(1);
    }

    console.log("✅ AAR data validation successful");
    return data;
}

/**
 * Generate markdown report from AAR data
 * @param {object} data - Validated AAR data
 * @param {string} outputDir - Output directory for generated reports
 * @returns {string} Path to generated markdown file
 */
function generateMarkdown(data, outputDir) {
    console.log("Generating markdown report...");

    // Load template
    const templatePath = path.join(__dirname, "../docs/AAR/templates/aar.hbs");
    const template = fs.readFileSync(templatePath, "utf8");
    const compiledTemplate = Handlebars.compile(template);

    // Generate markdown
    const markdown = compiledTemplate(data);

    // Create output filename (without date prefix since directory structure provides chronology)
    const sanitizedTitle = data.title
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');
    const filename = `${sanitizedTitle}.md`;

    // Get structured output directory (year/quarter/type)
    const structuredOutputDir = getStructuredOutputDir(data, outputDir);
    const outputPath = path.join(structuredOutputDir, filename);

    // Ensure structured output directory exists
    if (!fs.existsSync(structuredOutputDir)) {
        fs.mkdirSync(structuredOutputDir, { recursive: true });
    }

    // Write markdown file
    fs.writeFileSync(outputPath, markdown);

    console.log(`✅ Markdown report generated: ${outputPath}`);
    return outputPath;
}

/**
 * Generate summary report for all AARs
 * @param {string} reportsDir - Directory containing AAR reports
 */
function generateSummary(reportsDir) {
    console.log("Generating AAR summary...");

    if (!fs.existsSync(reportsDir)) {
        console.log("No reports directory found, skipping summary generation");
        return;
    }

    const reports = fs.readdirSync(reportsDir)
        .filter(file => file.endsWith('.md') && !file.startsWith('_'))
        .sort()
        .reverse(); // Most recent first

    let summary = `# DevOnboarder AAR Reports\n\n`;
    summary += `Generated: ${new Date().toISOString()}\n\n`;
    summary += `## Reports (${reports.length} total)\n\n`;

    reports.forEach(report => {
        const reportPath = path.join(reportsDir, report);
        const content = fs.readFileSync(reportPath, 'utf8');
        const titleMatch = content.match(/^# (.+)$/m);
        const dateMatch = content.match(/\*\*Date:\*\* (.+)$/m);
        const typeMatch = content.match(/\*\*Type:\*\* (.+)$/m);

        const title = titleMatch ? titleMatch[1] : report;
        const date = dateMatch ? dateMatch[1] : 'Unknown';
        const type = typeMatch ? typeMatch[1] : 'Unknown';

        summary += `- [${title}](${report}) - ${type} (${date})\n`;
    });

    const summaryPath = path.join(reportsDir, '_index.md');
    fs.writeFileSync(summaryPath, summary);

    console.log(`✅ Summary generated: ${summaryPath}`);
}

/**
 * Main execution function
 */
function main() {
    const args = process.argv.slice(2);

    if (args.length === 0) {
        console.error("Usage: node render_aar.js <aar-data.json> [output-dir]");
        console.error("Example: node render_aar.js docs/AAR/data/my-project.aar.json docs/AAR/reports");
        process.exit(1);
    }

    const dataPath = args[0];
    const outputDir = args[1] || path.join(__dirname, "../docs/AAR/reports");

    try {
        // Validate and load AAR data
        const data = loadAndValidateAAR(dataPath);

        // Generate markdown report
        const markdownPath = generateMarkdown(data, outputDir);

        // Generate summary index
        generateSummary(outputDir);

        console.log(`\n🎉 AAR processing complete!`);
        console.log(`📄 Report: ${markdownPath}`);
        console.log(`📋 Summary: ${path.join(outputDir, '_index.md')}`);

    } catch (error) {
        console.error(`❌ Error processing AAR: ${error.message}`);
        process.exit(1);
    }
}

// Run if called directly
if (require.main === module) {
    main();
}

module.exports = {
    loadAndValidateAAR,
    generateMarkdown,
    generateSummary
};
