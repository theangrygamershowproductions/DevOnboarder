---
agent: documentation-quality-enforcer
authentication_required: true
author: DevOnboarder Team
codex_dry_run: false
codex_runtime: true
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
discord_role_required: ''
document_type: documentation
environment: CI
integration_log: Documentation quality enforcement and validation
merge_candidate: false
output: .codex/logs/documentation-quality.log
permissions:
- repo:read
- workflows:write
- pull_requests:write
project: core-agents
purpose: Enforce documentation quality standards on all PR submissions
similarity_group: documentation-quality-enforcer.md-agents
status: active
tags:
- documentation
- documentation
title: Documentation Quality Enforcer
trigger: pull_request opened, synchronize
updated_at: '2025-09-12'
visibility: internal
---

# Documentation Quality Enforcer Agent

## Purpose

Automatically enforces DevOnboarder's documentation quality standards on all pull request submissions, ensuring 95%+ quality threshold compliance and maintaining certification status.

## Responsibilities

### Automated Quality Checks

1. **Markdownlint Validation**

   - Run markdownlint on all changed .md files

   - Enforce zero-tolerance for formatting violations

   - Block PRs with markdown formatting issues

2. **Vale Content Quality**

   - Execute Vale linting on documentation changes

   - Validate project name consistency ("DevOnboarder")

   - Check technical writing standards

3. **Cross-Reference Integrity**

   - Validate internal links in changed documentation

   - Verify external link accessibility

   - Check for broken references

4. **Technical Accuracy Verification**

   - Validate code examples against current codebase

   - Check version numbers and configuration references

   - Ensure setup instructions remain current

### PR Enhancement Actions

1. **Quality Status Reporting**

   - Add quality assessment comment to PRs

   - Provide specific fix recommendations

   - Include compliance score and certification impact

2. **Automated Fixes**

   - Apply markdownlint auto-fixes where possible

   - Suggest standardized project name corrections

   - Propose formatting improvements

3. **Documentation Impact Assessment**

   - Identify if changes affect documentation certification

   - Flag potential regression risks

   - Recommend review escalation for significant changes

## Trigger Conditions

### Automatic Execution

- Pull request opened with documentation changes

- Pull request synchronized (new commits pushed)

- Manual trigger via workflow dispatch

- Scheduled weekly validation of main branch

### File Pattern Matching

```bash

# Monitored file patterns

**/*.md
docs/**/*
README.md

CONTRIBUTING.md
.markdownlint.json
.vale.ini

```

## Quality Standards Enforcement

### Pass Criteria

- ✅ 100% markdownlint compliance

- ✅ 99%+ Vale content quality

- ✅ All internal links functional

- ✅ Code examples validated

- ✅ Technical accuracy confirmed

### Fail Criteria

- ❌ Any markdownlint violations

- ❌ Vale errors (warnings acceptable)

- ❌ Broken internal links

- ❌ Outdated code examples

- ❌ Technical inaccuracies

### Warning Criteria

- ⚠️ Vale warnings requiring review

- ⚠️ New external link dependencies

- ⚠️ Significant structural changes

- ⚠️ Potential certification impact

## Integration Points

### GitHub Actions Workflow

```yaml
name: Documentation Quality Enforcement
on:
  pull_request:
    paths:
      - '**/*.md'

      - 'docs/**/*'

    types: [opened, synchronize]

jobs:
  documentation-quality:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code

        uses: actions/checkout@v4

      - name: Setup Node.js

        uses: actions/setup-node@v4
        with:
          node-version: '22'

      - name: Install markdownlint-cli

        run: npm install -g markdownlint-cli

      - name: Setup Vale

        run: |
          wget -O vale.tar.gz https://github.com/errata-ai/vale/releases/latest/download/vale_Linux_64-bit.tar.gz
          tar -xzf vale.tar.gz
          sudo mv vale /usr/local/bin/

      - name: Run Documentation Quality Checks

        run: |
          echo "Running markdownlint validation..."
          markdownlint **/*.md --config .markdownlint.json

          echo "Running Vale content quality check..."
          vale docs/ --config=.vale.ini

          echo "Validating cross-references..."
          python scripts/validate_documentation_links.py

          echo "Documentation quality enforcement complete"

      - name: Update PR with Quality Report

        if: always()
        uses: actions/github-script@v7
        with:
          script: |
            const qualityReport = `
            ## 📚 Documentation Quality Report

            **Status**: ${{ job.status === 'success' && '✅ PASSED' || '❌ FAILED' }}

            ### Quality Checks

            - **Markdownlint**: ${{ steps.markdownlint.outcome === 'success' && '✅ PASSED' || '❌ FAILED' }}

            - **Vale Content**: ${{ steps.vale.outcome === 'success' && '✅ PASSED' || '❌ FAILED' }}

            - **Link Validation**: ${{ steps.links.outcome === 'success' && '✅ PASSED' || '❌ FAILED' }}

            ### Certification Impact

            ${{ job.status === 'success' && 'No impact on documentation certification status.' || 'Documentation quality issues detected. Certification may be affected.' }}

            See [Documentation Quality Certification](docs/public/documentation-quality-certification.md) for standards.
            `;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: qualityReport
            });

```

### DevOnboarder Integration

- Integrated with existing QC pre-push validation

- Enforced via pre-commit hooks

- Monitored by CI Triage Guard system

- Reported via AAR system for continuous improvement

## Success Metrics

### Quality Maintenance

- Maintain 100% markdownlint compliance

- Keep Vale content quality above 99%

- Zero broken internal links

- 100% technical accuracy in code examples

### Process Efficiency

- Reduce documentation review time by 50%

- Automatic fix rate above 80%

- PR approval acceleration for quality submissions

- Zero certification regression incidents

## Escalation Procedures

### Automatic Escalation

1. **Critical Failures**: Markdownlint errors or broken links

2. **Certification Risk**: Changes affecting quality certification

3. **Technical Inaccuracy**: Code examples or setup instructions outdated

### Manual Review Required

- New documentation structure changes

- External dependency additions

- Technical accuracy disputes

- Quality standard modifications

## DevOnboarder Philosophy Alignment

This agent embodies DevOnboarder's core principles:

- **Quiet Operation**: Automatic validation without interruption

- **Reliable Standards**: Consistent quality enforcement

- **Service Orientation**: Supporting contributors with clear feedback

The Documentation Quality Enforcer ensures that DevOnboarder's commitment to excellence extends to every piece of documentation, maintaining the project's reputation for quality and reliability.

---

**Maintained By**: DevOnboarder Quality Control Team

**Integration**: GitHub Actions + Pre-commit Hooks

**Monitoring**: CI Triage Guard + AAR System
