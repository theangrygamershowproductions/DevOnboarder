---
similarity_group: navigation-navigation

content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---

# DevOnboarder Navigation Framework - Phase 1 MVN

## Overview

The **Minimum Viable Navigator (MVN)** is a constrained experiment to optimize AI conversation efficiency by providing focused, context-aware entry points for complex DevOnboarder tasks.

## Problem Statement

Traditional AI conversations for complex projects suffer from:

- **Context overhead**: 20-30 iterations building project understanding

- **Focus drift**: Mixed topics in single conversations

- **Repeated explanations**: Re-describing DevOnboarder architecture

- **Inefficient cycles**: Linear conversations with accumulated bloat

## Phase 1 Solution

**Constrained scope**: Issue Management + CI Troubleshooting only

**Three-file implementation**:

- `scripts/project_navigator.sh` - Interactive menu system

- `config/navigation_config.yaml` - Domain configuration

- `docs/navigation/context_loader.md` - This documentation

## Usage

### Quick Start

```bash

# Launch the navigator

./scripts/project_navigator.sh

```

### Navigation Menu

```text
🏠 DevOnboarder Navigator (MVN)
==================================

Select your focus area:

  [1] 📋 Issue Management
      Sprint operations, triage, GitHub issues

  [2] 🔧 CI/CD Troubleshooting
      Pipeline failures, quality gates, service issues

  [9] 📊 Navigation Metrics
      View MVN experiment results

  [0] Exit

```

### Pre-loaded Context

**Issue Management Context**:

- Current state: 63 issues, 100% priority labeled

- Active framework: Strategic Planning Framework v1.0.0

- Sprint status: Sprint 1 COMPLETE

- Key tools and files ready for reference

**CI/CD Troubleshooting Context**:

- Quality standards: 95% threshold, coverage requirements

- Service architecture: 8 services, ports, dependencies

- Common tools: qc_pre_push.sh, run_tests.sh, safe_commit.sh

- Environment requirements: .venv, Python 3.12, Node.js 22

## Experiment Metrics

The MVN tracks usage to validate Phase 1 success:

**Success Indicators**:

- **Context-reset reduction**: Fewer conversations starting with "DevOnboarder is..."

- **Focused sessions**: Single-topic conversations with faster resolution

- **Consistent patterns**: Regular use of pre-loaded context

**Measurement**:

- Navigation session logs in `logs/navigation_session_*.log`

- Domain usage tracking (Issue Management vs CI focus)

- Session completion rates and patterns

## Phase 1 Constraints

**Maximum scope boundaries**:

- **2 domains only**: Prevents tool overhead and complexity

- **Zero dependencies**: Uses existing DevOnboarder tools only

- **Measurement focus**: Prove value before expansion

**Design principles**:

- **Lightweight**: Minimal cognitive load

- **Integrated**: Works with existing DevOnboarder workflows

- **Measurable**: Clear success/failure criteria

## Success Criteria

**Phase 1 validation metrics**:

- **5+ successful navigation sessions** using the system

- **Measurable efficiency gains** in conversation focus

- **Positive user experience** without tool overhead

**Expansion triggers**:

- Clear reduction in context-building conversations

- Regular use patterns indicating value

- User preference for navigation vs linear conversations

## Next Phases (If Phase 1 Succeeds)

**Phase 2: Domain Expansion**:

- Add Backend Development, Frontend Development domains

- Include Onboarding, Documentation domains

- Expand context loading to more DevOnboarder areas

**Phase 3: Universal Template**:

- Extract as independent repository/submodule

- Create project-agnostic configuration patterns

- Develop universal navigation framework for any complex project

## Technical Implementation

### Context Loading Pattern

```bash

# Pre-load specific domain context

echo "🎯 DOMAIN CONTEXT LOADED"
echo "Current State: [relevant status]"
echo "Active Framework: [applicable standards]"
echo "Common Tasks: [domain-specific operations]"
echo "Key Tools: [relevant scripts and files]"
echo "▶️ Ready for focused conversation"

```

### Session Logging

```bash

# Track navigation usage

SESSION_LOG="logs/navigation_session_$(date +%Y%m%d_%H%M%S).log"
log_action "User selected: [domain]"
log_action "Context session completed"

```

### Configuration Structure

```yaml

# Constrained domain definitions

navigation_domains:
  domain_name:
    name: "Display Name"
    description: "Domain purpose"
    context_files: ["relevant", "documentation"]
    quick_context: "Pre-loaded summary"
    common_tasks: ["typical", "operations"]

```

## Integration with DevOnboarder

**Existing tool compatibility**:

- Works with current scripts and documentation

- Leverages established DevOnboarder patterns

- Maintains "work quietly and reliably" philosophy

- Integrates with quality control frameworks

**No disruption**:

- Optional usage - doesn't change existing workflows

- Supplements rather than replaces current approaches

- Backward compatible with linear conversation patterns

## Troubleshooting

**If navigation feels heavy**:

- Use only for complex, multi-step tasks

- Skip for simple questions or quick operations

- Measure actual time savings vs overhead

**If context seems insufficient**:

- Add relevant files to domain configuration

- Update quick_context summaries

- Request additional pre-loaded information

**If domains feel limiting**:

- Complete Phase 1 validation first

- Document additional domain needs

- Proceed to Phase 2 expansion only after proving Phase 1 value

---

**Experiment Status**: Phase 1 Active

**Framework Version**: 1.0.0-mvn
**Validation Period**: 2 weeks
**Success Metrics**: Context reduction, focused sessions, user adoption
