# DevOnboarder GitHub CLI Shortcuts

## Overview

DevOnboarder provides a comprehensive set of shell functions and GitHub CLI shortcuts that integrate seamlessly with your development workflow. These shortcuts leverage the existing automation scripts and follow the project's "quiet reliability" philosophy.

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- `jq` for JSON processing
- DevOnboarder repository with `.zshrc` integration
- Bash/Zsh shell environment

## Installation

### 1. Add to Your Shell Configuration

Add the DevOnboarder functions to your `~/.zshrc` or `~/.bashrc`:

```bash
# See the DevOnboarder GitHub CLI Integration section in .zshrc
# Functions are automatically available after sourcing
source ~/.zshrc
```

### 2. Verify Installation

```bash
# Check if functions are available
devonboarder-help
```

## Available Functions

### Environment Management

#### `devonboarder-env`

Detect if you're in a DevOnboarder repository and show environment status.

**Usage:**

```bash
devonboarder-env
```

**Output:**

```text
DevOnboarder repository detected
Repository: theangrygamershowproductions/DevOnboarder
Branch: feature/cli-shortcuts
Virtual env: /home/user/DevOnboarder/.venv
Node env: development
```

#### `devonboarder-activate`

Auto-activate the DevOnboarder virtual environment and show available commands.

**Usage:**

```bash
devonboarder-activate
```

**What it does:**

- Activates `.venv` if not already active
- Shows available CLI shortcuts
- Verifies environment is ready for development

#### `devonboarder-health-full`

Run comprehensive health checks using existing DevOnboarder scripts.

**Usage:**

```bash
devonboarder-health-full
```

**Checks performed:**

- CI health monitoring (via `scripts/monitor_ci_health.sh`)
- GitHub status and issues
- Root artifact pollution check
- Log management status

### GitHub CLI Aliases

#### Quick Issue Management

```bash
ghissue-ci      # List CI failure issues
ghissue-auto    # List automated issues
ghissue-triage  # List issues needing triage
```

#### Pull Request Management

```bash
ghpr-ready      # List non-draft pull requests
```

#### Workflow Management

```bash
ghworkflow      # List all workflows
ghci            # Show recent CI workflow runs
```

### Monitoring & Dashboards

#### `gh-ci-health`

Quick CI status report showing recent workflow runs and open issues.

**Usage:**

```bash
gh-ci-health
```

**Output:**

```text
DevOnboarder CI Health Report
==============================
Recent workflow runs:
ci.yml: success (2025-08-01)
auto-fix.yml: success (2025-08-01)

Open CI issues:
#123: FIX(ci): resolve test timeout issues
```

#### `gh-dashboard`

Comprehensive status dashboard showing workflows, issues, PRs, and repository health.

**Usage:**

```bash
gh-dashboard
```

**Features:**

- Last 10 workflow runs with status
- Issue counts by label
- Active pull requests with review status
- Repository health metrics (branch status, uncommitted changes)

#### `gh-watch`

Auto-refreshing dashboard that updates every 30 seconds.

**Usage:**

```bash
gh-watch
# Press Ctrl+C to stop
```

**Use cases:**

- Monitor CI during active development
- Watch for new issues or PR updates
- Real-time repository health monitoring

#### `gh-branch-status`

Branch and pull request overview.

**Usage:**

```bash
gh-branch-status
```

**Shows:**

- Active branches with last commit dates
- Open pull requests with titles

### Workflow Automation

#### `gh-auto-fix`

Trigger the DevOnboarder auto-fix workflow.

**Usage:**

```bash
gh-auto-fix
```

**What it does:**

- Triggers `auto-fix.yml` workflow
- Monitors run status
- Shows run URL for detailed tracking

#### `gh-trigger-workflow`

Trigger any workflow with monitoring.

**Usage:**

```bash
gh-trigger-workflow <workflow-name> [ref]
```

**Examples:**

```bash
# Trigger security audit on main branch
gh-trigger-workflow "security-audit.yml" "main"

# Trigger CI on current branch
gh-trigger-workflow "ci.yml"

# List available workflows
gh-trigger-workflow
```

#### `gh-triage`

Triage issues by label.

**Usage:**

```bash
gh-triage [label]
```

**Examples:**

```bash
# Default: triage issues
gh-triage

# Specific label
gh-triage "ci-failure"
gh-triage "priority-high"
```

### Utilities

#### `devonboarder-create-issue`

Create issues using DevOnboarder templates.

**Usage:**

```bash
devonboarder-create-issue <title> [label]
```

**Examples:**

```bash
# Create CI issue
devonboarder-create-issue "FIX(ci): resolve test timeout issues" "ci-failure"

# Create general issue (default: triage label)
devonboarder-create-issue "FEAT: add new dashboard widget"
```

#### `gh-config-devonboarder`

Configure GitHub CLI for optimal DevOnboarder workflows.

**Usage:**

```bash
gh-config-devonboarder
```

**Sets:**

- Default editor to VS Code
- HTTPS protocol for git operations
- Pager configuration
- Prompt confirmations

#### `devonboarder-help` / `devhelp`

Show quick reference for all available shortcuts.

**Usage:**

```bash
devonboarder-help
# or
devhelp
```

## Integration Patterns

### Daily Development Workflow

```bash
# Start your development session
cd /path/to/DevOnboarder
devonboarder-activate

# Check overall health
gh-dashboard

# Monitor CI while working
gh-watch  # In separate terminal

# Quick health check
gh-ci-health

# Trigger auto-fix if needed
gh-auto-fix

# Create issues for problems
devonboarder-create-issue "FIX(bug): resolve memory leak" "bug"
```

### CI Troubleshooting Workflow

```bash
# Quick CI status
gh-ci-health

# Full dashboard view
gh-dashboard

# Check specific issues
ghissue-ci

# Trigger workflows
gh-auto-fix
gh-trigger-workflow "security-audit.yml"

# Create issue for persistent problems
devonboarder-create-issue "FIX(ci): recurring timeout in test suite" "ci-failure"
```

### Issue Management Workflow

```bash
# Review triage queue
gh-triage

# Check automated issues
ghissue-auto

# Review CI failures
ghissue-ci

# Create new issues with proper labels
devonboarder-create-issue "DOCS: update API documentation" "documentation"
```

## Error Handling

All functions include proper error handling and graceful fallbacks:

- **GitHub CLI unavailable**: Functions show appropriate error messages
- **Not in DevOnboarder repo**: Environment functions detect this and exit gracefully
- **Missing dependencies**: Clear error messages with installation hints
- **API rate limits**: Functions handle GitHub API limits appropriately

## Fallback Commands

If shortcuts aren't available, use these standard GitHub CLI commands:

```bash
# Instead of gh-ci-health
gh run list --limit 5 --json conclusion,status,workflowName
gh issue list --label "ci-failure" --state open

# Instead of gh-dashboard
gh run list --limit 10
gh issue list --state open
gh pr list --state open

# Instead of gh-auto-fix
gh workflow run auto-fix.yml

# Instead of devonboarder-create-issue
gh issue create --title "Issue Title" --label "label" --body "Description"
```

## Agent Integration

For AI agents and automation tools:

### Availability Check

```bash
# Check if shortcuts are available
if command -v devonboarder-env >/dev/null 2>&1; then
    echo "DevOnboarder shortcuts available"
    devonboarder-activate
else
    echo "Using standard GitHub CLI commands"
    source .venv/bin/activate
fi
```

### Recommendation Pattern

AI agents should:

1. **Check for shortcuts first**: Recommend `gh-ci-health` before manual commands
2. **Provide fallbacks**: Always include standard `gh` command alternatives
3. **Reference documentation**: Point users to this guide for full integration
4. **Suggest appropriate tools**: Use `gh-dashboard` for status, `gh-auto-fix` for fixes

### Example Agent Response

```markdown
If you have DevOnboarder CLI shortcuts installed, try:

```bash
gh-ci-health
```

Otherwise, use the standard approach:

```bash
gh run list --limit 5 --json conclusion,status,workflowName
gh issue list --label "ci-failure" --state open
```

For full integration guide, see: docs/cli-shortcuts.md

```text
Example agent response showing CLI shortcuts with fallbacks
```

## Troubleshooting

### Common Issues

**Functions not found:**

```bash
# Reload shell configuration
source ~/.zshrc

# Verify DevOnboarder integration is installed
grep -n "DevOnboarder GitHub CLI" ~/.zshrc
```

**GitHub CLI authentication:**

```bash
# Check authentication
gh auth status

# Re-authenticate if needed
gh auth login
```

**Virtual environment issues:**

```bash
# Ensure you're in DevOnboarder repository
devonboarder-env

# Manually activate if needed
source .venv/bin/activate
```

**Missing dependencies:**

```bash
# Install jq for JSON processing
sudo apt-get install jq  # Ubuntu/Debian
brew install jq          # macOS

# Verify GitHub CLI installation
gh --version
```

### Debug Mode

For troubleshooting function execution:

```bash
# Enable debug output
set -x
gh-ci-health
set +x

# Check GitHub CLI calls
gh run list --limit 1 --json status
```

## Contributing

To add new shortcuts or improve existing ones:

1. **Follow naming convention**: Use `gh-` prefix for GitHub CLI functions
2. **Include error handling**: Graceful fallbacks for missing tools
3. **Add documentation**: Update this file with new functions
4. **Test thoroughly**: Verify functions work in different environments
5. **Update copilot instructions**: Add to `.github/instructions/copilot-instructions.md`

## Related Documentation

- [DevOnboarder Setup Guide](setup.md)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [Contributing Guidelines](../CONTRIBUTING.md)
- [Copilot Instructions](../.github/instructions/copilot-instructions.md)

---

**Last Updated**: 2025-08-01

**Maintainers**: DevOnboarder Core Team

**License**: MIT (see [LICENSE.md](../LICENSE.md))
