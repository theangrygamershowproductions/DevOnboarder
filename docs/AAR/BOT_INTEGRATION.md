# Bot Integration: Schema-Driven AAR System

This document provides specific guidance for Discord bots and automated systems integrating with the DevOnboarder Schema-Driven AAR System.

## Bot Commands and Integration

### Discord Bot Commands

The DevOnboarder Discord bot can integrate with the schema-driven AAR system for automated report generation:

```typescript
// Example Discord bot command for AAR generation
import { SlashCommandBuilder, ChatInputCommandInteraction } from 'discord.js';

export const command = {
    data: new SlashCommandBuilder()
        .setName('generate-aar')
        .setDescription('Generate an After Action Report using schema-driven system')
        .addStringOption(option =>
            option.setName('title')
                .setDescription('AAR title')
                .setRequired(true))
        .addStringOption(option =>
            option.setName('type')
                .setDescription('AAR type')
                .setRequired(true)
                .addChoices(
                    { name: 'Infrastructure', value: 'Infrastructure' },
                    { name: 'CI', value: 'CI' },
                    { name: 'Monitoring', value: 'Monitoring' },
                    { name: 'Documentation', value: 'Documentation' },
                    { name: 'Feature', value: 'Feature' },
                    { name: 'Security', value: 'Security' }
                ))
        .addStringOption(option =>
            option.setName('priority')
                .setDescription('AAR priority')
                .setRequired(true)
                .addChoices(
                    { name: 'Critical', value: 'Critical' },
                    { name: 'High', value: 'High' },
                    { name: 'Medium', value: 'Medium' },
                    { name: 'Low', value: 'Low' }
                )),

    async execute(interaction: ChatInputCommandInteraction) {
        const title = interaction.options.getString('title', true);
        const type = interaction.options.getString('type', true);
        const priority = interaction.options.getString('priority', true);

        // Generate AAR JSON data structure
        const aarData = {
            title,
            date: new Date().toISOString().split('T')[0],
            type,
            priority,
            executive_summary: {
                problem: "Generated via Discord bot command",
                solution: "Automated AAR creation workflow",
                outcome: "Structured report generated for team review"
            },
            participants: [`@${interaction.user.username}`]
        };

        // Create filename from title
        const filename = title.toLowerCase()
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/^-+|-+$/g, '');

        await interaction.reply({
            content: `Creating AAR: ${title}`,
            ephemeral: true
        });

        // Bot would execute the schema-driven AAR generation
        // Implementation would call the Node.js renderer via subprocess
    }
};
```

### Automated AAR Triggers

Bots can automatically generate AARs for specific events:

#### CI Failure AARs

```typescript
// Automated AAR generation for CI failures
async function generateCIFailureAAR(workflowId: string, failureData: any) {
    const aarData = {
        title: `CI Pipeline Failure - ${failureData.workflow_name}`,
        date: new Date().toISOString().split('T')[0],
        type: "CI",
        priority: "High",
        executive_summary: {
            problem: `CI pipeline failed at ${failureData.failed_step}`,
            solution: "Automated failure analysis and remediation recommendations",
            outcome: "Issue documented for team investigation"
        },
        phases: [
            {
                name: "Failure Detection",
                description: "Automated monitoring detected pipeline failure",
                status: "Completed"
            },
            {
                name: "Analysis",
                description: "Error log analysis and pattern recognition",
                status: "Completed"
            },
            {
                name: "Remediation",
                description: "Apply fixes and validate pipeline",
                status: "Not Started"
            }
        ],
        outcomes: {
            success_metrics: [
                `Failure detected: ${failureData.detection_time}`,
                `Alert sent: ${failureData.alert_time}`
            ],
            challenges_overcome: [
                "Automated detection prevented extended downtime",
                "Structured AAR enables systematic resolution"
            ]
        },
        follow_up: {
            action_items: [
                {
                    task: "Investigate root cause of pipeline failure",
                    owner: "@devops-team",
                    due_date: new Date(Date.now() + 24*60*60*1000).toISOString().split('T')[0],
                    status: "Not Started"
                }
            ]
        }
    };

    // Generate AAR using schema-driven system
    await generateSchemaAAR(aarData, `ci-failure-${workflowId}`);
}
```

#### Infrastructure Event AARs

```typescript
// Automated AAR for infrastructure events
async function generateInfrastructureAAR(eventType: string, eventData: any) {
    const aarData = {
        title: `Infrastructure Event - ${eventType}`,
        date: new Date().toISOString().split('T')[0],
        type: "Infrastructure",
        priority: eventData.severity || "Medium",
        executive_summary: {
            problem: eventData.problem_description,
            solution: eventData.solution_applied,
            outcome: eventData.resolution_status
        },
        participants: ["@infrastructure-team", "@monitoring-team"],
        outcomes: {
            success_metrics: eventData.metrics || [],
            challenges_overcome: eventData.challenges || []
        },
        lessons_learned: eventData.lessons || [
            "Automated detection and response improves MTTR",
            "Structured documentation enables knowledge transfer"
        ]
    };

    await generateSchemaAAR(aarData, `infrastructure-${eventType.toLowerCase()}`);
}
```

### Bot Helper Functions

```typescript
// Helper function to generate schema-driven AAR
async function generateSchemaAAR(aarData: any, filenameBase: string) {
    const fs = require('fs').promises;
    const { exec } = require('child_process');
    const path = require('path');

    // Validate required fields
    const requiredFields = ['title', 'date', 'type', 'priority', 'executive_summary'];
    for (const field of requiredFields) {
        if (!aarData[field]) {
            throw new Error(`Missing required field: ${field}`);
        }
    }

    // Create JSON file
    const filename = `${aarData.date}_${filenameBase}.aar.json`;
    const filepath = path.join('docs/AAR/data', filename);

    await fs.writeFile(filepath, JSON.stringify(aarData, null, 2));

    // Generate markdown using schema-driven system
    return new Promise((resolve, reject) => {
        exec(`node scripts/render_aar.js ${filepath} docs/AAR/reports`, (error, stdout, stderr) => {
            if (error) {
                reject(error);
            } else {
                resolve({
                    success: true,
                    jsonFile: filepath,
                    markdownFile: stdout.match(/Report: (.+\.md)/)?.[1],
                    summary: stdout.match(/Summary: (.+\.md)/)?.[1]
                });
            }
        });
    });
}

// Validation helper for enum values
function validateEnumValue(value: string, enumName: string, allowedValues: string[]) {
    if (!allowedValues.includes(value)) {
        throw new Error(`Invalid ${enumName}: ${value}. Allowed values: ${allowedValues.join(', ')}`);
    }
}

// AAR type validation
function validateAARType(type: string) {
    const allowedTypes = ['Infrastructure', 'CI', 'Monitoring', 'Documentation', 'Feature', 'Security'];
    validateEnumValue(type, 'type', allowedTypes);
}

// AAR priority validation
function validateAARPriority(priority: string) {
    const allowedPriorities = ['Critical', 'High', 'Medium', 'Low'];
    validateEnumValue(priority, 'priority', allowedPriorities);
}
```

### Bot Configuration

```typescript
// Bot configuration for AAR system integration
interface AAR SystemConfig {
    aarDataPath: string;
    aarReportsPath: string;
    rendererScript: string;
    autoGenerateOnFailures: boolean;
    notificationChannels: {
        aarGenerated: string;
        validationFailed: string;
        systemStatus: string;
    };
}

const aarConfig: AARSystemConfig = {
    aarDataPath: 'docs/AAR/data',
    aarReportsPath: 'docs/AAR/reports',
    rendererScript: 'scripts/render_aar.js',
    autoGenerateOnFailures: true,
    notificationChannels: {
        aarGenerated: process.env.AAR_NOTIFICATION_CHANNEL || 'general',
        validationFailed: process.env.AAR_ERROR_CHANNEL || 'dev-alerts',
        systemStatus: process.env.AAR_STATUS_CHANNEL || 'system-status'
    }
};
```

## Integration with DevOnboarder Services

### CI/CD Pipeline Integration

```yaml
# GitHub Actions integration with AAR system
- name: Generate AAR on Failure
  if: failure()
  run: |
    # Create AAR JSON data for CI failure
    cat > docs/AAR/data/ci-failure-$(date +%Y%m%d).aar.json << 'EOF'
    {
      "title": "CI Pipeline Failure - ${{ github.workflow }}",
      "date": "$(date +%Y-%m-%d)",
      "type": "CI",
      "priority": "High",
      "executive_summary": {
        "problem": "CI pipeline failed during ${{ github.job }}",
        "solution": "Automated failure detection and documentation",
        "outcome": "Failure documented for investigation"
      }
    }
    EOF

    # Generate AAR report
    node scripts/render_aar.js docs/AAR/data/ci-failure-$(date +%Y%m%d).aar.json docs/AAR/reports
```

### Monitoring System Integration

```typescript
// Integration with monitoring alerts
async function handleMonitoringAlert(alert: any) {
    if (alert.severity === 'critical' || alert.status === 'resolved') {
        const aarData = {
            title: `Monitoring Alert - ${alert.alertname}`,
            date: new Date().toISOString().split('T')[0],
            type: "Monitoring",
            priority: alert.severity === 'critical' ? 'Critical' : 'High',
            executive_summary: {
                problem: alert.description,
                solution: alert.resolution || "Alert monitoring and escalation",
                outcome: alert.status === 'resolved' ? "Issue resolved" : "Investigation in progress"
            },
            outcomes: {
                success_metrics: [
                    `Alert detection time: ${alert.startsAt}`,
                    alert.status === 'resolved' ? `Resolution time: ${alert.endsAt}` : ""
                ].filter(Boolean)
            }
        };

        await generateSchemaAAR(aarData, `monitoring-${alert.alertname.toLowerCase()}`);
    }
}
```

## Quality Assurance for Bots

### Validation Requirements

All bot-generated AARs must pass schema validation:

```typescript
// Bot validation workflow
async function validateBotAAR(aarData: any): Promise<boolean> {
    try {
        // Write temporary file
        const tempFile = '/tmp/bot-aar-validation.json';
        await fs.writeFile(tempFile, JSON.stringify(aarData, null, 2));

        // Validate using schema-driven system
        const { exec } = require('child_process');
        return new Promise((resolve) => {
            exec(`npm run aar:validate ${tempFile}`, (error) => {
                resolve(!error);
            });
        });
    } catch (error) {
        console.error('AAR validation failed:', error);
        return false;
    }
}
```

### Error Handling

```typescript
// Robust error handling for bot AAR generation
async function safeBotAARGeneration(aarData: any, filename: string) {
    try {
        // Validate before generation
        const isValid = await validateBotAAR(aarData);
        if (!isValid) {
            throw new Error('AAR data failed schema validation');
        }

        // Generate AAR
        const result = await generateSchemaAAR(aarData, filename);

        // Log success
        console.log(`AAR generated successfully: ${result.markdownFile}`);

        return result;
    } catch (error) {
        // Log error details
        console.error('Bot AAR generation failed:', error);

        // Create fallback minimal AAR
        const fallbackAAR = {
            title: "Bot AAR Generation Error",
            date: new Date().toISOString().split('T')[0],
            type: "Documentation",
            priority: "High",
            executive_summary: {
                problem: "Automated AAR generation encountered an error",
                solution: "Manual AAR creation required",
                outcome: "Error documented for investigation"
            },
            lessons_learned: [
                `Error details: ${error.message}`,
                "Bot AAR generation needs manual fallback procedures"
            ]
        };

        // Generate error AAR
        return await generateSchemaAAR(fallbackAAR, 'bot-error');
    }
}
```

## Best Practices for Bot Integration

### Data Collection

1. **Structured Data**: Always collect complete information before AAR generation
2. **Default Values**: Provide sensible defaults for optional fields
3. **Validation**: Validate all enum values before AAR creation
4. **Error Handling**: Include comprehensive error handling for all bot operations

### Automation Patterns

1. **Event-Driven**: Generate AARs automatically for significant events
2. **Threshold-Based**: Create AARs when metrics exceed defined thresholds
3. **Time-Based**: Generate periodic summary AARs for ongoing initiatives
4. **User-Triggered**: Allow manual AAR generation via bot commands

### Integration Guidelines

1. **Schema Compliance**: Always use the schema-driven AAR system
2. **File Management**: Follow DevOnboarder file placement standards
3. **Notifications**: Notify appropriate channels when AARs are generated
4. **Quality Assurance**: Validate all generated content before committing

### Performance Considerations

1. **Async Operations**: Use asynchronous functions for AAR generation
2. **Error Recovery**: Implement fallback mechanisms for failures
3. **Rate Limiting**: Prevent excessive AAR generation from automated systems
4. **Resource Management**: Clean up temporary files and resources

## Security and Permissions

### Bot Permissions

Required permissions for AAR system integration:

- **File System**: Read/write access to docs/AAR/ directory
- **Node.js Execution**: Ability to run schema validation and rendering scripts
- **Git Operations**: Commit and push generated AAR files
- **Discord Permissions**: Send messages and create embeds for notifications

### Data Security

1. **Sensitive Information**: Never include secrets or credentials in AAR data
2. **Access Control**: Restrict AAR generation to authorized bot roles
3. **Audit Logging**: Log all bot AAR operations for security review
4. **Validation**: Sanitize all user input before AAR generation

---

This integration guide ensures that all DevOnboarder bots and automated systems can leverage the schema-driven AAR system while maintaining quality standards and security requirements.
