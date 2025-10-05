"""
YAML Serialization for Extended Metadata Schema

This module provides YAML serialization and deserialization capabilities
for the extended metadata schema, with support for custom handling of
enums, datetime objects, and complex nested structures.

Key Features:
- Custom YAML representers for enum types
- DateTime handling with ISO format
- Schema validation during deserialization
- File-based metadata management
- Backward compatibility with Priority Matrix Bot v2.1
"""

import yaml
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, Optional, List
import logging

from .extended_metadata import (
    ExtendedMetadata,
    GovernanceLevel,
    ComplianceTag,
    ExecutionFrequency,
    ContextAwarenessLevel,
    DecisionMakingCapability,
    LogLevel,
    create_default_metadata,
)

# Configure logging
logger = logging.getLogger(__name__)


class ExtendedMetadataYAMLManager:
    """
    Manager class for YAML serialization/deserialization of extended metadata.

    Handles file-based metadata storage with the pattern:
    {script_directory}/.metadata/{script_name}.yaml
    """

    def __init__(self, base_directory: Optional[Path] = None):
        """
        Initialize the YAML manager.

        Args:
            base_directory: Base directory for metadata storage.
                          If None, uses current working directory.
        """
        self.base_directory = base_directory or Path.cwd()
        self._setup_yaml_representers()

    def _setup_yaml_representers(self):
        """Setup custom YAML representers for enum types and datetime"""

        # Enum representers
        def represent_governance_level(dumper, data):
            return dumper.represent_scalar("tag:yaml.org,2002:str", data.value)

        def represent_compliance_tag(dumper, data):
            return dumper.represent_scalar("tag:yaml.org,2002:str", data.value)

        def represent_execution_frequency(dumper, data):
            return dumper.represent_scalar("tag:yaml.org,2002:str", data.value)

        def represent_context_awareness_level(dumper, data):
            return dumper.represent_scalar("tag:yaml.org,2002:str", data.value)

        def represent_decision_making_capability(dumper, data):
            return dumper.represent_scalar("tag:yaml.org,2002:str", data.value)

        def represent_log_level(dumper, data):
            return dumper.represent_scalar("tag:yaml.org,2002:str", data.value)

        def represent_datetime(dumper, data):
            return dumper.represent_scalar("tag:yaml.org,2002:str", data.isoformat())

        # Register representers
        yaml.add_representer(GovernanceLevel, represent_governance_level)
        yaml.add_representer(ComplianceTag, represent_compliance_tag)
        yaml.add_representer(ExecutionFrequency, represent_execution_frequency)
        yaml.add_representer(ContextAwarenessLevel, represent_context_awareness_level)
        yaml.add_representer(
            DecisionMakingCapability, represent_decision_making_capability
        )
        yaml.add_representer(LogLevel, represent_log_level)
        yaml.add_representer(datetime, represent_datetime)

    def serialize_metadata(self, metadata: ExtendedMetadata) -> str:
        """
        Serialize ExtendedMetadata to YAML string.

        Args:
            metadata: ExtendedMetadata instance to serialize

        Returns:
            YAML string representation
        """
        try:
            metadata_dict = metadata.to_dict()
            return yaml.dump(
                metadata_dict,
                default_flow_style=False,
                sort_keys=False,
                indent=2,
                width=88,  # Match line length limit
                allow_unicode=True,
            )
        except Exception as e:
            logger.error(f"Failed to serialize metadata: {e}")
            raise

    def deserialize_metadata(self, yaml_content: str) -> ExtendedMetadata:
        """
        Deserialize YAML string to ExtendedMetadata.

        Args:
            yaml_content: YAML string to deserialize

        Returns:
            ExtendedMetadata instance

        Raises:
            ValueError: If YAML content is invalid or missing required fields
        """
        try:
            data = yaml.safe_load(yaml_content)
            if not isinstance(data, dict):
                raise ValueError("Invalid YAML content: not a dictionary")

            return ExtendedMetadata.from_dict(data)
        except yaml.YAMLError as e:
            logger.error(f"YAML parsing error: {e}")
            raise ValueError(f"Invalid YAML content: {e}")
        except Exception as e:
            logger.error(f"Failed to deserialize metadata: {e}")
            raise

    def get_metadata_file_path(self, script_path: Path) -> Path:
        """
        Get the metadata file path for a given script.

        Args:
            script_path: Path to the script file

        Returns:
            Path to the corresponding metadata file
        """
        script_dir = script_path.parent
        metadata_dir = script_dir / ".metadata"
        metadata_file = metadata_dir / f"{script_path.name}.yaml"
        return metadata_file

    def save_metadata(self, script_path: Path, metadata: ExtendedMetadata) -> Path:
        """
        Save metadata to YAML file.

        Args:
            script_path: Path to the script file
            metadata: ExtendedMetadata to save

        Returns:
            Path to the saved metadata file
        """
        metadata_file = self.get_metadata_file_path(script_path)

        try:
            # Create metadata directory if it doesn't exist
            metadata_file.parent.mkdir(parents=True, exist_ok=True)

            # Serialize and save
            yaml_content = self.serialize_metadata(metadata)
            metadata_file.write_text(yaml_content, encoding="utf-8")

            logger.info(f"Saved metadata for {script_path.name} to {metadata_file}")
            return metadata_file

        except Exception as e:
            logger.error(f"Failed to save metadata for {script_path}: {e}")
            raise

    def load_metadata(self, script_path: Path) -> Optional[ExtendedMetadata]:
        """
        Load metadata from YAML file.

        Args:
            script_path: Path to the script file

        Returns:
            ExtendedMetadata instance or None if file doesn't exist

        Raises:
            ValueError: If metadata file exists but is invalid
        """
        metadata_file = self.get_metadata_file_path(script_path)

        if not metadata_file.exists():
            logger.debug(f"No metadata file found for {script_path.name}")
            return None

        try:
            yaml_content = metadata_file.read_text(encoding="utf-8")
            metadata = self.deserialize_metadata(yaml_content)
            logger.debug(f"Loaded metadata for {script_path.name}")
            return metadata

        except Exception as e:
            logger.error(f"Failed to load metadata for {script_path}: {e}")
            raise

    def create_default_metadata_file(
        self, script_path: Path, similarity_group: str = "script_automation"
    ) -> Path:
        """
        Create a default metadata file for a script.

        Args:
            script_path: Path to the script file
            similarity_group: Priority Matrix Bot similarity group

        Returns:
            Path to the created metadata file
        """
        metadata = create_default_metadata(script_path.name, similarity_group)
        return self.save_metadata(script_path, metadata)

    def validate_metadata_file(self, metadata_file: Path) -> bool:
        """
        Validate a metadata file.

        Args:
            metadata_file: Path to the metadata file

        Returns:
            True if valid, False otherwise
        """
        try:
            if not metadata_file.exists():
                return False

            yaml_content = metadata_file.read_text(encoding="utf-8")
            self.deserialize_metadata(yaml_content)
            return True

        except Exception as e:
            logger.warning(f"Invalid metadata file {metadata_file}: {e}")
            return False

    def find_all_metadata_files(
        self, search_directory: Optional[Path] = None
    ) -> List[Path]:
        """
        Find all metadata files in a directory tree.

        Args:
            search_directory: Directory to search. If None, uses base_directory.

        Returns:
            List of metadata file paths
        """
        if search_directory is None:
            search_directory = self.base_directory

        metadata_files = []
        for metadata_dir in search_directory.rglob(".metadata"):
            if metadata_dir.is_dir():
                metadata_files.extend(metadata_dir.glob("*.yaml"))

        return sorted(metadata_files)

    def validate_all_metadata(
        self, search_directory: Optional[Path] = None
    ) -> Dict[str, bool]:
        """
        Validate all metadata files in a directory tree.

        Args:
            search_directory: Directory to search. If None, uses base_directory.

        Returns:
            Dictionary mapping metadata file paths to validation results
        """
        metadata_files = self.find_all_metadata_files(search_directory)
        results = {}

        for metadata_file in metadata_files:
            results[str(metadata_file)] = self.validate_metadata_file(metadata_file)

        return results

    def generate_metadata_report(
        self, search_directory: Optional[Path] = None
    ) -> Dict[str, Any]:
        """
        Generate a comprehensive metadata report.

        Args:
            search_directory: Directory to search. If None, uses base_directory.

        Returns:
            Dictionary containing metadata statistics and validation results
        """
        metadata_files = self.find_all_metadata_files(search_directory)
        validation_results = self.validate_all_metadata(search_directory)

        # Count by governance level
        governance_levels = {}
        compliance_tags = {}
        similarity_groups = {}

        valid_files = 0
        for file_path, is_valid in validation_results.items():
            if is_valid:
                valid_files += 1
                try:
                    yaml_content = Path(file_path).read_text(encoding="utf-8")
                    metadata = self.deserialize_metadata(yaml_content)

                    # Count governance levels
                    gov_level = metadata.governance.level.value
                    governance_levels[gov_level] = (
                        governance_levels.get(gov_level, 0) + 1
                    )

                    # Count compliance tags
                    for tag in metadata.governance.compliance_tags:
                        tag_value = tag.value
                        compliance_tags[tag_value] = (
                            compliance_tags.get(tag_value, 0) + 1
                        )

                    # Count similarity groups
                    sim_group = metadata.similarity_group
                    similarity_groups[sim_group] = (
                        similarity_groups.get(sim_group, 0) + 1
                    )

                except Exception as e:
                    logger.warning(f"Error processing {file_path}: {e}")

        return {
            "total_metadata_files": len(metadata_files),
            "valid_metadata_files": valid_files,
            "invalid_metadata_files": len(metadata_files) - valid_files,
            "governance_levels": governance_levels,
            "compliance_tags": compliance_tags,
            "similarity_groups": similarity_groups,
            "validation_results": validation_results,
        }


# Convenience functions for common operations
def save_script_metadata(script_path: Path, metadata: ExtendedMetadata) -> Path:
    """
    Convenience function to save metadata for a script.

    Args:
        script_path: Path to the script file
        metadata: ExtendedMetadata to save

    Returns:
        Path to the saved metadata file
    """
    manager = ExtendedMetadataYAMLManager()
    return manager.save_metadata(script_path, metadata)


def load_script_metadata(script_path: Path) -> Optional[ExtendedMetadata]:
    """
    Convenience function to load metadata for a script.

    Args:
        script_path: Path to the script file

    Returns:
        ExtendedMetadata instance or None if not found
    """
    manager = ExtendedMetadataYAMLManager()
    return manager.load_metadata(script_path)


def create_default_script_metadata(
    script_path: Path, similarity_group: str = "script_automation"
) -> Path:
    """
    Convenience function to create default metadata for a script.

    Args:
        script_path: Path to the script file
        similarity_group: Priority Matrix Bot similarity group

    Returns:
        Path to the created metadata file
    """
    manager = ExtendedMetadataYAMLManager()
    return manager.create_default_metadata_file(script_path, similarity_group)
