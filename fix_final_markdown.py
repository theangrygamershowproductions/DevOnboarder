#!/usr/bin/env python3

import re


def fix_markdown_file(filename):
    """Fix all markdown formatting issues in a file."""
    print(f"Fixing {filename}...")

    with open(filename, "r", encoding="utf-8") as f:
        content = f.read()

    # Fix MD026: Remove trailing punctuation from headings
    content = re.sub(r"^(#\s.*[^:]):$", r"\1", content, flags=re.MULTILINE)

    # Fix MD022: Add blank lines around headings
    # Add blank line before headings (but not at start of file)
    content = re.sub(r"(?<!^)(?<!\n)\n(#{1,6}\s[^\n])", r"\n\n\1", content)
    # Add blank line after headings
    content = re.sub(r"(#{1,6}\s[^\n])\n(?!\n)([^\n#])", r"\1\n\n\2", content)

    # Fix MD032: Add blank lines around lists
    # Add blank line before lists
    content = re.sub(r"(?<!\n)\n([-*]\s[^\n])", r"\n\n\1", content)
    content = re.sub(r"(?<!\n)\n(\d\.\s[^\n])", r"\n\n\1", content)
    # Add blank line after lists (before non-list content)
    content = re.sub(r"([-*]\s[^\n])\n(?!\n)(?![-*\d]\s)", r"\1\n\n", content)
    content = re.sub(r"(\d\.\s[^\n])\n(?!\n)(?![-*\d]\s)", r"\1\n\n", content)

    # Fix MD031: Add blank lines around fenced code blocks
    # Add blank line before code blocks
    content = re.sub(r"(?<!\n)\n(```[^\n]*)", r"\n\n\1", content)
    # Add blank line after code blocks
    content = re.sub(r"(```)\n(?!\n)([^`\n])", r"\1\n\n\2", content)

    # Clean up multiple consecutive blank lines (more than 2)
    content = re.sub(r"\n{3,}", "\n\n", content)

    # Ensure file ends with single newline
    content = content.rstrip()  "\n"

    with open(filename, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"Fixed {filename}")


if __name__ == "__main__":
    files_to_fix = [
        "PRIORITY_MATRIX_AUTO_SYNTHESIS_COMPLETE.md",
        "docs/templates/enhanced-frontmatter-priority-matrix.md",
    ]

    for filename in files_to_fix:
        try:
            fix_markdown_file(filename)
        except Exception as e:
            print(f"Error fixing {filename}: {e}")

    print("Markdown fixing complete!")
