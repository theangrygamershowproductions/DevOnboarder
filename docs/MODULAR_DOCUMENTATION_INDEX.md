---
author: TAGS Engineering

codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: Complete navigation guide to DevOnboarder's modular documentation structure
  with cross-references and quick access
document_type: standards
merge_candidate: false
project: core-instructions
similarity_group: documentation-guides
status: active
tags:

- devonboarder

- documentation

- modular

- navigation

- index

title: DevOnboarder Modular Documentation Index
updated_at: '2025-09-11'
visibility: internal
---

# DevOnboarder Modular Documentation Index

## 🎯 Quick Navigation

### 📋 Core Bootstrap Instructions

- **Primary**: `.github/copilot-instructions.md` - Essential project overview and critical policies

- **Purpose**: Core bootstrap instructions for agent initialization

### 📚 Modular Documentation Structure

#### 🛡️ Policies (Critical Requirements)

| Module | Purpose | Priority | Enforcement |
|--------|---------|----------|-------------|
| [`docs/policies/terminal-output-policy.md`](policies/terminal-output-policy.md) | ZERO TOLERANCE terminal hanging prevention | CRITICAL | Mandatory |
| [`docs/policies/virtual-environment-policy.md`](policies/virtual-environment-policy.md) | Virtual environment isolation requirements | CRITICAL | Mandatory |
| [`docs/policies/potato-policy.md`](policies/potato-policy.md) | Enhanced security file protection | CRITICAL | Automatic |
| [`docs/policies/quality-control-policy.md`](policies/quality-control-policy.md) | 95% quality threshold validation | CRITICAL | Mandatory |
| [`docs/policies/security-best-practices.md`](policies/security-best-practices.md) | Security requirements and access control | HIGH | Mandatory |

#### 🔧 Development Guides

| Module | Purpose | Focus Area |
|--------|---------|-----------|
| [`docs/development/architecture-overview.md`](development/architecture-overview.md) | TAGS stack integration and service architecture | Architecture |
| [`docs/development/development-workflow.md`](development/development-workflow.md) | Complete development workflow guidelines | Workflow |
| [`docs/development/code-quality-requirements.md`](development/code-quality-requirements.md) | Linting rules and testing standards | Quality |
| [`docs/development/file-structure-conventions.md`](development/file-structure-conventions.md) | Directory layout and organization | Structure |
| [`docs/development/plugin-development.md`](development/plugin-development.md) | Plugin creation guidelines | Extensions |

#### 🔗 Integration Patterns

| Module | Purpose | Integration Type |
|--------|---------|-----------------|
| [`docs/integration/service-integration-patterns.md`](integration/service-integration-patterns.md) | API conventions and Discord bot patterns | Service Layer |
| [`docs/integration/ci-cd-automation.md`](integration/ci-cd-automation.md) | GitHub Actions and automation ecosystem | CI/CD |
| [`docs/integration/common-integration-points.md`](integration/common-integration-points.md) | Feature development workflows | Development |

#### 🤖 Agent Requirements

| Module | Purpose | Agent Type |
|--------|---------|-----------|
| [`docs/agents/agent-requirements.md`](agents/agent-requirements.md) | AI agent guidelines and compliance | All Agents |

#### 🔧 Troubleshooting

| Module | Purpose | Coverage |
|--------|---------|----------|
| [`docs/troubleshooting/common-issues-resolution.md`](troubleshooting/common-issues-resolution.md) | Problem resolution patterns | Common Issues |
| [`docs/troubleshooting/devonboarder-key-systems.md`](troubleshooting/devonboarder-key-systems.md) | Key systems and utilities | System Navigation |

## 🚀 Quick Access Patterns

### By Role/Need

#### **New Agent Initialization**

1. `.github/copilot-instructions.md` (Core bootstrap)

2. `docs/policies/terminal-output-policy.md` (CRITICAL requirements)

3. `docs/policies/virtual-environment-policy.md` (Environment setup)

4. `docs/agents/agent-requirements.md` (Agent-specific guidelines)

#### **Development Setup**

1. `docs/development/development-workflow.md` (Complete workflow)

2. `docs/policies/quality-control-policy.md` (QC requirements)

3. `docs/development/architecture-overview.md` (System understanding)

4. `docs/troubleshooting/common-issues-resolution.md` (Problem solving)

#### **Security & Compliance**

1. `docs/policies/potato-policy.md` (File protection)

2. `docs/policies/security-best-practices.md` (Security requirements)

3. `docs/policies/terminal-output-policy.md` (Output compliance)

4. `docs/policies/quality-control-policy.md` (Quality compliance)

#### **Architecture & Integration**

1. `docs/development/architecture-overview.md` (System architecture)

2. `docs/integration/service-integration-patterns.md` (Service patterns)

3. `docs/integration/ci-cd-automation.md` (Automation systems)

4. `docs/development/file-structure-conventions.md` (Project structure)

#### **Troubleshooting & Support**

1. `docs/troubleshooting/common-issues-resolution.md` (Problem resolution)

2. `docs/troubleshooting/devonboarder-key-systems.md` (System navigation)

3. `docs/policies/virtual-environment-policy.md` (Environment issues)

4. `docs/policies/terminal-output-policy.md` (Output issues)

## 📖 Cross-References

### Policy Interdependencies

- **Terminal Output** ↔ **Quality Control** ↔ **Agent Requirements**

- **Virtual Environment** ↔ **Development Workflow** ↔ **Plugin Development**

- **Potato Policy** ↔ **Security Best Practices** ↔ **Quality Control**

### Development Flow References

- **Architecture Overview** → **Service Integration** → **Common Integration Points**

- **Development Workflow** → **Code Quality** → **File Structure**

- **Agent Requirements** → All policies and development guides

### Troubleshooting Chain

- **Common Issues** → **Virtual Environment** + **Terminal Output** policies

- **Key Systems** → **Architecture** + **Quality Control** + **Agent Requirements**

## 🔄 Migration Notes

### From Monolithic Structure (September 2025)

- **Original**: `.github/copilot-instructions.md` (1,930 lines)

- **Preserved**: `.github/copilot-instructions.md.backup` (Complete backup)

- **New Structure**: 16 modular documents with standardized frontmatter

- **Source Attribution**: All modules reference original source for traceability

### Module Relationships

All modules include `related_modules` in frontmatter for automated cross-referencing and navigation.

### Standards Compliance

- ✅ YAML frontmatter following core-instructions standards

- ✅ Markdown compliance (MD022, MD032, MD031, MD007, MD009)

- ✅ Source attribution and extraction tracking

- ✅ Codex integration readiness

---

**Quick Start**: For immediate agent work, load `.github/copilot-instructions.md` first, then access specific modules as needed.

**Navigation**: Use this index for module discovery, then follow cross-references in individual module frontmatter.

**Maintenance**: Update related_modules in frontmatter when adding new cross-references.
