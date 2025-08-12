# DevOnboarder ASCII Replacement Standards

## Overview

DevOnboarder enforces **ZERO TOLERANCE** for emojis and Unicode characters in terminal output due to system hanging issues. All development must use ASCII replacements.

## Mandatory ASCII Replacements

### Status Indicators

- ✅ → `[OK]` or `SUCCESS`
- ❌ → `[FAIL]` or `ERROR`
- ⚠️ → `[WARN]` or `WARNING`
- ℹ️ → `[INFO]` or `NOTE`

### Action/Process Indicators

- 🚀 → `[DEPLOY]` or `STARTING`
- 🔧 → `[TOOLS]` or `BUILDING`
- 🧹 → `[CLEAN]` or `CLEANING`
- 🔍 → `[SEARCH]` or `SCANNING`
- 📋 → `[LIST]` or `CHECKLIST`
- 💡 → `[IDEA]` or `TIP`

### Security/Access

- 🔐 → `[LOCK]` or `SECURE`
- 🔓 → `[UNLOCK]` or `OPEN`
- 🛡️ → `[SHIELD]` or `PROTECTED`

### Documentation/Content

- 📖 → `[DOCS]` or `MANUAL`
- 📝 → `[EDIT]` or `WRITING`
- 📄 → `[FILE]` or `DOCUMENT`

### Targets/Goals

- 🎯 → `[TARGET]` or `GOAL`
- 🏆 → `[TROPHY]` or `SUCCESS`

### Intelligence/Processing

- 🧠 → `[BRAIN]` or `PROCESSING`
- 🤖 → `[BOT]` or `AUTOMATED`

### Symbols/Punctuation

- → → `->`
- • → `*` or `-`
- ‑ → `-`
- … → `...`

## Implementation Requirements

### 1. **Pre-commit Hook Integration**

All commits are automatically scanned for emoji violations using our data-driven validation system.

### 2. **Documentation Standards**

- All new documentation must use ASCII replacements
- Existing docs are being systematically updated
- No exceptions for "visual appeal" - functionality over aesthetics

### 3. **Code Comments**

```bash
# ❌ WRONG - emoji will cause terminal hanging
echo "✅ Task completed"

# ✅ CORRECT - ASCII replacement
echo "[OK] Task completed"
echo "SUCCESS Task completed"
```

### 4. **Git Commit Messages**

```bash
# ❌ WRONG
git commit -m "🚀 DEPLOY: launch new feature"

# ✅ CORRECT  
git commit -m "[DEPLOY] launch new feature"
git commit -m "DEPLOY: launch new feature"
```

### 5. **Workflow Names and Steps**

```yaml
# ❌ WRONG
name: "🔐 Security Enforcement"

# ✅ CORRECT
name: "Security Enforcement"
name: "[SECURE] Policy Enforcement"
```

## Automated Enforcement

### Detection System

- **Database**: `.codex/terminal_violations.json` contains all problematic characters
- **Validation**: `scripts/validate_terminal_output_simple.sh` scans all files
- **Pre-commit**: Automatic blocking of emoji violations
- **CI/CD**: Workflow-level validation enforcement

### Safe Replacement Lookup

The violations database includes automatic replacement suggestions:

```json
"safe_replacements": {
  "🔐": "[LOCK]",
  "🎯": "[TARGET]",
  "✅": "[OK]",
  "❌": "[FAIL]"
}
```

## Developer Workflow

### Before Committing

1. **Use ASCII from start** - don't add emojis planning to fix later
2. **Check terminal output** - run validation script if unsure
3. **Use replacement guide** - reference this document for standard replacements

### When Adding New Features

1. **Design with ASCII** - plan terminal output with ASCII characters only
2. **Update database** - add new problematic characters to `.codex/terminal_violations.json`
3. **Document patterns** - update this guide with new replacement standards

### Code Review Checklist

- [ ] No emojis in echo/printf statements
- [ ] No Unicode arrows or bullets in terminal output
- [ ] ASCII replacements used consistently
- [ ] Validation script passes clean

## Rationale

**Why ASCII-only?**

- **System Stability**: Emojis cause immediate terminal hanging in DevOnboarder environment
- **Reliability**: ASCII works consistently across all systems and terminals
- **Automation**: Simple character detection enables robust validation
- **Consistency**: Standardized replacements improve readability

**Performance Impact**: None - ASCII is faster to process than Unicode

**Accessibility**: ASCII is more accessible than emoji-dependent interfaces

## Enforcement Policy

**ZERO TOLERANCE**: Any emoji or problematic Unicode character in terminal output will:

1. **Block pre-commit** hooks
2. **Fail CI/CD** pipelines  
3. **Require immediate fixing** before merge
4. **Generate automatic issues** for pattern tracking

This policy ensures DevOnboarder's "quiet reliability" philosophy by preventing terminal hanging issues that disrupt development workflow.

## Future Enhancements

### Planned Improvements

- **Auto-fix script**: Automatic ASCII replacement during pre-commit
- **IDE integration**: Real-time emoji detection in VS Code
- **Team training**: Onboarding materials emphasizing ASCII-first development

### Pattern Recognition

The error learning system tracks emoji violations to improve automation and provide better developer guidance over time.

---

**Remember**: When in doubt, use plain ASCII text. It's more reliable, faster, and ensures compatibility with DevOnboarder's quality standards.
