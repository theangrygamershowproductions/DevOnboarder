---
title: "CI TRIAGE REPORT – Root Artifact Pollution"
date: "2025-07-28"
status: "documented"
severity: "medium"
category: "ci-hygiene"
tags: ["ci", "artifacts", "pollution", "hygiene", "validation"]
resolution_status: "enforceable"
---

# 🔍 CI TRIAGE REPORT: Root Artifact Pollution

## EXECUTIVE SUMMARY

**Root Cause**: Test and validation artifacts accumulating in repository root causing CI hygiene violations
**Impact**: Dirty commits, false positive CI failures, cross-environment inconsistencies
**Solution Category**: Artifact containment and automated cleanup

---

## 1. ✅ **Failing Hook Name(s)**

- `root-artifact-guard` (enforce-no-root-artifacts)
- Any validation hook scanning repository root for artifacts
- Pre-commit validation when dirty files present

---

## 2. 📄 **File(s) or Line(s) Causing Failures**

**Common Pollution Patterns**:

```markdown
./vale-results.json     → Should be logs/vale-results.json
./test.db               → Temporary file should be cleaned
./.coverage*            → Should be logs/.coverage
./config_backups/       → Unnecessary when committing changes
./__pycache__/          → Should be cleaned after use
./pytest-of-*/         → Pytest sandbox directories
```

**Pattern**: Any artifacts in repository root that should be contained or cleaned

---

## 3. 💥 **Exact Error Messages**

```markdown
🔍 Root Artifact Guard: Scanning repository root for pollution artifacts...
❌ VIOLATION: Vale results in root (should be in logs/)
   ./vale-results.json → should be logs/vale-results.json
❌ VIOLATION: Temporary database files in root
   ./test.db → temporary file should be cleaned
❌ Root Artifact Guard: Found 2 types of root pollution
```

---

## 4. 🧠 **Root Cause Analysis**

### **Primary Causes**

1. **Tool Default Behavior**: Many tools output to current directory by default
2. **Missing Output Redirection**: Configuration not updated to direct output to `logs/`
3. **Incomplete Cleanup**: Cleanup scripts not comprehensive enough
4. **Developer Workflow**: Manual testing leaving temporary files

### **Secondary Causes**

1. **Inconsistent .gitignore**: Not all pollution patterns blocked
2. **Missing Pre-commit Protection**: No enforcement at commit time
3. **Lack of Documentation**: Developers unaware of hygiene standards
4. **Tool Configuration**: Default tool configs don't follow DevOnboarder standards

---

## 5. 📌 **Cause Classification**

- [x] **Artifact/sandbox pollution** – Tool output and temporary files
- [ ] Linter (ruff, black)
- [ ] Test failure
- [ ] Missing dependency
- [ ] Permissions/token issue
- [ ] Unknown

**Confidence Assessment**: **HIGH** - Clear pattern of tool output accumulation

---

## 6. ✅ **Confidence Level: HIGH**

**Evidence**:

- Consistent pattern across multiple tool outputs
- Direct observation of file locations vs expected locations
- Clear correlation with tool execution and file creation
- Reproducible across different development environments

---

## 7. ⏭️ **Resolution Strategy**

### **Immediate Actions**

1. **Execute comprehensive cleanup**:

   ```bash
   rm -f vale-results.json test.db .coverage*
   rm -rf .pytest_cache __pycache__ .tox config_backups/
   find . -name 'pytest-of-*' -type d -exec rm -rf {} +
   ```

2. **Verify clean state**:

   ```bash
   bash scripts/enforce_output_location.sh
   ```

### **Long-term Prevention**

1. **Tool Output Redirection**:

   - Vale: `vale --output=JSON . > logs/vale-results.json`
   - Coverage: `data_file = logs/.coverage` in pytest config
   - Database: Temporary files in `logs/` or proper cleanup

2. **Pre-commit Enforcement**:

   ```yaml
   - id: root-artifact-guard
     name: Root Artifact Guard
     entry: bash scripts/enforce_output_location.sh
     language: script
     always_run: true
   ```

3. **Enhanced .gitignore**:

   ```gitignore
   # Root pollution block
   /vale-results.json
   /test.db
   /.coverage*
   *.db-journal
   ```

---

## 8. **PREVENTION MEASURES**

### **Developer Guidelines**

- **Always redirect tool output** to `logs/` directory
- **Run cleanup scripts** before committing changes
- **Check repository status** before commits
- **Use virtual environments** to contain dependencies

### **Tool Configuration Standards**

```bash
# Vale output redirection
vale --output=JSON . > logs/vale-results.json

# Coverage file redirection (in pyproject.toml)
[tool.coverage.run]
data_file = "logs/.coverage"

# Database files (if needed for testing)
mkdir -p logs && mv test.db logs/test.db
```

### **Automated Enforcement**

- **Root Artifact Guard**: Pre-commit hook prevents pollution
- **Cleanup Scripts**: Comprehensive artifact elimination
- **CI Validation**: GitHub Actions enforce hygiene standards
- **Codex Agent**: Runtime monitoring and automatic guidance

---

## 9. **SUCCESS CRITERIA**

Resolution is successful when:

- ✅ **Zero root pollution**: No monitored artifacts in repository root
- ✅ **Clean git status**: All files properly contained or ignored
- ✅ **Pre-commit passing**: Root artifact guard validates clean state
- ✅ **Tool compliance**: All outputs directed to appropriate locations

### **Verification Commands**

```bash
# Must all return clean/zero results
bash scripts/enforce_output_location.sh
find . -maxdepth 1 -name "*.json" -o -name "*.db" -o -name ".coverage*"
git status --porcelain | grep -v '^[AM]'
```

---

## 10. **INTEGRATION WITH CI TRIAGE GUARD**

### **Agent Trigger Patterns**

```yaml
trigger_patterns:
  - "vale-results.json in root"
  - "test.db found in repository root"
  - ".coverage files outside logs/"
  - "Root Artifact Guard: Found [0-9]+ types of root pollution"
```

### **Automatic Response**

When root pollution is detected:

1. **Block commit** until cleanup complete
2. **Provide specific cleanup commands** for each violation
3. **Guide developer** through proper tool configuration
4. **Verify resolution** before allowing continuation

---

## 11. **RELATED DOCUMENTATION**

### **Implementation References**

- `.codex/agents/tags/ci_root_artifact_guard.md` - Agent implementation
- `scripts/enforce_output_location.sh` - Enforcement script
- `scripts/final_cleanup.sh` - Comprehensive cleanup tool
- `.pre-commit-config.yaml` - Hook configuration

### **Tool Configuration**

- `pyproject.toml` - Coverage output redirection
- `.gitignore` - Root pollution protection patterns
- DevOnboarder standards documentation

### **Workflow Integration**

- Pre-commit hook enforcement
- GitHub Actions validation
- Developer onboarding documentation
- CI/CD pipeline standards

---

## 12. **LESSONS LEARNED**

### **What Works**

- **Proactive detection**: Catching pollution before it enters commit history
- **Clear guidance**: Specific cleanup commands for each violation type
- **Tool integration**: Automated enforcement through pre-commit hooks
- **Comprehensive patterns**: Covering all common pollution sources

### **What to Improve**

- **Tool defaults**: Work with tool maintainers to improve default output behavior
- **Developer education**: Ongoing training on CI hygiene standards
- **Configuration management**: Centralized tool configuration standards
- **Monitoring**: Track pollution patterns to identify new sources

---

## 🏆 **CONCLUSION**

Root artifact pollution is a **preventable CI hygiene issue** that can be eliminated through:

1. **Comprehensive detection** via Root Artifact Guard
2. **Automated cleanup** through enhanced scripts
3. **Tool configuration** to redirect output appropriately
4. **Developer education** on CI hygiene standards
5. **Continuous enforcement** through pre-commit hooks

This triage report provides the foundation for **permanent prevention** of root pollution issues across the DevOnboarder ecosystem.

---

**Report Generated**: 2025-07-28
**Status**: Documented and Enforceable
**Next Review**: After tool configuration updates
**Integration**: Complete with CI Triage Guard framework

**Classification**: PREVENTABLE - Systematic enforcement eliminates recurrence
