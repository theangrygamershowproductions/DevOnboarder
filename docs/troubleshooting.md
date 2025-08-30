# Troubleshooting Guide

Development setups and CI runs sometimes fail in surprising ways.
This page collects quick fixes for the most common problems.

## Failed pre-commit hooks

- Ensure you have run `pre-commit install` so git hooks execute automatically.
- If the Node.js download fails during the Prettier hook, see
  [Network troubleshooting](network-troubleshooting.md#pre-commit-nodeenv-ssl-errors).
- Missing Python packages? Install dev requirements with:

    ```bash
    pip install -r requirements-dev.txt
    ```

## Docker services won't start

- Run `docker compose -f ../archive/docker-compose.dev.yaml --env-file .env.dev up -d` to rebuild containers.
- Check container logs with `docker compose logs` for details.
- If services exit immediately, verify secrets with `./scripts/generate-secrets.sh`.

## CI pipeline failures

- Use `bash scripts/run_tests.sh` locally to reproduce lint and test failures.
- For network-restricted environments, follow [Offline setup](offline-setup.md) to cache dependencies.
- If CI cannot download tools or packages, review [Network troubleshooting](network-troubleshooting.md) for proxy tips.

## GitHub CLI authentication issues

**Problem**: `gh` commands fail with "Bad credentials" or "401 Unauthorized" errors.

**Root Cause**: `GH_TOKEN` environment variable is set for CI automation but lacks permissions for interactive development.

**Solutions**:

### Option 1: Temporarily clear GH_TOKEN

```bash
# Clear the token for interactive use
unset GH_TOKEN

# Authenticate with your personal token
gh auth login

# Use GitHub CLI normally
gh pr checks 1184
```

### Option 2: Use personal token directly

```bash
# Override with personal token
export GITHUB_TOKEN='your_personal_token_here'
gh pr checks 1184
```

### Option 3: Check via web interface

Visit the PR directly: `https://github.com/theangrygamershowproductions/DevOnboarder/pull/1184`

**Prevention**: Never use `GH_TOKEN` for interactive development work. It's designed for CI automation with limited permissions.

**Quick Reference**: See [GH_TOKEN Quick Reference](GH_TOKEN_QUICK_REFERENCE.md) for immediate solutions.
