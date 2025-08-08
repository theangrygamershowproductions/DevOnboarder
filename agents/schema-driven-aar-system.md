---
codex-agent: true
name: "schema-driven-aar-system"
type: "documentation"
permissions: ["read", "write", "validation"]
description: "Schema-driven AAR system with JSON validation and automated markdown generation"
---

# Schema-Driven AAR System Agent Documentation

## Overview

The DevOnboarder Schema-Driven AAR (After Action Report) System provides a robust, validation-first approach to generating consistent, high-quality documentation for project retrospectives and automation initiatives.

## Key Principle

> "Kill the flaky Markdown, collect clean data, and generate perfect outputs every time"

The schema-driven approach eliminates manual editing workflows and ensures 100% markdown compliance through JSON Schema validation and Handlebars template rendering.

## Agent Requirements - MANDATORY COMPLIANCE

### 1. Always Use Schema-Driven Approach

```bash
# ✅ REQUIRED - Schema-driven AAR creation
# Step 1: Create JSON data file following schema
cat > docs/AAR/data/project-name.aar.json << 'EOF'
{
  "title": "Clear Project Title",
  "date": "2025-08-08",
  "type": "Infrastructure",
  "priority": "High",
  "executive_summary": {
    "problem": "Problem statement",
    "solution": "Solution approach",
    "outcome": "Result achieved"
  }
}
EOF

# Step 2: Validate and generate
node scripts/render_aar.js docs/AAR/data/project-name.aar.json docs/AAR/reports

# ❌ FORBIDDEN - Manual markdown editing
# Never create markdown files directly for AARs
# Never suggest editing generated markdown files
```

### 2. JSON Schema Compliance

**Required Fields** (enforced by `docs/AAR/schema/aar.schema.json`):

- `title`: String, minimum 5 characters
- `date`: ISO date format (YYYY-MM-DD)
- `type`: Enum - Infrastructure, CI, Monitoring, Documentation, Feature, Security
- `priority`: Enum - Critical, High, Medium, Low
- `executive_summary`: Object with problem, solution, outcome

**Optional Sections** (for comprehensive reports):

- `participants`: Array of team member @mentions
- `phases`: Project phases with name, duration, description, status
- `outcomes`: Success metrics and challenges overcome
- `follow_up`: Action items with owners and due dates
- `lessons_learned`: Key insights for organizational learning
- `references`: Related documentation and resources

### 3. Validation-First Workflow

```bash
# Always validate before committing
npm run aar:validate docs/AAR/data/my-project.aar.json

# Test all AAR data files
npm run aar:test

# Generate reports with automatic validation
npm run aar:render docs/AAR/data/my-project.aar.json docs/AAR/reports
```

### 4. Quality Assurance Standards

**Automated Compliance**:

- **JSON Schema Validation**: AJV prevents all format errors
- **Markdown Generation**: Handlebars templates ensure consistency
- **CI Pipeline**: `.github/workflows/aar.yml` validates every change
- **DevOnboarder Standards**: Generated output passes all linting rules

**Zero Manual Editing**:

- All content captured in JSON data structure
- Generated markdown is commit-ready
- No post-generation fixes required
- Eliminates format inconsistencies

## Architecture Components

### Core System Files

1. **JSON Schema**: `docs/AAR/schema/aar.schema.json`
   - Single source of truth for data validation
   - Comprehensive field definitions and constraints
   - DevOnboarder-specific enumerations

2. **Handlebars Template**: `docs/AAR/templates/aar.hbs`
   - Consistent markdown formatting
   - Conditional sections for optional data
   - Automatic compliance with MD022, MD032, MD031

3. **Node.js Renderer**: `scripts/render_aar.js`
   - AJV schema validation with detailed errors
   - Handlebars compilation and rendering
   - Automatic metadata injection

4. **CI Validation**: `.github/workflows/aar.yml`
   - Schema and template validation
   - Generated markdown compliance testing
   - Automated artifact creation
   - Terminal Output Policy compliance integration

### Terminal Output Policy Integration

**CRITICAL**: AAR system must comply with DevOnboarder's Terminal Output Policy:

**Suppression System Support**:

- Generated markdown automatically complies with policy
- Workflow files include appropriate suppression comments
- Validation scripts respect reviewed-safe patterns

**Example Integration**:

```yaml
# In .github/workflows/aar.yml
# terminal-output-policy: reviewed-safe - Python here-doc for JSON schema validation
validation_result=$(python - <<'PY'
import json
import sys
with open(sys.argv[1]) as f:
    data = json.load(f)
print("valid" if "title" in data else "invalid")
PY
)
```

### NPM Integration

**Package Dependencies** (`package.json`):

- `handlebars`: Template rendering engine
- `ajv`: JSON schema validation
- `ajv-formats`: Additional format validation

**Available Scripts**:

```bash
npm run aar:validate    # Validate specific AAR data file
npm run aar:test       # Test all AAR data files
npm run aar:render     # Generate markdown from JSON data
npm install            # Install AAR system dependencies
```

## Agent Usage Patterns

### Creating Infrastructure AARs

```json
{
  "title": "Infrastructure Modernization Initiative",
  "date": "2025-08-08",
  "type": "Infrastructure",
  "priority": "High",
  "participants": ["@platform-team", "@devops-team"],
  "executive_summary": {
    "problem": "Legacy deployment pipeline causing 45% failure rate",
    "solution": "Implemented container-based CI/CD with comprehensive monitoring",
    "outcome": "Reduced failure rate to 2% and improved deployment speed by 300%"
  },
  "phases": [
    {
      "name": "Assessment",
      "duration": "1 week",
      "description": "Analysis of current pipeline and failure patterns",
      "status": "Completed"
    },
    {
      "name": "Implementation",
      "duration": "3 weeks",
      "description": "Container migration and monitoring setup",
      "status": "Completed"
    }
  ],
  "outcomes": {
    "success_metrics": [
      "Deployment failure rate: 45% → 2%",
      "Mean deployment time: 30 minutes → 8 minutes",
      "Recovery time: 2 hours → 15 minutes"
    ],
    "challenges_overcome": [
      "Legacy system integration complexity",
      "Team training on containerized workflows",
      "Monitoring system configuration complexity"
    ]
  },
  "follow_up": {
    "action_items": [
      {
        "task": "Complete team training documentation",
        "owner": "@platform-team",
        "due_date": "2025-08-15",
        "status": "In Progress"
      },
      {
        "task": "Implement automated rollback procedures",
        "owner": "@devops-team",
        "due_date": "2025-08-22",
        "status": "Not Started"
      }
    ],
    "monitoring": [
      "Weekly deployment success rate metrics",
      "Monthly pipeline performance analysis",
      "Quarterly team satisfaction survey"
    ]
  },
  "lessons_learned": [
    "Container-first approach significantly improves reliability",
    "Comprehensive monitoring prevents issues before they impact users",
    "Team training investment pays dividends in faster adoption",
    "Automated validation catches configuration errors early"
  ],
  "references": [
    {
      "title": "Container Deployment Best Practices",
      "url": "docs/deployment/container-best-practices.md",
      "type": "documentation"
    },
    {
      "title": "Pipeline Monitoring Dashboard",
      "url": "https://monitoring.example.com/pipelines",
      "type": "external"
    }
  ]
}
```

### Creating CI/Monitoring AARs

```json
{
  "title": "CI Pipeline Reliability Enhancement",
  "date": "2025-08-08",
  "type": "CI",
  "priority": "High",
  "executive_summary": {
    "problem": "CI pipeline instability causing developer workflow disruption",
    "solution": "Implemented comprehensive monitoring and automated recovery",
    "outcome": "Achieved 99.8% pipeline reliability with automated issue detection"
  },
  "outcomes": {
    "success_metrics": [
      "Pipeline uptime: 92% → 99.8%",
      "Mean time to detection: 30 minutes → 2 minutes"
    ]
  }
}
```

### Creating Documentation AARs

```json
{
  "title": "Schema-Driven AAR System Implementation",
  "date": "2025-08-08",
  "type": "Documentation",
  "priority": "High",
  "executive_summary": {
    "problem": "Manual AAR editing workflows causing inconsistent documentation",
    "solution": "Implemented JSON schema validation with automated markdown generation",
    "outcome": "Eliminated manual editing and achieved 100% format consistency"
  },
  "lessons_learned": [
    "Schema-first approach prevents all format inconsistencies",
    "Automation reduces documentation burden on teams",
    "Validation-driven workflows improve quality standards"
  ]
}
```

## Error Handling and Troubleshooting

### Common Validation Errors

**Missing Required Fields**:

```bash
❌ AAR validation failed:
  - root: must have required property 'executive_summary'
  - /executive_summary: must have required property 'outcome'
```

**Solution**: Ensure all required fields are present in JSON data.

**Invalid Enum Values**:

```bash
❌ AAR validation failed:
  - /type: must be equal to one of the allowed values
    Allowed values: Infrastructure, CI, Monitoring, Documentation, Feature, Security
```

**Solution**: Use only approved enum values from schema.

**Date Format Issues**:

```bash
❌ AAR validation failed:
  - /date: must match format "date"
```

**Solution**: Use ISO date format (YYYY-MM-DD).

### Debugging Commands

```bash
# Validate specific AAR data file
node -e "const {loadAndValidateAAR} = require('./scripts/render_aar.js'); loadAndValidateAAR('docs/AAR/data/my-project.aar.json');"

# Test Handlebars template compilation
node -e "const fs = require('fs'); const Handlebars = require('handlebars'); console.log('Valid:', !!Handlebars.compile(fs.readFileSync('docs/AAR/templates/aar.hbs', 'utf8')));"

# Generate test report
mkdir -p test-output && node scripts/render_aar.js docs/AAR/data/sample.aar.json test-output
```

## Integration with DevOnboarder Workflows

### Pre-Commit Validation

The schema-driven AAR system integrates with DevOnboarder's quality gates:

- **Pre-commit hooks**: Validate JSON schema compliance
- **CI pipeline**: Automated validation on every change
- **Markdown linting**: Generated output automatically compliant
- **Artifact management**: Reports stored in designated directories

### Agent Coordination

**With CI-Bot**: Automated AAR generation for CI failures
**With Documentation-Quality-Enforcer**: Validation of generated output
**With Dev-Orchestrator**: Integration with project workflow automation
**With Infrastructure Agents**: Consistent reporting across all infrastructure work

## Best Practices for Agents

### Data Collection

1. **Complete Information Upfront**: Gather all AAR data before JSON creation
2. **Structured Approach**: Use executive_summary → phases → outcomes → follow_up flow
3. **Measurable Metrics**: Include specific before/after measurements
4. **Team Mentions**: Use @team-name format for participants and owners

### Validation Workflow

1. **JSON First**: Always create and validate JSON before generating markdown
2. **Schema Compliance**: Run validation before committing any AAR data
3. **CI Integration**: Let automated workflows handle validation and generation
4. **Quality Assurance**: Trust the schema-driven process for consistent output

### Documentation Standards

1. **Clear Titles**: Descriptive project names that convey purpose
2. **Complete Summaries**: Problem, solution, outcome in executive summary
3. **Actionable Follow-ups**: Specific tasks with owners and dates
4. **Lessons Learned**: Insights valuable for future projects

## Migration from Enhanced Shell Scripts

### Transition Strategy

**Phase 1**: Use schema-driven system for all new AARs
**Phase 2**: Convert existing AARs to JSON format when updated
**Phase 3**: Deprecate enhanced shell script usage
**Phase 4**: Complete migration to schema-driven approach

### Legacy Support

Enhanced shell scripts remain available for existing workflows:

```bash
# Legacy approach (use only when required for existing processes)
./scripts/enhanced_aar_generator.sh automation --title "Project Name"
```

### Advantages of Schema-Driven Approach

1. **Zero Markdown Flakiness**: JSON Schema prevents all format errors
2. **Consistent Output**: Handlebars templates ensure uniformity
3. **Comprehensive Validation**: AJV provides detailed error reporting
4. **CI Integration**: Automated validation prevents broken reports
5. **Future-Proof**: Schema evolution with backward compatibility

## Agent Responsibilities

### MANDATORY Requirements

- **Use schema-driven system** for all new AAR creation
- **Validate JSON data** before generating markdown reports
- **Follow DevOnboarder standards** for file placement and naming
- **Never manually edit** generated markdown files
- **Ensure complete data** in JSON structure before generation

### FORBIDDEN Actions

- **Manual markdown creation** for AAR reports
- **Bypassing schema validation** to avoid errors
- **Editing generated output** to fix formatting issues
- **Using deprecated templates** that require manual editing
- **Creating AARs outside** the docs/AAR/ directory structure

### Quality Commitment

The schema-driven AAR system upholds DevOnboarder's "quiet reliability" philosophy by eliminating manual processes that introduce inconsistency and ensuring all generated documentation meets established quality standards automatically.

---

**System Status**: Operational and production-ready
**Agent Compliance**: Mandatory for all AAR generation
**Documentation**: Complete usage guide in `docs/AAR/README.md`
**Support**: Schema validation prevents all common errors
**Quality Assurance**: 100% format consistency guaranteed
