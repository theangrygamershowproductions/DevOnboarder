---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: v1-v1
status: active
tags:

- documentation

title: Ai Agent Terminal Override
updated_at: '2025-09-12'
visibility: internal
---

# AI Agent Terminal Output Override Instructions

## CRITICAL OVERRIDE FOR ALL AI AGENTS

**BEFORE ANY echo STATEMENT IN GITHUB ACTIONS WORKFLOWS:**

### Mandatory Pre-Echo Validation Checklist

1. **Is this plain ASCII text only?**

   - ❌ NO emojis (✅, ❌, 🛠️, 📊, 📈, 📥, 🔗, 🐛, ⚠️, 💡, 🎯, 🚀, 📋, 🔍, 📝)

   - ❌ NO Unicode characters

   - ❌ NO special formatting symbols

   - ✅ ONLY letters, numbers, basic punctuation (. , : ; - _ )

2. **Is this a single line with no variables or command substitution?**

   - ❌ NO `$(command)` substitution

   - ❌ NO `$VARIABLE` expansion

   - ❌ NO `${VARIABLE}` expansion

   - ✅ ONLY plain static text

3. **Am I using individual echo commands instead of multi-line?**

   - ❌ NO multi-line string variables

   - ❌ NO here-doc in echo context

   - ❌ NO escape sequences (\n, \t)

   - ✅ ONLY individual echo statements

**IF ANY ANSWER IS NO, STOP AND REWRITE.**

## Approved Patterns Only

### ✅ SAFE - Individual Echo Commands

```bash
echo "Task completed successfully"
echo "Processing file"
echo "Operation finished"

```

### ✅ SAFE - File-Based Complex Output

```bash
cat > output.md << 'EOF'
**Complex Content**

Multi-line content goes here.

Can include formatting and details.
EOF

```

### ❌ FORBIDDEN - Will Cause Terminal Hanging

```bash

# NEVER USE THESE PATTERNS

echo "✅ Success"                    # Emoji

echo "Files: $(ls | wc -l)"         # Command substitution

echo "Status: $BUILD_STATUS"        # Variable expansion

COMMENT="Line1\nLine2"              # Multi-line variable

echo "$COMMENT"                     # Multi-line echo

echo -e "Line1\nLine2"              # Escape sequences

```

## Emergency Override Protocol

**If tempted to use forbidden patterns:**

1. **STOP** - Do not proceed with the violation

2. **REWRITE** - Use only approved patterns from above

3. **VALIDATE** - Check against the three mandatory questions

4. **PROCEED** - Only after confirming compliance

## Enforcement Reality

- **Pre-commit hooks** will block violations

- **CI pipelines** will fail on violations

- **Code review bots** will auto-reject PRs

- **Terminal hanging** is immediate and real

## Zero Tolerance Rationale

DevOnboarder's terminal output policy exists because:

- Violations cause **immediate system hanging**

- No workarounds or exceptions exist

- System reliability depends on strict compliance

- Real production incidents have occurred

## Mandatory Acknowledgment

**Every AI agent must acknowledge:**

> "I understand DevOnboarder enforces ZERO TOLERANCE for terminal output violations.
> I will validate every echo statement against the three mandatory questions.
> I will use ONLY individual echo commands with plain ASCII text.
> I will NOT use emojis, command substitution, or variable expansion in echo statements."

## Template Enforcement

Use these templates exclusively:

### Status Updates

```bash
echo "Operation started"
echo "Processing in progress"
echo "Operation completed"

```

### Error Reporting

```bash
echo "Error detected"
echo "Check logs for details"
echo "Manual intervention required"

```

### File Operations

```bash
echo "Creating output file"
cat > result.txt << 'EOF'
Complex content here
EOF
echo "File creation completed"

```

**REMEMBER: The three validation questions are non-negotiable. Every echo statement must pass all three checks.**
