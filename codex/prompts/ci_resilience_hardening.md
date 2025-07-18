# Codex Task: CI Resilience Hardening

Follow these steps when investigating a failed CI run:

1. Detect which jobs failed by inspecting the workflow summary and step results.
2. Gather relevant log excerpts that show stack traces or error messages.
3. Generate a concise Markdown summary highlighting root causes.
4. Suggest minimal patches to resolve the failure, such as lint fixes or test adjustments.
5. Output the summary and patch suggestion for maintainers to review.
