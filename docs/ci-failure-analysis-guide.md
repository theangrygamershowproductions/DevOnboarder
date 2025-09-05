# CI Failure Analysis Guide

This guide explains how to use the `"conclusion": "FAILURE"` filter to focus CI analysis on relevant failures only.

## Why Use Failure Filters?

When analyzing CI issues, filtering by `"conclusion": "FAILURE"` helps:

- **Reduce noise**: Skip successful and pending runs that aren't relevant for troubleshooting
- **Focus analysis**: Only examine runs that actually failed
- **Improve performance**: Fetch fewer records, faster queries
- **Better reporting**: Generate targeted failure reports

## Available Tools with Failure Filtering

### 1. Enhanced CI Monitor (scripts/ci-monitor.py)

The CI monitor now includes failed workflow context:

```bash
# Monitor PR with failed workflow context
python scripts/ci-monitor.py 970

# Output includes recent failed runs section when failures are detected
```

**Key enhancement**: `get_failed_workflow_runs()` method uses `--conclusion FAILURE` filter.

### 2. Failed Run Analysis Script (scripts/analyze_failed_ci_runs.sh)

Dedicated script for analyzing only failed runs:

```bash
# Analyze recent failed CI runs
bash scripts/analyze_failed_ci_runs.sh

# Shows:
# - Count of failed runs
# - Grouping by workflow name
# - Recent failure patterns
# - Quick analysis commands
```

### 3. Enhanced CI Health Monitor (scripts/monitor_ci_health.sh)

Updated to include detailed failed run analysis:

```bash
# Monitor overall CI health with failure details
bash scripts/monitor_ci_health.sh

# Now includes section showing recent failed runs with URLs
```

### 4. Download CI Failure Issues (scripts/download_ci_failure_issue.sh)

Enhanced to focus on failed runs only:

```bash
# Downloads artifacts only from failed CI runs
# Now includes --conclusion FAILURE filter
```

## GitHub CLI Commands with Failure Filter

### Basic Commands

```bash
# List recent failed runs
gh run list --conclusion FAILURE --limit 10

# Get detailed failed run data
gh run list --conclusion FAILURE --json conclusion,status,workflowName,createdAt,url,displayTitle

# Failed runs for specific workflow
gh run list -w "Enhanced Potato Policy Enforcement" --conclusion FAILURE

# Failed runs from specific branch
gh run list --branch feat/potato-ignore-policy-focused --conclusion FAILURE
```

### Advanced Analysis

```bash
# Group failed runs by workflow
gh run list --conclusion FAILURE --json workflowName,conclusion --limit 20 | \
  jq 'group_by(.workflowName) | map({workflow: .[0].workflowName, count: length})'

# Recent failures with timestamps
gh run list --conclusion FAILURE --json createdAt,workflowName,displayTitle --limit 10 | \
  jq -r '.[] | "\(.createdAt[0:19]) \(.workflowName): \(.displayTitle)"'

# Download logs from most recent failure
LATEST_FAILED=$(gh run list --conclusion FAILURE --json databaseId --limit 1 --jq '.[0].databaseId')
gh run download "$LATEST_FAILED"
```

## Integration in Scripts

### Pattern: Fetch Failed Runs Only

```bash
# Get failed runs with error handling
if failed_runs=$(gh run list --limit 15 --json conclusion,status,workflowName,createdAt,url --conclusion FAILURE 2>/dev/null); then
    echo "✅ Retrieved failed run data"

    # Process failed runs
    total_failed=$(echo "$failed_runs" | jq length)
    echo "📈 Total failed runs: $total_failed"

    # Group by workflow
    echo "$failed_runs" | jq -r 'group_by(.workflowName) | map({workflow: .[0].workflowName, count: length}) | .[] | "  \(.count)x \(.workflow)"'
else
    echo "❌ Failed to fetch failed workflow runs"
fi
```

### Pattern: Download Failed Run Artifacts

```bash
# Find specific failed run and download artifacts
run_id=$(gh run list -w "CI" --json databaseId,conclusion -L 10 --conclusion FAILURE \
    --jq '.[0].databaseId' || true)

if [ -n "${run_id:-}" ]; then
    echo "Downloading artifacts from failed run $run_id"
    gh run download "$run_id" --name ci-failure-logs --dir ./failed-run-logs/
fi
```

## Best Practices

### 1. Always Use Error Handling

```bash
# ✅ Good: Handle GitHub CLI failures
if failed_runs=$(gh run list --conclusion FAILURE 2>/dev/null); then
    # Process data
else
    echo "⚠️  GitHub CLI not available or not authenticated"
    # Fallback behavior
fi

# ❌ Bad: No error handling
failed_runs=$(gh run list --conclusion FAILURE)
```

### 2. Limit Results for Performance

```bash
# ✅ Good: Limit results
gh run list --conclusion FAILURE --limit 10

# ❌ Bad: Fetch all failures (could be thousands)
gh run list --conclusion FAILURE
```

### 3. Combine with Other Filters

```bash
# Recent failures from specific branch
gh run list --conclusion FAILURE --branch main --limit 5

# Failures from specific workflow
gh run list --conclusion FAILURE -w "CI" --limit 10

# Failures from last 24 hours (if supported)
gh run list --conclusion FAILURE --created "$(date -d '24 hours ago' -Iseconds)"
```

## Troubleshooting

### GitHub CLI Authentication

If you see "Failed to fetch workflow run data":

```bash
# Check authentication status
gh auth status

# Login if needed
gh auth login

# Test basic functionality
gh run list --limit 1
```

### No Failed Runs Found

If no failed runs are returned:

```bash
# Check if there are any runs at all
gh run list --limit 5

# Check specific workflow
gh run list -w "workflow-name" --limit 5

# Check different conclusion states
gh run list --json conclusion --limit 10 | jq 'group_by(.conclusion)'
```

### Performance Issues

If queries are slow:

```bash
# Use smaller limits
gh run list --conclusion FAILURE --limit 5

# Filter by specific workflow
gh run list -w "specific-workflow" --conclusion FAILURE --limit 10

# Focus on recent runs only
gh run list --conclusion FAILURE --limit 10 --json conclusion,workflowName
```

## Example: Complete Failure Analysis

```bash
#!/bin/bash
set -euo pipefail

echo "🔍 Comprehensive Failure Analysis"
echo "================================="

# 1. Get recent failures
if failed_runs=$(gh run list --conclusion FAILURE --limit 15 --json conclusion,workflowName,createdAt,url 2>/dev/null); then

    # 2. Count and categorize
    total=$(echo "$failed_runs" | jq length)
    echo "📊 Total failed runs: $total"

    # 3. Group by workflow
    echo ""
    echo "🔧 Failures by workflow:"
    echo "$failed_runs" | jq -r 'group_by(.workflowName) | map({workflow: .[0].workflowName, count: length}) | sort_by(-.count) | .[] | "  \(.count)x \(.workflow)"'

    # 4. Recent timeline
    echo ""
    echo "🕒 Recent failure timeline:"
    echo "$failed_runs" | jq -r '.[] | "\(.createdAt[0:19]) \(.workflowName)"' | head -5

    # 5. Actionable recommendations
    echo ""
    echo "🎯 Recommended actions:"
    echo "1. Focus on workflow with most failures"
    echo "2. Download logs: gh run download <run-id>"
    echo "3. Check for patterns in failure messages"

else
    echo "❌ Cannot fetch failure data - check GitHub CLI authentication"
fi
```

This comprehensive approach using `"conclusion": "FAILURE"` filters ensures you only analyze relevant failed runs, making troubleshooting more efficient and focused.
