# Issue Labeling Guide

## Overview

DevOnboarder uses a comprehensive labeling system to organize, prioritize, and track issues effectively. This guide explains all labels, their meanings, and how to use them for project planning and development workflow.

## Label Categories

### 🚨 Priority Labels

Priority labels indicate the business impact and urgency of issues:

| Label | Description | When to Use | Color |
|-------|-------------|-------------|-------|
| `priority-high` | Critical infrastructure improvements | Breaking issues, security vulnerabilities, CI failures | ![#d73a4a](https://via.placeholder.com/15/d73a4a/d73a4a.png) Red |
| `priority-medium` | Significant developer experience improvements | Performance optimizations, workflow enhancements | ![#fbca04](https://via.placeholder.com/15/fbca04/fbca04.png) Yellow |
| `priority-low` | Nice-to-have enhancements | Optional features, quality-of-life improvements | ![#0e8a16](https://via.placeholder.com/15/0e8a16/0e8a16.png) Green |

### 🕐 Effort Labels

Effort labels estimate implementation complexity and time investment:

| Label | Description | Estimated Time | Color |
|-------|-------------|----------------|-------|
| `effort-small` | 1-2 day implementations | Quick fixes, minor enhancements | ![#c2e0c6](https://via.placeholder.com/15/c2e0c6/c2e0c6.png) Light Green |
| `effort-medium` | 3-5 day implementations | Feature development, moderate refactoring | ![#fef2c0](https://via.placeholder.com/15/fef2c0/fef2c0.png) Light Yellow |
| `effort-large` | 1+ week implementations | Major features, architectural changes | ![#f9d0c4](https://via.placeholder.com/15/f9d0c4/f9d0c4.png) Light Red |

### 🏗️ Component Labels

Component labels categorize issues by technical area:

| Label | Description | Examples | Color |
|-------|-------------|----------|-------|
| `testing-infrastructure` | Test-related enhancements and infrastructure | Test runners, coverage, artifact management | ![#1d76db](https://via.placeholder.com/15/1d76db/1d76db.png) Blue |
| `developer-experience` | Developer workflow and experience improvements | Tooling, documentation, setup automation | ![#0052cc](https://via.placeholder.com/15/0052cc/0052cc.png) Dark Blue |
| `security-enhancement` | Security features and improvements | Authentication, authorization, vulnerability fixes | ![#b60205](https://via.placeholder.com/15/b60205/b60205.png) Dark Red |
| `cross-platform` | Platform compatibility improvements | Windows support, macOS compatibility | ![#5319e7](https://via.placeholder.com/15/5319e7/5319e7.png) Purple |
| `performance` | Speed and efficiency improvements | Optimization, caching, resource usage | ![#ff6600](https://via.placeholder.com/15/ff6600/ff6600.png) Orange |

### 📋 Standard GitHub Labels

DevOnboarder maintains standard GitHub labels for common issue types:

| Label | Description | Usage |
|-------|-------------|-------|
| `enhancement` | New feature or request | All feature requests and improvements |
| `bug` | Something isn't working | Defects, errors, unexpected behavior |
| `documentation` | Improvements or additions to documentation | Doc updates, guides, README improvements |
| `ci-hygiene` | CI/CD pipeline and infrastructure issues | Build failures, workflow improvements |
| `automated` | Issues created by automation | Bot-generated issues, CI alerts |

### 🔧 Technology Labels

Technology labels identify the primary tech stack involved:

| Label | Description |
|-------|-------------|
| `python` | Python code and dependencies |
| `javascript` | JavaScript/TypeScript code |
| `codex` | DevOnboarder agent system related |

### 🎯 Special Purpose Labels

| Label | Description | Usage |
|-------|-------------|-------|
| `artifact-pollution` | Repository hygiene issues | Root directory artifacts, misplaced files |
| `phase-3` | Legacy project phase identifier | Historical tracking |

## Usage Guidelines

### 🚀 For Issue Creation

When creating new issues, apply labels in this order:

1. **Priority** (`priority-high`, `priority-medium`, `priority-low`)
2. **Effort** (`effort-small`, `effort-medium`, `effort-large`)
3. **Component** (one or more: `testing-infrastructure`, `developer-experience`, etc.)
4. **Technology** (`python`, `javascript`, `codex`)
5. **Type** (`enhancement`, `bug`, `documentation`)

**Example**: A new test automation feature would get:

- `priority-medium` (significant dev experience improvement)
- `effort-medium` (3-5 day implementation)
- `testing-infrastructure` (test-related)
- `python` (Python implementation)
- `enhancement` (new feature)

### 📊 For Project Planning

**Sprint Planning**:

- Filter by `effort-small` for quick wins
- Combine `priority-high` + `effort-medium` for high-impact work
- Use `effort-large` for dedicated sprint themes

**Roadmap Planning**:

- `priority-high` issues for immediate next sprint
- `priority-medium` issues for quarterly planning
- `priority-low` issues for backlog grooming

**Resource Allocation**:

- `developer-experience` issues for frontend developers
- `testing-infrastructure` issues for QA/DevOps engineers
- `security-enhancement` issues for security specialists

### 🔍 Filter Examples

Common GitHub issue filter combinations:

```bash
# High priority, quick wins
is:open label:priority-high label:effort-small

# Testing infrastructure improvements
is:open label:testing-infrastructure label:enhancement

# Medium effort developer experience improvements
is:open label:developer-experience label:effort-medium

# Python-related enhancements
is:open label:python label:enhancement

# Security issues requiring immediate attention
is:open label:security-enhancement label:priority-high
```

## Strategic Implementation Order

Based on our labeling system, here's the recommended implementation sequence:

### Phase 1: Quick Wins (1-2 weeks)

```bash
is:open label:priority-medium label:effort-small
```

Focus on high-impact, low-effort improvements that provide immediate developer experience benefits.

### Phase 2: Core Infrastructure (3-4 weeks)

```bash
is:open label:priority-medium label:effort-medium label:testing-infrastructure
```

Systematic improvements to testing and development infrastructure.

### Phase 3: Advanced Features (4+ weeks)

```bash
is:open label:priority-high label:effort-large
```

Major architectural improvements and complex feature development.

### Phase 4: Platform Expansion

```bash
is:open label:priority-low label:effort-large label:cross-platform
```

Broader ecosystem support and platform compatibility.

## Label Management

### Adding Labels to Issues

```bash
# Add single label
gh issue edit <issue-number> --add-label "priority-high"

# Add multiple labels
gh issue edit <issue-number> --add-label "priority-medium,effort-small,testing-infrastructure"

# Remove labels
gh issue edit <issue-number> --remove-label "priority-low"
```

### Creating New Labels

```bash
# Create a new label
gh label create "new-label" --description "Description" --color "ff6600"
```

### Bulk Label Operations

For applying labels to multiple issues, use GitHub CLI with issue lists:

```bash
# Apply performance label to all optimization issues
gh issue list --label enhancement --json number --jq '.[].number' | \
  xargs -I {} gh issue edit {} --add-label "performance"
```

## Best Practices

### ✅ Do

- **Apply multiple labels** - Issues often span multiple categories
- **Update labels** as requirements change during development
- **Use consistent labeling** across similar issues
- **Review labels** during sprint planning and retrospectives
- **Document label changes** in issue comments when significant

### ❌ Don't

- **Over-label** - Avoid more than 6-8 labels per issue
- **Use conflicting priorities** - Each issue should have exactly one priority label
- **Ignore effort estimation** - All enhancement issues should have effort labels
- **Create duplicate labels** - Check existing labels before creating new ones

## Integration with DevOnboarder Workflows

### CI/CD Integration

Labels trigger specific automation:

- `ci-failure` labels automatically create issues for persistent CI problems
- `automated` labels identify bot-generated issues
- `artifact-pollution` labels trigger cleanup workflows

### GitHub Actions

Several workflows use labels for conditional execution:

- Test infrastructure changes (`testing-infrastructure` label)
- Security scanning for security enhancements (`security-enhancement` label)
- Cross-platform testing for compatibility issues (`cross-platform` label)

### Reporting and Metrics

Labels enable automated reporting:

- Sprint velocity tracking by effort labels
- Component health monitoring by component labels
- Priority distribution analysis for planning

## Examples from Current Issues

### Issue #1008: Unicode Handling Enhancement

```text
Labels: enhancement, codex, python, priority-low, effort-small, testing-infrastructure
```

- **Why**: Optional feature (`priority-low`), quick implementation (`effort-small`), improves test infrastructure (`testing-infrastructure`)

### Issue #1010: Parallel Test Execution

```text
Labels: enhancement, codex, python, priority-medium, effort-medium, testing-infrastructure, performance
```

- **Why**: Significant developer impact (`priority-medium`), moderate complexity (`effort-medium`), performance improvement (`performance`)

### Issue #1012: CI Health Analytics

```text
Labels: enhancement, ci-hygiene, automated, priority-high, effort-large
```

- **Why**: Critical infrastructure (`priority-high`), complex implementation (`effort-large`), CI system improvement (`ci-hygiene`)

## Conclusion

This labeling system provides structure for:

- **Strategic planning** through priority and effort estimation
- **Resource allocation** via component and technology categorization
- **Progress tracking** through consistent labeling practices
- **Automation** integration with DevOnboarder workflows

Regular review and maintenance of labels ensures the system remains effective as the project evolves.

---

**Last Updated**: 2025-07-30
**Maintained by**: DevOnboarder Team
**Review Schedule**: Quarterly during retrospectives
