---
author: "DevOnboarder Team"
ci_integration: true
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
date_created: 2025-07-29
description: "Standards documentation"

document_type: standards
enforcement: CI/CD
merge_candidate: false
project: DevOnboarder
similarity_group: standards-standards
status: MANDATORY
tags: 
title: "DevOnboarder Centralized Logging Policy"

updated_at: 2025-10-27
version: 1.0.0
violation_severity: CRITICAL
virtual_env_required: true
visibility: internal
---

# 🗒️ DevOnboarder Centralized Logging Policy

## 📜 **POLICY STATEMENT - MANDATORY COMPLIANCE**

**ALL logging in DevOnboarder MUST use the centralized `logs/` directory. NO EXCEPTIONS.**

This is a **CRITICAL INFRASTRUCTURE REQUIREMENT** enforced by CI/CD pipelines and pre-commit hooks.

## 🚨 **ENFORCEMENT LEVEL: CRITICAL**

- **Violation Severity**: CRITICAL - Blocks all commits and CI runs

- **Enforcement Points**: Pre-commit hooks, CI validation, Root Artifact Guard

- **Appeal Process**: Requires project lead approval with architectural justification

##  **DIRECTORY STRUCTURE REQUIREMENTS**

###  **APPROVED: Single Centralized Location**

```text

logs/                           # THE ONLY approved log directory

── test_run_*.log             # Test execution logs

── coverage_data_*            # Coverage reports

── ci_diagnostic_*.log        # CI diagnostic logs

── pytest.log                # Pytest output (CI)

── pip-install*.log          # Package installation logs

── docker-build.log          # Docker build logs

── enhanced_potato_check_*.log # Security audit logs

── potato_violations.log     # Security violation logs

── vale_*.log                # Documentation linting

── [script-name]_*.log       # All other script logs

```

###  **PROHIBITED: All Other Log Locations**

```text

# NEVER create logs in these locations

./                             # Repository root - BLOCKED

ci-logs/                       # Legacy - DEPRECATED

tmp/                          # Temporary logs - PROHIBITED

scripts/logs/                 # Script-specific dirs - PROHIBITED

src/logs/                     # Source code logs - PROHIBITED

tests/logs/                   # Test-specific logs - PROHIBITED

[any-other-directory]/logs/   # Scattered logging - PROHIBITED

```

##  **IMPLEMENTATION REQUIREMENTS**

### **Script Logging Standards**

ALL scripts MUST follow this pattern:

```bash
#!/usr/bin/env bash
set -euo pipefail

# MANDATORY: Create logs directory if it doesn't exist

mkdir -p logs

# MANDATORY: Use centralized logging with timestamps

LOG_FILE="logs/$(basename "$0" .sh)_$(date %Y%m%d_%H%M%S).log"

# MANDATORY: Log all output to centralized location

exec > >(tee -a "$LOG_FILE") 2>&1

echo "🗒️ Logging to: $LOG_FILE"
echo "📅 Started at: $(date -Iseconds)"

# Your script logic here...

echo " Completed at: $(date -Iseconds)"

```

### **Python Script Logging Standards**

```python

#!/usr/bin/env python3
"""Script with mandatory centralized logging."""

import logging
import os
from datetime import datetime
from pathlib import Path

# MANDATORY: Create logs directory

logs_dir = Path("logs")
logs_dir.mkdir(exist_ok=True)

# MANDATORY: Use centralized logging with timestamps

log_file = logs_dir / f"{Path(__file__).stem}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"

# MANDATORY: Configure centralized logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',

    handlers=[
        logging.FileHandler(log_file),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)
logger.info(f"🗒️ Logging to: {log_file}")

# Your script logic here...

```

### **GitHub Actions Workflow Standards**

```yaml

- name: Setup Centralized Logging

  run: mkdir -p logs

- name: Script Execution with Centralized Logging

  run: |
      source .venv/bin/activate
      # MANDATORY: All output goes to logs/

      your-command 2>&1 | tee logs/workflow-step.log

```

##  **VALIDATION & ENFORCEMENT**

### **Pre-commit Hook Validation**

```bash

# Check for prohibited log locations

if find . -name "*.log" -not -path "./logs/*" -not -path "./.git/*" -not -path "./.venv/*"; then
    echo " CRITICAL: Logs found outside logs/ directory"
    echo "🚨 VIOLATION: Centralized Logging Policy"
    exit 1
fi

```

### **CI Pipeline Enforcement**

- **Root Artifact Guard**: `scripts/enforce_output_location.sh` blocks commits with scattered logs

- **CI Validation**: All workflows validate log centralization

- **Failure Response**: Automatic issue creation for violations

### **Log Management Integration**

The centralized `logs/` directory integrates with:

- **Log Management**: `scripts/manage_logs.sh` (list, clean, archive, purge)

- **Enhanced Test Runner**: `scripts/run_tests_with_logging.sh`

- **CI Artifact Upload**: All workflows upload `logs/` as artifacts

- **Security Auditing**: Enhanced Potato Policy monitors `logs/`

##  **COMPLIANCE MONITORING**

### **Automated Compliance Checks**

```bash

# Daily compliance audit

bash scripts/audit_log_compliance.sh

# Immediate compliance check

bash scripts/enforce_output_location.sh

# Log centralization health check

bash scripts/validate_log_centralization.sh

```

### **Violation Response Protocol**

1. **Detection**: Automated scanning finds violations

2. **Blocking**: CI/CD pipelines fail immediately

3. **Notification**: Issues created with violation details

4. **Resolution**: Manual intervention required to fix violations

5. **Verification**: Re-run compliance checks before proceeding

##  **MIGRATION GUIDE**

### **For Existing Scripts**

```bash

# Step 1: Update existing scripts

sed -i 's|ci-logs/|logs/|g' scripts/*.sh
sed -i 's|tmp/|logs/|g' scripts/*.sh

# Step 2: Update all workflows

sed -i 's|ci-logs|logs|g' .github/workflows/*.yml

# Step 3: Validate changes

bash scripts/validate_log_centralization.sh

```

### **Legacy Cleanup**

```bash

# Remove legacy log directories

rm -rf ci-logs/ tmp/ */logs/

# Update .gitignore if needed

echo "logs/" >> .gitignore

```

## GROW: **BENEFITS OF CENTRALIZED LOGGING**

### **Operational Benefits**

-  **Single Source of Truth**: All logs in one location

-  **Easier Diagnosis**: No hunting across directories

-  **Consistent Management**: Single log retention policy

-  **CI Integration**: Simplified artifact collection

-  **Security Monitoring**: Centralized audit trail

### **Developer Experience**

-  **Predictable Location**: Always check `logs/` first

-  **Automated Cleanup**: `scripts/manage_logs.sh` handles retention

-  **CI Debugging**: Download single artifact with all logs

-  **Local Development**: Consistent with CI environment

## 🔒 **SECURITY IMPLICATIONS**

### **Enhanced Potato Policy Integration**

- **Monitoring**: Security audits scan `logs/` for violations

- **Protection**: `logs/` directory protected in `.gitignore`

- **Isolation**: Prevents log pollution in sensitive directories

- **Compliance**: Aligns with DevOnboarder security standards

##  **ENFORCEMENT CHECKLIST**

### **For Script Authors**

- [ ] Script creates `logs/` directory if needed

- [ ] All output redirected to `logs/[script-name]_timestamp.log`

- [ ] No temporary log files in other locations

- [ ] Logging includes timestamps and metadata

- [ ] Script tested with centralized logging enabled

### **For Workflow Authors**

- [ ] Workflow creates `logs/` directory early

- [ ] All steps use `tee logs/step-name.log` pattern

- [ ] Artifacts upload includes `logs/` directory

- [ ] No log files created outside `logs/`

- [ ] Workflow tested with log validation enabled

### **For Code Reviewers**

- [ ] No new logging outside `logs/` directory

- [ ] Scripts follow centralized logging pattern

- [ ] Workflows properly configure logging

- [ ] Documentation updated if logging changes

- [ ] Compliance validation passes

## 🚨 **VIOLATION EXAMPLES & FIXES**

###  **VIOLATION: Scattered Logging**

```bash

# WRONG - Creates logs in multiple locations

echo "Starting..." > ./script.log
python test.py > tests/output.log
docker build . > /tmp/build.log

```

###  **COMPLIANT: Centralized Logging**

```bash

# CORRECT - All logs in centralized location

mkdir -p logs
echo "Starting..." | tee logs/script_$(date %Y%m%d_%H%M%S).log
python test.py 2>&1 | tee logs/test_output.log
docker build . 2>&1 | tee logs/docker_build.log

```

## 📚 **REFERENCES**

- **Root Artifact Guard**: `scripts/enforce_output_location.sh`

- **Log Management**: `scripts/manage_logs.sh`

- **Enhanced Testing**: `scripts/run_tests_with_logging.sh`

- **CI Integration**: `.github/workflows/ci.yml`

- **Security Policy**: `docs/enhanced-potato-policy.md`

---

**Status**: MANDATORY COMPLIANCE - Enforced by CI/CD

**Last Updated**: 2025-07-29
**Next Review**: 2025-10-29
**Policy Owner**: DevOnboarder Infrastructure Team
**Violation Severity**: CRITICAL - Blocks all operations
