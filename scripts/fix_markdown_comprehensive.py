#!/usr/bin/env python3
"""Comprehensive markdown fixer for DevOnboarder quality standards.

Fixes common markdown linting issues:
- MD029: Ordered list item prefix (renumber lists)
- MD022: Blanks around headings
- MD032: Blanks around lists
- MD058: Blanks around tables
- MD036: Emphasis used instead of heading
"""

import re
import sys
from pathlib import Path


def fix_md029_ordered_lists(content: str) -> str:
    """Fix MD029: Ordered list item prefix - restart numbering at 1."""
    lines = content.split("\n")
    result = []
    in_ordered_list = False
    list_counter = 1

    for line in lines:
        # Check if this is an ordered list item
        if re.match(r"^\s*\d\.\s", line):
            if not in_ordered_list:
                # Starting a new ordered list
                in_ordered_list = True
                list_counter = 1
            # Replace the number with the correct counter
            indentation = len(line) - len(line.lstrip())
            rest_of_line = re.sub(r"^\s*\d\.\s*", "", line)
            result.append(" " * indentation + f"{list_counter}. {rest_of_line}")
            list_counter = 1
        else:
            # Not an ordered list item
            if in_ordered_list and line.strip() == "":
                # Blank line might continue the list
                result.append(line)
            elif (
                in_ordered_list and not re.match(r"^\s*[-*]\s", line) and line.strip()
            ):
                # Non-list content, end the ordered list
                in_ordered_list = False
                list_counter = 1
                result.append(line)
            else:
                result.append(line)

    return "\n".join(result)


def fix_md022_blanks_around_headings(content: str) -> str:
    """Fix MD022: Blanks around headings."""
    lines = content.split("\n")
    result = []

    for i, line in enumerate(lines):
        # Check if current line is a heading
        if re.match(r"^#{1,6}\s", line):
            # Add blank line before heading (if not already present and not first line)
            if (
                i > 0
                and lines[i - 1].strip() != ""
                and (not result or result[-1].strip() != "")
            ):
                result.append("")

            result.append(line)

            # Add blank line after heading (if not already present and not last line)
            if i < len(lines) - 1 and lines[i + 1].strip() != "":
                result.append("")
        else:
            result.append(line)

    return "\n".join(result)


def fix_md032_blanks_around_lists(content: str) -> str:
    """Fix MD032: Blanks around lists."""
    lines = content.split("\n")
    result = []

    for i, line in enumerate(lines):
        # Check if current line starts a list
        if re.match(r"^\s*[-*\d\.]\s", line):
            # Check if previous line is not blank and not a list item
            if (
                i > 0
                and lines[i - 1].strip() != ""
                and not re.match(r"^\s*[-*\d\.]\s", lines[i - 1])
            ):
                result.append("")

        # Check if current line ends a list (next line is not a list item or blank)
        elif (
            i > 0
            and re.match(r"^\s*[-*\d\.]\s", lines[i - 1])
            and line.strip() != ""
            and not re.match(r"^\s*[-*\d\.]\s", line)
        ):
            result.insert(-1 if result and result[-1] == "" else len(result), "")

        result.append(line)

    return "\n".join(result)


def fix_md058_blanks_around_tables(content: str) -> str:
    """Fix MD058: Blanks around tables."""
    lines = content.split("\n")
    result = []
    in_table = False

    for i, line in enumerate(lines):
        # Check if line is a table row
        line_stripped = line.strip()
        is_table_row = (
            "|" in line
            and line_stripped.startswith("|")
            and line_stripped.endswith("|")
        )

        if is_table_row and not in_table:
            # Starting a table - add blank line before if needed
            if i > 0 and lines[i - 1].strip() != "":
                result.append("")
            in_table = True
        elif not is_table_row and in_table:
            # Ending a table - add blank line after previous line if needed
            in_table = False
            if line.strip() != "":
                result.append("")

        result.append(line)

    return "\n".join(result)


def fix_md036_emphasis_instead_of_heading(content: str) -> str:
    """Fix MD036: Emphasis used instead of heading."""
    lines = content.split("\n")
    result = []

    for line in lines:
        # Look for lines that are just bold text (likely should be headings)
        if re.match(r"^\s*\*\*[^*]\*\*\s*$", line):
            # Convert to heading
            text = re.sub(r"^\s*\*\*([^*])\*\*\s*$", r"\1", line)
            # Use ## for section headings
            result.append(f"## {text.strip()}")
        else:
            result.append(line)

    return "\n".join(result)


def fix_md031_blanks_around_fences(content: str) -> str:
    """Fix MD031: Blanks around fences (enhanced)."""
    lines = content.split("\n")
    result: list[str] = []
    in_fence = False
    fence_pattern = re.compile(r"^```")

    for i, line in enumerate(lines):
        is_fence_line = fence_pattern.match(line.strip())

        if is_fence_line and not in_fence:
            # Starting a fence - add blank line before if needed
            if i > 0 and lines[i - 1].strip() != "":
                result.append("")
            in_fence = True
            result.append(line)
        elif is_fence_line and in_fence:
            # Ending a fence
            result.append(line)
            # Add blank line after if needed
            if i < len(lines) - 1 and lines[i + 1].strip() != "":
                result.append("")
            in_fence = False
        else:
            result.append(line)

    return "\n".join(result)


def fix_md026_trailing_punctuation_in_headings(content: str) -> str:
    """Fix MD026: Remove trailing punctuation from headings."""
    lines = content.split("\n")
    result = []

    for line in lines:
        # Check if line is a heading
        if re.match(r"^#{1,6}\s", line):
            # Remove trailing punctuation (., :, !, ?) from heading
            line = re.sub(r"^(#{1,6}\s.*?)[\.\:\!\?]\s*$", r"\1", line)
        result.append(line)

    return "\n".join(result)


def fix_md001_heading_increment(content: str) -> str:
    """Fix MD001: Heading levels should only increment by one level at a time."""
    lines = content.split("\n")
    result = []
    last_heading_level = 0

    for line in lines:
        # Check if line is a heading
        heading_match = re.match(r"^(#{1,6})\s", line)
        if heading_match:
            current_level = len(heading_match.group(1))

            # If jumping more than 1 level, adjust to be 1 level deeper
            if current_level > last_heading_level + 1:
                new_level = last_heading_level + 1
                line = "#" * new_level + line[current_level:]
                last_heading_level = new_level
            else:
                last_heading_level = current_level
        result.append(line)

    return "\n".join(result)


def fix_md040_fenced_code_language(content: str) -> str:
    """Fix MD040: Add language to fenced code blocks."""
    lines = content.split("\n")
    result = []

    for line in lines:
        # Look for fenced code blocks without language
        if re.match(r"^```\s*$", line.strip()):
            # Add bash as default language
            result.append("```bash")
        else:
            result.append(line)

    return "\n".join(result)


def fix_md024_duplicate_headings(content: str) -> str:
    """Fix MD024: Handle duplicate headings by adding context numbers."""
    lines = content.split("\n")
    result: list[str] = []
    heading_counts: dict[str, int] = {}

    for line in lines:
        # Check if line is a heading
        heading_match = re.match(r"^(#{1,6})\s(.)", line)
        if heading_match:
            level, text = heading_match.groups()
            text_clean = text.strip()

            # Track heading occurrences
            if text_clean in heading_counts:
                heading_counts[text_clean] = 1
                # Add context number to duplicate
                line = f"{level} {text_clean} ({heading_counts[text_clean]})"
            else:
                heading_counts[text_clean] = 1

        result.append(line)

    return "\n".join(result)


def fix_markdown_file(file_path: Path) -> bool:
    """Fix all markdown issues in a file."""
    try:
        content = file_path.read_text(encoding="utf-8")

        # Apply fixes in order
        content = fix_md029_ordered_lists(content)
        content = fix_md022_blanks_around_headings(content)
        content = fix_md032_blanks_around_lists(content)
        content = fix_md058_blanks_around_tables(content)
        content = fix_md036_emphasis_instead_of_heading(content)
        content = fix_md031_blanks_around_fences(content)
        content = fix_md026_trailing_punctuation_in_headings(content)
        content = fix_md001_heading_increment(content)
        content = fix_md040_fenced_code_language(content)
        content = fix_md024_duplicate_headings(content)

        # Clean up multiple blank lines (max 2 consecutive)
        content = re.sub(r"\n{3,}", "\n\n", content)

        # Ensure file ends with single newline
        content = content.rstrip() + "\n"

        file_path.write_text(content, encoding="utf-8")
        print(f"Fixed: {file_path}")
        return True

    except (OSError, UnicodeDecodeError, UnicodeEncodeError) as e:
        print(f"Error fixing {file_path}: {e}")
        return False


def main():
    """Main function."""
    if len(sys.argv) < 2:
        print("Usage: python fix_markdown_comprehensive.py <file1> [file2] ...")
        sys.exit(1)

    success_count = 0
    total_count = 0

    for file_arg in sys.argv[1:]:
        file_path = Path(file_arg)
        if not file_path.exists():
            print(f"Warning: {file_path} does not exist")
            continue

        if not file_path.suffix == ".md":
            print(f"Warning: {file_path} is not a markdown file")
            continue

        total_count = 1
        if fix_markdown_file(file_path):
            success_count = 1

    print(f"Fixed {success_count}/{total_count} files")
    return 0 if success_count == total_count else 1


if __name__ == "__main__":
    sys.exit(main())
