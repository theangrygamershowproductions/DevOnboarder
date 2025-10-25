---
similarity_group: CI_DASHBOARD_WORKFLOW_INTEGRATION.md-docs

content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---

# CI Health Dashboard - Workflow Integration Examples

This document shows how to integrate CI Health monitoring into existing workflows for real-time failure prediction and cost optimization.

Architecture: docs/CI_DASHBOARD_INTEGRATION_ARCHITECTURE.md

## Integration Pattern 1: Early Detection in Main CI Workflow

Add this step early in the ci.yml workflow to catch issues before expensive operations:

```yaml
jobs:
  ci-health-check:
    runs-on: ubuntu-latest
    outputs:
      failure-predicted: ${{ steps.health-monitor.outputs.failure-predicted }}
      confidence: ${{ steps.health-monitor.outputs.confidence }}
      failure-type: ${{ steps.health-monitor.outputs.failure-type }}
    steps:
      - uses: actions/checkout@v5

      - name: CI Health Pre-flight Check

        id: health-monitor
        uses: ./.github/actions/ci-health-monitor
        with:
          workflow-name: ${{ github.workflow }}
          step-name: 'pre-flight-check'
          on-failure: 'continue'
          prediction-threshold: '0.8'

      - name: Early Cancellation Decision

        if: steps.health-monitor.outputs.failure-predicted == 'true'
        run: |
          echo "::warning::Failure predicted with ${{ steps.health-monitor.outputs.confidence }} confidence"
          echo "::warning::Failure type: ${{ steps.health-monitor.outputs.failure-type }}"
          echo "::warning::Potential cost savings: ${{ steps.health-monitor.outputs.cost-savings }} minutes"

          # For high confidence predictions, recommend cancellation

          if (( $(echo "${{ steps.health-monitor.outputs.confidence }} >= 0.9" | bc -l) )); then
            echo "::error::HIGH CONFIDENCE FAILURE - Consider manual cancellation"

            # Actual auto-cancellation can be implemented here if desired

          fi

  # Make subsequent jobs depend on health check

  validate-yaml:
    needs: ci-health-check
    if: needs.ci-health-check.outputs.failure-predicted != 'true' || needs.ci-health-check.outputs.confidence < 0.9
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5

      - uses: ibiqlik/action-yamllint@v3

        with:
          file_or_dir: ".github/workflows/**/*.yml"
          config_file: .github/.yamllint-config

```

## Integration Pattern 2: Continuous Monitoring During Test Execution

Add monitoring checkpoints during expensive test operations:

```yaml
  python-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5

      - name: Setup Python

        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: CI Health Monitor - Pre-test

        uses: ./.github/actions/ci-health-monitor
        with:
          workflow-name: ${{ github.workflow }}
          step-name: 'python-test-pre'

      - name: Install dependencies

        run: |
          python -m pip install --upgrade pip
          pip install -e .[test]

      - name: Run tests with monitoring

        run: |
          # Run tests with CI health monitoring integration

          python -m pytest --cov=src --cov-fail-under=95 \
            --tb=short --maxfail=5 \
            --log-cli-level=INFO

      - name: CI Health Monitor - Post-test

        if: always()
        uses: ./.github/actions/ci-health-monitor
        with:
          workflow-name: ${{ github.workflow }}
          step-name: 'python-test-post'

```

## Integration Pattern 3: Smart Cancellation for Resource Optimization

Implement automatic cancellation for predicted failures:

```yaml
  smart-cancellation-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5

      - name: Comprehensive Health Check

        id: health-check
        uses: ./.github/actions/ci-health-monitor
        with:
          workflow-name: ${{ github.workflow }}
          step-name: 'smart-cancellation-check'
          on-failure: 'report'
          prediction-threshold: '0.85'

      - name: Auto-cancellation Decision

        if: steps.health-check.outputs.failure-predicted == 'true'
        run: |
          CONFIDENCE="${{ steps.health-check.outputs.confidence }}"
          FAILURE_TYPE="${{ steps.health-check.outputs.failure-type }}"
          COST_SAVINGS="${{ steps.health-check.outputs.cost-savings }}"

          echo "Failure prediction details:"
          echo "  Type: $FAILURE_TYPE"
          echo "  Confidence: $CONFIDENCE"
          echo "  Cost Savings: $COST_SAVINGS minutes"

          # Auto-cancel for very high confidence detached HEAD issues

          if [[ "$FAILURE_TYPE" == "detached_head" ]] && (( $(echo "$CONFIDENCE >= 0.9" | bc -l) )); then
            echo "::error::AUTO-CANCELLING: Detached HEAD with 90% confidence"

            echo "::error::This saves approximately $COST_SAVINGS minutes of compute time"

            # Cancel the workflow run (requires appropriate permissions)

            gh run cancel ${{ github.run_id }} || echo "Manual cancellation required"
            exit 1
          fi

```

## Integration Pattern 4: AAR System Integration

Connect monitoring results with the existing AAR system:

```yaml
  aar-integration:
    if: failure() || cancelled()
    needs: [ci-health-check, validate-yaml, python-test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5

      - name: Generate AAR with CI Health Data

        run: |
          # Collect CI health monitoring results

          HEALTH_DATA=$(echo '${{ needs.ci-health-check.outputs }}' | jq -c .)

          # Generate AAR with enhanced CI health context

          make aar-generate WORKFLOW_ID=${{ github.run_id }} CREATE_ISSUE=true

          # Add CI health prediction data to AAR

          echo "=== CI Health Predictions ===" >> logs/aar_${{ github.run_id }}.md
          echo "Failure Predicted: ${{ needs.ci-health-check.outputs.failure-predicted }}" >> logs/aar_${{ github.run_id }}.md
          echo "Confidence: ${{ needs.ci-health-check.outputs.confidence }}" >> logs/aar_${{ github.run_id }}.md
          echo "Failure Type: ${{ needs.ci-health-check.outputs.failure-type }}" >> logs/aar_${{ github.run_id }}.md
          echo "Cost Savings Potential: ${{ needs.ci-health-check.outputs.cost-savings }} minutes" >> logs/aar_${{ github.run_id }}.md

```

## Implementation Recommendations

### Phase 1: Low-Risk Integration (Week 1)

- Add CI health monitoring to `documentation-quality.yml` (low compute cost)

- Add monitoring to `auto-fix.yml` (predictable patterns)

- Test monitoring accuracy with existing workflow patterns

### Phase 2: Critical Path Integration (Week 2)

- Add pre-flight checks to `ci.yml` main workflow

- Implement smart cancellation for high-confidence detached HEAD detection

- Monitor `priority-matrix-synthesis.yml` for automation patterns

### Phase 3: Comprehensive Monitoring (Week 3)

- Add monitoring to all 45 workflows via reusable action

- Implement automatic AAR generation for predicted failures

- Enable cost optimization reporting and analytics

### Phase 4: Advanced Features (Week 4)

- Machine learning pattern recognition for new failure types

- Integration with external monitoring systems

- Predictive analytics dashboard for trend analysis

## Success Metrics

- **Cost Savings**: Target 20 minutes/week through early cancellation

- **Prediction Accuracy**: Target 90% accuracy for detached HEAD detection

- **False Positive Rate**: Target <5% false positive rate for high-confidence predictions

- **Integration Coverage**: Target monitoring on 20 critical workflows

## Security Considerations

- CI health monitoring logs may contain sensitive information

- Token requirements follow DevOnboarder Token Architecture v2.1

- Monitoring data is retained for 7 days only via GitHub Actions artifacts

- No external data transmission - all analysis performed locally
