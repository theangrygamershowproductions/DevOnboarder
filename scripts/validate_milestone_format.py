#!/usr/bin/env python3
"""
Milestone Documentation Format Validator

Validates milestone documentation against the standard format defined in
docs/standards/milestone-documentation-format.md

Usage:
    python scripts/validate_milestone_format.py [file_or_directory]
    python scripts/validate_milestone_format.py milestones/
    python scripts/validate_milestone_format.py milestones/2025-09/specific-milestone.md
"""

import argparse
import re
import sys
from pathlib import Path
from typing import List, Dict, Any
import yaml


class MilestoneFormatValidator:
    """Validates milestone documentation format compliance."""

    REQUIRED_YAML_FIELDS = {
        "milestone_id": str,
        "date": str,
        "type": str,
        "priority": str,
        "complexity": str,
        "generated_by": str,
    }

    VALID_TYPES = {"enhancement", "feature", "bugfix", "infrastructure", "process"}
    VALID_PRIORITIES = {"critical", "high", "medium", "low"}
    VALID_COMPLEXITIES = {"simple", "moderate", "complex", "very-complex"}

    MILESTONE_ID_PATTERN = re.compile(r"^\d{4}-\d{2}-\d{2}-[a-z0-9-]$")
    DATE_PATTERN = re.compile(r"^\d{4}-\d{2}-\d{2}$")
    GITHUB_LINK_PATTERN = re.compile(
        r"https://github\.com/theangrygamershowproductions/DevOnboarder/"
        r"(pull|issues|commit|actions/runs)/\d"
    )

    def __init__(self):
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.milestone_ids: set = set()

    def validate_file(self, file_path: Path) -> bool:
        """Validate a single milestone file."""
        self.errors.clear()
        self.warnings.clear()

        if not file_path.exists():
            self.errors.append(f"File does not exist: {file_path}")
            return False

        try:
            content = file_path.read_text(encoding="utf-8")
        except Exception as e:
            self.errors.append(f"Cannot read file {file_path}: {e}")
            return False

        # Validate file naming
        self._validate_filename(file_path)

        # Parse YAML front matter
        yaml_data = self._extract_yaml_frontmatter(content)
        if yaml_data is None:
            self.errors.append("Missing or invalid YAML front matter")
            return False

        # Validate YAML fields
        self._validate_yaml_fields(yaml_data)

        # Validate content structure
        self._validate_content_structure(content)

        # Validate Evidence Anchors
        self._validate_evidence_anchors(content)

        return len(self.errors) == 0

    def _validate_filename(self, file_path: Path):
        """Validate filename follows convention."""
        filename = file_path.name
        expected_pattern = re.compile(
            r"^\d{4}-\d{2}-\d{2}-(enhancement|feature|bugfix|infrastructure|process)"
            r"-[a-z0-9-]\.md$"
        )

        if not expected_pattern.match(filename):
            self.errors.append(
                f"Filename '{filename}' doesn't match pattern: " + "YYYY-MM-DD-type-brief-descriptive-name.md"
            )

    def _extract_yaml_frontmatter(self, content: str) -> Dict[str, Any]:
        """Extract and parse YAML front matter."""
        if not content.startswith("---\n"):
            return None

        # Find the end of YAML front matter
        yaml_end = content.find("\n---\n", 4)
        if yaml_end == -1:
            return None

        yaml_content = content[4:yaml_end]

        try:
            return yaml.safe_load(yaml_content)
        except yaml.YAMLError as e:
            self.errors.append(f"Invalid YAML front matter: {e}")
            return None

    def _validate_yaml_fields(self, yaml_data: Dict[str, Any]):
        """Validate required YAML fields."""
        # Check required fields
        for field, expected_type in self.REQUIRED_YAML_FIELDS.items():
            if field not in yaml_data:
                self.errors.append(f"Missing required YAML field: {field}")
                continue

            value = yaml_data[field]
            if not isinstance(value, expected_type):
                self.errors.append(
                    f"YAML field '{field}' must be {expected_type.__name__}, "
                    f"got {type(value).__name__}"
                )
                continue

        # Validate specific field formats
        if "milestone_id" in yaml_data:
            milestone_id = yaml_data["milestone_id"]
            if not self.MILESTONE_ID_PATTERN.match(milestone_id):
                self.errors.append(
                    f"milestone_id '{milestone_id}' doesn't match format: " + "YYYY-MM-DD-brief-descriptive-name"
                )

            # Check for uniqueness
            if milestone_id in self.milestone_ids:
                self.errors.append(f"Duplicate milestone_id: {milestone_id}")
            else:
                self.milestone_ids.add(milestone_id)

        if "date" in yaml_data:
            date = yaml_data["date"]
            if not self.DATE_PATTERN.match(date):
                self.errors.append(f"date '{date}' doesn't match format: YYYY-MM-DD")

        if "type" in yaml_data:
            type_val = yaml_data["type"]
            if type_val not in self.VALID_TYPES:
                self.errors.append(
                    f"type '{type_val}' must be one of: {', '.join(self.VALID_TYPES)}"
                )

        if "priority" in yaml_data:
            priority = yaml_data["priority"]
            if priority not in self.VALID_PRIORITIES:
                self.errors.append(
                    f"priority '{priority}' must be one of: "
                    f"{', '.join(self.VALID_PRIORITIES)}"
                )

        if "complexity" in yaml_data:
            complexity = yaml_data["complexity"]
            if complexity not in self.VALID_COMPLEXITIES:
                self.errors.append(
                    f"complexity '{complexity}' must be one of: "
                    f"{', '.join(self.VALID_COMPLEXITIES)}"
                )

    def _validate_content_structure(self, content: str):
        """Validate required content sections."""
        required_sections = [
            r"# . - .",  # Title with description
            r"## .*Overview",  # Some kind of overview section
            r"## Evidence Anchors",  # Evidence Anchors section
        ]

        for pattern in required_sections:
            if not re.search(pattern, content, re.MULTILINE):
                self.errors.append(
                    f"Missing required section matching pattern: {pattern}"
                )

    def _validate_evidence_anchors(self, content: str):
        """Validate Evidence Anchors section has GitHub links."""
        evidence_section_match = re.search(
            r"## Evidence Anchors\n(.*?)(?=\n## |\n---|\Z)", content, re.DOTALL
        )

        if not evidence_section_match:
            return  # Already reported as missing section

        evidence_content = evidence_section_match.group(1)
        github_links = self.GITHUB_LINK_PATTERN.findall(evidence_content)

        if not github_links:
            self.errors.append(
                "Evidence Anchors section must contain at least one direct GitHub link"
            )

    def validate_directory(self, directory: Path) -> Dict[Path, bool]:
        """Validate all milestone files in a directory."""
        results = {}

        # Find all .md files recursively
        for md_file in directory.rglob("*.md"):
            # Skip template files and other non-milestone docs
            if "template" in str(md_file).lower() or "README" in md_file.name:
                continue

            results[md_file] = self.validate_file(md_file)

        return results

    def print_results(self, file_path: Path):
        """Print validation results for a file."""
        print(f"\n{'='*60}")
        print(f"Validating: {file_path}")
        print(f"{'='*60}")

        if self.errors:
            print(f"\n ERRORS ({len(self.errors)}):")
            for error in self.errors:
                print(f"  • {error}")

        if self.warnings:
            print(f"\n + WARNINGS ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"  • {warning}")

        if not self.errors and not self.warnings:
            print("\n File passes all validation checks!")

        return len(self.errors) == 0


def main():
    parser = argparse.ArgumentParser(
        description="Validate milestone documentation format"
    )
    parser.add_argument(
        "path",
        nargs="?",
        default="milestones/",
        help="File or directory to validate (default: milestones/)",
    )
    parser.add_argument(
        "--summary",
        action="store_true",
        help="Show only summary, not individual file details",
    )

    args = parser.parse_args()

    validator = MilestoneFormatValidator()
    path = Path(args.path)

    if not path.exists():
        print(f" Path does not exist: {path}")
        sys.exit(1)

    if path.is_file():
        success = validator.validate_file(path)
        if not args.summary:
            validator.print_results(path)
        print(
            f"\n{'' if success else ''} Validation "
            f"{'PASSED' if success else 'FAILED'}"
        )
        sys.exit(0 if success else 1)

    # Validate directory
    results = validator.validate_directory(path)

    if not results:
        print(f"No milestone files found in {path}")
        sys.exit(0)

    # Print individual results if not summary mode
    if not args.summary:
        for file_path, success in results.items():
            validator.validate_file(file_path)  # Re-run to get current errors
            validator.print_results(file_path)

    # Print summary
    total_files = len(results)
    passed_files = sum(1 for success in results.values() if success)
    failed_files = total_files - passed_files

    print(f"\n{'='*60}")
    print("VALIDATION SUMMARY")
    print(f"{'='*60}")
    print(f"Total files:  {total_files}")
    print(f" Passed:    {passed_files}")
    print(f" Failed:    {failed_files}")

    if failed_files == 0:
        print("\n🎉 All milestone files pass validation!")
        sys.exit(0)
    else:
        print(f"\n💥 {failed_files} files failed validation")
        sys.exit(1)


if __name__ == "__main__":
    main()
