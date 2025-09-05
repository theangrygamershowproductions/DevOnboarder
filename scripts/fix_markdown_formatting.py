#!/usr/bin/env python3
"""
DevOnboarder Markdown Quality Control Tool.

Automatically fixes common markdown formatting issues to ensure compliance
with DevOnboarder's documentation standards and markdownlint rules.

Usage:
    python scripts/fix_markdown_formatting.py <filepath>
    python scripts/fix_markdown_formatting.py docs/ci/document.md

Fixes Applied:
    - MD009: Remove trailing spaces
    - MD022: Ensure blank lines around headings
    - MD032: Ensure blank lines around lists
    - MD031: Ensure blank lines around fenced code blocks
    - Clean up excessive blank lines

Part of DevOnboarder's Quality Control system.
"""

import re
import sys
import os


def validate_file_exists(filepath: str) -> bool:
    """Validate that the file exists and is readable."""
    if not os.path.isfile(filepath):
        print(f"ERROR: File not found: {filepath}")
        return False

    if not filepath.endswith(".md"):
        print(f"WARNING: File is not a markdown file: {filepath}")

    return True


def create_backup(filepath: str) -> str:
    """Create a backup of the original file."""
    backup_path = f"{filepath}.bak"
    try:
        with open(filepath, "r", encoding="utf-8") as original:
            with open(backup_path, "w", encoding="utf-8") as backup:
                backup.write(original.read())
        return backup_path
    except (OSError, IOError) as e:
        print(f"WARNING: Could not create backup: {e}")
        return ""


def fix_markdown_formatting(filepath: str) -> bool:
    """Fix common markdown formatting issues."""
    print(f"Processing: {filepath}")

    # Create backup
    backup_path = create_backup(filepath)
    if backup_path:
        print(f"Backup created: {backup_path}")

    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        original_content = content
        issues_fixed = []

        # Remove trailing spaces (MD009)
        before_spaces = len(re.findall(r" +$", content, flags=re.MULTILINE))
        content = re.sub(r" +$", "", content, flags=re.MULTILINE)
        if before_spaces > 0:
            issues_fixed.append(f"MD009: Fixed {before_spaces} trailing space issues")

        # Fix MD022 - Ensure blank lines around headings
        before_headings = content
        content = re.sub(
            r"(^#{1,6}[^\n]*)\n([^#\n])", r"\1\n\n\2", content, flags=re.MULTILINE
        )
        content = re.sub(
            r"([^\n])\n(^#{1,6}[^\n]*)", r"\1\n\n\2", content, flags=re.MULTILINE
        )
        if content != before_headings:
            issues_fixed.append("MD022: Fixed heading spacing issues")

        # Fix MD032 - Ensure blank lines around lists
        before_lists = content
        content = re.sub(r"([^\n])\n(^- )", r"\1\n\n\2", content, flags=re.MULTILINE)
        content = re.sub(
            r"(^- [^\n]*)\n([^-\n])", r"\1\n\n\2", content, flags=re.MULTILINE
        )
        if content != before_lists:
            issues_fixed.append("MD032: Fixed list spacing issues")

        # Fix MD031 - Ensure blank lines around fenced code blocks
        before_fenced = content
        content = re.sub(r"([^\n])\n(^```)", r"\1\n\n\2", content, flags=re.MULTILINE)
        content = re.sub(r"(^```$)\n([^`\n])", r"\1\n\n\2", content, flags=re.MULTILINE)
        if content != before_fenced:
            issues_fixed.append("MD031: Fixed fenced code block spacing")

        # Clean up excessive blank lines
        before_cleanup = content
        content = re.sub(r"\n{3,}", "\n\n", content)
        if content != before_cleanup:
            issues_fixed.append("Cleaned up excessive blank lines")

        # Write the fixed content
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)

        # Report results
        if issues_fixed:
            print("Issues fixed:")
            for issue in issues_fixed:
                print(f"  - {issue}")
            print(f"SUCCESS: Fixed {len(issues_fixed)} formatting issue types")
        else:
            print("SUCCESS: No formatting issues found")

        # Clean up backup if no changes were made
        if content == original_content and backup_path:
            os.remove(backup_path)
            print("Backup removed (no changes needed)")

        return True

    except (OSError, IOError) as e:
        print(f"ERROR: Failed to process file: {e}")
        return False


def main() -> int:
    """Main function for command-line usage."""
    if len(sys.argv) != 2:
        print("DevOnboarder Markdown Quality Control Tool")
        print("Usage: python scripts/fix_markdown_formatting.py <filepath>")
        print("Example: python scripts/fix_markdown_formatting.py docs/README.md")
        return 1

    filepath = sys.argv[1]

    if not validate_file_exists(filepath):
        return 1

    success = fix_markdown_formatting(filepath)
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
