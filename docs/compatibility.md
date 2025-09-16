---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Compatibility requirements and supported platforms for DevOnboarder
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: compatibility.md-docs
status: active
tags:
- compatibility
- requirements
- platforms
- documentation
title: Compatibility
updated_at: '2025-09-12'
visibility: internal
---

# Compatibility

This document outlines compatibility requirements and supported platforms for DevOnboarder.

## Supported Platforms

### Operating Systems

- Linux (Ubuntu 20.04+, RHEL 8+)
- macOS (10.15+)
- Windows (10+) with WSL2

### Language Versions

- Python: 3.12 (enforced via `.tool-versions`)
- Node.js: 22
- Ruby: 3.2.3

### Containers

- Docker Engine 20.10+
- Docker Compose 2.0+

## Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Database Compatibility

- PostgreSQL 13+ (production)
- SQLite 3.31+ (development)
