---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: copilot-refactor-copilot-refactor
status: active
tags:

- documentation

title: Extraction Plan
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder Copilot Instructions Refactoring Plan

## 🎯 **Safe Extraction Strategy**

**Original File**: `.github/copilot-instructions.md` (1,930 lines)

**Backup Created**: `.github/copilot-instructions.md.backup`
**Status**: PRESERVE ORIGINAL UNTIL FULL VALIDATION

## 📋 **Section Extraction Mapping**

### **CORE BOOTSTRAP (Keep in .github/copilot-instructions.md)**

**Target Size**: ~200 lines maximum

**Lines 1-8**: Project Overview & Philosophy
**Lines 9-99**: ZERO TOLERANCE Terminal Output Policy (CRITICAL)
**Lines 100-105**: Virtual Environment Requirements (CRITICAL)
**Lines 106-152**: Enhanced Potato Policy (CRITICAL)
**NEW**: Context Loading Strategy (Reference to modular docs)

### **POLICIES MODULE (docs/policies/)**

#### `terminal-output-policy.md`

- **Source Lines**: 9-99 (91 lines)

- **Content**: ZERO TOLERANCE policy, violations, safe patterns, enforcement

- **Priority**: CRITICAL - Must preserve exactly

#### `virtual-environment-policy.md`

- **Source Lines**: 100-195 (96 lines)

- **Content**: Virtual environment requirements, setup, commands

- **Priority**: CRITICAL - Must preserve exactly

#### `potato-policy.md`

- **Source Lines**: 106-152 (47 lines)

- **Content**: Enhanced Potato Policy, protected patterns, enforcement

- **Priority**: CRITICAL - Security mechanism

#### `quality-control-policy.md`

- **Source Lines**: 583-660 (78 lines)

- **Content**: 95% QC rule, coverage thresholds, testing requirements

- **Priority**: HIGH - Quality standards

#### `linting-policy.md`

- **Source Lines**: 442-480 (39 lines)

- **Content**: Linting rule policy, markdown standards compliance

- **Priority**: HIGH - Code quality standards

### **DEVELOPMENT MODULE (docs/development/)**

#### `architecture-overview.md`

- **Source Lines**: 196-263 (68 lines)

- **Content**: TAGS stack, core services, multi-environment setup

- **Priority**: HIGH - System understanding

#### `development-workflow.md`

- **Source Lines**: 264-439 (176 lines)

- **Content**: Environment setup, logging policy, workflow standards

- **Priority**: HIGH - Development process

#### `file-structure-conventions.md`

- **Source Lines**: 708-761 (54 lines)

- **Content**: Directory layout, key configuration files

- **Priority**: MEDIUM - Project navigation

#### `code-quality-standards.md`

- **Source Lines**: 440-582 (143 lines)

- **Content**: Linting rules, markdown compliance, CI hygiene

- **Priority**: HIGH - Quality enforcement

### **INTEGRATION MODULE (docs/integration/)**

#### `service-integration-patterns.md`

- **Source Lines**: 762-794 (33 lines)

- **Content**: API conventions, Discord bot patterns, database patterns

- **Priority**: HIGH - Service development

#### `ci-cd-automation.md`

- **Source Lines**: 795-898 (104 lines)

- **Content**: GitHub Actions workflows, critical scripts, AAR system

- **Priority**: HIGH - Automation understanding

#### `environment-variables.md`

- **Source Lines**: 1124-1138 (15 lines)

- **Content**: Required variables, development vs production

- **Priority**: MEDIUM - Configuration management

### **AGENTS MODULE (docs/agents/)**

#### `agent-requirements.md`

- **Source Lines**: 1513-1688 (176 lines)

- **Content**: Agent-specific guidelines, documentation creation, debugging

- **Priority**: CRITICAL - Agent behavior standards

#### `agent-documentation-standards.md`

- **Source Lines**: 1842-1930 (89 lines)

- **Content**: Codex agent requirements, integration framework, validation

- **Priority**: HIGH - Agent compliance

### **TROUBLESHOOTING MODULE (docs/troubleshooting/)**

#### `common-issues-resolution.md`

- **Source Lines**: 1139-1399 (261 lines)

- **Content**: Common issues, dependency management, debugging tools

- **Priority**: HIGH - Problem resolution

#### `devonboarder-key-systems.md`

- **Source Lines**: 1400-1512 (113 lines)

- **Content**: Phase framework, token architecture, essential scripts

- **Priority**: HIGH - System navigation

### **REFERENCE MODULE (docs/reference/)**

#### `security-best-practices.md`

- **Source Lines**: 899-942 (44 lines)

- **Content**: Security requirements, environment variable security

- **Priority**: HIGH - Security compliance

#### `plugin-development.md`

- **Source Lines**: 1101-1123 (23 lines)

- **Content**: Creating plugins, development setup

- **Priority**: LOW - Optional functionality

#### `common-integration-points.md`

- **Source Lines**: 943-1077 (135 lines)

- **Content**: Adding features, bot development, frontend integration

- **Priority**: MEDIUM - Development guidance

#### `quality-assurance-checklist.md`

- **Source Lines**: 1078-1100 (23 lines)

- **Content**: Pre-commit requirements, PR review checklist

- **Priority**: HIGH - Quality gates

## 🔄 **Extraction Process**

### **Phase 1: Extract to Modules (PRESERVE ORIGINAL)**

1. Create each module file with extracted content

2. Add proper markdown frontmatter

3. Ensure all content is preserved exactly

4. Cross-reference validation

### **Phase 2: Create New Bootstrap File**

1. Create new minimal copilot-instructions.md

2. Include only critical bootstrap content

3. Add navigation references to modules

4. Validate essential policies are included

### **Phase 3: Validation & Testing**

1. Test agent loading with new structure

2. Verify all content is accessible

3. Validate critical policies are enforced

4. Ensure no functionality is lost

### **Phase 4: Migration (ONLY AFTER FULL VALIDATION)**

1. Replace original file with new bootstrap

2. Archive backup with timestamp

3. Update context loading strategy

4. Document new navigation patterns

## ⚠️ **Safety Checkpoints**

- [ ] **Backup Created**: Original file backed up

- [ ] **Content Preservation**: All lines accounted for in extraction plan

- [ ] **Critical Policy Identification**: ZERO TOLERANCE and CRITICAL sections identified

- [ ] **Module Structure**: Logical organization created

- [ ] **Validation Plan**: Testing strategy established

- [ ] **Rollback Plan**: Restoration process documented

## 📝 **Next Steps**

1. **Execute Phase 1**: Extract content to modules while preserving original

2. **Validate Extraction**: Ensure all content is captured correctly

3. **Create Bootstrap**: Build new minimal copilot-instructions.md

4. **Test Loading**: Verify new structure works with agents

5. **Migration**: Replace original only after full validation

**CRITICAL**: Original file remains untouched until entire extraction and validation process is complete.
