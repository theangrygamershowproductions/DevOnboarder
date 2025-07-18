# Codex Task: Dependency Inventory to Excel

Parse the following files in the DevOnboarder repo:
- `pyproject.toml`
- All `package.json` files (root, frontend, bot)

For each dependency found, list:
- Package name
- Version
- File source
- Dependency type (runtime/dev, Python/Node)

Generate a spreadsheet (`dependency_inventory.xlsx`) and store it in the repo or temp path.

Log the results in `docs/codex-e2e-report.md` and post a summary to the Discord channel if applicable.
