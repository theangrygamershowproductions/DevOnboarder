---
project: "TAGS"
module: "Documentation"
phase: "Internal Tooling"
tags: ["docs", "internal"]
updated: "26 May 2025 17:48 (EST)"
version: "v1.0.0"
-----------------

# TAGS: PR Template

---

## Purpose

Establish a standardized pull request format to ensure consistent contributions, traceable updates, and team-wide quality control.

---

```markdown
## 📌 Summary
- _Brief description of the change._

## 🛠️ Type of Change
- [ ] Bugfix
- [ ] Feature
- [ ] Patch Update
- [ ] Security Fix
- [ ] Documentation Only

## 📂 Files Changed
- _List of key files modified or created._

## 🔍 Checklist
- [ ] Code is properly linted
- [ ] All applicable tests have been written/updated
- [ ] `.env.example` updated if needed
- [ ] CHANGELOG.md updated
- [ ] Patch header in file(s) updated
- [ ] Verified functionality in dev/test environment

## 📎 Related Work Items / Issues
- Closes #[IssueNumber] or Links to Azure Board #[WorkItemID]

## 🧪 Testing Notes
- _Instructions for reviewers to test the changes._
```

---

**Usage:** Include this template in the root `.github/pull_request_template.md` file or use in Git provider’s PR body field.

**Maintainer:** Chad Reesey
