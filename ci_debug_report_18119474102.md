---
similarity_group: docs-
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
updated_at: 2025-10-27
---
# CI Debugging Report

Run ID: 18119474102
Generated: 2025-09-30 01:44:07 UTC

# CI Failure Analysis - Run 18119474102

Generated: 2025-09-30 01:44:02 UTC

Found 1 failed job(s):

## Failed Job: Enhanced CI Failure Analysis

- Job ID: 51561411391
- Started: 2025-09-30T05:12:29Z
- Completed: 2025-09-30T05:13:12Z

### Recent Errors

- Enhanced CI Failure Analysis Post Checkout repository 2025-09-30T05:13:11.2720356Z [command]/usr/bin/git config --local --name-only --get-regexp http\.https\:\/\/github\.com\/\.extraheader
- Enhanced CI Failure Analysis Post Checkout repository 2025-09-30T05:13:11.2742038Z <http.https://github.com/.extraheader>
- Enhanced CI Failure Analysis Post Checkout repository 2025-09-30T05:13:11.2751834Z [command]/usr/bin/git config --local --unset-all <http.https://github.com/.extraheader>
- Enhanced CI Failure Analysis Post Checkout repository 2025-09-30T05:13:11.2781479Z [command]/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'http\.https\:\/\/github\.com\/\.extraheader' && git config --local --unset-all '<http.https://github.com/.extraheader>' || :"
- Enhanced CI Failure Analysis Complete job ﻿2025-09-30T05:13:11.3105381Z Cleaning up orphan processes

## Downloaded Files

- Logs: /home/potato/DevOnboarder/ci_debug_output
- Artifacts: /home/potato/DevOnboarder/ci_debug_output/artifacts_18119474102
