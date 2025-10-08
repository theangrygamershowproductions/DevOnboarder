"""
Tests for DevOnboarder Framework Phase 3 Extended Metadata Schema
"""

import pytest
from datetime import datetime

from src.framework.extended_metadata import (
    ExtendedMetadata,
    GovernanceMetadata,
    ObservabilityMetadata,
    IntelligenceMetadata,
    GovernanceLevel,
    ComplianceTag,
    ExecutionFrequency,
    ContextAwarenessLevel,
    DecisionMakingCapability,
    LogLevel,
    PerformanceBaseline,
    FailureThreshold,
    ObservabilityMetrics,
    HealthCheck,
    LoggingConfig,
    ContextAwareness,
    AutomationCapability,
    LearningMetrics,
    create_default_metadata,
)


class TestEnums:
    """Test all enum classes"""

    def test_governance_level_enum(self):
        """Test GovernanceLevel enum values"""
        assert GovernanceLevel.LOW.value == "low"
        assert GovernanceLevel.MEDIUM.value == "medium"
        assert GovernanceLevel.HIGH.value == "high"
        assert GovernanceLevel.CRITICAL.value == "critical"

    def test_compliance_tag_enum(self):
        """Test ComplianceTag enum values"""
        assert ComplianceTag.SECURITY.value == "security"
        assert ComplianceTag.AUDIT.value == "audit"
        assert ComplianceTag.PRIVACY.value == "privacy"
        assert ComplianceTag.FINANCIAL.value == "financial"
        assert ComplianceTag.REGULATORY.value == "regulatory"

    def test_execution_frequency_enum(self):
        """Test ExecutionFrequency enum values"""
        assert ExecutionFrequency.DAILY.value == "daily"
        assert ExecutionFrequency.WEEKLY.value == "weekly"
        assert ExecutionFrequency.MONTHLY.value == "monthly"
        assert ExecutionFrequency.ON_DEMAND.value == "on_demand"

    def test_context_awareness_level_enum(self):
        """Test ContextAwarenessLevel enum values"""
        assert ContextAwarenessLevel.LOW.value == "low"
        assert ContextAwarenessLevel.MEDIUM.value == "medium"
        assert ContextAwarenessLevel.HIGH.value == "high"

    def test_decision_making_capability_enum(self):
        """Test DecisionMakingCapability enum values"""
        assert DecisionMakingCapability.MANUAL.value == "manual"
        assert DecisionMakingCapability.ASSISTED.value == "assisted"
        assert DecisionMakingCapability.AUTOMATED.value == "automated"

    def test_log_level_enum(self):
        """Test LogLevel enum values"""
        assert LogLevel.DEBUG.value == "DEBUG"
        assert LogLevel.INFO.value == "INFO"
        assert LogLevel.WARNING.value == "WARNING"
        assert LogLevel.ERROR.value == "ERROR"


class TestGovernanceMetadata:
    """Test GovernanceMetadata dataclass"""

    def test_governance_metadata_creation(self):
        """Test creating GovernanceMetadata"""
        metadata = GovernanceMetadata(
            level=GovernanceLevel.HIGH,
            compliance_tags=[ComplianceTag.SECURITY, ComplianceTag.AUDIT],
            audit_frequency_days=90,
            approval_required=True,
            governance_owner="team_security",
        )

        assert metadata.level == GovernanceLevel.HIGH
        assert ComplianceTag.SECURITY in metadata.compliance_tags
        assert ComplianceTag.AUDIT in metadata.compliance_tags
        assert metadata.audit_frequency_days == 90
        assert metadata.approval_required is True
        assert metadata.governance_owner == "team_security"
        assert metadata.policy_exceptions == []

    def test_governance_metadata_validation_valid_audit_frequency(self):
        """Test valid audit frequency days"""
        for days in [30, 90, 180, 365]:
            metadata = GovernanceMetadata(
                level=GovernanceLevel.MEDIUM,
                compliance_tags=[ComplianceTag.SECURITY],
                audit_frequency_days=days,
                approval_required=False,
                governance_owner="team_devops",
            )
            assert metadata.audit_frequency_days == days

    def test_governance_metadata_validation_invalid_audit_frequency(self):
        """Test invalid audit frequency days raises ValueError"""
        with pytest.raises(ValueError, match="Invalid audit_frequency_days"):
            GovernanceMetadata(
                level=GovernanceLevel.MEDIUM,
                compliance_tags=[ComplianceTag.SECURITY],
                audit_frequency_days=45,  # Invalid
                approval_required=False,
                governance_owner="team_devops",
            )

    def test_governance_metadata_validation_valid_owner(self):
        """Test valid governance owners"""
        valid_owners = ["team_security", "team_devops", "team_platform", "team_qa"]
        for owner in valid_owners:
            metadata = GovernanceMetadata(
                level=GovernanceLevel.MEDIUM,
                compliance_tags=[ComplianceTag.SECURITY],
                audit_frequency_days=90,
                approval_required=False,
                governance_owner=owner,
            )
            assert metadata.governance_owner == owner

    def test_governance_metadata_validation_invalid_owner(self):
        """Test invalid governance owner raises ValueError"""
        with pytest.raises(ValueError, match="Invalid governance_owner"):
            GovernanceMetadata(
                level=GovernanceLevel.MEDIUM,
                compliance_tags=[ComplianceTag.SECURITY],
                audit_frequency_days=90,
                approval_required=False,
                governance_owner="invalid_team",
            )


class TestObservabilityComponents:
    """Test observability dataclasses"""

    def test_performance_baseline_creation(self):
        """Test PerformanceBaseline creation"""
        baseline = PerformanceBaseline(
            target_duration="< 30s", memory_usage="< 100MB", cpu_usage="< 10%"
        )
        assert baseline.target_duration == "< 30s"
        assert baseline.memory_usage == "< 100MB"
        assert baseline.cpu_usage == "< 10%"

    def test_failure_threshold_creation(self):
        """Test FailureThreshold creation"""
        threshold = FailureThreshold(error_rate="< 1%", timeout_rate="< 2%")
        assert threshold.error_rate == "< 1%"
        assert threshold.timeout_rate == "< 2%"

    def test_observability_metrics_creation(self):
        """Test ObservabilityMetrics creation"""
        metrics = ObservabilityMetrics(
            execution_frequency=ExecutionFrequency.DAILY,
            performance_baseline=PerformanceBaseline(
                target_duration="< 5min", memory_usage="< 500MB", cpu_usage="< 50%"
            ),
            failure_threshold=FailureThreshold(error_rate="< 5%", timeout_rate="< 2%"),
            monitoring_alerts=["performance_degradation", "failure_spike"],
        )

        assert metrics.execution_frequency == ExecutionFrequency.DAILY
        assert metrics.performance_baseline.target_duration == "< 5min"
        assert metrics.failure_threshold.error_rate == "< 5%"
        assert "performance_degradation" in metrics.monitoring_alerts

    def test_health_check_creation(self):
        """Test HealthCheck creation"""
        health_check = HealthCheck(
            endpoint="/health", interval_seconds=30, timeout_seconds=5
        )
        assert health_check.endpoint == "/health"
        assert health_check.interval_seconds == 30
        assert health_check.timeout_seconds == 5

    def test_logging_config_creation(self):
        """Test LoggingConfig creation"""
        logging_config = LoggingConfig(
            level=LogLevel.INFO, structured=True, retention_days=30
        )
        assert logging_config.level == LogLevel.INFO
        assert logging_config.structured is True
        assert logging_config.retention_days == 30

    def test_performance_baseline_validation(self):
        """Test PerformanceBaseline validation for uncovered lines"""
        # Test invalid target_duration (line 117)
        with pytest.raises(ValueError, match="Invalid target_duration: < 2hours"):
            PerformanceBaseline(
                target_duration="< 2hours",  # Invalid
                memory_usage="< 100MB",
                cpu_usage="< 10%",
            )

        # Test invalid memory_usage (line 119)
        with pytest.raises(ValueError, match="Invalid memory_usage: < 2GB"):
            PerformanceBaseline(
                target_duration="< 30s",
                memory_usage="< 2GB",  # Invalid
                cpu_usage="< 10%",
            )

        # Test invalid cpu_usage (line 121)
        with pytest.raises(ValueError, match="Invalid cpu_usage: < 90%"):
            PerformanceBaseline(
                target_duration="< 30s",
                memory_usage="< 100MB",
                cpu_usage="< 90%",  # Invalid
            )

    def test_failure_threshold_validation(self):
        """Test FailureThreshold validation for uncovered lines"""
        # Test invalid error_rate (line 137)
        with pytest.raises(ValueError, match="Invalid error_rate: < 20%"):
            FailureThreshold(error_rate="< 20%", timeout_rate="< 2%")  # Invalid

        # Test invalid timeout_rate (line 139)
        with pytest.raises(ValueError, match="Invalid timeout_rate: < 10%"):
            FailureThreshold(error_rate="< 1%", timeout_rate="< 10%")  # Invalid

    def test_observability_metrics_validation(self):
        """Test ObservabilityMetrics validation for uncovered lines"""
        # Test invalid monitoring alert (line 168)
        with pytest.raises(ValueError, match="Invalid monitoring alert: invalid_alert"):
            ObservabilityMetrics(
                execution_frequency=ExecutionFrequency.DAILY,
                performance_baseline=PerformanceBaseline(
                    target_duration="< 30s", memory_usage="< 100MB", cpu_usage="< 10%"
                ),
                failure_threshold=FailureThreshold(
                    error_rate="< 1%", timeout_rate="< 2%"
                ),
                monitoring_alerts=["invalid_alert"],  # Invalid alert type
            )

    def test_health_check_validation(self):
        """Test HealthCheck validation for uncovered lines"""
        # Test invalid endpoint (line 182)
        with pytest.raises(ValueError, match="Invalid health check endpoint: /invalid"):
            HealthCheck(
                endpoint="/invalid",  # Invalid endpoint
                interval_seconds=30,
                timeout_seconds=5,
            )

        # Test invalid interval_seconds (line 185)
        with pytest.raises(ValueError, match="Invalid interval_seconds: 120"):
            HealthCheck(
                endpoint="/health",
                interval_seconds=120,  # Invalid interval
                timeout_seconds=5,
            )

        # Test invalid timeout_seconds (line 188)
        with pytest.raises(ValueError, match="Invalid timeout_seconds: 60"):
            HealthCheck(
                endpoint="/health",
                interval_seconds=30,
                timeout_seconds=60,  # Invalid timeout
            )

    def test_logging_config_validation(self):
        """Test LoggingConfig validation for uncovered lines"""
        # Test invalid retention_days (line 202)
        with pytest.raises(ValueError, match="Invalid retention_days: 45"):
            LoggingConfig(
                level=LogLevel.INFO,
                structured=True,
                retention_days=45,  # Invalid retention period
            )

    def test_context_awareness_validation(self):
        """Test ContextAwareness validation for uncovered lines"""
        # Test invalid environmental factor (line 259)
        with pytest.raises(
            ValueError, match="Invalid environmental factor: invalid_factor"
        ):
            ContextAwareness(
                level=ContextAwarenessLevel.LOW,
                environmental_factors=["invalid_factor"],  # Invalid factor
                decision_inputs=["user_preferences"],
            )

        # Test invalid decision input (line 263)
        with pytest.raises(ValueError, match="Invalid decision input: invalid_input"):
            ContextAwareness(
                level=ContextAwarenessLevel.LOW,
                environmental_factors=["system_load"],
                decision_inputs=["invalid_input"],  # Invalid input
            )

    def test_intelligence_metadata_validation(self):
        """Test IntelligenceMetadata validation for uncovered lines"""
        # Test invalid integration point (line 323)
        with pytest.raises(
            ValueError, match="Invalid integration point: invalid_point"
        ):
            IntelligenceMetadata(
                context_awareness=ContextAwareness(
                    level=ContextAwarenessLevel.LOW,
                    environmental_factors=["system_load"],
                    decision_inputs=["user_preferences"],
                ),
                automation_capability=AutomationCapability(
                    decision_making=DecisionMakingCapability.MANUAL,
                    self_healing=False,
                    adaptive_behavior=False,
                    learning_enabled=True,
                ),
                integration_points=["invalid_point"],  # Invalid integration point
            )


class TestIntelligenceComponents:
    """Test intelligence dataclasses"""

    def test_context_awareness_creation(self):
        """Test ContextAwareness creation"""
        context = ContextAwareness(
            level=ContextAwarenessLevel.HIGH,
            environmental_factors=["git_branch_state", "ci_pipeline_status"],
            decision_inputs=["historical_performance", "current_system_state"],
        )

        assert context.level == ContextAwarenessLevel.HIGH
        assert "git_branch_state" in context.environmental_factors
        assert "historical_performance" in context.decision_inputs

    def test_automation_capability_creation(self):
        """Test AutomationCapability creation"""
        automation = AutomationCapability(
            decision_making=DecisionMakingCapability.ASSISTED,
            self_healing=True,
            adaptive_behavior=False,
            learning_enabled=True,
        )

        assert automation.decision_making == DecisionMakingCapability.ASSISTED
        assert automation.self_healing is True
        assert automation.adaptive_behavior is False
        assert automation.learning_enabled is True

    def test_learning_metrics_creation(self):
        """Test LearningMetrics creation"""
        learning = LearningMetrics(
            success_rate_tracking=True,
            user_feedback_integration=False,
            performance_optimization=True,
        )

        assert learning.success_rate_tracking is True
        assert learning.user_feedback_integration is False
        assert learning.performance_optimization is True


class TestExtendedMetadata:
    """Test the main ExtendedMetadata class"""

    def test_extended_metadata_creation(self):
        """Test creating ExtendedMetadata with all components"""
        now = datetime.now()

        metadata = ExtendedMetadata(
            script_name="test_script.sh",
            version="1.0.0",
            last_updated=now,
            similarity_group="ci_cd",
            content_uniqueness_score=0.85,
            merge_candidate=False,
            governance=GovernanceMetadata(
                level=GovernanceLevel.HIGH,
                compliance_tags=[ComplianceTag.SECURITY],
                audit_frequency_days=90,
                approval_required=False,
                governance_owner="team_devops",
            ),
            observability=ObservabilityMetadata(
                metrics=ObservabilityMetrics(
                    execution_frequency=ExecutionFrequency.DAILY,
                    performance_baseline=PerformanceBaseline(
                        target_duration="< 5min",
                        memory_usage="< 500MB",
                        cpu_usage="< 50%",
                    ),
                    failure_threshold=FailureThreshold(
                        error_rate="< 5%", timeout_rate="< 2%"
                    ),
                ),
                health_check=HealthCheck(),
                logging=LoggingConfig(
                    level=LogLevel.INFO, structured=True, retention_days=30
                ),
            ),
            intelligence=IntelligenceMetadata(
                context_awareness=ContextAwareness(
                    level=ContextAwarenessLevel.MEDIUM,
                    environmental_factors=["git_branch_state"],
                    decision_inputs=["historical_performance"],
                ),
                automation_capability=AutomationCapability(
                    decision_making=DecisionMakingCapability.MANUAL,
                    self_healing=False,
                    adaptive_behavior=False,
                    learning_enabled=False,
                ),
                integration_points=["ci_pipeline"],
                learning_metrics=LearningMetrics(
                    success_rate_tracking=True,
                    user_feedback_integration=False,
                    performance_optimization=True,
                ),
            ),
        )

        assert metadata.script_name == "test_script.sh"
        assert metadata.version == "1.0.0"
        assert metadata.last_updated == now
        assert metadata.similarity_group == "ci_cd"
        assert metadata.content_uniqueness_score == 0.85
        assert metadata.merge_candidate is False
        assert metadata.governance.level == GovernanceLevel.HIGH
        assert (
            metadata.observability.metrics.execution_frequency
            == ExecutionFrequency.DAILY
        )
        assert (
            metadata.intelligence.context_awareness.level
            == ContextAwarenessLevel.MEDIUM
        )

    def test_extended_metadata_validation_content_uniqueness_score(self):
        """Test validation of content_uniqueness_score"""
        # Valid scores should pass
        for score in [0.0, 0.5, 1.0]:
            metadata = ExtendedMetadata(
                script_name="test.sh",
                version="1.0.0",
                last_updated=datetime.now(),
                similarity_group="test",
                content_uniqueness_score=score,
                merge_candidate=False,
                governance=GovernanceMetadata(
                    level=GovernanceLevel.LOW,
                    compliance_tags=[],
                    audit_frequency_days=365,
                    approval_required=False,
                    governance_owner="team_devops",
                ),
                observability=ObservabilityMetadata(
                    metrics=ObservabilityMetrics(
                        execution_frequency=ExecutionFrequency.MONTHLY,
                        performance_baseline=PerformanceBaseline(
                            target_duration="< 1hour",
                            memory_usage="< 1GB",
                            cpu_usage="< 80%",
                        ),
                        failure_threshold=FailureThreshold(
                            error_rate="< 10%", timeout_rate="< 5%"
                        ),
                    ),
                    health_check=HealthCheck(),
                    logging=LoggingConfig(
                        level=LogLevel.INFO, structured=True, retention_days=30
                    ),
                ),
                intelligence=IntelligenceMetadata(
                    context_awareness=ContextAwareness(
                        level=ContextAwarenessLevel.LOW,
                        environmental_factors=[],
                        decision_inputs=[],
                    ),
                    automation_capability=AutomationCapability(
                        decision_making=DecisionMakingCapability.MANUAL,
                        self_healing=False,
                        adaptive_behavior=False,
                        learning_enabled=False,
                    ),
                    integration_points=[],
                    learning_metrics=LearningMetrics(
                        success_rate_tracking=False,
                        user_feedback_integration=False,
                        performance_optimization=False,
                    ),
                ),
            )
            assert metadata.content_uniqueness_score == score

        # Invalid scores should raise ValueError
        for invalid_score in [-0.1, 1.1, 2.0]:
            with pytest.raises(ValueError, match="Invalid content_uniqueness_score:"):
                ExtendedMetadata(
                    script_name="test.sh",
                    version="1.0.0",
                    last_updated=datetime.now(),
                    similarity_group="test",
                    content_uniqueness_score=invalid_score,
                    merge_candidate=False,
                    governance=GovernanceMetadata(
                        level=GovernanceLevel.LOW,
                        compliance_tags=[],
                        audit_frequency_days=365,
                        approval_required=False,
                        governance_owner="team_devops",
                    ),
                    observability=ObservabilityMetadata(
                        metrics=ObservabilityMetrics(
                            execution_frequency=ExecutionFrequency.MONTHLY,
                            performance_baseline=PerformanceBaseline(
                                target_duration="< 1hour",
                                memory_usage="< 1GB",
                                cpu_usage="< 80%",
                            ),
                            failure_threshold=FailureThreshold(
                                error_rate="< 10%", timeout_rate="< 5%"
                            ),
                        ),
                        health_check=HealthCheck(),
                        logging=LoggingConfig(
                            level=LogLevel.INFO, structured=True, retention_days=30
                        ),
                    ),
                    intelligence=IntelligenceMetadata(
                        context_awareness=ContextAwareness(
                            level=ContextAwarenessLevel.LOW,
                            environmental_factors=[],
                            decision_inputs=[],
                        ),
                        automation_capability=AutomationCapability(
                            decision_making=DecisionMakingCapability.MANUAL,
                            self_healing=False,
                            adaptive_behavior=False,
                            learning_enabled=False,
                        ),
                        integration_points=[],
                        learning_metrics=LearningMetrics(
                            success_rate_tracking=False,
                            user_feedback_integration=False,
                            performance_optimization=False,
                        ),
                    ),
                )

    def test_extended_metadata_validation_similarity_group(self):
        """Test validation of similarity_group"""
        # Test invalid similarity_group (line 367)
        with pytest.raises(ValueError, match="Invalid similarity_group: invalid_group"):
            ExtendedMetadata(
                script_name="test.sh",
                version="1.0.0",
                last_updated=datetime.now(),
                similarity_group="invalid_group",  # Invalid group
                content_uniqueness_score=0.8,
                merge_candidate=False,
                governance=GovernanceMetadata(
                    level=GovernanceLevel.LOW,
                    compliance_tags=[],
                    audit_frequency_days=365,
                    approval_required=False,
                    governance_owner="team_devops",
                ),
                observability=ObservabilityMetadata(
                    metrics=ObservabilityMetrics(
                        execution_frequency=ExecutionFrequency.MONTHLY,
                        performance_baseline=PerformanceBaseline(
                            target_duration="< 1hour",
                            memory_usage="< 1GB",
                            cpu_usage="< 80%",
                        ),
                        failure_threshold=FailureThreshold(
                            error_rate="< 10%", timeout_rate="< 5%"
                        ),
                    ),
                    health_check=HealthCheck(),
                    logging=LoggingConfig(
                        level=LogLevel.INFO, structured=True, retention_days=30
                    ),
                ),
                intelligence=IntelligenceMetadata(
                    context_awareness=ContextAwareness(
                        level=ContextAwarenessLevel.LOW,
                        environmental_factors=[],
                        decision_inputs=[],
                    ),
                    automation_capability=AutomationCapability(
                        decision_making=DecisionMakingCapability.MANUAL,
                        self_healing=False,
                        adaptive_behavior=False,
                        learning_enabled=False,
                    ),
                    integration_points=[],
                    learning_metrics=LearningMetrics(
                        success_rate_tracking=False,
                        user_feedback_integration=False,
                        performance_optimization=False,
                    ),
                ),
            )

    def test_extended_metadata_to_dict(self):
        """Test converting ExtendedMetadata to dictionary"""
        now = datetime.now()
        metadata = create_default_metadata("test_script.sh", "ci_cd")
        metadata.last_updated = now  # Set specific datetime for testing

        data = metadata.to_dict()

        assert isinstance(data, dict)
        assert data["script_name"] == "test_script.sh"
        assert data["similarity_group"] == "ci_cd"
        assert data["last_updated"] == now
        assert "governance" in data
        assert "observability" in data
        assert "intelligence" in data

    def test_extended_metadata_from_dict(self):
        """Test creating ExtendedMetadata from dictionary"""
        data = {
            "script_name": "test_script.sh",
            "version": "1.0.0",
            "last_updated": "2025-10-04T12:00:00",
            "similarity_group": "ci_cd",
            "content_uniqueness_score": 0.8,
            "merge_candidate": False,
            "governance": {
                "level": "medium",
                "compliance_tags": ["security"],
                "audit_frequency_days": 90,
                "approval_required": False,
                "governance_owner": "team_devops",
                "policy_exceptions": [],
            },
            "observability": {
                "metrics": {
                    "execution_frequency": "daily",
                    "performance_baseline": {
                        "target_duration": "< 5min",
                        "memory_usage": "< 500MB",
                        "cpu_usage": "< 50%",
                    },
                    "failure_threshold": {"error_rate": "< 5%", "timeout_rate": "< 2%"},
                    "monitoring_alerts": [],
                },
                "health_check": {
                    "endpoint": None,
                    "interval_seconds": None,
                    "timeout_seconds": None,
                },
                "logging": {"level": "INFO", "structured": True, "retention_days": 30},
            },
            "intelligence": {
                "context_awareness": {
                    "level": "medium",
                    "environmental_factors": [],
                    "decision_inputs": [],
                },
                "automation_capability": {
                    "decision_making": "manual",
                    "self_healing": False,
                    "adaptive_behavior": False,
                    "learning_enabled": False,
                },
                "integration_points": [],
                "learning_metrics": {
                    "success_rate_tracking": True,
                    "user_feedback_integration": False,
                    "performance_optimization": True,
                },
            },
        }

        metadata = ExtendedMetadata.from_dict(data)

        assert metadata.script_name == "test_script.sh"
        assert metadata.version == "1.0.0"
        assert metadata.similarity_group == "ci_cd"
        assert metadata.governance.level == GovernanceLevel.MEDIUM
        assert ComplianceTag.SECURITY in metadata.governance.compliance_tags
        assert (
            metadata.observability.metrics.execution_frequency
            == ExecutionFrequency.DAILY
        )


class TestCreateDefaultMetadata:
    """Test the create_default_metadata utility function"""

    def test_create_default_metadata(self):
        """Test creating default metadata"""
        metadata = create_default_metadata("test_script.sh", "ci_cd")

        assert metadata.script_name == "test_script.sh"
        assert metadata.version == "1.0.0"
        assert metadata.similarity_group == "ci_cd"
        assert metadata.content_uniqueness_score == 0.8
        assert metadata.merge_candidate is False

        # Test default governance
        assert metadata.governance.level == GovernanceLevel.MEDIUM
        assert ComplianceTag.SECURITY in metadata.governance.compliance_tags
        assert metadata.governance.audit_frequency_days == 90
        assert metadata.governance.approval_required is False
        assert metadata.governance.governance_owner == "team_devops"

        # Test default observability
        assert (
            metadata.observability.metrics.execution_frequency
            == ExecutionFrequency.DAILY
        )
        assert metadata.observability.logging.level == LogLevel.INFO
        assert metadata.observability.logging.structured is True

        # Test default intelligence
        assert (
            metadata.intelligence.context_awareness.level
            == ContextAwarenessLevel.MEDIUM
        )
        assert (
            metadata.intelligence.automation_capability.decision_making
            == DecisionMakingCapability.MANUAL
        )
        assert metadata.intelligence.learning_metrics.success_rate_tracking is True

    def test_create_default_metadata_different_similarity_groups(self):
        """Test creating default metadata with different similarity groups"""
        groups = ["ci_cd", "quality_assurance", "script_automation", "documentation"]

        for group in groups:
            metadata = create_default_metadata("test.sh", group)
            assert metadata.similarity_group == group
            assert metadata.script_name == "test.sh"
