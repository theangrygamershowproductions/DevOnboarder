# Codex Task: CI Resilience Hardening

Enhance analysis of failed workflow runs.

## Checklist

1. Validate that `.github/workflows/auto-fix.yml` is present and references the correct bot permissions.
2. Parse workflow logs to capture the exact failing command and any stack traces.
3. Summarize findings and recommended fixes in `audit.md` with links back to the run.
4. Confirm that the cleanup workflow grants the required write permissions before attempting issue or branch deletions.
