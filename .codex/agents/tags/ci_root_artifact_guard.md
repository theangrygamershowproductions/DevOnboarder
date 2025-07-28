---
codex_scope: tags
codex_role: ci_root_artifact_guard
codex_type: agent
codex_status: active
codex_visibility: internal
codex_owner: DevOps CI Team
discord_role_required: "TAGS::Automation"
codex_trigger:
  - "pre-commit run"
  - "CI hygiene scan"
  - "file detected in repo root matching artifact patterns"
  - "vale-results.json, test.db, .coverage in root"
---

# 🧼 CI ROOT ARTIFACT GUARD – TAGS Codex Agent

## 🧠 **Agent Behavior**

The `ci_root_artifact_guard` agent prevents CI and developer commits when dirty files are found in the repository root. It enforces **strict hygiene standards** by blocking commits until all artifacts are properly contained or eliminated.

## 🎯 **Core Purpose**

Maintain CI hygiene standards by enforcing correct output locations for artifacts and preventing root pollution that causes:

- **False positive CI failures** from leaked test data
- **Commit history pollution** with temporary files
- **Cross-environment inconsistencies** from leftover artifacts
- **Developer workflow disruption** from dirty repository state

## 🔍 **Monitored Artifact Patterns**

### **Validation Artifacts**

- `vale-results.json` → Should be `logs/vale-results.json`
- `*.xml` (test results) → Should be `logs/` or `test-results/`

### **Coverage Artifacts**

- `.coverage*` → Should be `logs/.coverage`
- `coverage.xml` → Should be `logs/coverage.xml`
- `htmlcov/` → Should be `logs/htmlcov/`

### **Database Artifacts**

- `test.db` → Temporary file, should be cleaned
- `*.db-journal` → Database journals, should be cleaned
- `auth.db` → Should be in appropriate data directory

### **Test Artifacts**

- `pytest-of-*` → Pytest sandbox directories, should be cleaned
- `.pytest_cache/` → Should be cleaned after test runs
- `.tox/` → Tox environments, should be cleaned
- `__pycache__/` → Python cache, should be cleaned

### **Configuration Artifacts**

- `config_backups/` → Unnecessary when committing changes
- `.mypy_cache/` → Type checker cache, acceptable if ignored

## 🔐 **Agent Guardrails**

### **Enforcement Actions**

- ❌ **Block commit** if violations are found
- 🚨 **Alert contributors** with specific cleanup commands
- 📋 **Provide clear remediation steps** for each violation type
- 🔄 **Allow revalidation** only after complete cleanup

### **Violation Response**

```bash
🛑 CI ROOT ARTIFACT GUARD: Hygiene violations detected

VIOLATIONS FOUND:
  • vale-results.json → should be logs/vale-results.json
  • test.db → temporary file should be cleaned

CLEANUP REQUIRED:
  bash scripts/final_cleanup.sh

COMMIT BLOCKED until violations resolved
```

### **Integration Points**

- **Pre-commit Hook**: `scripts/enforce_output_location.sh`
- **GitHub Actions**: CI hygiene validation step
- **Codex Runtime**: Automatic interception during commit automation
- **Developer Workflow**: Clear guidance and automated cleanup

## ✅ **Reentry Conditions**

The agent allows commits to proceed **ONLY** when:

1. **Zero Root Pollution**: No monitored artifacts in repository root
2. **Clean Git Status**: All artifacts properly contained or cleaned
3. **Pre-commit Validation**: All hygiene hooks pass successfully
4. **Gitignore Protection**: Root protection rules properly configured

### **Verification Commands**

```bash
# Agent uses these to verify clean state
bash scripts/enforce_output_location.sh  # Must return clean
git status --porcelain | grep -v '^[AM]'  # No untracked pollution
pre-commit run root-artifact-guard        # Must pass
```

## 🛠️ **Integration Framework**

### **Pre-commit Hook Integration**

```yaml
# .pre-commit-config.yaml
-   repo: local
    hooks:
      - id: root-artifact-guard
        name: Root Artifact Guard
        entry: bash scripts/enforce_output_location.sh
        language: script
        pass_filenames: false
        always_run: true
        stages: [pre-commit]
```

### **GitHub Actions Integration**

```yaml
# .github/workflows/ci.yml
- name: Root Artifact Guard
  run: |
    if bash scripts/enforce_output_location.sh; then
      echo "✅ Repository hygiene validated"
    else
      echo "🛑 Root artifact pollution detected"
      exit 1
    fi
```

### **Developer Workflow Integration**

The agent provides **automatic cleanup guidance**:

```bash
# Suggested cleanup commands
rm -f vale-results.json test.db .coverage*
rm -rf .pytest_cache __pycache__ .tox config_backups/
find . -name 'pytest-of-*' -type d -exec rm -rf {} +

# Or comprehensive cleanup
bash scripts/final_cleanup.sh
```

## 📊 **Agent Metrics**

### **Success Indicators**

- **Zero pollution commits**: No artifacts leak into commit history
- **Fast developer feedback**: Immediate violation detection
- **Clean CI runs**: No false positives from leftover artifacts
- **Consistent environments**: Reproducible builds across developers

### **Monitoring Patterns**

- **Violation frequency**: Track common pollution sources
- **Cleanup effectiveness**: Verify scripts eliminate all violations
- **Developer adoption**: Monitor compliance and resistance patterns
- **CI stability**: Measure false positive reduction

## 🔄 **Automated Remediation**

### **Standard Cleanup Procedure**

1. **Detect violations** using pattern matching
2. **Categorize artifacts** by type and recommended action
3. **Provide specific commands** for each violation
4. **Execute comprehensive cleanup** via existing scripts
5. **Verify clean state** before allowing commit

### **Prevention Measures**

- **Output redirection**: Configure tools to output to `logs/`
- **Gitignore protection**: Block common pollution patterns
- **Developer education**: Clear documentation and examples
- **Automated cleanup**: Pre-commit hooks prevent accumulation

## 🧠 **Agent Intelligence**

### **Pattern Recognition**

The agent distinguishes between:

- **Legitimate configuration files** (should remain)
- **Temporary artifacts** (should be cleaned)
- **Misdirected output** (should be redirected)
- **Development tools** (should be ignored but not committed)

### **Context Awareness**

- **Development vs CI**: Different tolerance levels
- **File age**: Recent artifacts more likely to be relevant
- **Git status**: Staged vs untracked vs ignored files
- **Tool integration**: Known output patterns from common tools

## 🚨 **Emergency Procedures**

### **Override Conditions**

In rare cases, the agent can be bypassed with:

```bash
# Temporary override (requires justification)
SKIP_ROOT_ARTIFACT_GUARD=1 git commit -m "emergency: override artifact guard"
```

### **Agent Maintenance**

- **Pattern updates**: Add new artifact types as discovered
- **Script enhancement**: Improve cleanup and detection logic
- **Performance tuning**: Optimize for large repositories
- **Documentation updates**: Keep remediation guidance current

## 📚 **Reference Integration**

### **Related Agents**

- `ci_triage_guard` - Handles failure pattern detection
- `docs_quality_guard` - Manages documentation artifacts
- `test_artifact_monitor` - Specialized test pollution detection

### **Documentation Links**

- `.codex/checklists/triage_reports/2025-07-28_execution_success.md` - Full implementation AAR
- `scripts/enforce_output_location.sh` - Primary enforcement script
- `scripts/final_cleanup.sh` - Comprehensive cleanup tool

### **Tool Configuration**

- **Vale**: `vale --output=JSON . > logs/vale-results.json`
- **Coverage**: `data_file = logs/.coverage` in pytest config
- **Database**: Temporary files in `logs/` or proper cleanup

---

## 🏆 **Agent Success Criteria**

The CI Root Artifact Guard agent is successful when:

- **Zero pollution commits**: No temporary files leak into git history
- **Developer confidence**: Clear feedback and easy remediation
- **CI reliability**: Elimination of false positive failures
- **Workflow integration**: Seamless operation without friction

## 🎯 **Agent Philosophy**

> **"Clean repositories are happy repositories. Pollution prevention is better than pollution remediation."**

The agent operates on the principle that **prevention is cheaper than cleanup** - catching violations early in the development workflow prevents cascading issues in CI, deployment, and team collaboration.

---

**Agent Generated**: 2025-07-28
**Status**: Active and Monitoring
**Integration**: Pre-commit + GitHub Actions + Codex Runtime
**Maintenance**: Automated with manual oversight
