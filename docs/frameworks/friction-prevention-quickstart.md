# Framework Phase 2 Quick Start Guide

## 🚀 5-Minute Setup

**Essential commands to get started with Framework Phase 2:**

```bash
# 1. Activate virtual environment (MANDATORY)
source .venv/bin/activate

# 2. Validate environment and run quality gates
./frameworks/friction_prevention/workflow/qc_pre_push.sh

# 3. Use safe commit for all commits
./frameworks/friction_prevention/developer_experience/safe_commit.sh "FEAT(your-feature): description"

# 4. Health check before major operations
./frameworks/friction_prevention/workflow/monitor_ci_health.sh
```

## 📋 Essential Scripts by Category

### 🔧 Daily Development

| Script | Purpose | Usage |
|--------|---------|-------|
| `safe_commit.sh` | Safe commits with validation | `./frameworks/friction_prevention/developer_experience/safe_commit.sh "TYPE(scope): msg"` |
| `qc_pre_push.sh` | Quality control validation | `./frameworks/friction_prevention/workflow/qc_pre_push.sh` |
| `smart_env_sync.sh` | Environment sync check | `./frameworks/friction_prevention/workflow/smart_env_sync.sh --validate-only` |

### 🤖 Automation

| Script | Purpose | Usage |
|--------|---------|-------|
| `automate_pr_process.sh` | Complete PR workflow | `./frameworks/friction_prevention/automation/automate_pr_process.sh` |
| `assess_pr_health.sh` | PR health assessment | `./frameworks/friction_prevention/automation/assess_pr_health.sh 1740` |
| `comprehensive_branch_cleanup.sh` | Branch cleanup | `./frameworks/friction_prevention/automation/comprehensive_branch_cleanup.sh` |

### 📊 Monitoring & Analysis

| Script | Purpose | Usage |
|--------|---------|-------|
| `monitor_ci_health.sh` | CI health monitoring | `./frameworks/friction_prevention/workflow/monitor_ci_health.sh` |
| `analyze_logs.sh` | Log analysis | `./frameworks/friction_prevention/productivity/analyze_logs.sh` |
| `generate_aar.py` | After Action Reports | `./frameworks/friction_prevention/productivity/generate_aar.py WORKFLOW_ID` |

## ⚡ Common Workflow Patterns

### Pattern 1: Feature Development

```bash
# Start feature work
source .venv/bin/activate
git checkout -b feat/your-feature-name

# Validate environment
./frameworks/friction_prevention/workflow/smart_env_sync.sh --validate-only

# [Do your development work]

# Pre-commit validation
./frameworks/friction_prevention/workflow/qc_pre_push.sh

# Safe commit
./frameworks/friction_prevention/developer_experience/safe_commit.sh "FEAT(component): your changes"

# Push and create PR
git push origin feat/your-feature-name
```

### Pattern 2: PR Management

```bash
# Assess PR health
./frameworks/friction_prevention/automation/assess_pr_health.sh YOUR_PR_NUMBER

# Automated PR processing
./frameworks/friction_prevention/automation/automate_pr_process.sh

# Monitor CI status
./frameworks/friction_prevention/workflow/monitor_ci_health.sh
```

### Pattern 3: Maintenance & Cleanup

```bash
# Branch cleanup
./frameworks/friction_prevention/automation/comprehensive_branch_cleanup.sh

# Log analysis for issues
./frameworks/friction_prevention/productivity/analyze_logs.sh

# Generate AAR for failed workflows
./frameworks/friction_prevention/productivity/generate_aar.py FAILED_WORKFLOW_ID
```

## 🛠️ VS Code Integration

### Quick Setup

1. Copy this to `.vscode/tasks.json`:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Framework QC",
            "type": "shell",
            "command": "./frameworks/friction_prevention/workflow/qc_pre_push.sh",
            "group": "build"
        },
        {
            "label": "Framework Safe Commit",
            "type": "shell",
            "command": "./frameworks/friction_prevention/developer_experience/safe_commit.sh",
            "args": ["${input:commitMessage}"],
            "group": "build"
        }
    ],
    "inputs": [
        {
            "id": "commitMessage",
            "description": "Commit message",
            "default": "FEAT(component): description",
            "type": "promptString"
        }
    ]
}
```

1. Use `Ctrl+Shift+P` → "Tasks: Run Task" → Select framework task

## 🚨 Common Issues & Quick Fixes

### ❌ "Virtual environment not activated"

```bash
# Fix: Always activate first
source .venv/bin/activate
```

### ❌ "Permission denied"

```bash
# Fix: Set execute permissions
chmod +x frameworks/friction_prevention/**/*.sh
```

### ❌ "QC validation failed"

```bash
# Fix: Run with verbose output to see specific issues
./frameworks/friction_prevention/workflow/qc_pre_push.sh --verbose
```

### ❌ "Script not found"

```bash
# Fix: Use absolute path from project root
./frameworks/friction_prevention/category/script_name.sh
# NOT: cd frameworks && friction_prevention/category/script_name.sh
```

## 📖 Need More Help

- **Full Documentation**: `docs/frameworks/friction-prevention.md`
- **Integration Guide**: `docs/frameworks/friction-prevention-integration.md`
- **Framework Overview**: `frameworks/friction_prevention/README.md`

---

**Quick Start Version**: 1.0.0
**Framework Phase**: 2 (Friction Prevention)
**Last Updated**: October 4, 2025
