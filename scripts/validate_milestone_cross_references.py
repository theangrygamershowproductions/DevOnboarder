#!/usr/bin/env python3
"""
Milestone Cross-Reference Validator

Validates milestone cross-references and dependencies across the entire project.
Ensures milestone_id uniqueness and validates cross-references between files.

Usage:
    python scripts/validate_milestone_cross_references.py
    python scripts/validate_milestone_cross_references.py --fix-duplicates
"""

import argparse
import re
import sys
from pathlib import Path
from typing import Dict, List
import yaml


class MilestoneCrossReferenceValidator:
    """Validates milestone cross-references and dependencies."""

    def __init__(self):
        self.milestone_ids: Dict[str, List[Path]] = {}
        self.errors: List[str] = []
        self.warnings: List[str] = []

    def find_milestone_files(self, search_paths: List[str]) -> List[Path]:
        """Find all milestone files in the specified paths."""
        milestone_files = []

        for search_path in search_paths:
            path = Path(search_path)
            if path.is_file() and path.suffix == ".md":
                milestone_files.append(path)
            elif path.is_dir():
                milestone_files.extend(path.rglob("*.md"))

        return milestone_files

    def extract_milestone_id(self, file_path: Path) -> str:
        """Extract milestone_id from a file's YAML frontmatter."""
        try:
            content = file_path.read_text(encoding="utf-8")
        except Exception as e:
            self.errors.append(f"Cannot read {file_path}: {e}")
            return None

        # Look for YAML frontmatter
        if not content.startswith("---\n"):
            return None

        yaml_end = content.find("\n---\n", 4)
        if yaml_end == -1:
            return None

        yaml_content = content[4:yaml_end]

        try:
            yaml_data = yaml.safe_load(yaml_content)
            return yaml_data.get("milestone_id")
        except yaml.YAMLError:
            return None

    def find_milestone_references(self, content: str) -> List[str]:
        """Find milestone_id references in content."""
        # Look for milestone_id patterns in text (more specific patterns)
        patterns = [
            # YAML format with date pattern
            r'milestone_id[:\s]*["\']([0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+)["\']',
            # Unquoted format with date pattern
            r"milestone_id[:\s]*([0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+)(?:\s|$)",
            # Markdown reference format
            r"\[milestone:\s*([0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+)\]",
        ]

        references = []
        for pattern in patterns:
            matches = re.findall(pattern, content, re.IGNORECASE)
            references.extend(matches)

        return list(set(references))  # Remove duplicates

    def validate_cross_references(self, search_paths: List[str]) -> bool:
        """Validate milestone cross-references across all files."""
        print("🔍 Milestone Cross-Reference Validation")
        print("=" * 50)

        # Find all milestone files
        milestone_files = self.find_milestone_files(search_paths)
        print(f"Found {len(milestone_files)} milestone files")

        # Extract milestone_ids and track duplicates
        valid_milestone_ids = set()

        for file_path in milestone_files:
            milestone_id = self.extract_milestone_id(file_path)

            if milestone_id:
                if milestone_id in self.milestone_ids:
                    self.milestone_ids[milestone_id].append(file_path)
                else:
                    self.milestone_ids[milestone_id] = [file_path]

                valid_milestone_ids.add(milestone_id)

        # Check for duplicate milestone_ids
        for milestone_id, files in self.milestone_ids.items():
            if len(files) > 1:
                self.errors.append(
                    f"Duplicate milestone_id '{milestone_id}' found in: "
                    f"{', '.join(str(f) for f in files)}"
                )

        print(f"Found {len(valid_milestone_ids)} unique milestone IDs")

        # Validate cross-references in all markdown files
        all_md_files = []
        for search_path in search_paths:
            path = Path(search_path)
            if path.is_dir():
                all_md_files.extend(path.rglob("*.md"))

        # Add additional common locations
        for location in ["MILESTONE_LOG.md", "docs/", "README.md"]:
            path = Path(location)
            if path.exists():
                if path.is_file():
                    all_md_files.append(path)
                else:
                    all_md_files.extend(path.rglob("*.md"))

        broken_references = []
        for file_path in all_md_files:
            try:
                content = file_path.read_text(encoding="utf-8")
                references = self.find_milestone_references(content)

                for ref in references:
                    if ref not in valid_milestone_ids:
                        broken_references.append((file_path, ref))

            except Exception as e:
                self.warnings.append(f"Cannot read {file_path}: {e}")

        if broken_references:
            for file_path, ref in broken_references:
                self.errors.append(f"Broken milestone reference '{ref}' in {file_path}")

        return len(self.errors) == 0

    def fix_duplicates(self, dry_run: bool = True) -> bool:
        """Fix duplicate milestone_ids by making them unique."""
        if not dry_run:
            print("🔧 Fixing duplicate milestone_ids...")
        else:
            print("🔍 Dry run - would fix duplicate milestone_ids:")

        fixes_applied = 0

        for milestone_id, files in self.milestone_ids.items():
            if len(files) > 1:
                # Keep the first file unchanged, modify others
                for i, file_path in enumerate(files[1:], 2):
                    new_id = f"{milestone_id}-{i}"

                    if dry_run:
                        print(
                            f"  Would rename '{milestone_id}' to '{new_id}' "
                            f"in {file_path}"
                        )
                    else:
                        try:
                            content = file_path.read_text(encoding="utf-8")
                            # Replace milestone_id in YAML frontmatter
                            pattern = (
                                rf'(milestone_id:\s*["\']?)'
                                rf'{re.escape(milestone_id)}(["\']?)'
                            )
                            updated_content = re.sub(pattern, rf"\1{new_id}\2", content)

                            if content != updated_content:
                                file_path.write_text(updated_content, encoding="utf-8")
                                print(
                                    f"  Updated {file_path}: {milestone_id} -> {new_id}"
                                )  # noqa: E501
                                fixes_applied += 1

                        except Exception as e:
                            self.errors.append(f"Failed to fix {file_path}: {e}")

        return fixes_applied > 0

    def print_results(self):
        """Print validation results."""
        if self.errors:
            print(f"\n❌ ERRORS ({len(self.errors)}):")
            for error in self.errors:
                print(f"  • {error}")

        if self.warnings:
            print(f"\n⚠️  WARNINGS ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"  • {warning}")

        print(f"\n{'='*50}")
        print("CROSS-REFERENCE VALIDATION SUMMARY")
        print(f"{'='*50}")
        print(f"Total milestone IDs: {len(self.milestone_ids)}")
        print(
            f"Unique milestone IDs: {len([ids for ids in self.milestone_ids.values() if len(ids) == 1])}"  # noqa: E501
        )
        print(
            f"Duplicate milestone IDs: {len([ids for ids in self.milestone_ids.values() if len(ids) > 1])}"  # noqa: E501
        )
        print(f"Errors: {len(self.errors)}")
        print(f"Warnings: {len(self.warnings)}")

        if len(self.errors) == 0:
            print("\n🎉 All milestone cross-references are valid!")
            return True
        else:
            print(f"\n💥 {len(self.errors)} cross-reference issues found")
            return False


def main():
    """Main function."""
    parser = argparse.ArgumentParser(
        description="Validate milestone cross-references and dependencies"
    )
    parser.add_argument(
        "paths",
        nargs="*",
        default=["milestones/", "MILESTONE_LOG.md", "docs/"],
        help="Paths to search for milestone files (default: milestones/, MILESTONE_LOG.md, docs/)",  # noqa: E501
    )
    parser.add_argument(
        "--fix-duplicates",
        action="store_true",
        help="Fix duplicate milestone_ids by making them unique",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be fixed without making changes",
    )

    args = parser.parse_args()

    validator = MilestoneCrossReferenceValidator()

    # Validate cross-references
    success = validator.validate_cross_references(args.paths)

    # Fix duplicates if requested
    if args.fix_duplicates:
        validator.fix_duplicates(dry_run=args.dry_run)

    # Print results
    success = validator.print_results()

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
