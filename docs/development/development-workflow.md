---
author: "TAGS Engineering"
codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: 2025-09-11
description: "Complete development workflow guidelines including environment setup,"

document_type: standards
merge_candidate: false
project: core-instructions
related_modules: 
similarity_group: environment-config
source: .github/copilot-instructions.md
status: active
tags: 
title: "DevOnboarder Development Workflow"

updated_at: 2025-10-27
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

./scripts/run_vale.sh docs/      # Run Vale documentation linting (virtual environment)

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
LOG_FILE="logs/$(basename "$0" .sh)_$(date %Y%m%d_%H%M%S).log"
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

#  CORRECT - Simple text only (MANDATORY)

echo "Task completed successfully"
echo "Files processed: 5"
echo "Next steps: Review and commit"

#  CORRECT - Plain ASCII characters only

echo "Status: Implementation complete"
echo "Result: All tests passing"
echo "Action: Ready for deployment"

#  FORBIDDEN - These WILL cause terminal hanging

echo " Multi-line output here"        # Emojis cause hanging

echo " Works with emojis"             # Unicode causes hanging

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

-  **NO EMOJIS**: , , 🎯, , , , , , , etc.

-  **NO UNICODE**: Special symbols, arrows, bullets, etc.

-  **NO SPECIAL FORMATTING**: Colors, bold, underline, etc.

-  **ONLY ASCII**: Letters, numbers, basic punctuation (. , : ; - _ )

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

### 4. Repository Scripting Standards - MANDATORY

#### CRITICAL REQUIREMENT: Always use git-aware commands for repository file operations

DevOnboarder enforces strict git-aware scripting practices to prevent pollution from ignored files:

```bash

#  CORRECT - Git-aware file discovery (respects .gitignore)

git ls-files '*.md'                          # List tracked markdown files
git ls-files --others --exclude-standard     # List untracked files (respects .gitignore)
git ls-files src/ | grep '\.py$'            # Find Python files in src/

#  FORBIDDEN - Disk-based discovery (ignores .gitignore)

find . -name '*.md'                          # Searches ALL files including node_modules/
find . -type f -name '*.py'                  # Bypasses .gitignore completely
ls -la **/*.md                               # Shell globbing ignores .gitignore

```

**Policy Enforcement**:

- **Root Artifact Guard**: Automatically detects and blocks repository pollution
- **Script validation**: All automation scripts must use git-aware commands
- **CI enforcement**: Pre-commit hooks validate script methodology

**Why This Matters**:

- **Prevents node_modules pollution**: Scripts won't search ignored directories
- **Respects .gitignore**: Only processes files that should be in repository
- **Performance**: Git index searches are faster than disk traversal
- **Reliability**: Consistent behavior across development environments

**Common Patterns**:

```bash

# Process all markdown files in repository
for file in $(git ls-files '*.md'); do
    echo "Processing: $file"
done

# Find Python files with specific patterns
git ls-files src/ | grep '\.py$' | while read -r file; do
    python -m pylint "$file"
done

# Validate configuration files only in tracked directories
git ls-files 'config/*.yml' 'config/*.yaml'

```

**MANDATORY Agent Requirements**:

- AI agents MUST use `git ls-files` instead of `find` for repository operations
- Scripts MUST respect repository boundaries and ignore patterns
- Any disk-based file discovery MUST include explicit .gitignore handling
- Repository pollution via ignored file processing is a CRITICAL VIOLATION

## 5. Workflow Standards

- **Trunk-based development**: All work branches from `main`, short-lived feature branches

- **Pull request requirement**: All changes via PR with review

- **Branch cleanup**: Delete feature branches after merge

- **95% test coverage minimum** across all services

- **Virtual environment enforcement**: All tooling in isolated environments
