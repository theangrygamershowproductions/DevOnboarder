---
author: "DevOnboarder Team"
consolidation_priority: P2
content_uniqueness_score: 5
created_at: 2025-09-21
description: "Comprehensive documentation of workflow automation scripts created for instruction gap elimination"

document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: automation-workflows
status: active
tags: 
title: "Workflow Automation Scripts Documentation"

updated_at: 2025-10-27
visibility: internal
---

# Workflow Automation Scripts Documentation

This document provides comprehensive documentation for the automated workflow scripts created to eliminate instruction gaps and prevent time waste in DevOnboarder development.

## Overview

Following the principle "There should be absolutely no gaps in our instructions", these automation scripts transform time-consuming manual processes into reliable automated workflows, preventing the 5.5 hour debugging sessions experienced in previous development cycles.

## Automation Scripts

### 1. Post-Merge Cleanup Automation

**Script**: `scripts/automate_post_merge_cleanup.sh`

**Purpose**: Eliminates manual post-merge cleanup processes that previously consumed significant developer time.

#### Usage

```bash
scripts/automate_post_merge_cleanup.sh <pr-number>

# Example: Clean up after PR #1555
scripts/automate_post_merge_cleanup.sh 1555
```

#### Features

- **Multi-Pattern Issue Search**: Uses comprehensive search patterns to find tracking issues:

    - `"is:open label:tracking PR #1555"`
    - `"is:open label:tracking #1555"`
    - `"is:open PR 1555"`
    - `"is:open tracking 1555"`

- **Automated Issue Closure**: Closes found tracking issues with standardized messages:

    - `"Resolved via PR #1555 - automated post-merge cleanup"`

- **Branch Cleanup**:

    - Switches to main branch if not already there
    - Updates main branch from origin
    - Identifies and deletes merged local branches
    - Provides verification of cleanup completion

- **Comprehensive Logging**: All operations logged to `logs/post_merge_cleanup_TIMESTAMP.log`

#### Error Handling

- Validates PR number format
- Checks GitHub CLI availability with fallback guidance
- Handles git operations with proper error reporting
- Provides manual action instructions when automation fails

### 2. Signature Verification Automation

**Script**: `scripts/automate_signature_verification.sh`

**Purpose**: Automates signature verification to prevent debugging time waste like the 5.5 hours spent on signature issues in PR #1397.

#### Signature Verification Usage

```bash
scripts/automate_signature_verification.sh [OPTIONS]

# Examples:
scripts/automate_signature_verification.sh                    # Check last 5 commits
scripts/automate_signature_verification.sh --import-keys      # Import GitHub keys
scripts/automate_signature_verification.sh --range HEAD~10..HEAD  # Check last 10 commits
scripts/automate_signature_verification.sh --help             # Show usage guide
```

#### Signature Verification Features

- **G/U/N Status Analysis**: Comprehensive parsing and interpretation of git signature status:

    - **G (Good)**: Verified signature - properly signed and verified
    - **U (Unverified)**: Valid signature but key not in local keyring
    - **N (No signature)**: Unsigned commit - requires investigation
    - **BAD**: Invalid signature - critical security issue

- **GitHub Key Import**: Automated GPG key setup for resolving U status signatures:

    - Imports GitHub main signing keys
    - Runs automated setup scripts if available
    - Provides manual resolution guidance

- **Git Config Validation**: Ensures proper signing configuration:

    - Checks user.email, user.signingkey, commit.gpgsign settings
    - Validates gpg.format configuration
    - Provides setup guidance for incomplete configurations

- **Security Analysis**: Identifies critical signature issues:

    - Flags BAD signatures as critical security issues
    - Provides investigation guidance for unsigned commits
    - Generates actionable recommendations

- **Comprehensive Reporting**: Creates detailed signature verification reports with:

    - Signature count summaries
    - Git configuration status
    - Overall security assessment
    - Specific action recommendations

#### Security Levels

- **CRITICAL**: Bad signatures detected - immediate action required
- **WARNING**: Unsigned commits found - review and sign as needed
- **ATTENTION_NEEDED**: Unverified signatures - import GitHub keys
- **GOOD**: All commits properly signed and verified

### 3. Issue Discovery Automation

**Script**: `scripts/automate_issue_discovery.sh`

**Purpose**: Automates comprehensive issue discovery and triage for repository health monitoring.

#### Issue Discovery Usage

```bash
scripts/automate_issue_discovery.sh [OPTIONS]

# Examples:
scripts/automate_issue_discovery.sh                    # Discover all issue types
scripts/automate_issue_discovery.sh --ci --priority    # Focus on CI and priority issues
scripts/automate_issue_discovery.sh --stale            # Find stale issues only
scripts/automate_issue_discovery.sh --actions          # Generate triage action plan
```

#### Issue Discovery Features

- **CI Issue Detection**: Finds issues with labels:

    - `ci-failure`, `ci-timeout`, `ci-flaky`, `workflow-failure`

- **Tracking Issue Discovery**: Locates milestone and epic issues using patterns:

    - `"is:open label:tracking"`
    - `"is:open track"`
    - `"is:open milestone"`
    - `"is:open epic"`

- **Stale Issue Analysis**: Identifies issues not updated in 30 days:

    - Cross-platform date calculation (GNU date vs BSD date)
    - Configurable staleness threshold
    - Assignee and update timestamp tracking

- **Priority Issue Monitoring**: Finds high-priority issues with labels:

    - `priority:high`, `priority:critical`, `urgent`, `blocker`, `security`

- **Health Assessment**: Provides overall repository issue health status:

    - **CRITICAL**: >5 priority issues or >10 CI issues
    - **WARNING**: >20 stale issues or >25 total issues
    - **ATTENTION**: >10 total issues requiring attention
    - **GOOD**: Manageable issue load

- **Triage Planning**: Generates actionable checklists saved to `logs/triage_actions_TIMESTAMP.txt`:

    - Priority action items
    - CI health actions
    - Stale issue cleanup tasks
    - General maintenance activities
    - Automation opportunities

#### Command Line Options

- `--ci`: Discover CI-related issues only
- `--tracking`: Discover tracking issues only
- `--stale`: Discover stale issues only
- `--priority`: Discover priority issues only
- `--actions`: Generate triage action plan
- `--help`: Show usage information

## Technical Standards

### DevOnboarder Compliance

All automation scripts follow DevOnboarder standards:

- **Terminal Output Compliance**: Plain ASCII text only, no emojis or Unicode
- **Centralized Logging**: All scripts log to `logs/` directory with timestamps
- **Virtual Environment Compatibility**: Scripts work within DevOnboarder's venv requirements
- **Git-Aware Operations**: Use `git ls-files` patterns to respect repository boundaries
- **Quality Gate Integration**: No bypassing of DevOnboarder validation processes
- **Error Handling**: Proper exit codes and error propagation
- **Token Architecture**: Compatible with enhanced token loader system

### Script Architecture

```bash
# Standard script structure
set -euo pipefail

# Centralized logging setup
mkdir -p logs
LOG_FILE="logs/script_name_$(date %Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Load DevOnboarder environment
if [[ -f "scripts/load_token_environment.sh" ]]; then
    source scripts/load_token_environment.sh
fi

# Script functionality...
```

### Error Handling Patterns

- **GitHub CLI Detection**: Check availability with fallback instructions
- **Validation Functions**: Validate inputs before processing
- **Graceful Degradation**: Provide manual alternatives when automation fails
- **Comprehensive Logging**: Log all operations for debugging
- **Exit Codes**: Proper error propagation for CI integration

## Integration with Development Workflow

### Post-PR Merge Workflow

```bash
# After successful PR merge
scripts/automate_post_merge_cleanup.sh <pr-number>

# Verify signature integrity
scripts/automate_signature_verification.sh

# Check repository health
scripts/automate_issue_discovery.sh --actions
```

### Weekly Maintenance Workflow

```bash
# Comprehensive issue health check
scripts/automate_issue_discovery.sh

# Generate triage action plan
scripts/automate_issue_discovery.sh --actions

# Verify signature status across recent commits
scripts/automate_signature_verification.sh --range HEAD~20..HEAD
```

### CI Integration

```bash
# Quality control validation
./scripts/qc_pre_push.sh

# Signature verification in CI
scripts/automate_signature_verification.sh --range HEAD~5..HEAD

# Issue health monitoring (optional)
scripts/automate_issue_discovery.sh --ci --priority
```

## Benefits and Time Savings

### Eliminated Manual Processes

1. **Post-Merge Cleanup**: Previously 30 minutes of manual issue search and branch cleanup
2. **Signature Verification**: Previously 5.5 hours of debugging signature issues
3. **Issue Discovery**: Previously manual searching across multiple label categories and timeframes

### Prevented Time Waste

- **Systematic Issue Search**: No more missed tracking issues
- **Automated Key Import**: No more manual GPG key management
- **Health Monitoring**: Proactive issue detection before they become problems
- **Standardized Workflows**: Consistent processes across all developers

### Quality Improvements

- **Comprehensive Logging**: Full audit trail of all operations
- **Error Recovery**: Clear guidance when automation fails
- **Validation Steps**: Built-in verification of completion
- **Documentation Integration**: Full integration with troubleshooting guides

## Related Documentation

- **Development Workflow**: [`docs/development/development-workflow.md`](../development/development-workflow.md)
- **GitHub Copilot Instructions**: [`.github/instructions/copilot-instructions.md`](../../.github/instructions/copilot-instructions.md)
- **Automation Enhancements**: [`docs/scripts/automation-enhancements.md`](../scripts/automation-enhancements.md)
- **Quality Control**: [`docs/quality-control-95-rule.md`](../quality-control-95-rule.md)
- **Troubleshooting**: [`docs/troubleshooting.md`](../troubleshooting.md)

---

**Created**: September 21, 2025
**Purpose**: Eliminate instruction gaps and prevent developer time waste
**Philosophy**: "Quiet and reliable" automation that works in service of developers
