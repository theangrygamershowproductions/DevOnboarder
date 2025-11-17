# Getting Started with DevOnboarder

**Audience**: New engineer at TAGS
**Goal**: Ship your first change through DevOnboarder's CI in under 30 minutes

---

## Prerequisites

- Git configured with GitHub access
- Python 3.12.x installed
- Node.js 18+ installed (for frontend work)

---

## Golden Path: Clone → QC → Dev → Ship

### 1. Clone with Submodules

From the TAGS-META root:

```bash
cd ~/TAGS/ecosystem/DevOnboarder
git status  # verify you're on cleanup/DevOnboarder-2025-11-04
```

Or if starting fresh:

```bash
git clone --recurse-submodules https://github.com/theangrygamershowproductions/TAGS-META.git TAGS
cd TAGS/ecosystem/DevOnboarder
```

### 2. Bootstrap Local Environment

**Backend (Python):**

```bash
# Create and activate virtual environment
python3 -m venv .venv
source .venv/bin/activate  # or: .venv\Scripts\activate on Windows

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

**Frontend (Node.js):**

```bash
cd frontend
npm install
cd ..
```

### 3. Verify Quality Control Passes

**MANDATORY before any code changes:**

```bash
./scripts/qc_pre_push.sh
```

**Expected output:**
```
Quality Score: 1/1 (100%)
✅ PASS: Quality score meets 95% threshold
Ready to push!
```

If you see this, you're golden. If not:
- Check you're on the `cleanup/DevOnboarder-2025-11-04` branch
- Verify virtual environment is activated
- See [DEVONBOARDER_QC_CONTRACT.md](../docs/ci/DEVONBOARDER_QC_CONTRACT.md) for troubleshooting

### 4. Make a Trivial Change

**Example: Update a docstring**

```bash
# Create feature branch
git checkout -b feat/update-docs

# Edit a file (example: backend/app.py)
# Add or improve a docstring

# Verify QC still passes
./scripts/qc_pre_push.sh
```

### 5. Commit Using Safe Commit

**NEVER use `git commit` directly** - always use the safe commit wrapper:

```bash
# Stage your changes first
git add <files>

# Then commit using safe_commit.sh
./scripts/safe_commit.sh "DOCS(backend): improve app.py docstring

- UPDATE main application docstring with clearer description
- ADD context about FastAPI integration"
```

**Important**: You must `git add` files before running `safe_commit.sh`. The script will fail with a clear error if no files are staged.

This enforces:
- Conventional commit format
- Security checks (detect-secrets)
- Pre-commit hooks
- Branch protection (blocks direct commits to main)

### 6. Push and Create Pull Request

```bash
git push origin feat/update-docs
```

Then:
1. Go to GitHub: https://github.com/theangrygamershowproductions/DevOnboarder
2. Click "Compare & pull request"
3. Fill in PR description
4. Wait for CI to pass (GitHub Actions)
5. Request review from maintainer

### 7. After Merge

```bash
# Switch back to main branch
git checkout cleanup/DevOnboarder-2025-11-04
git pull origin cleanup/DevOnboarder-2025-11-04

# Delete feature branch
git branch -d feat/update-docs
```

---

## Common Tasks

### Run Tests

**Backend:**
```bash
pytest --cov=backend --cov-report=term-missing
```

**Frontend:**
```bash
cd frontend
npm test
```

### Run Linters

**Python:**
```bash
ruff check .
black --check .
```

**JavaScript:**
```bash
cd frontend
npm run lint
```

### Run Local Development Server

**Backend:**
```bash
cd backend
uvicorn app:app --reload
```

**Frontend:**
```bash
cd frontend
npm run dev
```

---

## Quality Control Rules

### Branch Protection

- ❌ **FORBIDDEN**: Direct commits to `main` or `cleanup/DevOnboarder-2025-11-04`
- ✅ **REQUIRED**: Feature branches (`feat/`, `fix/`, `docs/`, etc.)

### QC Threshold

- **95% minimum** quality score required
- Currently: **100%** (let's keep it there)
- Failing QC = blocked push

### Commit Format

**MUST follow conventional commits:**

```
TYPE(scope): brief description

- Detailed bullet points
- Each starts with uppercase verb
- Technical details included
```

**Valid types:** `FEAT`, `FIX`, `DOCS`, `CHORE`, `TEST`, `REFACTOR`

### Safe Commit Only

**Always use:**
```bash
./scripts/safe_commit.sh "TYPE(scope): message"
```

**Never use:**
```bash
git commit -m "message"  # ❌ BLOCKED by pre-commit hooks
```

---

## Troubleshooting

### QC Script Fails on Feature Branch

**Symptom:** `./scripts/qc_pre_push.sh` exits with error

**Solution:**
1. Check you're not on `main` branch (script blocks main by design)
2. Verify virtual environment is activated
3. Run tests individually to isolate failure:
   ```bash
   pytest tests/
   ruff check .
   black --check .
   ```

### Safe Commit Blocks Push

**Symptom:** Commit rejected with format validation error

**Solution:**
- Check commit message follows `TYPE(scope): description` format
- Ensure TYPE is uppercase (`FEAT`, not `feat`)
- Include detailed bullets (not just one-line description)

### Import Errors in Tests

**Symptom:** `ModuleNotFoundError` when running pytest

**Solution:**
```bash
# Verify virtual environment is activated
source .venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt -r requirements-dev.txt
```

---

## Related Documentation

- [DEVONBOARDER_QC_CONTRACT.md](../docs/ci/DEVONBOARDER_QC_CONTRACT.md) - Quality invariants
- [AGENTS.md](../AGENTS.md) - AI agent guidelines
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Contribution guidelines
- [TAGS v3 Rebuild Plan](../../TAGS_V3_GROUND_UP_REBUILD_PLAN.md) - Overall strategy

---

## Success Criteria

You've successfully onboarded when you can:

- [x] Clone DevOnboarder with submodules
- [x] Activate virtual environment and install deps
- [x] Run `./scripts/qc_pre_push.sh` and see 100% quality score
- [x] Create feature branch and make trivial change
- [x] Commit using `./scripts/safe_commit.sh`
- [x] Push and create pull request
- [x] See CI pass on GitHub Actions

**Time to complete:** ~20-30 minutes for first-time setup

---

**Last Updated:** 2025-11-17 (Phase 4 - Golden Path Documentation)
**Maintained By:** TAGS Engineering
**Questions?** See [AGENTS.md](../AGENTS.md) for AI agent support
