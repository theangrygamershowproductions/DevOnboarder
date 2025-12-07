---
title: "Getting Started: Your First 48 Hours"
description: "Step-by-step guide for new developers joining the DevOnboarder project"
author: "TAGS DevOnboarder Team"
created_at: "2025-12-07"
updated_at: "2025-12-07"
status: "active"
visibility: "public"
tags:
  - onboarding
  - getting-started
  - new-developers
  - first-contribution
document_type: "onboarding-guide"
related_components:
  - WHY_DEVONBOARDER.md
  - CONTRIBUTING.md
  - README.md
codex_scope: "product"
codex_audience: "new-developers"
codex_purpose: "onboarding-path"
---

# Getting Started: Your First 48 Hours

**Purpose**: This guide walks you through your first contribution to DevOnboarder. By the end, you'll have:
- Joined Discord and GitHub
- Cloned the repo
- Made a small change
- Opened your first pull request

**Timeline**: Most people complete this in 2 days (a few hours each day).

---

## What You Need Before You Start

### Required
- **Discord account** (free) — where the team communicates
- **GitHub account** (free) — where the code lives
- **Git installed locally** — [download here](https://git-scm.com/downloads)
- **GitHub SSH key configured** — [setup guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

### Recommended (but not required for first PR)
- **VS Code** or your preferred editor
- **Docker** (if you want to run the full system locally)
- **Node.js** and **Python 3.12+** (for running tests)

**Don't have everything set up?** That's fine. You can complete Steps 1-3 without any local tooling.

---

## Step 1: Join Discord

1. **Accept the invite link** (you'll get this from whoever invited you to the project)
2. **Introduce yourself in #welcome**
   - Name (or handle)
   - What you're interested in working on
   - Your timezone (helps with async coordination)
3. **Find the right channels**:
   - `#devonboarder` — main project discussion
   - `#github-events` — automated GitHub notifications
   - `#ci-logs` — CI/CD pipeline updates
   - Role-specific channels (you'll be added based on your role)

**What "done" looks like**: You can see messages in #devonboarder and you've said hello in #welcome.

---

## Step 2: Accept GitHub Org Invite

1. **Check your email** for a GitHub organization invite from `theangrygamershowproductions`
2. **Accept the invite** (this gives you access to private repos)
3. **Configure git locally** (first time only):
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your-email@example.com"
   ```
4. **Confirm you can see the DevOnboarder repo**: Visit [github.com/theangrygamershowproductions/DevOnboarder](https://github.com/theangrygamershowproductions/DevOnboarder)

**What "done" looks like**: You can open the DevOnboarder repo on GitHub without seeing a 404.

---

## Step 3: First Contact with the Repo

Before you clone anything, spend 15 minutes reading:

1. **[WHY_DEVONBOARDER.md](WHY_DEVONBOARDER.md)** — why this project exists
2. **[README.md](../../README.md)** — project overview and structure
3. **[CONTRIBUTING.md](../../CONTRIBUTING.md)** — how we work (branching, commit messages, PR process)

**Why this matters**: You're about to touch real code that other people depend on. These docs explain how we keep things stable.

**What "done" looks like**: You understand what DevOnboarder does and you've skimmed the contribution rules.

---

## Step 4: Clone the Repo Locally

```bash
# Navigate to where you keep code projects
cd ~/projects  # (or wherever you prefer)

# Clone via SSH (recommended)
git clone git@github.com:theangrygamershowproductions/DevOnboarder.git

# Enter the directory
cd DevOnboarder

# Confirm you're on the main branch
git branch
```

**What "done" looks like**: You have a local copy of the repo and `git status` shows you're on the `main` branch.

**Troubleshooting**:
- If SSH fails: Check that your SSH key is added to GitHub (Step 2)
- If you see "Permission denied": You might not have been added to the org yet (ping in #devonboarder)

---

## Step 5: Find Your First Issue

**Don't pick a hero issue.** Pick something small.

### Where to Look
1. **GitHub Issues labeled `good-first-issue`**: [Filter here](https://github.com/theangrygamershowproductions/DevOnboarder/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
2. **Ask in #devonboarder**: "What's a good first task for someone new?"
3. **Look for documentation fixes**: Typos, unclear instructions, missing examples

### Good First Issues Look Like
- "Update README to clarify X"
- "Add example Y to CONTRIBUTING.md"
- "Fix typo in /docs/setup.md"
- "Add validation message to form field Z"

### What to Avoid for Your First PR
- Major refactors
- Database schema changes
- CI/CD pipeline modifications
- Anything labeled `breaking-change` or `architecture`

**What "done" looks like**: You've picked an issue and commented "I'd like to work on this" so others know it's claimed.

**Important**: Ask for context if the issue is unclear. "What does success look like for this?" is always a valid question.

---

## Step 6: Make Your Change (Branch → Change → Commit)

### 6.1: Create a Feature Branch

```bash
# Make sure you're starting from main
git checkout main
git pull origin main

# Create a branch (use a descriptive name)
git checkout -b docs/clarify-setup-steps  # example for a docs change
```

**Branch naming convention**:
- `docs/` for documentation changes
- `feat/` for new features
- `fix/` for bug fixes
- `chore/` for maintenance tasks

### 6.2: Make Your Change

Open the file you need to edit and make the change. Keep it small.

**Example**: If you're fixing a typo in `README.md`, just fix the typo. Don't rewrite the whole file.

### 6.3: Commit Your Change

```bash
# Stage the file
git add path/to/changed/file

# Commit with a clear message
git commit -m "DOCS(readme): fix typo in setup instructions"
```

**Commit message format**: `TYPE(scope): description`
- `DOCS` for documentation
- `FEAT` for new features
- `FIX` for bug fixes
- Scope is the area you changed (readme, api, bot, etc.)

**What "done" looks like**: You've committed your change and `git log` shows your commit message.

---

## Step 7: Open Your First Pull Request

```bash
# Push your branch to GitHub
git push -u origin docs/clarify-setup-steps
```

Then:
1. **Go to GitHub** — you'll see a yellow banner saying "Compare & pull request"
2. **Click "Compare & pull request"**
3. **Fill out the PR template**:
   - What changed?
   - Why did you change it?
   - How did you test it? (even if it's just "I read the docs again")
4. **Request a review** from someone in #devonboarder (or tag `@devonboarder-maintainers`)
5. **Wait for feedback** — this usually happens within 24 hours

**What "done" looks like**: Your PR is open and you've requested a review.

**What happens next**:
- A maintainer will review your PR
- You might get feedback ("can you change X?")
- Once approved, a maintainer will merge it
- You'll get a notification when it's merged

**Don't silently spin**: If you're stuck waiting for review after 48 hours, ping in #devonboarder.

---

## What "Good Onboarding" Looks Like

Here's what a successful first 48 hours looks like:

### Day 1 (a few hours)
- ✅ Joined Discord and introduced yourself
- ✅ Accepted GitHub org invite
- ✅ Read WHY_DEVONBOARDER.md, README.md, CONTRIBUTING.md
- ✅ Cloned the repo locally

### Day 2 (a few hours)
- ✅ Picked a `good-first-issue`
- ✅ Created a branch, made a change, committed it
- ✅ Opened a pull request
- ✅ Requested a review

**Timeline**: Most people complete this in 2 days. If you're stuck longer than 2 days on any step, ask for help in #devonboarder.

---

## If You Get Stuck

### Try This First
1. **Check #devonboarder in Discord** — someone may have already asked your question
2. **Search the docs** — README, CONTRIBUTING, and docs/ folder
3. **Ask in #devonboarder** — "I'm stuck at [step] because [reason]. I tried [X] but got [Y]. What should I try next?"

### What "Stuck" Means
- You've been trying to fix something for >1 hour without progress
- You don't understand what the next step is
- You're blocked waiting for access/permissions/review

**Don't silently spin.** If you're stuck, say so. Your confusion is valuable feedback.

### If the Docs Are Wrong
If you hit a step that didn't work as documented:
1. Document what you tried and what happened
2. Ask in #devonboarder for clarification
3. Once you figure it out, consider opening a PR to fix the docs

This is one of the best contributions you can make — you're seeing the docs with fresh eyes.

---

## What's Next After Your First PR?

Once your first PR is merged:
- **You're no longer "new"** — you've completed the full loop (branch → change → commit → PR → review → merge)
- **Pick a slightly bigger issue** — look for `good-second-issue` or ask "What's next?"
- **Help the next new person** — answer questions in #welcome or #devonboarder
- **Explore the codebase** — backend/ (Python + FastAPI), bot/ (Node.js + Discord.js), frontend/ (React)

**Optional next steps**:
- Set up the full local environment (Docker + databases)
- Run the test suite locally
- Pick a feature issue (not just docs)
- Propose a new feature or improvement

---

## Summary: Your Checklist

- [ ] Join Discord and introduce yourself
- [ ] Accept GitHub org invite
- [ ] Read WHY_DEVONBOARDER.md, README.md, CONTRIBUTING.md
- [ ] Clone repo locally
- [ ] Pick a `good-first-issue` and comment on it
- [ ] Create feature branch
- [ ] Make your change
- [ ] Commit with clear message
- [ ] Push branch to GitHub
- [ ] Open pull request
- [ ] Request review
- [ ] Respond to feedback (if any)
- [ ] Wait for merge

**When you've checked all these boxes, you're no longer "new."** Welcome to the team.

---

**Questions?** Ask in #devonboarder on Discord. We're here to help.
