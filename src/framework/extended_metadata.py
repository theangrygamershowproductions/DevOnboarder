"""
Extended Metadata Schema for DevOnboarder Framework Phase 3

This module defines the dataclasses and enums for the extended metadata schema
that enables governance, observability, and intelligence capabilities across
all DevOnboarder scripts and processes.

Building upon Priority Matrix Bot v2.1's existing metadata foundation.
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional, Dict, Any
from datetime import datetime


# Enums for constrained values
class GovernanceLevel(Enum):
    """Governance level definitions for policy-driven development"""

    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"


class ComplianceTag(Enum):
    """Compliance tags for categorizing security and regulatory requirements"""

    SECURITY = "security"
    AUDIT = "audit"
    PRIVACY = "privacy"
    FINANCIAL = "financial"
    REGULATORY = "regulatory"


class ExecutionFrequency(Enum):
    """Execution frequency for observability metrics"""

    REALTIME = "realtime"
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"


class ContextAwarenessLevel(Enum):
    """Context awareness levels for intelligence capabilities"""

    AUTONOMOUS = "autonomous"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"


class DecisionMakingCapability(Enum):
    """Decision making capability levels"""

    AUTONOMOUS = "autonomous"
    ASSISTED = "assisted"
    MANUAL = "manual"


class LogLevel(Enum):
    """Logging levels"""

    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"


# Governance Metadata Structures
@dataclass
class GovernanceMetadata:
    """
    Governance metadata for policy-driven development with automated compliance
    verification and approval workflows.
    """

    level: GovernanceLevel
    compliance_tags: List[ComplianceTag]
    audit_frequency_days: int  # 30, 90, 180, 365
    approval_required: bool
    governance_owner: str  # team_security, team_devops, team_platform, team_qa
    policy_exceptions: List[str] = field(default_factory=list)

    def __post_init__(self):
        """Validate governance metadata constraints"""
        if self.audit_frequency_days not in [30, 90, 180, 365]:
            raise ValueError(
                f"Invalid audit_frequency_days: {self.audit_frequency_days}"
            )

        valid_owners = ["team_security", "team_devops", "team_platform", "team_qa"]
        if self.governance_owner not in valid_owners:
            raise ValueError(f"Invalid governance_owner: {self.governance_owner}")


# Observability Metadata Structures
@dataclass
class PerformanceBaseline:
    """Performance baseline metrics for observability"""

    target_duration: str  # "< 30s", "< 5min", "< 30min", "< 1hour"
    memory_usage: str  # "< 100MB", "< 500MB", "< 1GB"
    cpu_usage: str  # "< 10%", "< 50%", "< 80%"

    def __post_init__(self):
        """Validate performance baseline constraints"""
        valid_durations = ["< 30s", "< 5min", "< 30min", "< 1hour"]
        valid_memory = ["< 100MB", "< 500MB", "< 1GB"]
        valid_cpu = ["< 10%", "< 50%", "< 80%"]

        if self.target_duration not in valid_durations:
            raise ValueError(f"Invalid target_duration: {self.target_duration}")
        if self.memory_usage not in valid_memory:
            raise ValueError(f"Invalid memory_usage: {self.memory_usage}")
        if self.cpu_usage not in valid_cpu:
            raise ValueError(f"Invalid cpu_usage: {self.cpu_usage}")


@dataclass
class FailureThreshold:
    """Failure threshold metrics for observability"""

    error_rate: str  # "0%", "< 1%", "< 5%", "< 10%"
    timeout_rate: str  # "0%", "< 2%", "< 5%"

    def __post_init__(self):
        """Validate failure threshold constraints"""
        valid_error_rates = ["0%", "< 1%", "< 5%", "< 10%"]
        valid_timeout_rates = ["0%", "< 2%", "< 5%"]

        if self.error_rate not in valid_error_rates:
            raise ValueError(f"Invalid error_rate: {self.error_rate}")
        if self.timeout_rate not in valid_timeout_rates:
            raise ValueError(f"Invalid timeout_rate: {self.timeout_rate}")


@dataclass
class ObservabilityMetrics:
    """Observability metrics configuration"""

    execution_frequency: ExecutionFrequency
    performance_baseline: PerformanceBaseline
    failure_threshold: FailureThreshold
    monitoring_alerts: List[str] = field(
        default_factory=lambda: [
            "performance_degradation",
            "failure_spike",
            "security_anomaly",
            "resource_exhaustion",
        ]
    )

    def __post_init__(self):
        """Validate monitoring alerts"""
        valid_alerts = [
            "performance_degradation",
            "failure_spike",
            "security_anomaly",
            "resource_exhaustion",
        ]
        for alert in self.monitoring_alerts:
            if alert not in valid_alerts:
                raise ValueError(f"Invalid monitoring alert: {alert}")


@dataclass
class HealthCheck:
    """Health check configuration for observability"""

    endpoint: Optional[str] = None  # "/health", "/status", or null
    interval_seconds: Optional[int] = None  # 30, 60, 300
    timeout_seconds: Optional[int] = None  # 5, 10, 30

    def __post_init__(self):
        """Validate health check constraints"""
        if self.endpoint and self.endpoint not in ["/health", "/status"]:
            raise ValueError(f"Invalid health check endpoint: {self.endpoint}")

        if self.interval_seconds and self.interval_seconds not in [30, 60, 300]:
            raise ValueError(f"Invalid interval_seconds: {self.interval_seconds}")

        if self.timeout_seconds and self.timeout_seconds not in [5, 10, 30]:
            raise ValueError(f"Invalid timeout_seconds: {self.timeout_seconds}")


@dataclass
class LoggingConfig:
    """Logging configuration for observability"""

    level: LogLevel
    structured: bool
    retention_days: int  # 7, 30, 90, 365

    def __post_init__(self):
        """Validate logging configuration"""
        if self.retention_days not in [7, 30, 90, 365]:
            raise ValueError(f"Invalid retention_days: {self.retention_days}")


@dataclass
class ObservabilityMetadata:
    """
    Observability metadata for comprehensive monitoring, performance tracking,
    and intelligent alerting across all DevOnboarder components.
    """

    metrics: ObservabilityMetrics
    health_check: HealthCheck
    logging: LoggingConfig


# Intelligence Metadata Structures
@dataclass
class ContextAwareness:
    """Context awareness configuration for intelligence"""

    level: ContextAwarenessLevel
    environmental_factors: List[str] = field(
        default_factory=lambda: [
            "git_branch_state",
            "ci_pipeline_status",
            "deployment_environment",
            "system_load",
            "time_of_day",
        ]
    )
    decision_inputs: List[str] = field(
        default_factory=lambda: [
            "historical_performance",
            "current_system_state",
            "user_preferences",
            "security_context",
        ]
    )

    def __post_init__(self):
        """Validate context awareness configuration"""
        valid_factors = [
            "git_branch_state",
            "ci_pipeline_status",
            "deployment_environment",
            "system_load",
            "time_of_day",
        ]
        valid_inputs = [
            "historical_performance",
            "current_system_state",
            "user_preferences",
            "security_context",
        ]

        for factor in self.environmental_factors:
            if factor not in valid_factors:
                raise ValueError(f"Invalid environmental factor: {factor}")

        for input_type in self.decision_inputs:
            if input_type not in valid_inputs:
                raise ValueError(f"Invalid decision input: {input_type}")


@dataclass
class AutomationCapability:
    """Automation capability configuration for intelligence"""

    decision_making: DecisionMakingCapability
    self_healing: bool
    adaptive_behavior: bool
    learning_enabled: bool


@dataclass
class LearningMetrics:
    """Learning metrics configuration for intelligence"""

    success_rate_tracking: bool
    user_feedback_integration: bool
    performance_optimization: bool


@dataclass
class IntelligenceMetadata:
    """
    Intelligence metadata for context-aware decision making, autonomous operation,
    and continuous learning capabilities.
    """

    context_awareness: ContextAwareness
    automation_capability: AutomationCapability
    integration_points: List[str] = field(
        default_factory=lambda: [
            "pre_commit_hooks",
            "ci_pipeline",
            "deployment_automation",
            "monitoring_systems",
            "notification_systems",
        ]
    )
    learning_metrics: LearningMetrics = field(
        default_factory=lambda: LearningMetrics(
            success_rate_tracking=True,
            user_feedback_integration=False,
            performance_optimization=True,
        )
    )

    def __post_init__(self):
        """Validate intelligence metadata configuration"""
        valid_integration_points = [
            "pre_commit_hooks",
            "ci_pipeline",
            "deployment_automation",
            "monitoring_systems",
            "notification_systems",
        ]

        for point in self.integration_points:
            if point not in valid_integration_points:
                raise ValueError(f"Invalid integration point: {point}")


# Core Extended Metadata Structure
@dataclass
class ExtendedMetadata:
    """
    Complete extended metadata schema for DevOnboarder Framework Phase 3,
    building upon Priority Matrix Bot v2.1's existing metadata foundation.
    """

    # Script identification
    script_name: str
    version: str
    last_updated: datetime

    # Existing Priority Matrix Bot fields (maintained)
    similarity_group: str  # Priority Matrix Bot similarity group
    content_uniqueness_score: float  # 0.0 - 1.0
    merge_candidate: bool

    # Phase 3 Extensions
    governance: GovernanceMetadata
    observability: ObservabilityMetadata
    intelligence: IntelligenceMetadata

    def __post_init__(self):
        """Validate extended metadata constraints"""
        if not 0.0 <= self.content_uniqueness_score <= 1.0:
            raise ValueError(
                f"Invalid content_uniqueness_score: {self.content_uniqueness_score}"
            )

        valid_similarity_groups = [
            "script_automation",
            "ci_cd",
            "quality_assurance",
            "documentation",
        ]
        if self.similarity_group not in valid_similarity_groups:
            raise ValueError(f"Invalid similarity_group: {self.similarity_group}")

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        from dataclasses import asdict

        return asdict(self)

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "ExtendedMetadata":
        """Create from dictionary for deserialization"""
        # Handle datetime conversion
        if isinstance(data.get("last_updated"), str):
            data["last_updated"] = datetime.fromisoformat(data["last_updated"])

        # Convert enum strings back to enums
        if "governance" in data:
            gov = data["governance"]
            if isinstance(gov["level"], str):
                gov["level"] = GovernanceLevel(gov["level"])
            if "compliance_tags" in gov:
                gov["compliance_tags"] = [
                    ComplianceTag(tag) for tag in gov["compliance_tags"]
                ]

        if "observability" in data:
            obs = data["observability"]
            if "metrics" in obs and "execution_frequency" in obs["metrics"]:
                obs["metrics"]["execution_frequency"] = ExecutionFrequency(
                    obs["metrics"]["execution_frequency"]
                )
            if "logging" in obs and "level" in obs["logging"]:
                obs["logging"]["level"] = LogLevel(obs["logging"]["level"])

        if "intelligence" in data:
            intel = data["intelligence"]
            if "context_awareness" in intel and "level" in intel["context_awareness"]:
                intel["context_awareness"]["level"] = ContextAwarenessLevel(
                    intel["context_awareness"]["level"]
                )
            automation_cap = intel.get("automation_capability", {})
            if "decision_making" in automation_cap:
                automation_cap["decision_making"] = DecisionMakingCapability(
                    automation_cap["decision_making"]
                )

        return cls(**data)


# Utility functions for metadata management
def create_default_metadata(
    script_name: str, similarity_group: str
) -> ExtendedMetadata:
    """Create default extended metadata for a script"""
    return ExtendedMetadata(
        script_name=script_name,
        version="1.0.0",
        last_updated=datetime.now(),
        similarity_group=similarity_group,
        content_uniqueness_score=0.8,
        merge_candidate=False,
        governance=GovernanceMetadata(
            level=GovernanceLevel.MEDIUM,
            compliance_tags=[ComplianceTag.SECURITY],
            audit_frequency_days=90,
            approval_required=False,
            governance_owner="team_devops",
        ),
        observability=ObservabilityMetadata(
            metrics=ObservabilityMetrics(
                execution_frequency=ExecutionFrequency.DAILY,
                performance_baseline=PerformanceBaseline(
                    target_duration="< 5min", memory_usage="< 500MB", cpu_usage="< 50%"
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
            context_awareness=ContextAwareness(level=ContextAwarenessLevel.MEDIUM),
            automation_capability=AutomationCapability(
                decision_making=DecisionMakingCapability.MANUAL,
                self_healing=False,
                adaptive_behavior=False,
                learning_enabled=False,
            ),
        ),
    )
