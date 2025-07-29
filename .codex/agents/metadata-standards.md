---
title: "Core Instructions Metadata Standards"
description: "Standardized YAML frontmatter structure for all prompt files and documentation in the core-instructions repository"
author: "TAGS Engineering"
created_at: "2025-07-21"
updated_at: "2025-07-21"
tags: ["codex", "metadata", "standards", "yaml", "frontmatter", "documentation"]
project: "core-instructions"
document_type: "standards"
status: "active"
visibility: "internal"
codex_scope: "TAGS"
codex_role: "Engineering"
codex_type: "STANDARDS"
codex_runtime: false
---

# Core Instructions Metadata Standards

## Overview

This document defines the standardized YAML frontmatter structure that must be used across all files in the core-instructions repository to ensure consistency, automated discovery, and proper integration with Codex agents and DevOnboarder systems.

## Required Fields for All Files

### Core Identification

```yaml
title: "Descriptive Title"
description: "Clear, concise description of the file's purpose"
author: "TAGS Engineering"
created_at: "YYYY-MM-DD"
updated_at: "YYYY-MM-DD"
```

### Categorization

```yaml
tags: ["array", "of", "relevant", "tags"]
project: "core-instructions"
document_type: "agent|charter|checklist|handoff|standards"
status: "active|draft|deprecated"
visibility: "internal|public|restricted"
```

### Codex Integration

```yaml
codex_scope: "TAGS|CRFV"
codex_role: "CEO|CTO|CFO|CMO|COO|DevSecOps Manager|Engineering"
codex_type: "AGENT|CHARTER|CHECKLIST|HANDOFF|STANDARDS"
codex_runtime: false
```

### Authentication (for Agent files)

```yaml
discord_role_required: "CEO|CTO|CFO|CMO|COO"
authentication_required: true
```

## Optional Fields

### Integration

```yaml
related_components: ["DevOnboarder", "Codex Agents", "CI/CD", "Discord Integration"]
canonical_url: "https://codex.theangrygamershow.com/docs/path"
```

## Field Definitions

### title

- **Type**: String
- **Required**: Yes
- **Format**: "Organization Role Agent: Function" (e.g., "TAGS CEO Agent: Strategic Leadership")
- **Purpose**: Human-readable title for documentation and UI display

### description

- **Type**: String
- **Required**: Yes
- **Format**: Concise description without ending period
- **Purpose**: Brief summary of file purpose and functionality

### author

- **Type**: String
- **Required**: Yes
- **Value**: "TAGS Engineering"
- **Purpose**: Attribution and maintenance responsibility

### created_at / updated_at

- **Type**: String
- **Required**: Yes
- **Format**: "YYYY-MM-DD"
- **Purpose**: Version tracking and maintenance scheduling

### tags

- **Type**: Array
- **Required**: Yes
- **Format**: ["lowercase", "hyphenated", "tags"]
- **Purpose**: Automated categorization and search

### project

- **Type**: String
- **Required**: Yes
- **Value**: "core-instructions"
- **Purpose**: Repository identification

### document_type

- **Type**: String
- **Required**: Yes
- **Values**: "agent", "charter", "checklist", "handoff", "standards"
- **Purpose**: Document classification for automated processing

### status

- **Type**: String
- **Required**: Yes
- **Values**: "active", "draft", "deprecated"
- **Purpose**: Lifecycle management

### visibility

- **Type**: String
- **Required**: Yes
- **Values**: "internal", "public", "restricted"
- **Purpose**: Access control and security classification

### codex_scope

- **Type**: String
- **Required**: Yes
- **Values**: "TAGS", "CRFV"
- **Purpose**: Organization assignment for Codex agents

### codex_role

- **Type**: String
- **Required**: Yes
- **Values**: "CEO", "CTO", "CFO", "CMO", "COO", "DevSecOps Manager", "Engineering"
- **Purpose**: Role assignment for authentication and command routing

### codex_type

- **Type**: String
- **Required**: Yes
- **Values**: "AGENT", "CHARTER", "CHECKLIST", "HANDOFF", "STANDARDS"
- **Purpose**: Agent system type classification

### codex_runtime

- **Type**: Boolean
- **Required**: Yes
- **Value**: false (during draft/development phase)
- **Purpose**: Runtime execution control

### discord_role_required

- **Type**: String
- **Required**: For agent files
- **Values**: "CEO", "CTO", "CFO", "CMO", "COO"
- **Purpose**: Discord authentication mapping

### authentication_required

- **Type**: Boolean
- **Required**: For agent files
- **Value**: true
- **Purpose**: Security enforcement flag

## Examples

### Agent File Example

```yaml
---
title: "TAGS CEO Agent: Strategic Leadership"
description: "Chief Executive Officer agent for strategic leadership and company vision at The Angry Gamer Show Productions"
author: "TAGS Engineering"
created_at: "2025-07-21"
updated_at: "2025-07-21"
tags: ["codex", "tags", "ceo", "executive", "strategy", "leadership"]
project: "core-instructions"
document_type: "agent"
status: "active"
visibility: "internal"
codex_scope: "TAGS"
codex_role: "CEO"
codex_type: "AGENT"
codex_runtime: false
discord_role_required: "CEO"
authentication_required: true
---
```

### Documentation File Example

```yaml
---
title: "DevSecOps Handoff Report: core-instructions → DevOnboarder"
description: "Formal handoff summary of the C-Suite Management Module, integration readiness, and security posture for activation by the DevOnboarder team"
author: "TAGS Engineering"
created_at: "2025-07-21"
updated_at: "2025-07-21"
tags: ["devsecops", "handoff", "core-instructions", "discord", "codex", "authentication", "security"]
project: "core-instructions"
related_components: ["DevOnboarder", "Codex Agents", "CI/CD", "Discord Integration"]
document_type: "handoff"
status: "active"
visibility: "internal"
canonical_url: "https://codex.theangrygamershow.com/docs/core-instructions/devsecops-handoff"
codex_scope: "TAGS"
codex_role: "DevSecOps Manager"
codex_type: "HANDOFF"
codex_runtime: false
---
```

## Validation

The `.codex/validate_prompts.sh` script includes metadata consistency validation that checks:

- All required fields are present
- Field values match allowed options
- Consistent author and project fields
- Proper date formatting
- Authentication fields for agent files

## Enforcement

- All new files must include proper metadata
- CI/CD pipeline validates metadata on commit
- Pull requests must pass metadata validation
- Existing files updated during maintenance should be brought to current standards

---

**Prepared by**: TAGS Engineering
**Review Required by**: DevSecOps Manager
**Approval Required for**: New file creation and metadata updates
**Next Review Date**: Monthly metadata standards review
**Document Classification**: Internal - TAGS Engineering
