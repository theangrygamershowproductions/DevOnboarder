---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: agent-context-loading-strategy.md-docs
status: active
tags:

- documentation

title: Agent Context Loading Strategy
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder Agent Context Loading Strategy

## 🎯 Purpose

This document provides a systematic approach for AI agents to efficiently load DevOnboarder project context, maintain accuracy, and navigate the complex ecosystem autonomously. It includes cross-session memory patterns to eliminate the need for temporary session handoff files.

## 🧠 Cross-Session Memory Strategy

### Session Continuity via Existing Infrastructure

DevOnboarder uses a comprehensive frontmatter metadata system instead of temporary session files:

**Agent Registry**: `.codex/agents/index.json` contains 27 registered agents with complete metadata

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

-  Creating SESSION_HANDOFF.md files in repository root (causes pollution)

-  Duplicating metadata that exists in frontmatter system

-  Manual session files that bypass established validation

-  **USE**: Existing agent registry and session documentation in `docs/sessions/`

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

# Based on user query type, load relevant context

# For CI/Development Issues

read_file docs/troubleshooting/README.md
semantic_search "CI failures testing quality control"

# For Policy Violations

./scripts/devonboarder_policy_check.sh [specific-area]
read_file docs/TERMINAL_OUTPUT_VIOLATIONS.md

# For Project Management

read_file docs/PRIORITY_STACK_FRAMEWORK_UPDATE.md
read_file PHASE_ISSUE_INDEX.md

# For Technical Implementation

read_file docs/troubleshooting/DOCUMENTATION_AS_INFRASTRUCTURE_IMPLEMENTATION_GUIDELINES.md
semantic_search "[specific technology or service]"

# For Architecture Questions

semantic_search "service ports architecture Token Architecture"

```

## FOLDER: Knowledge Navigation Map

### Critical Reference Documents (Memorize These Locations)

| Document | Purpose | When to Use |
|----------|---------|-------------|
| `.github/copilot-instructions.md` | **Core bootstrap** - Essential project overview and critical policies | **Always first** - Agent initialization |

| `docs/MODULAR_DOCUMENTATION_INDEX.md` | **Modular navigation** - Complete guide to 16 specialized modules | **Detailed work** - Specific domain needs |

| `PHASE_INDEX.md` | **Navigation hub** - All active phases and systems | **Project status** - What's currently active |

| `docs/PRIORITY_STACK_FRAMEWORK_UPDATE.md` | **Decision framework** - How to prioritize work | **Planning decisions** - What to work on |

| `docs/ISSUE_DISCOVERY_TRIAGE_SOP.md` | **Process guide** - How to handle discovered issues | **New issues** - When problems are found |

### Modular Documentation Quick Access

**Critical Policies** (ZERO TOLERANCE):

- Primary: `docs/policies/terminal-output-policy.md` - Terminal hanging prevention

- Environment: `docs/policies/virtual-environment-policy.md` - Isolation requirements

- Security: `docs/policies/potato-policy.md` - File protection mechanisms

- Quality: `docs/policies/quality-control-policy.md` - 95% QC standards

**Development Workflow**:

- Workflow: `docs/development/development-workflow.md` - Complete development guide

- Architecture: `docs/development/architecture-overview.md` - TAGS stack integration

- Quality: `docs/development/code-quality-requirements.md` - Linting and testing

- Structure: `docs/development/file-structure-conventions.md` - Directory organization

**Integration & Automation**:

- Services: `docs/integration/service-integration-patterns.md` - API and bot patterns

- CI/CD: `docs/integration/ci-cd-automation.md` - GitHub Actions ecosystem

- Integration: `docs/integration/common-integration-points.md` - Feature workflows

**Agent & Troubleshooting**:

- Agents: `docs/agents/agent-requirements.md` - AI agent compliance guidelines

- Issues: `docs/troubleshooting/common-issues-resolution.md` - Problem resolution

- Systems: `docs/troubleshooting/devonboarder-key-systems.md` - Key utilities

### Domain-Specific Navigation

**Terminal Output Issues** (CRITICAL - Zero Tolerance):

- Primary: `docs/policies/terminal-output-policy.md`

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

##  Information Location Strategies

### 1. Semantic Search Patterns

```bash

# For policy questions

semantic_search "ZERO TOLERANCE terminal output policy emoji Unicode"
semantic_search "Enhanced Potato Policy security protection"

# For architecture questions

semantic_search "service ports 8000 8001 8002 authentication"
semantic_search "Docker compose multi-service environment"

# For process questions

semantic_search "Priority Stack Framework Tier classification"
semantic_search "Issue Discovery Triage SOP process"

# For troubleshooting

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

# Modular documentation structure (September 2025)

- docs/policies/[POLICY]*.md          # Critical policies and requirements

- docs/development/[ASPECT]*.md       # Development workflows and standards

- docs/integration/[PATTERN]*.md      # Service integration and CI/CD

- docs/agents/[REQUIREMENT]*.md       # Agent-specific guidelines

- docs/troubleshooting/[TOPIC]*.md    # Problem resolution patterns

- scripts/[FUNCTION]*.sh              # Automation and validation tools

```

##  Autonomous Navigation Protocol

### When You Don't Know Where to Find Information

1. **Start with core bootstrap**: `.github/copilot-instructions.md` for project overview

2. **Use modular index**: `docs/MODULAR_DOCUMENTATION_INDEX.md` for specific domains

3. **Check the navigation hub**: `PHASE_INDEX.md` for current project context

4. **Use semantic search** with relevant keywords across modular docs

5. **Search specific modules** based on need (policies, development, integration, etc.)

### Pattern Recognition

**Policy Questions**  `docs/policies/[specific-policy].md`

**Development Setup**  `docs/development/development-workflow.md`

**Integration Patterns**  `docs/integration/service-integration-patterns.md`

**Agent Compliance**  `docs/agents/agent-requirements.md`

**Problem Solving**  `docs/troubleshooting/common-issues-resolution.md`

**Architecture Questions**  `docs/development/architecture-overview.md`

**Quality Control**  `docs/policies/quality-control-policy.md`

**Security Issues**  `docs/policies/potato-policy.md`  `docs/policies/security-best-practices.md`

**Current Status**  `PHASE_INDEX.md`  `PHASE_ISSUE_INDEX.md`

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

##  Quick Context Loading Automation

### New Conversation Startup Script

```bash
#!/bin/bash

# DevOnboarder Agent Context Loader (Updated for Modular Structure)

echo "DevOnboarder Context Loading..."
echo "==============================="

echo "1. Current project status:"

echo "   Branch: $(git branch --show-current)"
echo "   Last commit: $(git log -1 --pretty=format:'%h %s')"
echo ""

echo "2. Core documentation structure:"

echo "   Bootstrap: .github/copilot-instructions.md (Core overview)"
echo "   Modular Index: docs/MODULAR_DOCUMENTATION_INDEX.md (Navigation)"
echo "   Policies: docs/policies/ (Critical requirements)"
echo "   Development: docs/development/ (Workflow guides)"
echo "   Integration: docs/integration/ (Service patterns)"
echo "   Troubleshooting: docs/troubleshooting/ (Problem resolution)"
echo ""

echo "3. Active phases and priorities:"

echo "   See: PHASE_INDEX.md for current systems"
echo "   See: docs/PRIORITY_STACK_FRAMEWORK_UPDATE.md for priorities"
echo ""

echo "4. Key reference locations loaded:"

echo "   - .github/copilot-instructions.md (core bootstrap)"

echo "   - docs/MODULAR_DOCUMENTATION_INDEX.md (navigation guide)"

echo "   - docs/policies/terminal-output-policy.md (CRITICAL compliance)"

echo "   - docs/policies/virtual-environment-policy.md (environment)"

echo "   - docs/agents/agent-requirements.md (AI agent guidelines)"

echo ""

echo "Context loading complete. Ready for DevOnboarder work."
echo "Use 'docs/MODULAR_DOCUMENTATION_INDEX.md' for detailed navigation."

```

## GROW: Success Metrics

- **Reduced context loading time**: <2 minutes to project readiness

- **Policy accuracy**: Zero policy violations in suggestions

- **Autonomous navigation**: No user guidance needed for reference lookup

- **Consistent patterns**: Always use established DevOnboarder approaches

## SYNC: Continuous Learning

- **Track reference patterns**: Note which documents are most useful for different question types

- **Update navigation map**: Add new reference locations as they're discovered

- **Refine search patterns**: Improve semantic search queries based on results

- **Document common issues**: Build knowledge of frequent problem areas

---

**Key Principle**: DevOnboarder has comprehensive documentation and tooling. The challenge is knowing where to look, not finding the information once you know the location.

**Success Pattern**: Master the navigation map, use semantic search strategically, and always validate with existing tools before suggesting changes.
