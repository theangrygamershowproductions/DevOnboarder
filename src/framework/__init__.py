"""
Framework Phase 3: Extended Metadata System

This package provides comprehensive metadata management for DevOnboarder scripts
with governance, observability, and intelligence capabilities.

Key modules:
- extended_metadata: Core dataclasses and enums for metadata schema
- metadata_yaml: YAML serialization/deserialization utilities
- governance_engine: Policy-driven development with automated compliance
"""

from .extended_metadata import (
    ExtendedMetadata,
    GovernanceMetadata,
    ObservabilityMetadata,
    IntelligenceMetadata,
    GovernanceLevel,
)

from .metadata_yaml import (
    ExtendedMetadataYAMLManager,
    load_script_metadata,
    save_script_metadata,
    create_default_script_metadata,
)

from .governance_engine import (
    GovernancePolicyEngine,
    ApprovalManager,
    PolicyRule,
    ApprovalRequest,
)

__all__ = [
    # Extended metadata classes
    "ExtendedMetadata",
    "GovernanceMetadata",
    "ObservabilityMetadata",
    "IntelligenceMetadata",
    # Enums
    "GovernanceLevel",
    # YAML utilities
    "ExtendedMetadataYAMLManager",
    "load_script_metadata",
    "save_script_metadata",
    "create_default_script_metadata",
    # Governance engine
    "GovernancePolicyEngine",
    "ApprovalManager",
    "PolicyRule",
    "ApprovalRequest",
]

__version__ = "3.0.0"
__author__ = "DevOnboarder Team"
