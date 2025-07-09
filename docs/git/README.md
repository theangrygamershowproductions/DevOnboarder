# Project Git Workflow Reference

> � For advanced Git workflows and configuration (e.g. `.gitignore`, SSH,
> hooks, submodules), see [Git.md](./Git.md)

This project uses a structured Git workflow for managing source code, feature
development, and deployment. Below is a quick-reference guide to help team
members perform common Git tasks correctly.

---

## � Switching Between Branches Without Committing

### Option 1: Stash Changes

```bash
git stash push -m "WIP: unsaved changes"
git switch target-branch
```

To restore later:

```bash
git stash pop
```

### Option 2: Temporary WIP Commit

```bash
git add .
git commit -m "WIP: partial changes"
git switch target-branch
```

To undo:

```bash
git reset HEAD~1
```

### Option 3: `git switch` (If no conflicts)

```bash
git switch target-branch
```

---

## � Merging Working Branch into Development

1. Commit your changes:

```bash
git add .
git commit -m "Feature complete"
```

1. Switch to `development`:

```bash
git switch development
```

1. Pull latest development branch:

```bash
git pull origin development
```

1. Merge your feature branch:

```bash
git merge your-branch-name
```

1. Push updated development:

```bash
git push origin development
```

1. (Optional) Clean up:

```bash
git branch -d your-branch-name
```

---

## � Managing Multiple Remotes

### Add a Secondary Remote

```bash
git remote add working git@github.com:your-org/project-working.git
```

Push to it:

```bash
git push working development
```

### Make a Remote Fetch-Only

```bash
git remote set-url --push origin no_push
```

Re-enable pushing:

```bash
git remote set-url --push origin git@github.com:your-org/project.git
```

### Rename a Remote

```bash
git remote rename origin source
```

---

## ✅ Helpful Commands

- Show remotes:

```bash
git remote -v
```

- View stashes:

```bash
git stash list
```

- Apply a specific stash:

```bash
git stash apply stash@{0}
```

- Push via SSH:

```bash
# Start the agent and add key (one-time per session)
eval $(ssh-agent -s)
ssh-add /path/to/private_key

git push
```

- Reminder: pre-commit hooks and `.gitignore` are enforced—see `Git.md` for setup steps.

---

Stay consistent. Follow the Git SOP in [Git.md](./Git.md) for commit standards, hooks, and more.

Need help? Ping the team lead or check the internal Git training resources.
