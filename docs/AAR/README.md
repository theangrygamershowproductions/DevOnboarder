# Schema-Driven AAR System

The DevOnboarder Schema-Driven AAR (After Action Report) System provides a robust, validation-driven approach to generating consistent, high-quality documentation for project retrospectives and automation initiatives.

## Architecture Overview

### Core Components

1. **JSON Schema Validation** (`docs/AAR/schema/aar.schema.json`)
   - Single source of truth for AAR data structure
   - Comprehensive validation rules
   - DevOnboarder-specific properties and enumerations

2. **Handlebars Templates** (`docs/AAR/templates/aar.hbs`)
   - Consistent markdown generation
   - Conditional sections based on data availability
   - Proper formatting and compliance with DevOnboarder standards

3. **Node.js Renderer** (`scripts/render_aar.js`)
   - AJV schema validation
   - Handlebars compilation and rendering
   - Automatic metadata injection

4. **CI/CD Pipeline** (`.github/workflows/aar.yml`)
   - Automated validation on every change
   - Schema and template validation
   - Generated markdown compliance testing

### Workflow

```text
JSON Data → Schema Validation → Template Rendering → Markdown Output
     ↓              ↓                    ↓              ↓
  aar.json    aar.schema.json       aar.hbs        report.md
```

## Usage Guide

### 1. Creating AAR Data

Create a JSON file in `docs/AAR/data/` following the schema:

```json
{
  "title": "Infrastructure Initiative Success",
  "date": "2025-01-08",
  "type": "Infrastructure",
  "priority": "High",
  "participants": ["@devops-team", "@platform-team"],
  "executive_summary": {
    "problem": "Legacy deployment pipeline reliability issues",
    "solution": "Implemented container-based CI/CD with comprehensive monitoring",
    "outcome": "95% reduction in deployment failures"
  },
  "phases": [
    {
      "name": "Assessment",
      "duration": "1 week",
      "description": "Analyzed current pipeline failure patterns",
      "status": "Completed"
    }
  ],
  "outcomes": {
    "success_metrics": [
      "Deployment failure rate: 45% → 2%",
      "Mean time to recovery: 2 hours → 15 minutes"
    ],
    "challenges_overcome": [
      "Legacy system integration complexity",
      "Team training on new tooling"
    ]
  },
  "follow_up": {
    "action_items": [
      {
        "task": "Document new deployment procedures",
        "owner": "@platform-team",
        "due_date": "2025-01-15",
        "status": "In Progress"
      }
    ]
  }
}
```

### 2. Generating Reports

#### Command Line Usage

```bash
# Render single AAR
node scripts/render_aar.js docs/AAR/data/my-project.aar.json

# Render to specific directory
node scripts/render_aar.js docs/AAR/data/my-project.aar.json docs/AAR/reports

# Validate without rendering
npm run aar:validate docs/AAR/data/my-project.aar.json
```

#### NPM Scripts

```bash
# Install AAR system dependencies
npm run aar:install

# Test all AAR data files
npm run aar:test

# Render specific file
npm run aar:render docs/AAR/data/my-project.aar.json
```

### 3. Validation Features

The system provides comprehensive validation:

- **Schema Compliance**: All required fields present and correctly typed
- **Enumeration Validation**: Type, priority, and status values from approved lists
- **Date Format Validation**: ISO 8601 date formats
- **Markdown Generation**: Output automatically complies with DevOnboarder linting rules

### 4. CI/CD Integration

The GitHub Actions workflow (`.github/workflows/aar.yml`) automatically:

- Validates JSON schema on changes
- Tests Handlebars template compilation
- Validates all AAR data files
- Generates and validates markdown output
- Creates artifacts for review

## Schema Reference

### Required Fields

- `title`: Project or initiative name
- `date`: Report date (YYYY-MM-DD format)
- `type`: One of: Infrastructure, CI, Monitoring, Documentation, Feature, Security
- `priority`: One of: High, Medium, Low, Critical
- `executive_summary`: Object with problem, solution, outcome

### Optional Sections

- `participants`: Array of team members or stakeholders
- `phases`: Array of project phases with status tracking
- `outcomes`: Success metrics and challenges overcome
- `follow_up`: Action items with owners and due dates
- `references`: Links to related documentation or issues
- `lessons_learned`: Key insights for future projects

### DevOnboarder-Specific Features

- **Phase Enumeration**: Predefined phases (Planning, Implementation, Testing, Deployment, Monitoring)
- **Status Tracking**: Standard status values (Not Started, In Progress, Completed, Blocked, Cancelled)
- **Team Integration**: Support for GitHub-style @mentions and team references
- **Metadata Injection**: Automatic schema version and generation timestamps

## Quality Assurance

### Automated Validation

1. **Schema Validation**: AJV ensures data compliance
2. **Template Validation**: Handlebars compilation testing
3. **Markdown Compliance**: Generated output passes markdownlint
4. **CI Pipeline**: Continuous validation on every change

### Quality Standards

- **Zero Manual Editing**: Generated reports are commit-ready
- **Consistent Formatting**: Handlebars templates ensure uniformity
- **DevOnboarder Compliance**: Follows project markdown standards
- **Validation-Driven**: No output without successful validation

## Migration from Enhanced Shell Scripts

### Advantages of Schema-Driven Approach

1. **Elimination of Markdown Flakiness**: JSON Schema validation prevents format errors
2. **Consistent Output**: Handlebars templates ensure uniform formatting
3. **Comprehensive Validation**: AJV provides detailed error reporting
4. **CI Integration**: Automated validation prevents broken reports
5. **Future-Proof**: Schema evolution with backward compatibility

### Transition Guide

1. **Existing AARs**: Continue using enhanced shell script until schema system is fully operational
2. **New AARs**: Use schema-driven system for all new reports
3. **Migration**: Convert existing AARs to JSON format using schema
4. **Validation**: All output automatically validated and compliant

## Development Guidelines

### Adding New Fields

1. Update `docs/AAR/schema/aar.schema.json`
2. Modify `docs/AAR/templates/aar.hbs` template
3. Test with sample data
4. Update documentation

### Template Modifications

1. Use Handlebars conditionals for optional sections
2. Maintain markdown compliance (MD022, MD032, MD031)
3. Test rendering with various data combinations
4. Validate generated output

### CI/CD Enhancements

1. Add new validation steps to `.github/workflows/aar.yml`
2. Test with comprehensive data sets
3. Ensure artifact generation for review
4. Maintain backward compatibility

## Best Practices

### Data Creation

- **Complete Data**: Provide all available information upfront
- **Consistent Naming**: Use standard team and project names
- **Proper Dates**: Use ISO 8601 format (YYYY-MM-DD)
- **Descriptive Content**: Clear problem statements and outcomes

### Validation

- **Test Early**: Validate data before committing
- **Use CI**: Rely on automated validation in pipeline
- **Review Output**: Check generated markdown for completeness
- **Update Schema**: Evolve schema for new requirements

### Maintenance

- **Schema Versioning**: Track schema changes with version numbers
- **Template Updates**: Maintain consistency across all templates
- **Documentation**: Keep usage guide current with features
- **Testing**: Comprehensive validation of all components

## Troubleshooting

### Common Issues

1. **Schema Validation Errors**
   - Check required fields are present
   - Verify enum values match allowed options
   - Ensure date formats are correct

2. **Template Rendering Errors**
   - Validate Handlebars syntax
   - Check for missing template variables
   - Test with minimal data set

3. **CI Pipeline Failures**
   - Review workflow logs for specific errors
   - Test locally before pushing changes
   - Ensure all dependencies are installed

### Debugging Commands

```bash
# Validate specific AAR data
node -e "const {loadAndValidateAAR} = require('./scripts/render_aar.js'); loadAndValidateAAR('path/to/file.aar.json');"

# Test template compilation
node -e "const fs = require('fs'); const Handlebars = require('handlebars'); console.log('Valid:', !!Handlebars.compile(fs.readFileSync('docs/AAR/templates/aar.hbs', 'utf8')));"

# Generate test report
mkdir -p test-output && node scripts/render_aar.js docs/AAR/data/sample.aar.json test-output
```

## Future Enhancements

### Planned Features

1. **React Form Interface**: Web-based AAR creation with real-time validation
2. **Multiple Output Formats**: PDF, HTML, and other formats
3. **Template Library**: Specialized templates for different project types
4. **Integration APIs**: Programmatic AAR generation from CI systems

### Extensibility

The schema-driven architecture supports:

- **Custom Fields**: Project-specific data requirements
- **Multiple Templates**: Different output formats and styles
- **Validation Rules**: Enhanced business logic validation
- **Workflow Integration**: Automated AAR generation from project milestones

---

**System Status**: Operational and ready for production use

**Quality Assurance**: All components validated and tested

**Documentation**: Complete usage guide and reference materials

**DevOnboarder Compliance**: Follows all project standards and best practices
