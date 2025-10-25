# Frameworks Audit (2025-10-12T10:34:44UTC)

Root: \033[0;34mframeworks

## Status & Script Count Check
| Framework | README Status Snippet | README Claim | Actual .sh | Match? |
|---|---|---:|---:|:---:|
| \033[0;34mbuild-deployment\033[0m | — | — | 47 | — |
| \033[0;34mfriction_prevention\033[0m | — | — | 35 | — |
| \033[0;34mmonitoring-automation\033[0m | — | — | 26 | — |
| \033[0;34mquality-assurance\033[0m | — | — | 6 | — |

------------------------------------------------------------------

## Migration/Temp Artifact Scan
```text
frameworks/monitoring-automation/MIGRATION_PLAN.md
```

------------------------------------------------------------------

## Legacy Path Reference Scan (underscorehyphen)
### \033[0;34mbuild-deployment\033[0m  \033[0;34mbuild-deployment
```text
111:source frameworks/build-deployment/deployment_scripts/deploy_to_staging.sh
124:frameworks/build-deployment/build_automation/build_docker_images.sh
130:frameworks/build-deployment/deployment_scripts/deploy_to_staging.sh
137:frameworks/build-deployment/deployment_scripts/rollback_deployment.sh --environment=production --version=previous
144:frameworks/build-deployment/environment_management/sync_environments.sh --source=staging --target=production
222:frameworks/build-deployment/build_automation/build_validation.sh --debug
229:frameworks/build-deployment/environment_management/validate_environment_config.sh
236:frameworks/build-deployment/continuous_integration/pipeline_health_monitor.sh
```

### \033[0;34mfriction_prevention\033[0m  \033[0;34mfriction-prevention
```text
10:frameworks/friction_prevention/
123:   ./frameworks/friction_prevention/workflow/qc_pre_push.sh
132:./frameworks/friction_prevention/automation/automate_pr_process.sh
135:./frameworks/friction_prevention/workflow/smart_env_sync.sh
138:./frameworks/friction_prevention/productivity/analyze_logs.sh
141:./frameworks/friction_prevention/developer_experience/safe_commit.sh
```

### \033[0;34mmonitoring-automation\033[0m  \033[0;34mmonitoring-automation
```text
116:source frameworks/monitoring-automation/monitoring_scripts/monitor_ci_health.sh
129:frameworks/monitoring-automation/monitoring_scripts/monitor_ci_health.sh --daemon
132:frameworks/monitoring-automation/health_checks/mvp_health_monitor.sh --continuous
135:frameworks/monitoring-automation/alerting_systems/ci-health-aar-integration --enable
142:frameworks/monitoring-automation/automation_orchestration/orchestrate-dev.sh --with-monitoring
145:frameworks/monitoring-automation/automation_orchestration/orchestrate-prod.sh --health-check-enabled
152:frameworks/monitoring-automation/health_checks/comprehensive_token_health_check.sh --emergency
155:frameworks/monitoring-automation/health_checks/assess_pr_health_robust.sh --critical-path
267:frameworks/monitoring-automation/health_checks/comprehensive_token_health_check.sh --debug
274:frameworks/monitoring-automation/automation_orchestration/orchestrate-dev.sh --validate-only
281:frameworks/monitoring-automation/health_checks/mvp_health_monitor.sh --comprehensive
```

### \033[0;34mquality-assurance\033[0m  \033[0;34mquality-assurance
```text
148:bash frameworks/quality-assurance/quality-control/qc_pre_push.sh
152:cd frameworks/quality-assurance/quality-control
170:bash frameworks/quality-assurance/quality-control/qc_pre_push.sh
184:bash frameworks/quality-assurance/quality-control/qc_pre_push.sh
190:bash frameworks/quality-assurance/quality-control/qc_pre_push.sh
194:bash frameworks/quality-assurance/quality-control/qc_docs.sh
198:bash frameworks/quality-assurance/quality-control/validation_summary.sh
206:frameworks/quality-assurance/code-standards/standards_enforcement_assessment.sh
214:frameworks/quality-assurance/testing/run_tests.sh
218:frameworks/quality-assurance/testing/run_tests_with_logging.sh
226:python frameworks/quality-assurance/formatting/fix_markdown_comprehensive.py
325:frameworks/quality-assurance/quality-control/validation_summary.sh --debug
335:frameworks/quality-assurance/testing/run_tests_with_logging.sh --verbose
345:python frameworks/quality-assurance/formatting/fix_markdown_comprehensive.py --check-only
```

------------------------------------------------------------------

## Script Quality & Security Checks
### \033[0;34mbuild-deployment
#### Shell Scripts Found:
```text
analyze_ci_patterns.sh
analyze_failed_ci_runs.sh
analyze_service_dependencies.sh
assess_pr_health.sh
audit_env_vars.sh
auto_environment_setup.sh
auto_fix_terminal_violations.sh
batch_close_ci_noise.sh
check_dependencies.sh
check_environment_consistency.sh
ci_recovery_system.sh
ci_troubleshooting_framework.sh
ci_troubleshoot.sh
clean_pytest_artifacts.sh
clean_root_artifacts.sh
deployment_summary.sh
dev_setup.sh
enhanced_ci_failure_analysis.sh
enhanced_root_artifact_guard.sh
env_security_audit.sh
load_token_environment.sh
manage_logs.sh
manage_test_artifacts.sh
migrate_tokens_from_env.sh
monitor_ci_health.sh
next_steps_deployment.sh
orchestrate-dev.sh
orchestrate-prod.sh
orchestrate-staging.sh
qc_with_autofix.sh
quick_ci_dashboard.sh
rapid_ci_cleanup.sh
run_tests.sh
run_tests_with_logging.sh
setup_automation.sh
setup_discord_env.sh
setup-env.sh
setup_tests.sh
setup_tunnel.sh
setup_vscode_integration.sh
smart_env_sync.sh
sync_env_variables.sh
test_coverage_implementation.sh
validate_ci_locally.sh
validate_tunnel_setup.sh
wait_for_service.sh
workflow_health_validator.sh
```
- **load_token_environment.sh**: \033[1;33m[WEAK ERROR HANDLING]\033[0m 
- **env_security_audit.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[WEAK ERROR HANDLING]\033[0m 
- **sync_env_variables.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[WEAK ERROR HANDLING]\033[0m 
- **migrate_tokens_from_env.sh**: \033[1;33m[INCOMPLETE LOGGING: NO_LOG_DIR_CREATION ]\033[0m 
- **smart_env_sync.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[WEAK ERROR HANDLING]\033[0m 
- **quick_ci_dashboard.sh**: \033[1;33m[WEAK ERROR HANDLING]\033[0m 
- **validate_tunnel_setup.sh**: \033[1;33m[WEAK ERROR HANDLING]\033[0m 
- **setup_tunnel.sh**: \033[1;33m[WEAK ERROR HANDLING]\033[0m 
- **deployment_summary.sh**: \033[1;33m[WEAK ERROR HANDLING]\033[0m 
- **next_steps_deployment.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[WEAK ERROR HANDLING]\033[0m 

### \033[0;34mfriction_prevention
#### Shell Scripts Found:
```text
analyze_logs.sh
assess_pr_health.sh
auto_branch_manager.sh
automate_issue_discovery.sh
automate_post_merge_cleanup.sh
automate_pr_process.sh
automate_signature_verification.sh
batch_close_ci_noise.sh
check_dependencies.sh
clean_pytest_artifacts.sh
cleanup_branches.sh
close_ci_batch.sh
close_resolved_issues.sh
comprehensive_branch_cleanup.sh
create_pr_safe.sh
create_pr.sh
create_pr_tracking_issue.sh
enhanced_token_loader.sh
env_security_audit.sh
execute_automation_plan.sh
final_automation_execution.sh
framework_integration.sh
manage_ci_failure_issues.sh
manage_logs.sh
manual_branch_cleanup.sh
monitor_ci_health.sh
pr_decision_engine.sh
qc_pre_push.sh
run_tests.sh
run_tests_with_logging.sh
safe_commit_enhanced.sh
safe_commit.sh
setup_automation.sh
smart_env_sync.sh
validate_internal_links.sh
```
- **comprehensive_branch_cleanup.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m 
- **close_ci_batch.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **create_pr.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **setup_automation.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **auto_branch_manager.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **close_resolved_issues.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **cleanup_branches.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **manage_ci_failure_issues.sh**: \033[1;33m[INCOMPLETE LOGGING: NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **execute_automation_plan.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **automate_post_merge_cleanup.sh**: \033[1;33m[INCOMPLETE LOGGING: NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **automate_issue_discovery.sh**: \033[1;33m[INCOMPLETE LOGGING: NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **create_pr_safe.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **pr_decision_engine.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **create_pr_tracking_issue.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[INCOMPLETE LOGGING: NO_TIMESTAMPED_LOGS NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **final_automation_execution.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **manual_branch_cleanup.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[INCOMPLETE LOGGING: NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **batch_close_ci_noise.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **automate_pr_process.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[INCOMPLETE LOGGING: NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **assess_pr_health.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **automate_signature_verification.sh**: \033[1;33m[INCOMPLETE LOGGING: NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **safe_commit_enhanced.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **safe_commit.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **framework_integration.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **monitor_ci_health.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **env_security_audit.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[WEAK ERROR HANDLING]\033[0m \033[1;33m[INCOMPLETE LOGGING: NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **enhanced_token_loader.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[WEAK ERROR HANDLING]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **smart_env_sync.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[WEAK ERROR HANDLING]\033[0m \033[1;33m[INCOMPLETE LOGGING: NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **clean_pytest_artifacts.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **analyze_logs.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **check_dependencies.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 

### \033[0;34mmonitoring-automation
#### Shell Scripts Found:
```text
analyze_ci_patterns_robust.sh
analyze_ci_patterns.sh
analyze_failed_ci_runs.sh
analyze_service_dependencies.sh
assess_pr_health_robust.sh
assess_pr_health.sh
automate_pr_process.sh
check_automerge_health.sh
comprehensive_token_health_check.sh
coverage_monitor.sh
execute_automation_plan.sh
final_automation_execution.sh
fix_markdown_compliance_automation.sh
manage_ci_failure_issues.sh
monitor_ci_health.sh
monitor_duplication.sh
monitor_validation.sh
mvp_health_monitor.sh
orchestrate-dev.sh
orchestrate-prod.sh
orchestrate-staging.sh
quick_ci_dashboard.sh
setup_automation.sh
simple_token_health.sh
token_health_check.sh
workflow_health_validator.sh
```
- **workflow_health_validator.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[INCOMPLETE LOGGING: NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **monitor_validation.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **analyze_ci_patterns_robust.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m 
- **analyze_failed_ci_runs.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **monitor_ci_health.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **analyze_ci_patterns.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **monitor_duplication.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[HERE-DOC SYNTAX]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **token_health_check.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **mvp_health_monitor.sh**: \033[1;33m[INCOMPLETE LOGGING: NO_LOG_DIR_CREATION NO_TIMESTAMPED_LOGS NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **assess_pr_health_robust.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m 
- **quick_ci_dashboard.sh**: \033[1;33m[WEAK ERROR HANDLING]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **simple_token_health.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **analyze_service_dependencies.sh**: \033[1;33m[INCOMPLETE LOGGING: NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **assess_pr_health.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **fix_markdown_compliance_automation.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **setup_automation.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **orchestrate-staging.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **orchestrate-prod.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **manage_ci_failure_issues.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[INCOMPLETE LOGGING: NO_SCRIPT_NAME_IN_LOG ]\033[0m 
- **execute_automation_plan.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **orchestrate-dev.sh**: \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **final_automation_execution.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[0;31m[NOT USING CENTRALIZED LOGGING]\033[0m 
- **automate_pr_process.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m \033[1;33m[INCOMPLETE LOGGING: NO_SCRIPT_NAME_IN_LOG ]\033[0m 

### \033[0;34mquality-assurance
#### Shell Scripts Found:
```text
qc_docs.sh
qc_pre_push.sh
run_tests.sh
run_tests_with_logging.sh
standards_enforcement_assessment.sh
validation_summary.sh
```
- **validation_summary.sh**: \033[1;33m[EMOJIS IN ECHO]\033[0m 


------------------------------------------------------------------

## Documentation Quality Checks
### \033[0;34mbuild-deployment
\033[0;31m[MISSING 'Description' SECTION]\033[0m \033[0;31m[MISSING 'Usage' SECTION]\033[0m \033[0;31m[MISSING 'Requirements' SECTION]\033[0m \033[0;31m[MISSING 'Scripts' SECTION]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/validation/validate_log_centralization.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/build-deployment/deployment_scripts/deploy_to_staging.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/build-deployment/build_automation/build_docker_images.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality_assurance/testing/run_tests.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/build-deployment/deployment_scripts/deploy_to_staging.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/build-deployment/deployment_scripts/rollback_deployment.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/build-deployment/environment_management/sync_environments.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/build-deployment/build_automation/build_validation.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/build-deployment/environment_management/validate_environment_config.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/build-deployment/continuous_integration/pipeline_health_monitor.sh]\033[0m 

### \033[0;34mfriction_prevention
\033[0;31m[MISSING 'Description' SECTION]\033[0m \033[0;31m[MISSING 'Usage' SECTION]\033[0m \033[0;31m[MISSING 'Requirements' SECTION]\033[0m \033[0;31m[MISSING 'Scripts' SECTION]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/friction_prevention/workflow/qc_pre_push.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/friction_prevention/automation/automate_pr_process.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/friction_prevention/workflow/smart_env_sync.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/friction_prevention/productivity/analyze_logs.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/friction_prevention/developer_experience/safe_commit.sh]\033[0m 

### \033[0;34mmonitoring-automation
\033[0;31m[MISSING 'Description' SECTION]\033[0m \033[0;31m[MISSING 'Usage' SECTION]\033[0m \033[0;31m[MISSING 'Requirements' SECTION]\033[0m \033[0;31m[MISSING 'Scripts' SECTION]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/validation/validate_log_centralization.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/build-deployment/deployment_scripts/deploy_to_staging.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/monitoring-automation/monitoring_scripts/monitor_ci_health.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/monitoring-automation/monitoring_scripts/monitor_ci_health.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/monitoring-automation/health_checks/mvp_health_monitor.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/monitoring-automation/automation_orchestration/orchestrate-dev.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/monitoring-automation/automation_orchestration/orchestrate-prod.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/monitoring-automation/health_checks/comprehensive_token_health_check.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/monitoring-automation/health_checks/assess_pr_health_robust.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/monitoring-automation/health_checks/comprehensive_token_health_check.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/monitoring-automation/automation_orchestration/orchestrate-dev.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/monitoring-automation/health_checks/mvp_health_monitor.sh]\033[0m 

### \033[0;34mquality-assurance
\033[0;31m[MISSING 'Description' SECTION]\033[0m \033[0;31m[MISSING 'Usage' SECTION]\033[0m \033[0;31m[MISSING 'Requirements' SECTION]\033[0m \033[0;31m[MISSING 'Scripts' SECTION]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/quality-control/qc_pre_push.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/quality-control/qc_pre_push.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/quality-control/qc_pre_push.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/quality-control/qc_pre_push.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/quality-control/qc_docs.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/quality-control/validation_summary.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/code-standards/standards_enforcement_assessment.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/testing/run_tests.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/testing/run_tests_with_logging.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/quality-control/validation_summary.sh]\033[0m \033[1;33m[BROKEN SCRIPT LINK: frameworks/quality-assurance/testing/run_tests_with_logging.sh]\033[0m 


------------------------------------------------------------------

## Framework Consistency Checks
### Script Naming Patterns
- **\033[0;34mbuild-deployment\033[0m**: \033[0;36m4 kebab-case\033[0m, \033[1;33m43 snake_case\033[0m, \033[0;35m0 camelCase\033[0m (47 total)
- **\033[0;34mfriction_prevention\033[0m**: \033[0;36m0 kebab-case\033[0m, \033[1;33m35 snake_case\033[0m, \033[0;35m0 camelCase\033[0m (35 total)
- **\033[0;34mmonitoring-automation\033[0m**: \033[0;36m3 kebab-case\033[0m, \033[1;33m23 snake_case\033[0m, \033[0;35m0 camelCase\033[0m (26 total)
- **\033[0;34mquality-assurance\033[0m**: \033[0;36m0 kebab-case\033[0m, \033[1;33m6 snake_case\033[0m, \033[0;35m0 camelCase\033[0m (6 total)

### Framework Structure Consistency
| Framework | Has scripts/ | Has README | Has tests/ |
|---|:---:|:---:|:---:|
| \033[0;34mbuild-deployment\033[0m | \033[0;31m[NO] | \033[0;32m[YES] | \033[0;31m[NO] |
| \033[0;34mfriction_prevention\033[0m | \033[0;31m[NO] | \033[0;32m[YES] | \033[0;31m[NO] |
| \033[0;34mmonitoring-automation\033[0m | \033[0;31m[NO] | \033[0;32m[YES] | \033[0;31m[NO] |
| \033[0;34mquality-assurance\033[0m | \033[0;31m[NO] | \033[0;32m[YES] | \033[0;31m[NO] |

------------------------------------------------------------------

## Summary

**Audit completed at 2025-10-12T10:34:48UTC**

- Frameworks scanned: 4
- Total scripts found: 114
- Migration artifacts: 1

_This audit helps prevent repeatable errors in framework development and maintenance._
