#!/usr/bin/env python3
"""Agent validation script for Codex agents with DevOnboarder integration."""

import json
import sys
import yaml
from pathlib import Path
from typing import Dict, Any, List
from jsonschema import validate, ValidationError


def validate_devonboarder_metadata(
    frontmatter: Dict[str, Any], agent_name: str
) -> List[str]:
    """Validate DevOnboarder-specific metadata requirements.

    Parameters
    ----------
    frontmatter : dict
        The YAML frontmatter from the agent file
    agent_name : str
        Name of the agent being validated

    Returns
    -------
    list
        List of validation error messages
    """
    errors = []

    # Check for DevOnboarder-specific fields
    devonboarder_fields = {
        "virtual_env_required": bool,
        "integration_status": str,
        "ci_integration": bool,
        "project": str,
    }

    for field, expected_type in devonboarder_fields.items():
        if field in frontmatter:
            value = frontmatter[field]
            if not isinstance(value, expected_type):
                errors.append(
                    f"Field '{field}' should be {expected_type.__name__}, "
                    f"got {type(value).__name__}"
                )

    # Validate integration_status values
    if "integration_status" in frontmatter:
        valid_statuses = {
            "production",
            "staging",
            "development",
            "draft",
            "pending_authentication",
            "disabled",
        }
        status = frontmatter["integration_status"]
        if status not in valid_statuses:
            errors.append(
                f"integration_status '{status}' not in valid values: "
                f"{', '.join(sorted(valid_statuses))}"
            )

    # Check project field for DevOnboarder agents
    if "project" in frontmatter and frontmatter["project"] == "DevOnboarder":
        required_fields = ["virtual_env_required", "ci_integration"]
        for field in required_fields:
            if field not in frontmatter:
                errors.append(f"DevOnboarder project requires '{field}' field")

    # Validate document_type for consistency
    if "document_type" in frontmatter:
        valid_types = {
            "agent",
            "status",
            "configuration",
            "template",
            "case_study",
            "documentation",
        }
        doc_type = frontmatter["document_type"]
        if doc_type not in valid_types:
            errors.append(
                f"document_type '{doc_type}' not in valid values: "
                f"{', '.join(sorted(valid_types))}"
            )

    return errors


def load_schema(schema_path: Path) -> Dict[str, Any]:
    """Load the JSON schema."""
    with open(schema_path, encoding="utf-8") as f:
        return json.load(f)


def extract_frontmatter(agent_file: Path) -> Dict[str, Any] | None:
    """Extract YAML frontmatter from an agent file."""
    content = agent_file.read_text(encoding="utf-8")
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
        print(f"   YAML parsing error: {e}")
        return None


def main():
    """Main validation function."""
    print("Starting agent validation...")

    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    schema_file = project_root / "schema" / "agent-schema.json"

    print("🤖 Validating Codex Agent Files...")
    print(f"   Schema file: {schema_file}")

    if not schema_file.exists():
        print(f"❌ Agent schema not found: {schema_file}")
        sys.exit(1)

    try:
        schema = load_schema(schema_file)
    except Exception as e:
        print(f"❌ Failed to load schema: {e}")
        sys.exit(1)

    validation_errors = 0
    total_files = 0

    # Find all agent files
    agent_patterns = [
        project_root.glob("*/.codex/agents/*.md"),
        project_root.glob("*/agents/*.md"),
        project_root.glob("agents/*.md"),
        project_root.glob("codex/agents/*.md"),
    ]

    agent_files = []
    for pattern in agent_patterns:
        agent_files.extend(pattern)

    # Remove duplicates and sort
    agent_files = sorted(set(agent_files))

    for agent_file in agent_files:
        if not agent_file.is_file():
            continue

        total_files += 1
        agent_name = agent_file.stem

        # Extract frontmatter
        frontmatter = extract_frontmatter(agent_file)

        if frontmatter is None:
            print(f"❌ {agent_name}: Failed to parse YAML frontmatter")
            validation_errors += 1
            continue

        if not frontmatter:
            print(f"⚠️  {agent_name}: No frontmatter found")
            print(f"   File: {agent_file}")
            continue

        # Validate against schema
        schema_valid = True
        try:
            validate(instance=frontmatter, schema=schema)
        except ValidationError as e:
            print(f"❌ {agent_name}: Schema validation failed")
            print(f"   File: {agent_file}")
            print(f"   Error: {e.message}")
            if e.path:
                print(f"   Path: {' -> '.join(str(p) for p in e.path)}")
            validation_errors += 1
            schema_valid = False
        except Exception as e:
            print(f"❌ {agent_name}: Validation error: {e}")
            validation_errors += 1
            schema_valid = False

        # DevOnboarder-specific validation
        devonboarder_errors = validate_devonboarder_metadata(frontmatter, agent_name)
        if devonboarder_errors:
            print(f"❌ {agent_name}: DevOnboarder validation failed")
            print(f"   File: {agent_file}")
            for error in devonboarder_errors:
                print(f"   • {error}")
            validation_errors += 1
            schema_valid = False

        if schema_valid and not devonboarder_errors:
            print(f"✅ {agent_name}: Valid")

    print()
    print("📊 Agent Validation Summary:")
    print(f"   Total files: {total_files}")
    print(f"   Validation errors: {validation_errors}")
    print("   Validation includes:")
    print("   • JSON schema compliance")
    print("   • DevOnboarder metadata standards")
    print("   • Integration status validation")
    print("   • Virtual environment requirements")

    if validation_errors == 0:
        print("🎉 All agent files are valid!")
        print("   ✅ Schema validation passed")
        print("   ✅ DevOnboarder standards met")
        sys.exit(0)
    else:
        print(f"💥 {validation_errors} agent file(s) failed validation")
        print("   Check schema compliance and DevOnboarder requirements")
        sys.exit(1)


if __name__ == "__main__":
    main()
