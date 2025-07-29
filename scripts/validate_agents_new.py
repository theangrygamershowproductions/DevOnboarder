#!/usr/bin/env python3
"""Agent validation script for Codex agents using Python."""

import json
import sys
import yaml
from pathlib import Path
from typing import Dict, Any
from jsonschema import validate, ValidationError


def load_schema(schema_path: Path) -> Dict[str, Any]:
    """Load the JSON schema."""
    with open(schema_path) as f:
        return json.load(f)


def extract_frontmatter(agent_file: Path) -> Dict[str, Any] | None:
    """Extract YAML frontmatter from an agent file."""
    content = agent_file.read_text()
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
    print(f"   Found {len(agent_files)} agent files")

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
            continue

        # Validate against schema
        try:
            validate(instance=frontmatter, schema=schema)
            print(f"✅ {agent_name}: Valid")
        except ValidationError as e:
            print(f"❌ {agent_name}: Schema validation failed")
            print(f"   Error: {e.message}")
            if e.path:
                print(f"   Path: {' -> '.join(str(p) for p in e.path)}")
            validation_errors += 1
        except Exception as e:
            print(f"❌ {agent_name}: Validation error: {e}")
            validation_errors += 1

    print()
    print("📊 Agent Validation Summary:")
    print(f"   Total files: {total_files}")
    print(f"   Validation errors: {validation_errors}")

    if validation_errors == 0:
        print("🎉 All agent files are valid!")
        sys.exit(0)
    else:
        print(f"💥 {validation_errors} agent file(s) failed validation")
        sys.exit(1)


if __name__ == "__main__":
    main()
