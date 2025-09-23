---
similarity_group: templates-templates
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# DevOnboarder Automation Framework

This directory contains templates and documentation for creating new automated workflows with unified GPG signing in DevOnboarder.

## Quick Start

1. **Copy workflow template**: Use `gpg-automation-workflow.yml` as starting point
2. **Generate GPG key**: Customize and run the setup script template
3. **Configure GitHub**: Add required secrets and variables
4. **Deploy workflow**: Test and deploy your automation

## Templates

### Workflow Template

- **File**: `gpg-automation-workflow.yml`
- **Purpose**: Complete GitHub Actions workflow template with GPG signing
- **Usage**: Copy, customize placeholders, and deploy to `.github/workflows/`

### GPG Setup Script Template

- **File**: `setup_bot_gpg_key_template.sh`
- **Purpose**: Generate GPG keys and provide GitHub configuration instructions
- **Usage**: Copy to `scripts/`, customize bot details, and run

## Documentation

### Complete Guides

- **Adding Automated Workflows**: `../guides/adding-automated-workflows.md`

    - Step-by-step process for creating new automation

    - Best practices and naming conventions

    - Security and reliability guidelines

- **GPG Troubleshooting**: `../guides/gpg-troubleshooting.md`

    - Common issues and solutions

    - Diagnostic commands and validation

    - Advanced debugging techniques

### Architecture References

- **Token Architecture v2.1**: `../TOKEN_ARCHITECTURE_V2.1.md`

    - Token hierarchy and authentication patterns

    - Integration with GPG signing workflows

- **Signature Verification**: GitHub issue #1575

    - Migration from SSH to unified GPG approach

    - Implementation details and lessons learned

## Examples

### Working Implementation

Study the Priority Matrix Bot as a reference implementation:

- **Workflow**: `.github/workflows/priority-matrix-synthesis.yml`
- **Setup Script**: `scripts/setup_bot_gpg_key.sh`
- **GPG Key**: Successfully generated and configured (9BA7DCDBF5D4DEDD)

### Common Automation Types

**Documentation Enhancement**:

```yaml
on:
  push:
    branches: [main]
    paths: ['docs/**', '**.md']
```bash

**Code Quality Automation**:

```yaml
on:
  pull_request:
    types: [opened, synchronize]
    paths: ['src/**', 'tests/**']
```bash

**Scheduled Maintenance**:

```yaml
on:
  schedule:

    - cron: '0 2 * * 1'  # Weekly

```bash

## Implementation Checklist

### Pre-Development

- [ ] Define automation scope and triggers
- [ ] Review existing workflows for patterns
- [ ] Plan GPG key naming convention
- [ ] Consider security and permission requirements

### Development Phase

- [ ] Copy and customize workflow template
- [ ] Generate GPG key using setup script
- [ ] Configure GitHub secrets and variables
- [ ] Test locally before CI deployment

### Deployment Phase

- [ ] Deploy workflow to test branch
- [ ] Validate GPG signatures work
- [ ] Monitor for any policy violations
- [ ] Update documentation as needed

### Post-Deployment

- [ ] Monitor workflow runs for failures
- [ ] Verify commits show as verified on GitHub
- [ ] Document any lessons learned
- [ ] Plan for key rotation and maintenance

## Standards Compliance

All automation must comply with DevOnboarder standards:

### Required Compliance

- **Terminal Output Policy**: No emojis, Unicode, or multi-line echo statements
- **Centralized Logging**: Use `logs/` directory for output files
- **Quality Gates**: Pass pre-commit hooks and QC validation
- **Potato Policy**: Respect sensitive file protection patterns
- **Token Architecture**: Use established authentication hierarchy

### Quality Validation

```bash

# Validate your workflow before deployment

scripts/qc_pre_push.sh

# Check for terminal output violations

scripts/validate_terminal_output.sh

# Verify markdown compliance

markdownlint docs/
```bash

## Support and Troubleshooting

### Common Issues

- GPG signing failures → See GPG troubleshooting guide
- Permission errors → Verify token hierarchy in workflow
- Signature verification → Check public key upload to GitHub
- Workflow not triggering → Review trigger conditions and paths

### Getting Help

1. Review working implementations in `.github/workflows/`
2. Check comprehensive guides in `docs/guides/`
3. Use validation tools: `scripts/qc_pre_push.sh`
4. Create issues for bugs or enhancement requests

### Validation Tools

```bash

# Test GPG key generation

bash scripts/setup_bot_gpg_key.sh

# Validate workflow syntax

gh workflow list

# Check git signing configuration

git config --list | grep -E "(user\.|gpg\.|commit\.)"
```bash

## Migration from SSH

If upgrading existing SSH-based automation:

1. **Audit current workflows**: Identify SSH signing usage
2. **Generate GPG keys**: Use setup script for each bot
3. **Update workflows**: Replace SSH setup with GPG template
4. **Test thoroughly**: Validate signature verification works
5. **Deprecate SSH**: Mark old workflows as deprecated
6. **Update documentation**: Reference new GPG processes

## Version History

- **v1.0** (September 2025): Initial unified GPG framework
  - Priority Matrix Bot converted from SSH to GPG
  - Comprehensive templates and documentation created
  - Legacy SSH references cleaned up
  - GitHub issue #1575 tracks implementation

---

**Last Updated**: September 22, 2025
**Framework Version**: 1.0
**Status**: Production Ready
