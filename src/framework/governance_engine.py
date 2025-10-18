"""
Governance Policy Engine for DevOnboarder Framework Phase 3

This module provides the governance policy engine that enables policy-driven
development with automated compliance verification and approval workflows.

Key Features:
- Policy-based governance with automated compliance checking
- Approval workflow integration with configurable thresholds
- Audit trail and compliance reporting
- Integration with existing DevOnboarder quality gates
- Support for governance levels: critical, high, medium, low
- Team-based ownership and approval workflows
"""

from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
import logging
from abc import ABC, abstractmethod

from .extended_metadata import (
    ExtendedMetadata,
    GovernanceLevel,
    ComplianceTag,
)
from .metadata_yaml import ExtendedMetadataYAMLManager

# Configure logging
logger = logging.getLogger(__name__)


class PolicyViolationType(Enum):
    """Types of policy violations"""

    GOVERNANCE_LEVEL_INSUFFICIENT = "governance_level_insufficient"
    MISSING_COMPLIANCE_TAG = "missing_compliance_tag"
    APPROVAL_REQUIRED = "approval_required"
    AUDIT_OVERDUE = "audit_overdue"
    UNAUTHORIZED_OWNER = "unauthorized_owner"
    MISSING_METADATA = "missing_metadata"
    INVALID_CONFIGURATION = "invalid_configuration"


class PolicyViolationSeverity(Enum):
    """Policy violation severity levels"""

    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
    INFO = "info"


@dataclass
class PolicyViolation:
    """Represents a policy violation"""

    violation_type: PolicyViolationType
    severity: PolicyViolationSeverity
    message: str
    script_path: Path
    metadata: Optional[ExtendedMetadata] = None
    remediation_hint: Optional[str] = None
    blocking: bool = True  # Whether violation blocks execution


@dataclass
class ApprovalRequest:
    """Represents an approval request"""

    script_path: Path
    metadata: Optional[ExtendedMetadata]
    requested_by: str
    requested_at: datetime
    reason: str
    governance_level: GovernanceLevel
    compliance_tags: List[ComplianceTag]
    approved: Optional[bool] = None
    approved_by: Optional[str] = None
    approved_at: Optional[datetime] = None
    approval_notes: Optional[str] = None


class PolicyRule(ABC):
    """Abstract base class for governance policy rules"""

    @abstractmethod
    def check(
        self, script_path: Path, metadata: Optional[ExtendedMetadata]
    )  List[PolicyViolation]:
        """
        Check if the script/metadata violates this policy rule.

        Args:
            script_path: Path to the script being checked
            metadata: Extended metadata for the script (may be None)

        Returns:
            List of policy violations (empty if no violations)
        """
        pass

    @abstractmethod
    def get_rule_name(self)  str:
        """Get the name of this policy rule"""
        pass


class MetadataRequiredRule(PolicyRule):
    """Rule that requires scripts to have metadata"""

    def check(
        self, script_path: Path, metadata: Optional[ExtendedMetadata]
    )  List[PolicyViolation]:
        if metadata is None:
            return [
                PolicyViolation(
                    violation_type=PolicyViolationType.MISSING_METADATA,
                    severity=PolicyViolationSeverity.HIGH,
                    message=f"Script {script_path.name} missing required metadata",
                    script_path=script_path,
                    remediation_hint="Use create_default_script_metadata()",
                )
            ]
        return []

    def get_rule_name(self)  str:
        return "metadata_required"


class GovernanceLevelRule(PolicyRule):
    """Rule that enforces minimum governance levels for certain script types"""

    def __init__(self, required_levels: Dict[str, GovernanceLevel]):
        """
        Initialize with required governance levels by script pattern.

        Args:
            required_levels: Dict mapping script patterns to minimum governance levels
        """
        self.required_levels = required_levels

    def check(
        self, script_path: Path, metadata: Optional[ExtendedMetadata]
    )  List[PolicyViolation]:
        if metadata is None:
            return []  # Handled by MetadataRequiredRule

        violations = []
        for pattern, required_level in self.required_levels.items():
            if pattern in script_path.name:
                current_level = metadata.governance.level
                if self._level_priority(current_level) < self._level_priority(
                    required_level
                ):
                    violations.append(
                        PolicyViolation(
                            violation_type=PolicyViolationType.GOVERNANCE_LEVEL_INSUFFICIENT,
                            severity=self._get_severity_for_level(required_level),
                            message=(
                                f"Script {script_path.name} requires "
                                f"{required_level.value} governance level, "
                                f"but has {current_level.value}"
                            ),
                            script_path=script_path,
                            metadata=metadata,
                            remediation_hint=(
                                f"Update governance.level to '{required_level.value}'"
                            ),
                        )
                    )

        return violations

    def _level_priority(self, level: GovernanceLevel)  int:
        """Get numeric priority for governance level (higher = more restrictive)"""
        priorities = {
            GovernanceLevel.LOW: 1,
            GovernanceLevel.MEDIUM: 2,
            GovernanceLevel.HIGH: 3,
            GovernanceLevel.CRITICAL: 4,
        }
        return priorities[level]

    def _get_severity_for_level(
        self, level: GovernanceLevel
    )  PolicyViolationSeverity:
        """Get violation severity based on required governance level"""
        severity_map = {
            GovernanceLevel.LOW: PolicyViolationSeverity.LOW,
            GovernanceLevel.MEDIUM: PolicyViolationSeverity.MEDIUM,
            GovernanceLevel.HIGH: PolicyViolationSeverity.HIGH,
            GovernanceLevel.CRITICAL: PolicyViolationSeverity.CRITICAL,
        }
        return severity_map[level]

    def get_rule_name(self)  str:
        return "governance_level"


class ComplianceTagRule(PolicyRule):
    """Rule that requires specific compliance tags for certain scripts"""

    def __init__(self, required_tags: Dict[str, List[ComplianceTag]]):
        """
        Initialize with required compliance tags by script pattern.

        Args:
            required_tags: Dict mapping script patterns to required compliance tags
        """
        self.required_tags = required_tags

    def check(
        self, script_path: Path, metadata: Optional[ExtendedMetadata]
    )  List[PolicyViolation]:
        if metadata is None:
            return []  # Handled by MetadataRequiredRule

        violations = []
        for pattern, required_tags in self.required_tags.items():
            if pattern in script_path.name:
                current_tags = set(metadata.governance.compliance_tags)
                missing_tags = set(required_tags) - current_tags

                for missing_tag in missing_tags:
                    violations.append(
                        PolicyViolation(
                            violation_type=PolicyViolationType.MISSING_COMPLIANCE_TAG,
                            severity=self._get_severity_for_tag(missing_tag),
                            message=f"Script {script_path.name} missing required "
                            f"compliance tag: {missing_tag.value}",
                            script_path=script_path,
                            metadata=metadata,
                            remediation_hint=(
                                f"Add '{missing_tag.value}' to compliance_tags"
                            ),
                        )
                    )

        return violations

    def _get_severity_for_tag(self, tag: ComplianceTag)  PolicyViolationSeverity:
        """Get violation severity based on compliance tag"""
        severity_map = {
            ComplianceTag.SECURITY: PolicyViolationSeverity.HIGH,
            ComplianceTag.AUDIT: PolicyViolationSeverity.MEDIUM,
            ComplianceTag.PRIVACY: PolicyViolationSeverity.HIGH,
            ComplianceTag.FINANCIAL: PolicyViolationSeverity.CRITICAL,
            ComplianceTag.REGULATORY: PolicyViolationSeverity.HIGH,
        }
        return severity_map.get(tag, PolicyViolationSeverity.MEDIUM)

    def get_rule_name(self)  str:
        return "compliance_tags"


class ApprovalRequiredRule(PolicyRule):
    """Rule that requires approval for high-governance scripts"""

    def __init__(self, approval_manager: "ApprovalManager"):
        self.approval_manager = approval_manager

    def check(
        self, script_path: Path, metadata: Optional[ExtendedMetadata]
    )  List[PolicyViolation]:
        if metadata is None:
            return []  # Handled by MetadataRequiredRule

        if (
            metadata.governance.approval_required
            and not self.approval_manager.is_approved(script_path)
        ):
            return [
                PolicyViolation(
                    violation_type=PolicyViolationType.APPROVAL_REQUIRED,
                    severity=self._get_severity_for_level(metadata.governance.level),
                    message=(
                        f"Script {script_path.name} requires approval before execution"
                    ),
                    script_path=script_path,
                    metadata=metadata,
                    remediation_hint="Request approval through governance workflow",
                )
            ]

        return []

    def _get_severity_for_level(
        self, level: GovernanceLevel
    )  PolicyViolationSeverity:
        """Get violation severity based on governance level"""
        severity_map = {
            GovernanceLevel.LOW: PolicyViolationSeverity.LOW,
            GovernanceLevel.MEDIUM: PolicyViolationSeverity.MEDIUM,
            GovernanceLevel.HIGH: PolicyViolationSeverity.HIGH,
            GovernanceLevel.CRITICAL: PolicyViolationSeverity.CRITICAL,
        }
        return severity_map[level]

    def get_rule_name(self)  str:
        return "approval_required"


class AuditOverdueRule(PolicyRule):
    """Rule that checks for overdue audits"""

    def check(
        self, script_path: Path, metadata: Optional[ExtendedMetadata]
    )  List[PolicyViolation]:
        if metadata is None:
            return []  # Handled by MetadataRequiredRule

        # Check if audit is overdue based on last_updated and audit_frequency_days
        last_updated = metadata.last_updated
        audit_frequency = metadata.governance.audit_frequency_days
        next_audit_due = last_updated  timedelta(days=audit_frequency)

        if datetime.now() > next_audit_due:
            days_overdue = (datetime.now() - next_audit_due).days
            return [
                PolicyViolation(
                    violation_type=PolicyViolationType.AUDIT_OVERDUE,
                    severity=self._get_severity_for_overdue_days(days_overdue),
                    message=(
                        f"Script {script_path.name} audit overdue by {days_overdue}d"
                    ),
                    script_path=script_path,
                    metadata=metadata,
                    remediation_hint="Update metadata and perform audit review",
                    blocking=days_overdue > 30,  # Only blocking if > 30 days overdue
                )
            ]

        return []

    def _get_severity_for_overdue_days(self, days: int)  PolicyViolationSeverity:
        """Get violation severity based on overdue days"""
        if days > 90:
            return PolicyViolationSeverity.CRITICAL
        elif days > 30:
            return PolicyViolationSeverity.HIGH
        elif days > 7:
            return PolicyViolationSeverity.MEDIUM
        else:
            return PolicyViolationSeverity.LOW

    def get_rule_name(self)  str:
        return "audit_overdue"


class ApprovalManager:
    """Manages approval workflows for governance"""

    def __init__(self, approvals_file: Optional[Path] = None):
        self.approvals_file = approvals_file or Path(".governance/approvals.yaml")
        self.approvals: Dict[str, ApprovalRequest] = {}
        self._load_approvals()

    def _load_approvals(self):
        """Load existing approvals from file"""
        if self.approvals_file.exists():
            try:
                import yaml

                with open(self.approvals_file) as f:
                    data = yaml.safe_load(f) or {}

                # Deserialize approval requests
                for script_path_str, approval_data in data.items():
                    try:
                        # Convert string dates back to datetime
                        if approval_data.get("requested_at"):
                            approval_data["requested_at"] = datetime.fromisoformat(
                                approval_data["requested_at"]
                            )
                        if approval_data.get("approved_at"):
                            approval_data["approved_at"] = datetime.fromisoformat(
                                approval_data["approved_at"]
                            )

                        # Create ApprovalRequest (simplified metadata deserialization)
                        # In production, would need full metadata deserialization
                        request = ApprovalRequest(
                            script_path=Path(script_path_str),
                            metadata=None,  # Simplified for now
                            requested_by=approval_data["requested_by"],
                            requested_at=approval_data["requested_at"],
                            reason=approval_data["reason"],
                            governance_level=GovernanceLevel(
                                approval_data["governance_level"]
                            ),
                            compliance_tags=[
                                ComplianceTag(tag)
                                for tag in approval_data["compliance_tags"]
                            ],
                            approved=approval_data.get("approved"),
                            approved_by=approval_data.get("approved_by"),
                            approved_at=approval_data.get("approved_at"),
                            approval_notes=approval_data.get("approval_notes"),
                        )
                        self.approvals[script_path_str] = request
                    except Exception as e:
                        logger.warning(
                            f"Failed to deserialize approval for {script_path_str}: {e}"
                        )

                logger.debug(f"Loaded {len(self.approvals)} approvals")
            except Exception as e:
                logger.warning(f"Failed to load approvals: {e}")

    def request_approval(
        self,
        script_path: Path,
        metadata: ExtendedMetadata,
        requested_by: str,
        reason: str,
    )  ApprovalRequest:
        """Request approval for a script"""
        request = ApprovalRequest(
            script_path=script_path,
            metadata=metadata,
            requested_by=requested_by,
            requested_at=datetime.now(),
            reason=reason,
            governance_level=metadata.governance.level,
            compliance_tags=metadata.governance.compliance_tags,
        )

        self.approvals[str(script_path)] = request
        self._save_approvals()

        logger.info(f"Approval requested for {script_path.name} by {requested_by}")
        return request

    def approve(
        self, script_path: Path, approved_by: str, notes: Optional[str] = None
    )  bool:
        """Approve a script"""
        key = str(script_path)
        if key not in self.approvals:
            logger.warning(f"No approval request found for {script_path}")
            return False

        request = self.approvals[key]
        request.approved = True
        request.approved_by = approved_by
        request.approved_at = datetime.now()
        request.approval_notes = notes

        self._save_approvals()

        logger.info(f"Script {script_path.name} approved by {approved_by}")
        return True

    def is_approved(self, script_path: Path)  bool:
        """Check if a script is approved"""
        key = str(script_path)
        if key not in self.approvals:
            return False

        request = self.approvals[key]
        return request.approved is True

    def add_approval(self, request: ApprovalRequest)  None:
        """Add an approval request directly to the manager"""
        key = str(request.script_path)
        self.approvals[key] = request
        logger.debug(f"Added approval request for {request.script_path.name}")

    def save_approvals(self):
        """Public method to save approvals to file"""
        self._save_approvals()

    def _save_approvals(self):
        """Save approvals to file"""
        self.approvals_file.parent.mkdir(parents=True, exist_ok=True)

        try:
            import yaml

            # Serialize approvals to YAML-compatible format
            data = {}
            for script_path_str, approval in self.approvals.items():
                data[script_path_str] = {
                    "script_path": str(approval.script_path),
                    "requested_by": approval.requested_by,
                    "requested_at": approval.requested_at.isoformat(),
                    "reason": approval.reason,
                    "governance_level": approval.governance_level.value,
                    "compliance_tags": [tag.value for tag in approval.compliance_tags],
                    "approved": approval.approved,
                    "approved_by": approval.approved_by,
                    "approved_at": (
                        approval.approved_at.isoformat()
                        if approval.approved_at
                        else None
                    ),
                    "approval_notes": approval.approval_notes,
                }

            with open(self.approvals_file, "w") as f:
                yaml.safe_dump(data, f, default_flow_style=False, sort_keys=True)

            logger.debug(
                f"Saved {len(self.approvals)} approvals to {self.approvals_file}"
            )
        except Exception as e:
            logger.error(f"Failed to save approvals: {e}")


class GovernancePolicyEngine:
    """
    Main governance policy engine that orchestrates policy checking,
    approval workflows, and compliance reporting.
    """

    def __init__(
        self,
        metadata_manager: Optional[ExtendedMetadataYAMLManager] = None,
        approval_manager: Optional[ApprovalManager] = None,
    ):
        self.metadata_manager = metadata_manager or ExtendedMetadataYAMLManager()
        self.approval_manager = approval_manager or ApprovalManager()
        self.policy_rules: List[PolicyRule] = []
        self._setup_default_rules()

    def _setup_default_rules(self):
        """Setup default policy rules for DevOnboarder"""

        # All scripts require metadata
        self.add_rule(MetadataRequiredRule())

        # Security-sensitive scripts require high governance
        security_patterns = {
            "token": GovernanceLevel.CRITICAL,
            "auth": GovernanceLevel.HIGH,
            "security": GovernanceLevel.HIGH,
            "safe_commit": GovernanceLevel.HIGH,
            "enhanced_": GovernanceLevel.HIGH,
        }
        self.add_rule(GovernanceLevelRule(security_patterns))

        # Security scripts require security compliance tag
        security_compliance = {
            "token": [ComplianceTag.SECURITY, ComplianceTag.AUDIT],
            "auth": [ComplianceTag.SECURITY],
            "safe_commit": [ComplianceTag.SECURITY],
            "enhanced_": [ComplianceTag.SECURITY],
        }
        self.add_rule(ComplianceTagRule(security_compliance))

        # Approval and audit rules
        self.add_rule(ApprovalRequiredRule(self.approval_manager))
        self.add_rule(AuditOverdueRule())

    def add_rule(self, rule: PolicyRule):
        """Add a policy rule to the engine"""
        self.policy_rules.append(rule)
        logger.debug(f"Added policy rule: {rule.get_rule_name()}")

    def check_script_compliance(self, script_path: Path)  List[PolicyViolation]:
        """
        Check a script for policy compliance.

        Args:
            script_path: Path to the script to check

        Returns:
            List of policy violations
        """
        # Load metadata
        metadata = self.metadata_manager.load_metadata(script_path)

        # Check all rules
        violations = []
        for rule in self.policy_rules:
            try:
                rule_violations = rule.check(script_path, metadata)
                violations.extend(rule_violations)
            except Exception as e:
                logger.error(f"Error checking rule {rule.get_rule_name()}: {e}")
                violations.append(
                    PolicyViolation(
                        violation_type=PolicyViolationType.INVALID_CONFIGURATION,
                        severity=PolicyViolationSeverity.HIGH,
                        message=f"Policy rule {rule.get_rule_name()} failed: {e}",
                        script_path=script_path,
                        metadata=metadata,
                    )
                )

        return violations

    def check_directory_compliance(
        self, directory: Path, script_patterns: List[str] = ["*.sh", "*.py"]
    )  Dict[Path, List[PolicyViolation]]:
        """
        Check all scripts in a directory for compliance.

        Args:
            directory: Directory to scan
            script_patterns: File patterns to match

        Returns:
            Dictionary mapping script paths to violations
        """
        results = {}

        for pattern in script_patterns:
            for script_path in directory.rglob(pattern):
                if script_path.is_file():
                    violations = self.check_script_compliance(script_path)
                    if violations:  # Only store if there are violations
                        results[script_path] = violations

        return results

    def is_script_compliant(self, script_path: Path)  bool:
        """Check if a script is compliant (no blocking violations)"""
        violations = self.check_script_compliance(script_path)
        blocking_violations = [v for v in violations if v.blocking]
        return len(blocking_violations) == 0

    def get_compliance_report(self, directory: Path)  Dict[str, Any]:
        """Generate a comprehensive compliance report"""
        compliance_results = self.check_directory_compliance(directory)

        total_scripts = sum(
            1 for pattern in ["*.sh", "*.py"] for _ in directory.rglob(pattern)
        )
        compliant_scripts = total_scripts - len(compliance_results)

        # Count violations by type and severity
        violation_counts: Dict[str, int] = {}
        severity_counts: Dict[str, int] = {}

        for violations in compliance_results.values():
            for violation in violations:
                vtype = violation.violation_type.value
                severity = violation.severity.value

                violation_counts[vtype] = violation_counts.get(vtype, 0)  1
                severity_counts[severity] = severity_counts.get(severity, 0)  1

        return {
            "timestamp": datetime.now().isoformat(),
            "directory": str(directory),
            "total_scripts": total_scripts,
            "compliant_scripts": compliant_scripts,
            "non_compliant_scripts": len(compliance_results),
            "compliance_percentage": (
                (compliant_scripts / total_scripts * 100) if total_scripts > 0 else 100
            ),
            "violation_counts": violation_counts,
            "severity_counts": severity_counts,
            "detailed_violations": {
                str(path): [
                    {
                        "type": v.violation_type.value,
                        "severity": v.severity.value,
                        "message": v.message,
                        "blocking": v.blocking,
                        "remediation": v.remediation_hint,
                    }
                    for v in violations
                ]
                for path, violations in compliance_results.items()
            },
        }
