---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: agent-memory-best-practices.md-docs
status: active
tags:
- documentation
title: Agent Memory Best Practices
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder Agent Memory Best Practices

## 🎯 **Agent Memory Strategy**

DevOnboarder uses a **comprehensive frontmatter infrastructure** for agent memory and context management. This document establishes best practices to prevent duplication and repository pollution.

## ✅ **Approved Memory Patterns**

### **1. Agent Frontmatter System (Primary)**

**Schema Validation**: `schema/agent-schema.json` (133 lines)

**Agent Registry**: `.codex/agents/index.json` (27+ registered agents)

**CI Integration**: `scripts/validate_agents.py` (pre-commit enforcement)

```yaml
---
codex-agent:

    name: Agent.ExampleBot
    role: Manages specific functionality
    scope: Defined operational area
    triggers: Activation conditions
    output: Log file location
permissions:
    - repo:read

    - workflows:write

---

```

### **2. Session Documentation (Approved)**

**Location**: `docs/sessions/YYYY-MM-DD-session-topic.md`

**Purpose**: Session-specific achievements and context
**Format**: Markdown with proper linting compliance

### **3. Priority Context Documentation**

**Location**: `docs/priority-context-[date-or-topic].md`

**Purpose**: Strategic context and priority frameworks
**Lifecycle**: Long-term reference documentation

### **4. Agent Context Loading Strategy**

**Location**: `docs/agent-context-loading-strategy.md`

**Purpose**: Systematic context loading for new conversations
**Features**: Cross-session memory patterns, anti-duplication guidance

## ❌ **Prohibited Memory Patterns**

### **SESSION_HANDOFF.md Files (ELIMINATED)**

**Why Prohibited**:

- Creates repository pollution

- Duplicates existing frontmatter infrastructure

- Bypasses validated schema system

- Requires manual maintenance outside CI validation

**Historical Context**: SESSION_HANDOFF.md approach was eliminated September 11, 2025, in favor of existing comprehensive infrastructure.

### **Temporary Session Files in Repository Root**

**Prohibited Patterns**:

- `CURRENT_SESSION.md`

- `ACTIVE_WORK.md`

- `HANDOFF_NOTES.md`

- Any temporary documentation files in repository root

**Reason**: DevOnboarder maintains "quiet reliability" - temporary files create noise and bypass quality gates.

## 🧠 **Cross-Session Memory Implementation**

### **For Agent Continuity**

1. **Check Agent Registry**: Review `.codex/agents/index.json` for agent-specific metadata

2. **Load Recent Sessions**: Review `docs/sessions/` for latest completed work

3. **Validate Current Context**: Use `git status` and branch information

4. **Follow Loading Strategy**: Use `docs/agent-context-loading-strategy.md` systematic approach

### **For Session Handoffs**

1. **Document in Sessions Directory**: Create `docs/sessions/YYYY-MM-DD-topic.md`

2. **Update Priority Context**: Modify or create `docs/priority-context-*.md`

3. **Leverage Agent Registry**: Reference existing agent metadata

4. **NO TEMPORARY FILES**: Never create temporary session files in repository root

## 🎯 **Quality Standards**

### **All Memory Documentation Must**

- ✅ Pass markdown linting validation (MD022, MD032, MD031, MD007, MD009)

- ✅ Include proper trailing newlines

- ✅ Use blank lines around headings and lists

- ✅ Follow DevOnboarder documentation standards

### **Schema Validation Required**

- ✅ Agent frontmatter must validate against `schema/agent-schema.json`

- ✅ CI validation via `scripts/validate_agents.py`

- ✅ Pre-commit hooks enforce compliance

- ✅ 100% agent registry coverage maintained

## 📋 **Implementation Checklist**

### **For New Agents**

- [ ] Create agent documentation with proper codex-agent frontmatter

- [ ] Register in `.codex/agents/index.json`

- [ ] Validate against schema using `python scripts/validate_agents.py`

- [ ] Follow existing agent patterns from `/agents/` directory

- [ ] NO temporary session files

### **For Session Management**

- [ ] Use `docs/sessions/` directory for session-specific documentation

- [ ] Reference existing priority context documentation

- [ ] Follow systematic context loading strategy

- [ ] Leverage agent registry for continuity

- [ ] NO SESSION_HANDOFF.md or similar temporary files

## 🎯 **Strategic Benefits**

**Infrastructure Leverage**:

- 100% complete frontmatter system utilization

- Validated schema enforcement

- CI integration prevents drift

**Repository Hygiene**:

- Eliminates temporary file pollution

- Maintains "quiet reliability" philosophy

- Reduces maintenance overhead

**Quality Assurance**:

- All memory documentation follows established standards

- Schema validation prevents inconsistency

- CI enforcement ensures compliance

---

**Status**: Anti-Duplication Best Practices Established

**Effective Date**: September 11, 2025
**Supersedes**: SESSION_HANDOFF.md approach (eliminated)
**Reference**: See `docs/anti-duplication-strategy-complete.md` for elimination process
