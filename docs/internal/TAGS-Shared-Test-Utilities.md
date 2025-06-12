---
project: "TAGS"
module: "Documentation"
phase: "Internal Tooling"
tags: ["docs", "internal"]
updated: "26 May 2025 17:49 (EST)"
version: "v1.0.0"
-----------------

# TAGS: Shared Test Utilities

---

## Purpose

Provide a centralized, reusable set of test utilities for mocking users, sessions, guilds, and HTTP requests across all TAGS modules.

---

## Directory Structure

```makrdown
/test/utils/
├── mockUser.ts              # Mocks Discord user payloads
├── mockSession.ts           # Mocks valid/invalid session tokens
├── mockGuilds.ts            # Mocks guild membership data
├── testSetup.ts             # Common test configuration
├── mockRequest.ts           # Mocks Express.js req/res objects
├── testConstants.ts         # Common values used across test cases
```

## Integration

* **Used in:** auth-server, commander-bot, webapp
* **Imported into:** unit tests, integration tests, middleware validation

## Guidelines

* Do not redefine test objects inside test files
* Export all stubs, mocks, and constants from `test/utils/`
* Add types when possible for mock objects
* Update shared mocks as the application schema evolves

---

**Maintainer:** Chad Reesey
