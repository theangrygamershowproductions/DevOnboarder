# CRITICAL AI Agent Protocol Rules

## TERMINAL OUTPUT - ZERO TOLERANCE

**NEVER use these (WILL CAUSE HANGING):**

```bash
echo "✅ text"           # NO emojis
echo "Status: $VAR"     # NO variable expansion  
echo -e "line1\nline2"  # NO multi-line
```

**ALWAYS use these:**

```bash
echo "Task completed"              # Plain ASCII only
printf "Status: %s\n" "$VAR"     # Variables with printf
```

## ABSOLUTELY FORBIDDEN

1. **NEVER** use `git commit --no-verify` (bypasses quality gates) <!-- POTATO: EMERGENCY APPROVED - documentation-example-violation-20250810 -->
2. **NEVER** use emojis/Unicode in terminal output
3. **NEVER** install to system Python (always use `.venv`)
4. **NEVER** modify linting configs without human approval
5. **NEVER** create non-compliant markdown expecting auto-fix

## MANDATORY PATTERNS

1. **ALWAYS** activate virtual environment: `source .venv/bin/activate`  
2. **ALWAYS** use safe commit: `./scripts/safe_commit.sh "message"`
3. **ALWAYS** use schema-driven AAR system
4. **ALWAYS** create markdown compliant from start
5. **ALWAYS** follow validation-driven troubleshooting

## VALIDATION FIRST

Before doing anything, run appropriate validation:

- `./scripts/qc_pre_push.sh` - Quality control
- `bash scripts/validate_terminal_output.sh` - Terminal output check
- Virtual environment check: `which python` should show `.venv`

**Remember**: DevOnboarder philosophy is "quiet reliability" - work correctly without drama.
