# Summary

<!-- Provide a concise description of the change. Highlight major updates or new functionality. -->

# Linked Issues

<!-- List related issues. Use the `Closes #issue-number` syntax when applicable. -->

# Screenshots

<!-- Include before/after screenshots or GIFs if the change affects UI. -->

# Testing Steps

<!-- Detail how a reviewer can verify the change. Include any setup commands. -->

```bash
ruff check .
pytest -q
```

# Checklist

- [ ] All code passes automated lint, type, test, and security checks
- [ ] OpenAPI/contract and migration checks pass
- [ ] All FastAPI endpoints have docstrings and are documented
- [ ] CORS and security headers validated
- [ ] No secrets or sensitive data are present in commits
- [ ] Did Codex introduce any direct commit to main?
- [ ] Are all Codex changes covered by tests and docs?
- [ ] Coverage does not decrease (see Codecov status)

# Reviewer Sign-Off

- [ ] I, the reviewer, confirm the checklist above is complete.
