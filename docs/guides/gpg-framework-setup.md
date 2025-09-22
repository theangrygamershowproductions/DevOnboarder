---
similarity_group: guides-guides
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# DevOnboarder GPG Automation Framework Setup Guide

## Overview

DevOnboarder implements unified GPG signing across all automation workflows that create commits, providing cryptographic verification and audit trails for automated changes.

## Framework Architecture

### Unified Bot Account Strategy

**CRITICAL SECURITY REQUIREMENT**: DevOnboarder implements a secondary GitHub account strategy for bot and agent token management:

- **Secondary GitHub Account**: `developer@theangrygamershow.com` (scarabofthespudheap)
- **Corporate Governance**: Account MUST be owned and managed within your corporate structure
- **Access Control**: Separate from personal developer accounts to prevent privilege escalation
- **Security Oversight**: Centralized management enables proper audit trails and access reviews
- **Safety Kill Switch**: Independent account provides emergency revocation capabilities

### Security Benefits

- **Privilege Separation**: Bot operations isolated from main user accounts
- **Corporate Control**: Account management within established corporate governance
- **Audit Trail**: Clear separation of automated vs. human activities
- **Emergency Response**: Rapid token/key revocation via account suspension
- **Compliance**: Meets security standards for automated system access
- **Email Separation**: Each bot uses distinct email addresses for clear identification
- **GPG Key Management**: All bot GPG keys centrally managed through corporate-controlled account

### Account Management Requirements

1. **Corporate Ownership**: Secondary account MUST be created and owned by corporate entity
2. **Access Controls**: Multi-factor authentication and corporate security policies applied
3. **Documentation**: Account purpose and access documented in corporate security records
4. **Regular Review**: Periodic access reviews as part of corporate security audits
5. **Emergency Procedures**: Established protocols for account suspension/recovery

### Bot Infrastructure

| Bot | Email | Key ID | Purpose | Workflows |
|-----|-------|--------|---------|-----------|
| Priority Matrix Bot | `pmbot@theangrygamershow.com` | `AB78428FE3A090D3` | Priority matrix synthesis and document enhancement | `priority-matrix-synthesis.yml` |
| AAR Bot | `aarbot@theangrygamershow.com` | `99CA270AD84AE20C` | After Action Report generation and portal automation | `aar-automation.yml`, `aar-portal.yml` |

**Strategy**: Each bot has its own email identity for commit attribution, but all GPG keys are managed through the unified `scarabofthespudheap` GitHub account for centralized security control.

### Security Features

- **Passphrase-free keys**: Designed for non-interactive automation
- **Base64 encoded storage**: Secure key storage in GitHub secrets
- **Non-interactive trust**: Automated GPG trust configuration
- **Token hierarchy integration**: Uses CI_ISSUE_AUTOMATION_TOKEN → CI_BOT_TOKEN → GITHUB_TOKEN pattern

## Quick Start

### 1. Create New Automation Workflow

```bash
# Copy production-ready template
cp docs/templates/gpg-automation-workflow.yml .github/workflows/your-automation.yml

# Edit the workflow to match your automation needs
# Choose appropriate bot credentials (Priority Matrix Bot or AAR Bot)
```

### 2. Bot Selection Guidelines

**Use Priority Matrix Bot** for:

- Priority matrix synthesis work
- Document enhancement automation
- Content analysis and organization

**Use AAR Bot** for:

- After Action Report generation
- Portal automation and maintenance
- CI analysis and reporting
- General automation workflows

### 3. Required Configuration

#### GitHub Secrets (Repository Level)

- `AARBOT_GPG_PRIVATE` - Base64 encoded AAR Bot private key
- `PMBOT_GPG_PRIVATE` - Base64 encoded Priority Matrix Bot private key

#### GitHub Variables (Repository Level)

- `AARBOT_GPG_KEY_ID` - AAR Bot GPG key ID (99CA270AD84AE20C)
- `AARBOT_NAME` - AAR Bot display name (DevOnboarder AAR Bot)
- `AARBOT_EMAIL` - AAR Bot email address (`aarbot@theangrygamershow.com`)
- `PMBOT_GPG_KEY_ID` - Priority Matrix Bot GPG key ID (AB78428FE3A090D3)
- `PMBOT_NAME` - Priority Matrix Bot display name (Priority Matrix Bot)
- `PMBOT_EMAIL` - Priority Matrix Bot email address (`pmbot@theangrygamershow.com`)

### 4. Template Pattern

```yaml
name: Your Automation Workflow

on:
  # Your triggers here
  workflow_dispatch:

jobs:
  automation-job:
    runs-on: ubuntu-latest
    permissions:
      contents: write  # Required for commits

    steps:
      - name: Checkout repository
        uses: actions/checkout@v5
        with:
          token: ${{ secrets.CI_ISSUE_AUTOMATION_TOKEN || secrets.CI_BOT_TOKEN || secrets.GITHUB_TOKEN }}

      - name: Setup GPG commit signing (AAR Bot)
        env:
          AARBOT_GPG_PRIVATE: ${{ secrets.AARBOT_GPG_PRIVATE }}
          AARBOT_GPG_KEY_ID: ${{ vars.AARBOT_GPG_KEY_ID }}
          AARBOT_NAME: ${{ vars.AARBOT_NAME }}
          AARBOT_EMAIL: ${{ vars.AARBOT_EMAIL }}
        run: |
          # Import GPG private key
          printf '%s\n' "$AARBOT_GPG_PRIVATE" | base64 -d | gpg --batch --import --quiet

          # Configure git to use GPG signing
          git config --global user.name "$AARBOT_NAME"
          git config --global user.email "$AARBOT_EMAIL"
          git config --global user.signingkey "$AARBOT_GPG_KEY_ID"
          git config --global commit.gpgsign true
          git config --global gpg.format openpgp

          # Set up non-interactive GPG trust
          gpg --batch --no-tty --command-fd 0 --edit-key "$AARBOT_GPG_KEY_ID" <<EOF
          trust
          5
          y
          quit
          EOF

          printf "GPG signing configured for automation\n"

      # Your automation steps here

      - name: Commit changes (GPG signed)
        run: |
          git add .
          git commit -m "AUTO: your automation description [signed]"
          git push
```

## DevOnboarder Quality Standards

### Terminal Output Policy Compliance

**CRITICAL**: All GPG automation workflows MUST follow terminal output policy:

```bash
# ✅ CORRECT - Use printf instead of echo
printf "Status: %s\n" "$STATUS"
printf "GPG signing configured\n"

# ❌ WRONG - Echo with variables/emojis causes hanging
echo "Status: $STATUS"
echo "✅ GPG configured"
```

### Required Quality Gates

1. **Terminal Output Policy**: No emojis, Unicode, or variable expansion in echo
2. **YAML Validation**: Proper workflow syntax and structure
3. **Shellcheck Compliance**: All shell scripts pass shellcheck
4. **Token Hierarchy**: Proper fallback pattern for authentication tokens
5. **Comprehensive Commit Messages**: Detailed commit descriptions with automation context

## Testing Your Automation

### Framework Validation

Use the test framework to validate your automation patterns:

```bash
# Run the GPG framework test workflow
gh workflow run test-gpg-framework.yml --repo your-org/DevOnboarder

# Or manually dispatch via GitHub interface
# Actions → Test GPG Framework Demo → Run workflow
```

### Local Testing

```bash
# Validate YAML syntax
yamllint .github/workflows/your-automation.yml

# Check terminal output policy compliance
bash scripts/validate_terminal_output.sh

# Run DevOnboarder quality gates
bash scripts/qc_pre_push.sh
```

## Troubleshooting

### Common Issues

1. **GPG Import Failures**
   - Verify base64 encoding of private key
   - Check secret name matches workflow environment variables
   - Ensure key has no passphrase

2. **Commit Signing Failures**
   - Verify GPG key ID is correct
   - Check git configuration in workflow
   - Ensure non-interactive trust is configured

3. **Terminal Output Policy Violations**
   - Use printf instead of echo
   - Remove all emojis and Unicode characters
   - Avoid variable expansion in echo statements

### Support Resources

- **Template**: `docs/templates/gpg-automation-workflow.yml`
- **Setup Scripts**: `scripts/setup_aar_bot_gpg_key.sh`, `scripts/setup_priority_matrix_bot_gpg_key.sh`
- **Documentation**: `docs/guides/gpg-automation-development.md`
- **Test Workflow**: `.github/workflows/test-gpg-framework.yml`

## Framework Status

**Current Status**: Production Ready ✅

- **Workflows Converted**: 3/3 (100% compliance)
- **Success Rate**: 100% across all converted workflows
- **Template Validation**: Tested via `test-gpg-framework.yml`
- **Quality Standards**: Full DevOnboarder compliance
- **Security Features**: Non-interactive automation with cryptographic verification

---

Last Updated: 2025-01-15 - Framework Testing & Validation Complete
