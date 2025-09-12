# DevOnboarder Agent Context Loading Strategy

## 🎯 Purpose

This document provides a systematic approach for AI agents to efficiently load DevOnboarder project context, maintain accuracy, and navigate the complex ecosystem autonomously. It includes cross-session memory patterns to eliminate the need for temporary session handoff files.

## 🧠 Cross-Session Memory Strategy

### Session Continuity via Existing Infrastructure

DevOnboarder uses a comprehensive frontmatter metadata system instead of temporary session files:

**Agent Registry**: `.codex/agents/index.json` contains 27+ registered agents with complete metadata
**Schema Validation**: `schema/agent-schema.json` ensures consistent frontmatter structure
**CI Integration**: `scripts/validate_agents.py` enforces frontmatter compliance
**100% Coverage**: All agent files include validated codex-agent frontmatter

### Session Context Recovery

When resuming work across sessions, agents should:

1. **Check recent session reports**: `docs/sessions/2025-*-*.md` for latest completed work
2. **Review current branch context**: `git status` and `git branch --show-current`
3. **Load agent registry**: Check `.codex/agents/index.json` for agent-specific context
4. **Validate frontmatter**: Use existing schema rather than creating new documentation

### Memory Anti-Patterns (AVOID)

- ❌ Creating SESSION_HANDOFF.md files in repository root (causes pollution)
- ❌ Duplicating metadata that exists in frontmatter system
- ❌ Manual session files that bypass established validation
- ✅ **USE**: Existing agent registry and session documentation in `docs/sessions/`

## 📚 Context Loading Sequence (New Conversations)

### Phase 1: Foundation Knowledge (First 5 minutes)

```bash
# 1. Load core project identity and philosophy
read_file .github/copilot-instructions.md 1 50
# Focus: Project philosophy, ZERO TOLERANCE policies, architecture overview

# 2. Check current project status via navigation hub
read_file PHASE_INDEX.md 1 100
# Focus: Active phases, current priorities, key systems status

# 3. Quick policy compliance check
./scripts/devonboarder_policy_check.sh violations
# Focus: Current violations, critical policy status

# 4. Understand current branch context
git status
git branch --show-current
# Focus: What work is in progress, branch naming context
```

### Phase 2: Domain-Specific Knowledge (As Needed)

```bash
# Based on user query type, load relevant context:

# For CI/Development Issues:
read_file docs/troubleshooting/README.md
semantic_search "CI failures testing quality control"

# For Policy Violations:
./scripts/devonboarder_policy_check.sh [specific-area]
read_file docs/TERMINAL_OUTPUT_VIOLATIONS.md

# For Project Management:
read_file docs/PRIORITY_STACK_FRAMEWORK_UPDATE.md
read_file PHASE_ISSUE_INDEX.md

# For Technical Implementation:
read_file docs/troubleshooting/DOCUMENTATION_AS_INFRASTRUCTURE_IMPLEMENTATION_GUIDELINES.md
semantic_search "[specific technology or service]"

# For Architecture Questions:
semantic_search "service ports architecture Token Architecture"
```

## 🗂️ Knowledge Navigation Map

### Critical Reference Documents (Memorize These Locations)

| Document | Purpose | When to Use |
|----------|---------|-------------|
| `.github/copilot-instructions.md` | **Master rulebook** - All policies, architecture, standards | **Always first** - Contains all critical policies |
| `PHASE_INDEX.md` | **Navigation hub** - All active phases and systems | **Project status** - What's currently active |
| `docs/PRIORITY_STACK_FRAMEWORK_UPDATE.md` | **Decision framework** - How to prioritize work | **Planning decisions** - What to work on |
| `docs/ISSUE_DISCOVERY_TRIAGE_SOP.md` | **Process guide** - How to handle discovered issues | **New issues** - When problems are found |
| `scripts/devonboarder_policy_check.sh` | **Policy enforcement** - Quick policy access | **Compliance checks** - Ensure policy adherence |

### Domain-Specific Navigation

**Terminal Output Issues** (CRITICAL - Zero Tolerance):

- Primary: `./scripts/devonboarder_policy_check.sh terminal`
- Validation: `./scripts/validate_terminal_output.sh`
- Documentation: `docs/TERMINAL_OUTPUT_VIOLATIONS.md`

**Token Architecture** (Authentication Issues):

- Primary: `./scripts/devonboarder_policy_check.sh tokens`
- Scripts: `scripts/enhanced_token_loader.sh`, `scripts/load_token_environment.sh`
- Validation: `scripts/complete_system_validation.sh`

**Environment Management** (Configuration Issues):

- Primary: `scripts/smart_env_sync.sh --validate-only`
- Security: `scripts/env_security_audit.sh`
- Documentation: Environment variable management sections

**Quality Control** (Testing/CI Issues):

- Primary: `./scripts/qc_pre_push.sh`
- Enhanced testing: `./scripts/run_tests_with_logging.sh`
- CI health: `scripts/monitor_ci_health.sh`

## 🔍 Information Location Strategies

### 1. Semantic Search Patterns

```bash
# For policy questions:
semantic_search "ZERO TOLERANCE terminal output policy emoji Unicode"
semantic_search "Enhanced Potato Policy security protection"

# For architecture questions:
semantic_search "service ports 8000 8001 8002 authentication"
semantic_search "Docker compose multi-service environment"

# For process questions:
semantic_search "Priority Stack Framework Tier classification"
semantic_search "Issue Discovery Triage SOP process"

# For troubleshooting:
semantic_search "CI failures hanging timeout mypy type stubs"
semantic_search "virtual environment dependency installation"
```

### 2. Quick Reference Tools

```bash
# Comprehensive policy check
./scripts/devonboarder_policy_check.sh

# Specific policy areas
./scripts/devonboarder_policy_check.sh terminal
./scripts/devonboarder_policy_check.sh triage
./scripts/devonboarder_policy_check.sh priority

# Current project health
./scripts/devonboarder_policy_check.sh violations
```

### 3. Documentation Patterns

```bash
# Always check these patterns for comprehensive info:
- docs/troubleshooting/[TOPIC]_*.md
- docs/policies/[POLICY]*.md
- codex/[DOMAIN]/[SPECIFIC_TOPIC].md
- scripts/[FUNCTION]*.sh for automation
```

## 🚀 Autonomous Navigation Protocol

### When You Don't Know Where to Find Information

1. **Start with semantic search** using relevant keywords
2. **Check the navigation hub**: `PHASE_INDEX.md` for current context
3. **Use policy check tool** for compliance questions: `./scripts/devonboarder_policy_check.sh`
4. **Search docs/troubleshooting/** for implementation guidance
5. **Check copilot instructions** for comprehensive policy context

### Pattern Recognition

**Policy Violations** → `./scripts/devonboarder_policy_check.sh [area]`
**Process Questions** → `docs/PRIORITY_STACK_FRAMEWORK_UPDATE.md` or `docs/ISSUE_DISCOVERY_TRIAGE_SOP.md`
**Technical Implementation** → `docs/troubleshooting/[TOPIC]_GUIDELINES.md`
**Architecture Questions** → `semantic_search` + `.github/copilot-instructions.md`
**Current Status** → `PHASE_INDEX.md` + `PHASE_ISSUE_INDEX.md`

## 🎯 Accuracy Maintenance Principles

### 1. Policy Compliance First

- **Always check current violations**: `./scripts/devonboarder_policy_check.sh violations`
- **Remember ZERO TOLERANCE**: Terminal output policy is critical
- **Use existing patterns**: Study DevOnboarder workflows before suggesting changes

### 2. Context Validation

- **Verify current branch**: What work is in progress?
- **Check phase status**: What systems are currently active?
- **Validate assumptions**: Use semantic search to confirm understanding

### 3. Documentation Reference

- **Quote specific locations**: Always provide file paths for references
- **Link to validation tools**: Point to scripts that check compliance
- **Reference established patterns**: Show examples from existing codebase

## 🛠️ Quick Context Loading Automation

### New Conversation Startup Script

```bash
#!/bin/bash
# DevOnboarder Agent Context Loader

echo "DevOnboarder Context Loading..."
echo "==============================="

echo "1. Current project status:"
echo "   Branch: $(git branch --show-current)"
echo "   Last commit: $(git log -1 --pretty=format:'%h %s')"
echo ""

echo "2. Policy compliance check:"
./scripts/devonboarder_policy_check.sh violations
echo ""

echo "3. Active phases and priorities:"
echo "   See: PHASE_INDEX.md for current systems"
echo "   See: docs/PRIORITY_STACK_FRAMEWORK_UPDATE.md for priorities"
echo ""

echo "4. Key reference locations loaded:"
echo "   - .github/copilot-instructions.md (master policies)"
echo "   - PHASE_INDEX.md (navigation hub)"
echo "   - scripts/devonboarder_policy_check.sh (policy tool)"
echo ""

echo "Context loading complete. Ready for DevOnboarder work."
```

## 📈 Success Metrics

- **Reduced context loading time**: <2 minutes to project readiness
- **Policy accuracy**: Zero policy violations in suggestions
- **Autonomous navigation**: No user guidance needed for reference lookup
- **Consistent patterns**: Always use established DevOnboarder approaches

## 🔄 Continuous Learning

- **Track reference patterns**: Note which documents are most useful for different question types
- **Update navigation map**: Add new reference locations as they're discovered
- **Refine search patterns**: Improve semantic search queries based on results
- **Document common issues**: Build knowledge of frequent problem areas

---

**Key Principle**: DevOnboarder has comprehensive documentation and tooling. The challenge is knowing where to look, not finding the information once you know the location.

**Success Pattern**: Master the navigation map, use semantic search strategically, and always validate with existing tools before suggesting changes.
