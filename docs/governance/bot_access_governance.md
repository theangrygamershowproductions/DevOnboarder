# Codex Task List: Onboarder Bot Access & Governance

## 1. GitHub Permissions

- [ ] Audit all current GitHub bot/service account scopes and access levels for DevOnboarder automation.
- [ ] Restrict each bot to the minimum required **API scopes** for their tasks (e.g., `pull_requests`, `repo`, specific org permissions).
- [ ] Migrate to **deploy keys** or machine users for CI/CD where possible, scoped only to specific repositories.
- [ ] Remove or avoid any unnecessary admin/org-wide tokens from automation scripts or workflow configs.
- [ ] Require GitHub Actions **Environments** for dev/staging/prod, with manual approval gates for sensitive (e.g., production) deployments.
- [ ] Configure **secrets management** in GitHub Actions: ensure only workflows in the correct environment can access relevant secrets, using OIDC where feasible.
- [ ] Rotate all access tokens/keys regularly; document the rotation schedule.
- [ ] Ensure all bot actions (PRs, merges, issue edits, etc.) are logged and reviewable via the GitHub audit log.

## 2. Discord Permissions

- [ ] Review the OAuth2 scopes on all Discord bots; restrict to `bot` and `applications.commands` only.
- [ ] Limit Discord bot permission bitmask to only the minimum (e.g., Send Messages, Use Slash Commands). Avoid “Manage Server” unless strictly required.
- [ ] Implement Discord RBAC: restrict bot commands/visibility by channel and role as appropriate.
- [ ] Document bot permissions and justify any elevated rights.

## 3. Pipeline & Environment Access

- [ ] Migrate all pipeline/service credentials to deploy keys or service accounts with limited repo access.
- [ ] Separate environment secrets for dev/staging/prod. Ensure prod secrets require manual approval for use in workflows.
- [ ] Remove any broad Personal Access Tokens (PATs) or admin tokens from pipeline configuration.
- [ ] Ensure all pipeline jobs log their activities (builds, tests, deployments) and store results for auditing.
- [ ] Configure alerting for failed builds, suspicious deployments, or pipeline anomalies.

## 4. Metrics & Transparency

- [ ] Implement metrics collection for the following:
  - [ ] Open/closed issue and PR counts, and merge/close rates (track over time).
  - [ ] Last-activity timestamps on commits, PRs, and issues.
  - [ ] CI/CD job health: build success rate, mean build time, test coverage, etc.
  - [ ] Code quality/vulnerability scan results.
  - [ ] Discord bot usage stats: commands run, user engagement, error rates.
- [ ] Set up an internal dashboard or report system for visibility of these metrics.
- [ ] Document all metric sources and update methods.

## 5. Checks & Balances (Quarterly Review)

- [ ] Schedule a **quarterly audit** of all bot/service account permissions in both GitHub and Discord.
- [ ] Review GitHub audit logs and Discord audit logs for unexpected actions or privilege escalations.
- [ ] Revoke or rotate any unused or excess keys/tokens.
- [ ] Update and document permission scopes as project requirements evolve.
- [ ] Treat each review as a lightweight security audit; document findings and any remediations.

## 6. Documentation & Governance

- [ ] Maintain a public/visible governance document listing all bot/service accounts, their permissions, and last reviewed date.
- [ ] Add human approval gates and permission review tasks to the project management backlog as recurring items.
- [ ] Link to relevant GitHub/Discord best practices and security docs.

---

**Meta:**

- Each item should reference an owning team or individual.
- Checklist can be tracked in an Issue, Project Board, or in a Markdown doc (`codex/tasks/bot_access_governance.md`).
- On each quarterly review, update the review date and summarize findings in the doc.
