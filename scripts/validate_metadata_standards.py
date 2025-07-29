#!/usr/bin/env python3
"""Metadata standards validation for DevOnboarder documentation."""

import sys
import yaml
from pathlib import Path
from typing import Dict, Any, List


def extract_frontmatter(file_path: Path) -> Dict[str, Any] | None:
    """Extract YAML frontmatter from a documentation file.

    Parameters
    ----------
    file_path : Path
        Path to the file to extract frontmatter from

    Returns
    -------
    dict or None
        Parsed YAML frontmatter, empty dict if no frontmatter,
        None if parsing failed
    """
    try:
        content = file_path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        print(f"   ❌ Cannot read file (encoding issue): {file_path}")
        return None
    except FileNotFoundError:
        print(f"   ❌ File not found: {file_path}")
        return None

    lines = content.split("\n")

    if not lines or lines[0].strip() != "---":
        return {}

    # Find the closing ---
    end_idx = None
    for i, line in enumerate(lines[1:], 1):
        if line.strip() == "---":
            end_idx = i
            break

    if end_idx is None:
        return {}

    # Extract YAML content
    yaml_content = "\n".join(lines[1:end_idx])

    try:
        return yaml.safe_load(yaml_content) or {}
    except yaml.YAMLError as e:
        print(f"   ❌ YAML parsing error in {file_path}: {e}")
        return None


def validate_core_metadata(frontmatter: Dict[str, Any], file_path: Path) -> List[str]:
    """Validate core metadata requirements.

    Parameters
    ----------
    frontmatter : dict
        The YAML frontmatter from the file
    file_path : Path
        Path to the file being validated

    Returns
    -------
    list
        List of validation error messages
    """
    errors = []

    # Required core fields for all documentation
    required_fields = {"title", "description"}
    for field in required_fields:
        if field not in frontmatter:
            errors.append(f"Missing required field: {field}")

    # Validate field types
    field_types = {
        "title": str,
        "description": str,
        "tags": list,
        "author": str,
        "created_at": str,
        "updated_at": str,
        "version": str,
        "status": str,
        "visibility": str,
        "priority": str,
        "project": str,
        "document_type": str,
        "virtual_env_required": bool,
        "ci_integration": bool,
        "integration_status": str,
    }

    for field, expected_type in field_types.items():
        if field in frontmatter:
            value = frontmatter[field]
            if not isinstance(value, expected_type):
                errors.append(
                    f"Field '{field}' should be {expected_type.__name__}, "
                    f"got {type(value).__name__}"
                )

    # Validate controlled vocabulary fields
    if "status" in frontmatter:
        valid_statuses = {
            "draft",
            "review",
            "approved",
            "published",
            "archived",
            "deprecated",
        }
        status = frontmatter["status"]
        if status not in valid_statuses:
            errors.append(
                f"status '{status}' not in valid values: "
                f"{', '.join(sorted(valid_statuses))}"
            )

    if "visibility" in frontmatter:
        valid_visibility = {"public", "internal", "restricted", "private"}
        visibility = frontmatter["visibility"]
        if visibility not in valid_visibility:
            errors.append(
                f"visibility '{visibility}' not in valid values: "
                f"{', '.join(sorted(valid_visibility))}"
            )

    if "priority" in frontmatter:
        valid_priorities = {"low", "medium", "high", "critical"}
        priority = frontmatter["priority"]
        if priority not in valid_priorities:
            errors.append(
                f"priority '{priority}' not in valid values: "
                f"{', '.join(sorted(valid_priorities))}"
            )

    if "document_type" in frontmatter:
        valid_types = {
            "agent",
            "status",
            "configuration",
            "template",
            "case_study",
            "documentation",
            "guide",
            "reference",
        }
        doc_type = frontmatter["document_type"]
        if doc_type not in valid_types:
            errors.append(
                f"document_type '{doc_type}' not in valid values: "
                f"{', '.join(sorted(valid_types))}"
            )

    if "integration_status" in frontmatter:
        valid_integration = {
            "production",
            "staging",
            "development",
            "draft",
            "pending_authentication",
            "disabled",
        }
        integration = frontmatter["integration_status"]
        if integration not in valid_integration:
            errors.append(
                f"integration_status '{integration}' not in valid values: "
                f"{', '.join(sorted(valid_integration))}"
            )

    return errors


def validate_devonboarder_requirements(
    frontmatter: Dict[str, Any], file_path: Path
) -> List[str]:
    """Validate DevOnboarder-specific requirements.

    Parameters
    ----------
    frontmatter : dict
        The YAML frontmatter from the file
    file_path : Path
        Path to the file being validated

    Returns
    -------
    list
        List of validation error messages
    """
    errors = []

    # DevOnboarder project files require specific fields
    if "project" in frontmatter and frontmatter["project"] == "DevOnboarder":
        required_devonboarder_fields = ["virtual_env_required", "ci_integration"]
        for field in required_devonboarder_fields:
            if field not in frontmatter:
                errors.append(f"DevOnboarder project requires '{field}' field")

    # Agent files require additional fields
    if (
        file_path.parts
        and "agents" in file_path.parts
        or "document_type" in frontmatter
        and frontmatter["document_type"] == "agent"
    ):
        agent_fields = ["integration_status", "virtual_env_required"]
        for field in agent_fields:
            if field not in frontmatter:
                errors.append(f"Agent files require '{field}' field")

    # Files in docs/ directory should have certain metadata
    if file_path.parts and "docs" in file_path.parts:
        docs_fields = ["document_type", "status"]
        for field in docs_fields:
            if field not in frontmatter:
                errors.append(f"Documentation files require '{field}' field")

    return errors


def main():
    """Main validation function."""
    print("🔍 Starting Core Metadata Standards Validation...")

    script_dir = Path(__file__).parent
    project_root = script_dir.parent

    validation_errors = 0
    total_files = 0
    devonboarder_files = 0
    agent_files = 0

    # Find all documentation files to validate
    file_patterns = [
        project_root.glob("docs/**/*.md"),
        project_root.glob("agents/**/*.md"),
        project_root.glob(".codex/**/*.md"),
        project_root.glob("codex/**/*.md"),
    ]

    all_files = []
    for pattern in file_patterns:
        all_files.extend(pattern)

    # Remove duplicates and sort
    all_files = sorted(set(all_files))

    for file_path in all_files:
        if not file_path.is_file():
            continue

        total_files += 1
        file_name = file_path.name

        # Extract frontmatter
        frontmatter = extract_frontmatter(file_path)

        if frontmatter is None:
            print(f"❌ {file_name}: Failed to parse YAML frontmatter")
            validation_errors += 1
            continue

        if not frontmatter:
            print(f"⚠️  {file_name}: No frontmatter found")
            print(f"   File: {file_path}")
            continue

        # Track file types
        if "project" in frontmatter and frontmatter["project"] == "DevOnboarder":
            devonboarder_files += 1
        if "agents" in file_path.parts or (
            "document_type" in frontmatter and frontmatter["document_type"] == "agent"
        ):
            agent_files += 1

        # Core metadata validation
        core_errors = validate_core_metadata(frontmatter, file_path)
        devonboarder_errors = validate_devonboarder_requirements(frontmatter, file_path)

        all_errors = core_errors + devonboarder_errors

        if all_errors:
            print(f"❌ {file_name}: Metadata validation failed")
            print(f"   File: {file_path}")
            for error in all_errors:
                print(f"   • {error}")
            validation_errors += 1
        else:
            print(f"✅ {file_name}: Valid metadata")

    print()
    print("📊 Metadata Validation Summary:")
    print(f"   Total files validated: {total_files}")
    print(f"   DevOnboarder project files: {devonboarder_files}")
    print(f"   Agent files: {agent_files}")
    print(f"   Validation errors: {validation_errors}")
    print("   Standards checked:")
    print("   • Core metadata requirements")
    print("   • DevOnboarder project standards")
    print("   • Agent-specific requirements")
    print("   • Documentation type validation")

    if validation_errors == 0:
        print("🎉 All files meet metadata standards!")
        print("   ✅ Core metadata fields present")
        print("   ✅ DevOnboarder requirements met")
        print("   ✅ Agent standards compliant")
        sys.exit(0)
    else:
        print(f"💥 {validation_errors} file(s) failed metadata validation")
        print("   Review frontmatter requirements in:")
        print("   • docs/core-metadata-standards.md")
        print("   • .github/copilot-instructions.md")
        sys.exit(1)


if __name__ == "__main__":
    main()
