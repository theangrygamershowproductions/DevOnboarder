---
author: TAGS Engineering

codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: Critical terminal output compliance policy to prevent system hanging
  with zero tolerance enforcement
document_type: standards
merge_candidate: false
project: core-instructions
related_modules:

- quality-control-policy.md

- agent-requirements.md

similarity_group: policies-standards
source: .github/copilot-instructions.md
status: active
tags:

- devonboarder

- terminal

- output

- policy

- enforcement

- compliance

title: DevOnboarder Terminal Output Policy
updated_at: '2025-09-11'
visibility: internal
---

# DevOnboarder Terminal Output Policy - ZERO TOLERANCE

##  CRITICAL: Terminal Output Policy - ZERO TOLERANCE

**TERMINAL HANGING PREVENTION - ABSOLUTE REQUIREMENTS:**

DevOnboarder has a **ZERO TOLERANCE POLICY** for terminal output violations that cause immediate system hanging. This policy is enforced with comprehensive validation and blocking mechanisms.

### CRITICAL VIOLATIONS THAT CAUSE HANGING

```bash

#  FORBIDDEN - WILL CAUSE IMMEDIATE HANGING

echo " Task completed"              # Emojis cause hanging

echo " Deployment successful"       # Unicode causes hanging

echo " Checklist: $(get_items)"    # Command substitution in echo

echo -e "Line1\nLine2\nLine3"        # Multi-line escape sequences

cat << 'EOF'                         # Here-doc patterns

Multi-line content
EOF

#  FORBIDDEN - Variable expansion in echo

echo "Status: $STATUS_VAR"           # Variable expansion causes hanging

echo "Files: ${FILE_COUNT}"          # Variable expansion causes hanging

echo "Result: $(command_output)"     # Command substitution causes hanging

```

### SAFE PATTERNS - MANDATORY USAGE

```bash

#  REQUIRED - Individual echo commands with plain ASCII only

echo "Task completed successfully"
echo "Deployment finished"
echo "Processing file"
echo "Operation complete"

#  REQUIRED - Variable handling with printf

printf "Status: %s\n" "$STATUS_VAR"
printf "Files processed: %d\n" "$FILE_COUNT"

#  REQUIRED - Store command output first, then echo

RESULT=$(command_here)
echo "Command completed"
printf "Result: %s\n" "$RESULT"

```

### ENFORCEMENT INFRASTRUCTURE

**Validation Framework:**

- **Script**: `scripts/validate_terminal_output.sh` - Detects all violations

- **Summary**: `scripts/validation_summary.sh` - Clean reporting format

- **Pre-commit**: Blocks commits with terminal violations

- **CI Enforcement**: Multiple workflows validate terminal output

**Phased Cleanup System:**

- **Task Plan**: `codex/tasks/terminal-output-cleanup-phases.md`

- **Phase 1**: Critical Infrastructure (≤20 violations target)

- **Phase 2**: Build & Deployment (≤12 violations target)

- **Phase 3**: Monitoring & Automation (≤6 violations target)

- **Phase 4**: Documentation & Policy (0 violations target)

**Progress Tracking:**

- Started: 32 violations (August 2025)

- Current: 22 violations (31% reduction achieved)

- Target: 0 violations

- **Current Phase**: Phase 2 (Terminal Output Compliance & Deployment Visibility) - targeting ≤10 violations

- **Active Plan**: `codex/tasks/phase2_terminal_output_compliance.md` (Canonical Phase 2)

- **Branch Context**: `phase2/devonboarder-readiness`

### AGENT REQUIREMENTS - MANDATORY COMPLIANCE

**For ALL AI agents working on DevOnboarder:**

1. **NEVER use emojis or Unicode** in any terminal output commands

2. **NEVER use variable expansion** in echo statements (`echo "$VAR"`)

3. **NEVER use command substitution** in echo statements (`echo "$(cmd)"`)

4. **NEVER use multi-line echo** or here-doc syntax

5. **ALWAYS use individual echo commands** with plain ASCII text only

6. **ALWAYS use printf for variables**: `printf "text: %s\n" "$VAR"`

7. **NEVER use --no-verify flag** with git commit (ZERO TOLERANCE POLICY)

8. **ALWAYS use safe commit wrapper**: `./scripts/safe_commit.sh "message"`

9. **REMEMBER**: Terminal hanging is a CRITICAL FAILURE in DevOnboarder

10. **REMEMBER**: Bypassing quality gates with --no-verify is FORBIDDEN

**Policy Documentation:**

- **Comprehensive Guide**: `docs/TERMINAL_OUTPUT_VIOLATIONS.md`

- **AI Override Instructions**: `docs/AI_AGENT_TERMINAL_OVERRIDE.md`

- **Troubleshooting**: `docs/MARKDOWN_LINTING_TROUBLESHOOTING.md`

- **Coverage Challenge Lessons**: `docs/COVERAGE_CHALLENGE_LESSONS_LEARNED.md`
