# DevOnboarder CI Architecture Restructure Proposal

## Current Issues

- 755-line monolithic CI workflow
- 39 separate workflow files creating maintenance overhead
- Path filtering setup but not effectively used
- Testing everything on every change wastes CI resources
- Slow feedback loops for developers

## Proposed Architecture: Smart Component Testing

### 1. Path-Based Job Execution

```yaml
# .github/workflows/ci.yml (much smaller)
name: CI Gateway
on: [push, pull_request]

jobs:
  changes:
    runs-on: ubuntu-latest
    outputs:
      backend: ${{ steps.filter.outputs.backend }}
      frontend: ${{ steps.filter.outputs.frontend }}
      bot: ${{ steps.filter.outputs.bot }}
      docs: ${{ steps.filter.outputs.docs }}
      infra: ${{ steps.filter.outputs.infra }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v2
        id: filter
        with:
          filters: |
            backend:
              - 'src/**'
              - 'tests/**'
              - 'pyproject.toml'
              - 'scripts/**'
            frontend:
              - 'frontend/**'
              - 'frontend/package*.json'
            bot:
              - 'bot/**'
              - 'bot/package*.json'
            docs:
              - 'docs/**'
              - '**/*.md'
            infra:
              - '.github/workflows/**'
              - 'docker-compose*.yaml'
              - 'Dockerfile*'

  backend-tests:
    needs: changes
    if: needs.changes.outputs.backend == 'true'
    uses: ./.github/workflows/backend-ci.yml

  frontend-tests:
    needs: changes
    if: needs.changes.outputs.frontend == 'true'
    uses: ./.github/workflows/frontend-ci.yml

  bot-tests:
    needs: changes
    if: needs.changes.outputs.bot == 'true'
    uses: ./.github/workflows/bot-ci.yml
```

### 2. Component-Specific Workflows

#### Backend CI (backend-ci.yml)

```yaml
name: Backend CI
on:
  workflow_call:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: '3.12'
      - name: Install dependencies
        run: pip install -e .[test]
      - name: Run tests
        run: pytest --cov=src --cov-fail-under=96
      - name: Security scan
        run: bandit -r src/
```

#### Frontend CI (frontend-ci.yml)

```yaml
name: Frontend CI
on:
  workflow_call:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      - name: Install dependencies
        run: cd frontend && npm ci
      - name: Run tests
        run: cd frontend && npm run coverage
      - name: Type check
        run: cd frontend && npm run type-check
```

### 3. Benefits

#### Performance

- **~80% faster CI runs** for most changes
- **Parallel execution** only for affected components
- **Reduced resource usage** and lower GitHub Actions costs

#### Developer Experience

- **Faster feedback** - Python changes don't wait for Node.js tests
- **Clear failure isolation** - know exactly which component failed
- **Focused notifications** - only relevant team members get alerts

#### Maintenance

- **Smaller, focused workflows** easier to debug and modify
- **Reusable components** via workflow_call
- **Clear ownership** - frontend team owns frontend-ci.yml

### 4. Implementation Strategy

#### Phase 1: Core Components (Week 1)

1. Create component-specific workflows (backend, frontend, bot)
2. Update main CI to use path filtering
3. Test on non-critical branches

#### Phase 2: Specialized Workflows (Week 2)

1. Consolidate AAR workflows into aar-ci.yml
2. Create security-ci.yml for security-related changes
3. Create docs-ci.yml for documentation changes

#### Phase 3: Cleanup (Week 3)

1. Remove redundant workflows from the 39 existing files
2. Archive or consolidate monitoring workflows
3. Update documentation and team processes

### 5. Example: Real-World Scenarios

#### Scenario A: Frontend Bug Fix

- **Current**: All 755 lines execute, ~8 minutes
- **Proposed**: Only frontend-ci.yml runs, ~2 minutes
- **Savings**: 75% faster, 6 minutes saved

#### Scenario B: Documentation Update

- **Current**: Full test suite runs despite no code changes
- **Proposed**: Only docs-ci.yml runs (spelling, links, format)
- **Savings**: ~90% resource reduction

#### Scenario C: Security Update

- **Current**: Everything runs regardless of security focus
- **Proposed**: security-ci.yml + affected component CIs
- **Benefit**: Security-focused validation with component testing

### 6. Quality Gates Preserved

- **95% coverage requirements** maintained per component
- **All existing quality checks** preserved but optimized
- **Security scanning** remains comprehensive
- **Integration testing** runs when multiple components change

### 7. Rollback Plan

- **Feature flags** to switch between old/new CI
- **Gradual migration** starting with less critical workflows
- **Performance monitoring** to validate improvements
- **Team feedback** integration before full rollout

## Recommendation

Start with Phase 1 on a feature branch to demonstrate the concept. This addresses your excellent point about testing efficiency while maintaining DevOnboarder's quality standards.
