# Git.md Documentation

## Table of Contents

- [Git.md Documentation](#gitmd-documentation)
    - [Table of Contents](#table-of-contents)
    - [Adding Entries to .gitignore](#adding-entries-to-gitignore)
    - [Repository Structure and Submodules](#repository-structure-and-submodules)
        - [🔜 Submodule Plan](#-submodule-plan)
    - [Switching Between Branches Without Committing](#switching-between-branches-without-committing)
        - [Option 1: `git stash`](#option-1-git-stash)
        - [Option 2: WIP Commit](#option-2-wip-commit)
        - [Option 3: Use `git switch`](#option-3-use-git-switch)
    - [Merging a Working Branch into Development](#merging-a-working-branch-into-development)
    - [Managing Multiple Remotes](#managing-multiple-remotes)
        - [Add a second remote](#add-a-second-remote)
        - [Make a remote fetch-only](#make-a-remote-fetch-only)
        - [Rename a remote](#rename-a-remote)
    - [Maintenance Notes](#maintenance-notes)
    - [Git Commit Message SOP](#git-commit-message-sop)
        - [Purpose](#purpose)
        - [Guidelines](#guidelines)
        - [Format](#format)
            - [Types](#types)
            - [Example](#example)
            - [Versioning](#versioning)
    - [Using Git Hooks](#using-git-hooks)
        - [Why?](#why)
        - [Setup](#setup)
    - [Steps to Push with SSH](#steps-to-push-with-ssh)

---

## Adding Entries to .gitignore

1. **Navigate to your project directory**

    ```sh
    cd /path/to/your/project
    ```

2. **Add entries**

    ```sh
    echo "node_modules/" >> .gitignore
    echo "config.py" >> .gitignore
    ```

    `>>` appends. Use `>` to overwrite the file.

3. **Verify**

    ```sh
    cat .gitignore
    ```

---

## Repository Structure and Submodules

Our current structure:

```markdown
/company-project
├── .gitignore
├── frontend/ ← Separate Git repo (ignored)
├── backend/ ← Separate Git repo (ignored)
```

- `frontend/`: React + TypeScript + Tailwind stack
- `backend/`: Auth microservice

### 🔜 Submodule Plan

When ready:

```sh
git submodule add https://github.com/your-org/frontend.git frontend
git submodule add https://github.com/your-org/backend.git backend
```

---

## Switching Between Branches Without Committing

### Option 1: `git stash`

```sh
git stash push -m "WIP: unsaved changes"
git switch target-branch
```

Then restore:

```sh
git stash pop
```

### Option 2: WIP Commit

```sh
git add .
git commit -m "WIP: partial changes"
git switch target-branch
```

Undo later:

```sh
git reset HEAD~1
```

### Option 3: Use `git switch`

```sh
git switch target-branch
```

Only works if no conflicting changes.

---

## Merging a Working Branch into Development

1. Commit your work:

    ```sh
    git add .
    git commit -m "Feature complete"
    ```

2. Switch to development:

    ```sh
    git switch development
    ```

3. Pull latest

    ```sh
    git pull origin development
    ```

4. Merge your branch

    ```sh
    git merge your-branch-name
    ```

5. Push the result

    ```sh
    git push origin development
    ```

6. Optionally delete

    ```sh
    git branch -d your-branch-name
    git push origin --delete your-branch-name
    ```

---

## Managing Multiple Remotes

### Add a second remote

```sh
git remote add working git@github.com:your-org/project-working.git
```

Push to it:

```sh
git push working development
```

### Make a remote fetch-only

```sh
git remote set-url --push origin no_push
```

Re-enable:

```sh
git remote set-url --push origin git@github.com:your-org/project.git
```

### Rename a remote

```sh
git remote rename origin source
```

Verify:

```sh
git remote -v
```

---

## Maintenance Notes

The following tasks are now part of our standard workflow:

- `.gitignore` entries are validated by `scripts/check_potato_ignore.sh` and reviewed each release.
- Commit messages follow the guidelines in [docs/git-guidelines.md](../git-guidelines.md).
- Pre-commit hooks enforce linting and formatting.
- Merging and remote management workflows are documented in [docs/git/README.md](./README.md).

Submodule support will be revisited once the frontend and backend repositories stabilize.

---

## Git Commit Message SOP

### Purpose

Ensure clear, consistent commit messages that aid review and traceability.

### Guidelines

- Commit early and often (locally)
- Use descriptive messages
- Keep `main` and `release` clean
- Squash local commits when needed
- Use feature branches for WIP

### Format

```plaintext
<type>(<scope>): <subject>
```

#### Types

- **FEAT**: New features
- **FIX**: Bug/security fixes
- **DOCS**: Documentation
- **STYLE**: Formatting/linting
- **REFACTOR**: Structural changes
- **TEST**: Tests
- **CHORE**: Tooling, config, CI/CD

#### Example

```plaintext
feat(api): add token validation logic

- Added JWT parsing
- Included `express-jwt` middleware
```

#### Versioning

```plaintext
PATCH v0.0.6 — Adds debug logging to session management (useSession.ts)
```

---

## Using Git Hooks

### Why?

Hooks ensure:

- Code quality (lint/tests)
- Team consistency (commit format)
- Safer workflows (e.g. block `main` pushes)

### Setup

1. Navigate to hooks folder:

    ```sh
    cd .git/hooks
    ```

2. Create a hook

    ```sh
    touch pre-commit
    chmod +x pre-commit
    ```

3. Example pre-commit

    ```sh
    #!/bin/sh
    npm run lint
    [ $? -ne 0 ] && echo "Lint failed!" && exit 1
    ```

---

## Steps to Push with SSH

1. Start agent:

    ```sh
    eval $(ssh-agent -s)
    ```

2. Add key

    ```sh
    ssh-add /path/to/key
    ```

3. Push

    ```sh
    git push
    ```
