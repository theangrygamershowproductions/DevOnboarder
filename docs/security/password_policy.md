---
similarity_group: security-security
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# Password policy and bcrypt 72-byte limit

This document explains the decision to enforce a server-side password length limit
and the recommended client-side behavior.

## Background

bcrypt (the default scheme used by DevOnboarder via passlib) only processes the
first 72 bytes of the provided password. If a client submits a password whose
UTF-8 encoding exceeds 72 bytes, different behaviors are possible:

- Silent truncation: truncating to the first 72 bytes before hashing. This is
  insecure because it silently discards entropy and can make authentication
  behavior surprising.
- Rejecting the password: return an explicit HTTP 400 and ask the user to
  provide a shorter password or passphrase. This is the approach enforced by
  the server in this PR.

## Chosen policy

- Server rejects any password whose UTF-8 encoding is longer than 72 bytes.
  Registration will return HTTP 400 with a clear message.
- Login attempts that supply a password longer than 72 bytes are treated as
  "invalid credentials" (HTTP 400) to avoid leaking whether an account exists.
- The server will not silently truncate or accept truncated matches.

## Developer responsibilities

- Frontend must validate password length client-side (limit encoding to ≤72
  bytes). Show an explanatory message: "Password must be ≤72 bytes (UTF-8)."
- Tests must include cases for multibyte characters (e.g., emoji) to ensure
  validation is based on UTF-8 byte-length, not character length.

## Ops / Migration notes

- Users who may have registered while truncation was in place could be unable
  to log in if their original password relied on characters beyond the 72-byte
  boundary. Recommended actions:
    - Offer self-service password reset/email flow.
    - Optionally implement an admin recovery flow (opt-in, visible via audit),
    but avoid automatic acceptance of truncated matches.

## Compatibility fallback (opt-in)

If absolutely required, an opt-in compatibility fallback could be implemented
behind an environment flag. When enabled, the server would verify truncated
passwords only as a migration step and force a password reset on successful
truncated match. This behavior is not enabled by default and requires a
thorough security review.
