---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Per-service test coverage report for DevOnboarder showing backend 96%+, bot 100%, and frontend coverage statistics with quality metrics
document_type: report
merge_candidate: false
project: DevOnboarder
similarity_group: docs-
status: active

tags:

- coverage

- testing

- quality

title: DevOnboarder Per-Service Coverage Report
updated_at: '2025-09-12'
visibility: internal
---

# 📊 DevOnboarder Per-Service Coverage Report

## Service Quality Overview

| Service | Coverage | Threshold | Status | Description | Priority |
|---------|----------|-----------|--------|-------------|----------|
| devonboarder | 97.0% | 95% | 🟢 PASS | Core auth service | critical |
| utils | 0.0% | 95% | ❌ FAIL | Shared utilities | critical |
| xp | 0.0% | 90% | ❌ FAIL | XP/gamification | high |
| discord_integration | 0.0% | 90% | ❌ FAIL | Discord OAuth/roles | high |
| feedback_service | 0.0% | 85% | ❌ FAIL | User feedback | moderate |
| routes | 0.0% | 85% | ❌ FAIL | API routes | moderate |
| llama2_agile_helper | 0.0% | 85% | ❌ FAIL | LLM integration | moderate |

## Overall Metrics

- **Average Coverage**: 13.9%

- **Services Tested**: 7

- **Services Passing**: 1

- **Services Failing**: 6

## 🎯 Strategic Improvement Opportunities

Focus testing efforts on these services for maximum ROI:

1. **utils**: 0.0% (needs +95.0% to reach 95%)

2. **xp**: 0.0% (needs +90.0% to reach 90%)

3. **discord_integration**: 0.0% (needs +90.0% to reach 90%)

4. **feedback_service**: 0.0% (needs +85.0% to reach 85%)

5. **routes**: 0.0% (needs +85.0% to reach 85%)

6. **llama2_agile_helper**: 0.0% (needs +85.0% to reach 85%)

💡 **Recommendation**: Start with services having the largest coverage gaps for maximum improvement impact.

## 🔍 Quality Insights

- **Critical Services**: 1/2 passing (95% threshold)

- **High Priority Services**: 0/2 passing (90% threshold)
