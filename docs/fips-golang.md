---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: fips-golang.md-docs
status: active
tags:

- documentation

title: Fips Golang
updated_at: '2025-09-12'
visibility: internal
---

# FIPS Compliance for Golang Projects

Federal Information Processing Standards (FIPS) define security requirements for
cryptographic modules used in U.S. government systems. A Go service must use
FIPS-validated components and restrict algorithms that are not approved.

## Key Guidelines

- Use a FIPS 140 validated cryptographic library such as BoringCrypto or a FIPS build of OpenSSL.

- Enable FIPS mode on the operating system and verify only FIPS-approved algorithms are available.

- Document the module's FIPS boundary and maintain certificates proving validation.

- Disable or remove non-FIPS algorithms like MD5 or RC4.

- Ensure random number generation comes from a FIPS validated source.

- Run regular self-tests to confirm the crypto module operates in FIPS mode.

- Provide instructions for building the Go binaries with the FIPS-compliant toolchain.

Consult NIST publications for complete requirements and keep all dependencies up to date with validated versions.
