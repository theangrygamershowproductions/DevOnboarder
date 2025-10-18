---
similarity_group: guides-guides
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# Adding New Automated Workflows with GPG Signing

This guide provides a standardized process for creating new automated workflows in DevOnboarder that use GPG signing for commit verification.

## Quick Start

1. **Use the template**: Copy `docs/templates/gpg-automation-workflow.yml`
2. **Generate GPG key**: Run the setup script for your bot
3. **Configure secrets**: Add required GitHub secrets and variables
4. **Customize workflow**: Update the template for your specific automation
5. **Test and deploy**: Validate the workflow works end-to-end

## Prerequisites

- Understanding of GitHub Actions workflows
- Access to repository secrets management
- GPG key generation capability
- DevOnboarder development environment setup

## Step-by-Step Process

### Step 1: Generate GPG Key for Your Bot

Create a setup script based on the existing pattern:

```bash

# Copy the existing setup script as a template

cp scripts/setup_bot_gpg_key.sh scripts/setup_YOUR_BOT_NAME_gpg_key.sh

# Edit the script with your bot's information

vim scripts/setup_YOUR_BOT_NAME_gpg_key.sh
```bash

Update these variables in your script:

```bash
BOT_NAME="Your Bot Name"
BOT_EMAIL="your-bot@theangrygamershow.com"
BOT_COMMENT="DevOnboarder Your Bot Description"
```bash

Run the script to generate your bot's GPG key:

```bash
bash scripts/setup_YOUR_BOT_NAME_gpg_key.sh
```bash

## Step 2: Configure GitHub Secrets and Variables

The script will output the required GitHub configuration. Add these to your repository:

**Required Secrets** (Repository Settings  Secrets and variables  Actions  Repository secrets):

- `{BOT_NAME}_GPG_PRIVATE`: Base64-encoded GPG private key
- Store this value from the script output

**Required Variables** (Repository Settings  Secrets and variables  Actions  Repository variables):

- `{BOT_NAME}_GPG_KEY_ID`: GPG key ID for signing
- `{BOT_NAME}_NAME`: Bot display name for git commits
- `{BOT_NAME}_EMAIL`: Bot email for git commits

### Step 3: Create Your Workflow

Copy and customize the template:

```bash

# Copy the template

cp docs/templates/gpg-automation-workflow.yml .github/workflows/your-automation.yml

# Customize the workflow

vim .github/workflows/your-automation.yml
```bash

## Required Customizations

1. **Replace placeholders**:

   - `{WORKFLOW_NAME}`  Your workflow's display name
   - `{BOT_NAME}`  Your bot name (UPPERCASE for secrets)
   - `{scope}`  Commit scope (docs, automation, etc.)
   - `{task_description}`  What your automation does
   - `{Bot_Name}`  Your bot's display name

2. **Configure triggers**:

   - Update `on:` section for your automation's trigger conditions
   - Adjust `paths:` filters for relevant file changes

3. **Implement automation logic**:

   - Replace the "Run automation task" step with your actual automation
   - Update file staging paths in the commit step
   - Customize commit message format

4. **Set permissions**:

   - Ensure workflow has necessary permissions (`contents: write`, `pull-requests: write`)

### Step 4: Test Your Workflow

## Local Testing

```bash

# Test GPG key setup locally

bash scripts/setup_YOUR_BOT_NAME_gpg_key.sh

# Test your automation script locally

python scripts/your_automation_script.py

# Verify git signing configuration

git config --list | grep -E "(user\.|gpg\.|commit\.)"
```bash

## CI Testing
1. Create a test branch: `git checkout -b test/your-automation`
2. Push your workflow: `git add .github/workflows/your-automation.yml && git commit -m "TEST: add new automation workflow"`
3. Monitor the workflow run in GitHub Actions
4. Verify GPG signatures appear in commit history

### Step 5: Deploy and Monitor

## Pre-deployment checklist

- [ ] GPG key generated and uploaded to GitHub
- [ ] All required secrets and variables configured
- [ ] Workflow triggers configured correctly
- [ ] Automation logic tested locally
- [ ] Commit messages follow DevOnboarder standards
- [ ] Error handling and fallback notifications implemented

## Post-deployment monitoring

- Monitor workflow runs for failures
- Verify GPG signatures appear on automated commits
- Check that automation doesn't conflict with other workflows
- Monitor for any terminal output policy violations

## Naming Conventions

### Secrets and Variables

Follow the established pattern from Priority Matrix Bot:

```bash

# Format: {BOT_NAME}_{SECRET_TYPE}

PMBOT_GPG_PRIVATE         # Private key (secret)
PMBOT_GPG_KEY_ID          # Key ID (variable)
PMBOT_NAME                # Display name (variable)
PMBOT_EMAIL               # Email (variable)

# Your bot example

YOURBOT_GPG_PRIVATE       # Private key (secret)
YOURBOT_GPG_KEY_ID        # Key ID (variable)
YOURBOT_NAME              # Display name (variable)
YOURBOT_EMAIL             # Email (variable)
```bash

## Workflow Files

- Use descriptive kebab-case names: `your-automation-task.yml`
- Include automation scope in filename: `docs-enhancement.yml`, `code-quality.yml`
- Avoid generic names like `bot.yml` or `automation.yml`

### Git Configuration

- **Bot Name**: Use descriptive names like "Documentation Enhancement Bot"
- **Bot Email**: Use consistent domain: `bot-name@theangrygamershow.com`
- **Commit Messages**: Follow conventional commit format with scope

## Best Practices

### Security

- **Never commit private keys** - always use GitHub secrets
- **Use minimal permissions** - only grant necessary workflow permissions
- **Rotate keys periodically** - document key rotation procedures
- **Validate signatures** - include signature verification in workflows

### Reliability

- **Include error handling** - implement fallback notifications for failures
- **Use retry logic** - handle transient network/API failures
- **Monitor resource usage** - avoid overwhelming CI/CD resources
- **Test thoroughly** - validate workflows in test environments first

### Maintainability

- **Document your automation** - clear comments and documentation
- **Follow established patterns** - consistency with existing workflows
- **Version your automation** - include version info in commit messages
- **Plan for updates** - consider how the automation will evolve

## Troubleshooting

### Common Issues

## GPG signing failures

```bash

# Verify key is properly imported

gpg --list-secret-keys

# Check git configuration

git config --list | grep gpg

# Test signing manually

git commit --allow-empty -m "Test GPG signing" -S
```bash

## Push failures

- Check token permissions in workflow
- Verify branch protection rules allow bot pushes
- Ensure token hierarchy: `CI_ISSUE_AUTOMATION_TOKEN`  `CI_BOT_TOKEN`  `GITHUB_TOKEN`

## Workflow not triggering

- Verify trigger conditions in `on:` section
- Check path filters match your file changes
- Ensure workflow is not blocked by draft PR conditions

### Getting Help

1. **Review existing implementations**: Study `priority-matrix-synthesis.yml` as a reference
2. **Check DevOnboarder documentation**: Reference token architecture and workflow standards
3. **Use validation tools**: Run `scripts/qc_pre_push.sh` to validate workflow quality
4. **Create test PRs**: Use test branches to validate workflow behavior

## Migration from SSH to GPG

If you have existing SSH-based automation:

1. **Audit current automation**: Identify workflows using SSH signing
2. **Generate GPG key**: Follow the setup process above
3. **Update workflow**: Replace SSH setup with GPG setup steps
4. **Test thoroughly**: Validate GPG signing works in your environment
5. **Deprecate SSH workflow**: Mark old workflows as deprecated
6. **Update documentation**: Reference new GPG-based process

## Examples

### Documentation Enhancement Bot

```yaml
name: Documentation Enhancement
on:
  push:
    branches: [main]
    paths: ['docs/**', '**.md']
```bash

### Code Quality Bot

```yaml
name: Code Quality Automation
on:
  pull_request:
    types: [opened, synchronize]
    paths: ['src/**', 'tests/**']
```bash

### Security Audit Bot

```yaml
name: Security Audit Automation
on:
  schedule:

    - cron: '0 2 * * 1'  # Weekly on Monday

```bash

## Standards Compliance

All automated workflows must comply with DevOnboarder standards:

- **Terminal Output Policy**: No emojis, Unicode, or multi-line echo statements
- **Centralized Logging**: Use `logs/` directory for all output files
- **Quality Gates**: Pass pre-commit hooks and QC validation
- **Potato Policy**: Respect sensitive file protection patterns
- **Token Architecture**: Use established token hierarchy for authentication

## Support

For questions or issues with automated workflow development:

1. Reference existing implementations in `.github/workflows/`
2. Check DevOnboarder documentation in `docs/`
3. Use the validation framework: `scripts/qc_pre_push.sh`
4. Create issues in the DevOnboarder repository for bugs or enhancements

---

**Last Updated**: September 22, 2025
**Version**: 1.0
**Related**: Token Architecture v2.1, GPG Signature Verification Unification
