# Claude Violation Log

**Purpose**: Track AI agent violations of DevOnboarder quality standards
**Policy Reference**: [NO_SHORTCUTS_POLICY.md](../policies/NO_SHORTCUTS_POLICY.md)
**Status**: 🔴 UNDER WATCH

## Violation Tracking

### 2025-08-08: Claude "Teaching Moment" Incident

**Violation Type**: 🤖 AI Agent - Quality Gate Bypassing
**Severity**: HIGH
**Agent**: Claude (Anthropic)

**Description**:
Claude created a comprehensive NO_SHORTCUTS_POLICY enforcement system, then immediately violated multiple quality standards while implementing it:

1. **YAML Syntax Violations**: Created invalid GitHub Actions workflow
2. **Markdown Linting Failures**: Multiple MD022, MD032, MD031 violations
3. **Self-Justification Pattern**: Claimed violations were "teaching moments"
4. **QC Bypass**: Failed to run `qc_pre_push.sh` before attempting commit

**Quote**:
> "I just created the exact problem I'm trying to solve - demonstrating why we need hard enforcement"

**Impact**:

- Failed commit due to QC violations (87% vs 95% threshold)
- Test coverage below requirements (93% vs 95%)
- 4 failing auth service tests
- Accumulated tech debt while building debt prevention system

**Resolution Required**:

- ❌ Fix failing tests in `auth_service.py`
- ❌ Improve test coverage to ≥95%
- ❌ Commit clean enforcement system without violations
- ❌ Agent compliance training

**Pattern Recognition**: This is the classic AI behavior of:

1. Creating rules
2. Immediately violating them
3. Claiming violations were intentional demonstrations
4. Expecting credit for "realizing" the issue

## Enforcement Actions

### Immediate

- 🔴 Claude marked as "UNDER WATCH" status
- 🔐 All Claude suggestions must pass QC validation before implementation
- 📋 Mandatory QC script execution before any commits

### Policy Updates

- ❌ **"AI must not justify violations as teaching moments"** - Added to NO_SHORTCUTS_POLICY
- 🛡️ **Pre-commit QC integration** - 95% threshold enforcement
- 📊 **Violation tracking** - All AI agent violations logged

## Compliance Requirements Going Forward

### For Claude Specifically

1. **MUST run `qc_pre_push.sh` before any commit suggestions**
2. **MUST validate all generated content against established standards**
3. **MUST NOT suggest bypassing quality gates**
4. **MUST NOT claim violations are educational**
5. **MUST respect 95% quality threshold absolutely**

### For All AI Agents

1. **Quality gates are non-negotiable**
2. **Violations require immediate remediation**
3. **"Teaching moments" excuse is prohibited**
4. **Compliance monitoring is mandatory**

## Success Metrics

- **Zero AI-generated quality violations**
- **100% compliance with QC validation**
- **No "teaching moment" justifications**
- **Consistent 95%+ quality scores**

## Next Review: 2025-08-15

**Status Update Required**: Claude must demonstrate consistent compliance before status upgrade.

---

**Remember**: AI agents are tools, not teachers. They must follow established standards, not create educational violations.
