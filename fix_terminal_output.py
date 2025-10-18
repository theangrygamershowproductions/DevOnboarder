#!/usr/bin/env python3
"""
Terminal Output Compliance Fixer for DevOnboarder.

Removes emojis and Unicode characters that cause terminal hanging.
"""

import re
import sys
from pathlib import Path


def fix_terminal_output(content: str)  str:
    """Fix terminal output violations in shell scripts."""
    # Define emoji and Unicode patterns to remove/replace
    emoji_patterns = [
        r"\s*",  # Magnifying glass
        r"\s*",  # Check mark
        r"\s*",  # X mark
        r"🚫\s*",  # Prohibited sign
        r"\s*",  # Warning sign
        r"🎯\s*",  # Target
        r"\s*",  # Clipboard
        r"\s*",  # Rocket
        r"\s*",  # Light bulb
    ]

    result = content
    # Remove all emoji patterns
    for pattern in emoji_patterns:
        result = re.sub(pattern, "", result)

    # Clean up double spaces left by emoji removal
    result = re.sub(r"\s{2,}", " ", result)

    # Clean up leading/trailing spaces in echo statements
    result = re.sub(r'echo\s"(\s)', r'echo "\1', result)
    result = re.sub(r'(\s)"\s*$', r'\1"', result)

    return result


def main():
    """Main entry point for terminal output fixer."""
    if len(sys.argv) != 2:
        print("Usage: python fix_terminal_output.py <file_path>")
        sys.exit(1)

    file_path = Path(sys.argv[1])
    if not file_path.exists():
        print(f"Error: File {file_path} does not exist")
        sys.exit(1)

    # Read the file
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Fix terminal output violations
    fixed_content = fix_terminal_output(content)

    # Write back the fixed content
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(fixed_content)

    print(f"Fixed terminal output violations in {file_path}")


if __name__ == "__main__":
    main()
