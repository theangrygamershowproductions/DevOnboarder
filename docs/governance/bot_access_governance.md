# Codex Task List: Onboarder Bot Access & Governance

## 1. GitHub Permissions

| Task | Owner |
| ---- | ----- |
| - [ ] Audit all current GitHub bot/service account scopes and access levels for DevOnboarder automation. | Security Team |
| - [ ] Restrict each bot to the minimum required **API scopes** for their tasks (e.g., `pull_requests`, `repo`, specific org permissions). | Security Team |
| - [ ] Migrate to **deploy keys** or machine users for CI/CD where possible, scoped only to specific repositories. | DevOps Team |
| - [ ] Remove or avoid any unnecessary admin/org-wide tokens from automation scripts or workflow configs. | DevOps Team |
| - [ ] Require GitHub Actions **Environments** for dev/staging/prod, with manual approval gates for sensitive (e.g., production) deployments. | DevOps Team |
| - [ ] Configure **secrets management** in GitHub Actions: ensure only workflows in the correct environment can access relevant secrets, using OIDC where feasible. | DevOps Team |
| - [ ] Rotate all access tokens/keys regularly; document the rotation schedule. | Security Team |
| - [ ] Ensure all bot actions (PRs, merges, issue edits, etc.) are logged and reviewable via the GitHub audit log. | Security Team |

## 2. Discord Permissions

| Task | Owner |
| ---- | ----- |
| - [ ] Review the OAuth2 scopes on all Discord bots; restrict to `bot` and `applications.commands` only. | Discord Admins |
| - [ ] Limit Discord bot permission bitmask to only the minimum (e.g., Send Messages, Use Slash Commands). Avoid “Manage Server” unless strictly required. | Discord Admins |
| - [ ] Implement Discord RBAC: restrict bot commands/visibility by channel and role as appropriate. | Discord Admins |
| - [ ] Document bot permissions and justify any elevated rights. | Discord Admins |

## 3. Pipeline & Environment Access

| Task | Owner |
| ---- | ----- |
| - [ ] Migrate all pipeline/service credentials to deploy keys or service accounts with limited repo access. | DevOps Team |
| - [ ] Separate environment secrets for dev/staging/prod. Ensure prod secrets require manual approval for use in workflows. | DevOps Team |
| - [ ] Remove any broad Personal Access Tokens (PATs) or admin tokens from pipeline configuration. | DevOps Team |
| - [ ] Ensure all pipeline jobs log their activities (builds, tests, deployments) and store results for auditing. | DevOps Team |
| - [ ] Configure alerting for failed builds, suspicious deployments, or pipeline anomalies. | DevOps Team |

## 4. Metrics & Transparency

| Task | Owner |
| ---- | ----- |
| - [ ] Implement metrics collection for the following: Open/closed issue and PR counts; last-activity timestamps; CI/CD health; code quality scans; Discord bot usage stats. | Metrics Team |
| - [ ] Set up an internal dashboard or report system for visibility of these metrics. | Metrics Team |
| - [ ] Document all metric sources and update methods. | Metrics Team |

## 5. Checks & Balances (Quarterly Review)

| Task | Owner |
| ---- | ----- |
| - [ ] Schedule a **quarterly audit** of all bot/service account permissions in both GitHub and Discord. | Security Team |
| - [ ] Review GitHub audit logs and Discord audit logs for unexpected actions or privilege escalations. | Security Team |
| - [ ] Revoke or rotate any unused or excess keys/tokens. | Security Team |
| - [ ] Update and document permission scopes as project requirements evolve. | Security Team |
| - [ ] Treat each review as a lightweight security audit; document findings and any remediations. | Security Team |

## 6. Documentation & Governance

| Task | Owner |
| ---- | ----- |
| - [ ] Maintain a public/visible governance document listing all bot/service accounts, their permissions, and last reviewed date. | Documentation Team |
| - [ ] Add human approval gates and permission review tasks to the project management backlog as recurring items. | Project Management Team |
| - [ ] Link to relevant GitHub/Discord best practices and security docs. | Documentation Team |
| - [ ] Keep the full matrix of bot secrets and permissions in `.codex/bot-permissions.yaml`. | Documentation Team |

---

**Meta:**

- Each item should reference an owning team or individual.
- Checklist can be tracked in an Issue, Project Board, or in a Markdown doc (`codex/tasks/bot_access_governance.md`).
- On each quarterly review, update the review date and summarize findings in the doc.
