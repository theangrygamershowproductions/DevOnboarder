---
author: TAGS Engineering
codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: Complete development workflow guidelines including environment setup,
  branch management, and quality control
document_type: standards
merge_candidate: false
project: core-instructions
related_modules:
- architecture-overview.md
- code-quality-requirements.md
- file-structure-conventions.md
similarity_group: environment-config
source: .github/copilot-instructions.md
status: active
tags:
- devonboarder
- development
- workflow
- environment
- quality-control
title: DevOnboarder Development Workflow
updated_at: '2025-09-11'
visibility: internal
---

# DevOnboarder Development Workflow

## Development Guidelines

### 1. Environment First - ALWAYS

**Before ANY development work:**

```bash

# 1. Create feature branch from main

git checkout main
git pull origin main
git checkout -b feat/descriptive-feature-name

# 2. Activate virtual environment

source .venv/bin/activate

# 3. Verify you're in venv

which python  # Should show .venv path

which pip     # Should show .venv path

# 4. Install dependencies

pip install -e .[test]
npm ci --prefix bot
npm ci --prefix frontend

# 5. CRITICAL: Run QC validation before any work

./scripts/qc_pre_push.sh  # 95% quality threshold

```

**Branch Naming Conventions:**

- `feat/feature-description` - New features

- `fix/bug-description` - Bug fixes

- `docs/update-description` - Documentation changes

- `refactor/component-name` - Code refactoring

- `test/test-description` - Test improvements

- `chore/maintenance-task` - Maintenance tasks

**Essential Development Commands**:

```bash

# Development workflow

make deps && make up              # Build and start all services

make test                         # Run comprehensive test suite

make aar-setup                    # Set up CI failure analysis

./scripts/run_tests.sh           # Alternative test runner with hints

# Quality control (MANDATORY before push)

./scripts/qc_pre_push.sh         # Validates 8 quality metrics

source .venv/bin/activate        # Always activate venv first

# Documentation quality control (NEW)

./scripts/qc_docs.sh             # Check all documentation formatting

./scripts/qc_docs.sh --fix       # Fix markdown formatting issues

./scripts/qc_docs.sh --file docs/README.md --fix  # Fix specific file

# Service APIs (individual service testing)

devonboarder-api         # Start main API (port 8001)

devonboarder-auth        # Start auth service (port 8002)

devonboarder-integration # Start Discord integration (port 8081)

# Optional CLI shortcuts (if .zshrc integration enabled)

devonboarder-activate            # Auto-setup environment

gh-dashboard                     # View comprehensive status

gh-ci-health                     # Quick CI check

```

## 2. Centralized Logging Policy - MANDATORY

**ALL logging MUST use the centralized `logs/` directory. NO EXCEPTIONS.**

This is a **CRITICAL INFRASTRUCTURE REQUIREMENT** enforced by CI/CD pipelines:

```bash

# MANDATORY: All scripts create logs in centralized location

mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# MANDATORY: All workflows use centralized logging

command 2>&1 | tee logs/step-name.log

```

**Policy Enforcement**:

- **Pre-commit validation**: `scripts/validate_log_centralization.sh`

- **CI enforcement**: Root Artifact Guard blocks scattered logs

- **Documentation**: `docs/standards/centralized-logging-policy.md`

**Violation Severity**: CRITICAL - Blocks all commits and CI runs

## 3. Terminal Output Best Practices - MANDATORY

### CRITICAL PRIORITY: Terminal output rules are ENFORCED with ZERO TOLERANCE for violations

**ABSOLUTE REQUIREMENTS for terminal output to prevent hanging:**

```bash

# ✅ CORRECT - Simple text only (MANDATORY)

echo "Task completed successfully"
echo "Files processed: 5"
echo "Next steps: Review and commit"

# ✅ CORRECT - Plain ASCII characters only

echo "Status: Implementation complete"
echo "Result: All tests passing"
echo "Action: Ready for deployment"

# ❌ FORBIDDEN - These WILL cause terminal hanging

echo "✅ Multi-line output here"        # Emojis cause hanging

echo "📋 Works with emojis"             # Unicode causes hanging

echo "🎯 No escaping issues"            # Special chars cause hanging

echo "Multi-line
output that
hangs terminal"                         # Multi-line causes hanging

cat << 'EOF'                            # Here-doc causes hanging

This also hangs terminals
EOF

echo -e "Line1\nLine2\nLine3"          # Escape sequences cause hanging

```

**ZERO TOLERANCE ENFORCEMENT POLICY**:

- **NEVER use emojis or Unicode characters** - CAUSES IMMEDIATE TERMINAL HANGING

- **NEVER use multi-line echo** - Causes terminal hanging in DevOnboarder environment

- **NEVER use here-doc syntax** - Also causes terminal hanging issues

- **NEVER use echo -e with \n** - Unreliable and can hang

- **NEVER use special characters** - Stick to plain ASCII text only

- **ALWAYS use individual echo commands** - Only reliable method tested

- **ALWAYS use plain text only** - No formatting, emojis, or Unicode

**CRITICAL CHARACTER RESTRICTIONS**:

- ❌ **NO EMOJIS**: ✅, ❌, 🎯, 🚀, 📋, 🔍, 📝, 💡, ⚠️, etc.

- ❌ **NO UNICODE**: Special symbols, arrows, bullets, etc.

- ❌ **NO SPECIAL FORMATTING**: Colors, bold, underline, etc.

- ✅ **ONLY ASCII**: Letters, numbers, basic punctuation (. , : ; - _ )

**Safe Usage Patterns**:

```bash

# Status summaries (SAFE - plain text only)

echo "Task completed successfully"
echo "Files processed: 5"
echo "Next steps: Review and commit"

# Error reporting (SAFE - plain text only)

echo "Operation failed"
echo "Check logs in: logs/error.log"
echo "Resolution: Fix configuration"

# Multi-step progress (SAFE - plain text only)

echo "Starting deployment process"
echo "Building application"
echo "Running tests"
echo "Deployment complete"

```

**MANDATORY Agent Requirements**:

- All AI agents MUST use individual echo commands with plain text only

- Any multi-line output MUST be broken into separate plain text echo statements

- NO emojis, Unicode, or special characters allowed in terminal output

- Terminal hanging is considered a CRITICAL FAILURE in DevOnboarder

- This policy is enforced with ZERO TOLERANCE to maintain system reliability

- Violations will cause immediate cancellation of commands

## 4. Workflow Standards

- **Trunk-based development**: All work branches from `main`, short-lived feature branches

- **Pull request requirement**: All changes via PR with review

- **Branch cleanup**: Delete feature branches after merge

- **95% test coverage minimum** across all services

- **Virtual environment enforcement**: All tooling in isolated environments
