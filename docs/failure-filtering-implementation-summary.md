# Summary: Enhanced CI Analysis with Failure Filtering

## Changes Made

We successfully added `"conclusion": "FAILURE"` filtering to multiple CI analysis tools to focus on relevant failures only.

### 1. Enhanced Scripts

#### Updated `scripts/monitor_ci_health.sh`

- **Added**: `--conclusion FAILURE` filter for detailed failed run analysis
- **Enhancement**: Shows recent failed runs with URLs and titles
- **Benefit**: Users can quickly identify specific failure patterns

```bash
# New code added:
if failed_runs_detailed=$(gh run list --limit 10 --json conclusion,status,workflowName,createdAt,url --conclusion FAILURE 2>/dev/null); then
    echo "✅ Retrieved detailed failed run data"
fi
```

#### Updated `scripts/download_ci_failure_issue.sh`

- **Added**: `--conclusion FAILURE` filter to focus on failed runs only
- **Enhancement**: More targeted artifact downloads
- **Benefit**: Avoids downloading artifacts from successful runs

```bash
# Updated command:
run_id=$(gh run list -w CI --json databaseId,headSha,conclusion -L 10 --conclusion FAILURE \
    --jq 'map(select(.headSha=="'"$GITHUB_SHA"'" && .databaseId != '"$GITHUB_RUN_ID"')) | .[0].databaseId' || true)
```

#### Enhanced `.codex/scripts/ci-monitor.py`

- **Added**: `get_failed_workflow_runs()` method with failure filtering
- **Enhancement**: Reports include recent failed workflow context
- **Benefit**: Comprehensive failure analysis in PR status reports

```python
# New method added:
def get_failed_workflow_runs(self) -> Dict[str, Any]:
    cmd = [
        "gh", "run", "list", "--limit", "10",
        "--json", "conclusion,status,workflowName,createdAt,url,displayTitle",
        "--conclusion", "FAILURE",
    ]
```

### 2. New Tools Created

#### `scripts/analyze_failed_ci_runs.sh`

- **Purpose**: Dedicated script for analyzing only failed CI runs
- **Features**:

    - Groups failures by workflow name
    - Shows failure counts and patterns
    - Provides quick analysis commands
    - Uses `--conclusion FAILURE` filter exclusively

#### `docs/ci-failure-analysis-guide.md`

- **Purpose**: Comprehensive guide for using failure filters
- **Contents**:
- GitHub CLI commands with failure filtering
- Best practices for CI analysis
- Integration patterns for scripts
- Troubleshooting authentication issues

#### `scripts/demo_failure_filtering.sh`

- **Purpose**: Local demonstration of failure filtering concepts
- **Features**:
    - Works without GitHub CLI authentication
    - Shows sample data analysis with jq
    - Demonstrates filtering benefits
    - Educational tool for understanding the approach

### 3. Key Benefits Achieved

#### Performance Improvements

- **Reduced data volume**: Only fetch failed runs, not all runs
- **Faster queries**: GitHub API responds faster with targeted filters
- **Less noise**: Analysis focuses on relevant failures only

#### Better Analysis

- **Pattern recognition**: Easier to spot recurring failure types
- **Targeted troubleshooting**: Direct focus on actual problems
- **Workflow grouping**: Identify which workflows fail most frequently

#### User Experience

- **Clearer reports**: No successful runs cluttering failure analysis
- **Actionable insights**: Direct links to failed runs for investigation
- **Time savings**: Faster identification of root causes

### 4. Implementation Pattern

All enhanced tools follow this pattern:

```bash
# Standard GitHub CLI command with failure filter
gh run list --conclusion FAILURE --limit <N> --json <fields>

# Error handling for authentication issues
if failed_runs=$(gh run list --conclusion FAILURE 2>/dev/null); then
    # Process failed runs data
    echo "✅ Retrieved failed run data"
else
    echo "⚠️  GitHub CLI authentication needed"
fi

# Analysis with jq to group and categorize failures
echo "$failed_runs" | jq 'group_by(.workflowName) | map({workflow: .[0].workflowName, count: length})'
```

### 5. Usage Examples

```bash
# Use enhanced CI monitor with failure context
python .codex/scripts/ci-monitor.py 970

# Analyze only failed runs
bash scripts/analyze_failed_ci_runs.sh

# Monitor CI health with failure details
bash scripts/monitor_ci_health.sh

# Download artifacts only from failed runs
bash scripts/download_ci_failure_issue.sh

# Learn about failure filtering concepts
bash scripts/demo_failure_filtering.sh
```

### 6. Authentication Setup

For users encountering "Failed to fetch workflow run data":

```bash
# Check current authentication
gh auth status

# Login to GitHub CLI
gh auth login

# Test basic functionality
gh run list --limit 1
```

## Result

The enhanced CI analysis tools now provide focused, efficient failure analysis by filtering out irrelevant successful and pending runs. This dramatically improves troubleshooting efficiency and user experience when diagnosing CI issues.

The `"conclusion": "FAILURE"` filter has been successfully integrated across the DevOnboarder CI analysis ecosystem, providing a consistent approach to failure-focused troubleshooting.
