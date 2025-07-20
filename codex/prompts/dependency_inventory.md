# Codex Task: Dependency Inventory

Create a comprehensive inventory of project dependencies.

## Steps

1. Scan `pyproject.toml` and every `package.json` in the repository.
2. Record each package name, version, file path, and whether it is a runtime or development dependency for Python or Node.
3. Produce both CSV and Excel outputs saved as `docs/dependency_inventory.xlsx` (the CSV can be an additional sheet or separate file).
4. Use separate sheets for Python and Node packages when creating the Excel workbook.
5. If duplicate entries or missing versions are detected, append a short summary of those issues to the bottom of the spreadsheet.
6. Optionally log a brief summary in `docs/codex-e2e-report.md`.
