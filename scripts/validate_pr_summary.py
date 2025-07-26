#!/usr/bin/env python3
"""Validate PR_SUMMARY.md structure and content.

This script ensures that PR summaries follow the required template
and contain all necessary sections for proper documentation.
"""

import argparse
import re
import sys
from pathlib import Path
from typing import List, Tuple


def validate_pr_summary(file_path: Path) -> Tuple[bool, List[str]]:
    """Validate PR_SUMMARY.md structure and content.

    Parameters
    ----------
    file_path : Path
        Path to the PR_SUMMARY.md file

    Returns
    -------
    Tuple[bool, List[str]]
        (is_valid, list_of_errors)
    """
    errors = []

    if not file_path.exists():
        errors.append("PR_SUMMARY.md file not found")
        return False, errors

    try:
        content = file_path.read_text(encoding='utf-8')
    except Exception as e:
        errors.append(f"Failed to read PR_SUMMARY.md: {e}")
        return False, errors

    # Required sections
    required_sections = [
        "## Overview",
        "## Changes Made",
        "## Testing Strategy",
        "## Risk Assessment",
        "## Dependencies",
        "## Post-Merge Actions",
        "## Agent Notes"
    ]

    # Check for required sections
    for section in required_sections:
        if section not in content:
            errors.append(f"Missing required section: {section}")

    # Check for placeholder content that should be filled
    placeholders = [
        "[increase/decrease/no change]",
        "[yes/no - describe]",
        "[describe]",
        "[list any]",
        "[yes/no]"
    ]

    # Count how many placeholders are still present
    placeholder_count = 0
    for placeholder in placeholders:
        placeholder_count += content.count(placeholder)

    # Allow some placeholders if not all sections apply, but warn if too many
    if placeholder_count > 5:
        errors.append(
            f"Too many template placeholders remain ({placeholder_count}). "
            "Please fill in the relevant sections."
        )

    # Check for empty sections (header followed immediately by another section)
    section_pattern = r"## \w+[^\n]*\n\n(?=## \w+)"
    empty_sections = re.findall(section_pattern, content)
    if empty_sections:
        errors.append(
            "Some sections appear to be empty. "
            "Please provide content for all applicable sections."
        )

    # Check minimum content length (excluding template)
    content_lines = [
        line.strip() for line in content.split('\n')
        if line.strip() and not line.startswith('#')
    ]
    if len(content_lines) < 10:
        errors.append(
            "PR summary appears too brief. "
            "Please provide more detailed information."
        )

    return len(errors) == 0, errors


def main() -> int:
    """Main function for PR summary validation.

    Returns
    -------
    int
        Exit code (0 for success, 1 for failure)
    """
    parser = argparse.ArgumentParser(
        description="Validate PR_SUMMARY.md structure"
    )
    parser.add_argument("file", help="Path to PR_SUMMARY.md file")
    parser.add_argument(
        "--strict", action="store_true",
        help="Strict mode - fail on warnings"
    )

    args = parser.parse_args()

    file_path = Path(args.file)
    _, errors = validate_pr_summary(file_path)

    if errors:
        print("❌ PR Summary Validation Failed:")
        for error in errors:
            print(f"  • {error}")
        print("\n💡 Use the template: .github/PR_SUMMARY_TEMPLATE.md")
        return 1

    print("✅ PR Summary validation passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
