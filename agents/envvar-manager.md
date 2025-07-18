---
codex-agent:
  name: Agent.EnvVarManager
  role: Audits and synchronizes environment variables across projects
  scope: repo-wide
  triggers: Workflow runs, scheduled checks, or manual dispatch
  output: Updated `.env.example` files or issues for misaligned variables
---

# EnvVar Manager Agent

**Status:** Proposed.

**Purpose:**  
Ensure every project directory maintains an up-to-date `.env.example` file that reflects the variables referenced in code, workflow YAMLs, and agent documentation. The agent scans for variable usage, compares it to existing `.env.example` files, and reports discrepancies.

**Inputs:**  
- Source code and workflow YAML files  
- Existing `.env.example` files  
- `agents/index.md` for the authoritative variable list

**Outputs:**  
- Updated `.env.example` files for each project directory  
- GitHub issues summarizing missing or redundant variables

**Environment:**  
Requires read access to the repository and write/PR permissions to update example files or open issues.

**Workflow:**  
1. Parse environment variable references in code and workflows.  
2. Map each variable to the directories that use it.  
3. Update or generate `.env.example` files so that each directory reflects the variables it requires.  
4. Open a PR (or issue) when variables are missing, unused, or duplicated.

**Notification:**  
Route alerts through `.github/workflows/notify.yml`.

**Escalation:**  
If environment misalignment persists longer than 24 hours, notify the DevOps lead.

## \U0001F4CC Markdown Standards

- We use [`markdownlint`](https://github.com/DavidAnson/markdownlint) v0.38+ to enforce style and consistency.
- Configured via `.markdownlint.json` with all rules enabled by default.
- File-specific rule overrides are applied using inline comments.
- CI automatically runs linting via `markdownlint-cli2-action`.

### Customizations:
```json
{
  "MD013": false,
  "MD007": { "indent": 4 }
}
```

* To disable rules in a file, add:

  ```markdown
  <!-- markdownlint-disable-file MD### -->
  ```
