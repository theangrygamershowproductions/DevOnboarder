---
similarity_group: frameworks-strategic-planning
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# PR Workflow Checklist

## Critical Process Requirements for DevOnboarder PRs

### **🚨 Mandatory Pre-Merge Checklist**

#### **1. Code Quality Validation**

- [ ] **QC Pre-Push**: Run `./scripts/qc_pre_push.sh` (95% threshold required)
- [ ] **All CI Checks**: Verify all automated checks are passing
- [ ] **Virtual Environment**: Ensure all work done in proper `.venv` context

#### **2. Copilot Inline Comment Review**

> ⚠️ **CRITICAL STEP - Do NOT skip this**

- [ ] **Check for Comments**: Run `bash scripts/check_pr_inline_comments.sh <PR_NUMBER>`
- [ ] **Address ALL Comments**: Fix every Copilot inline comment found
- [ ] **Verify Resolution**: Re-run script to confirm all comments addressed
- [ ] **Document Fixes**: Include comment IDs in commit messages

**Why This Step is MANDATORY**:

- Copilot comments identify critical markdown rendering issues
- Unresolved comments can block clean CI completion
- Missing this step prevents proper quality assurance
- Creates workflow delays and process gaps

#### **3. Branch and Merge Validation**

- [ ] **Branch Updated**: Ensure branch is current with main (`git merge origin/main`)
- [ ] **Conflict Resolution**: All merge conflicts resolved properly
- [ ] **Clean History**: No broken commits or malformed messages

#### **4. Documentation Standards**

- [ ] **Markdown Compliance**: All files pass markdownlint validation
- [ ] **Cross-References**: All internal links updated and functional
- [ ] **Framework Standards**: Documentation follows DevOnboarder structure

### **Process Enforcement**

#### **Automated Validation**

```bash
# Complete pre-merge validation
./scripts/qc_pre_push.sh

# Check Copilot comments (MANDATORY)
bash scripts/check_pr_inline_comments.sh <PR_NUMBER>

# Validate branch status
gh pr checks <PR_NUMBER>
```

#### **Manual Verification**

1. **Review PR description** for completeness and accuracy
2. **Verify acceptance criteria** are met for the feature/fix
3. **Check integration points** with existing DevOnboarder systems
4. **Confirm framework compliance** for documentation changes

### **Common Issues and Prevention**

#### **Copilot Comment Oversights**

**Problem**: Skipping inline comment review
**Impact**: Markdown rendering failures, CI blocks
**Prevention**: Make this step mandatory in all PR workflows

#### **Branch Lag Issues**

**Problem**: Working on outdated branch
**Impact**: Merge conflicts, CI failures
**Prevention**: Regular branch updates with main

#### **Quality Gate Bypassing**

**Problem**: Using `--no-verify` or skipping QC checks
**Impact**: Reduced code quality, technical debt
**Prevention**: Use `scripts/safe_commit.sh` wrapper only

### **Emergency Procedures**

#### **When CI Hangs**

1. Check for terminal output policy violations
2. Verify Root Artifact Guard compliance
3. Review branch update requirements
4. Check for token authentication issues

#### **When Copilot Comments Block Merge**

1. **DO NOT** ignore or bypass comments
2. Run comment extraction script for full details
3. Fix each comment systematically
4. Verify resolution before declaring ready

---

**Process Version**: 1.0.0
**Last Updated**: September 16, 2025
**Enforcement Level**: MANDATORY for all DevOnboarder PRs
**Authority**: Strategic Planning Framework v1.0.0
