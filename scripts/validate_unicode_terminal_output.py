#!/usr/bin/env python3
"""
Unicode Terminal Output Validator

This script validates that shell scripts and Python scripts don't contain
Unicode characters or emojis in terminal output commands (echo, print, etc.).

This is a CRITICAL requirement for DevOnboarder as Unicode characters in
terminal output cause immediate terminal hanging.

Issue: #1008 - Unicode Handling Enhancement for Testing Infrastructure
"""

import argparse
import re
import sys
from pathlib import Path
from typing import List, Tuple


class UnicodeTerminalValidator:
    """Validates terminal output for Unicode characters."""

    def __init__(self):
        # Patterns that indicate terminal output in shell scripts
        self.shell_output_patterns = [
            r'echo\s["\']([^"\']*)["\']',  # echo "text" or echo 'text'
            r"echo\s([^#\n]*)",  # echo text (unquoted)
            r'printf\s["\']([^"\']*)["\']',  # printf "text"
        ]

        # Patterns that indicate terminal output in Python scripts
        self.python_output_patterns = [
            r'print\s*\(\s*["\']([^"\']*)["\']',  # print("text")
            # sys.stdout.write("text")
            r'sys\.stdout\.write\s*\(\s*["\']([^"\']*)["\']',
            # sys.stderr.write("text")
            r'sys\.stderr\.write\s*\(\s*["\']([^"\']*)["\']',
        ]

        # Known problematic Unicode characters and emojis
        self.problematic_unicode = {
            "\u2705",
            "\u274c",
            "\U0001f3af",
            "\U0001f680",
            "\U0001f4cb",
            "\U0001f50d",
            "\U0001f4dd",
            "\U0001f4a1",
            "\u26a0\ufe0f",
            "\U0001f9f9",
            "\U0001f4ca",
            "\U0001f504",
            "\u2b50",
            "\U0001f389",
            "\U0001f41b",
            "\U0001f527",
            "\U0001f4c8",
            "\U0001f4c9",
            "\U0001f7e2",
            "\U0001f534",
            "\U0001f7e1",
            "\U0001f535",
            "\u26aa",
            "\u26ab",
            "\U0001f7e0",
            "\U0001f7e3",
            "\U0001f7e4",
            "\u2192",
            "\u2190",
            "\u2191",
            "\u2193",
            "\u21d2",
            "\u21d0",
            "\u21d1",
            "\u21d3",
            "\u21a9",
            "\u21aa",
            "\u25a0",
            "\u25a1",
            "\u25b2",
            "\u25b3",
            "\u25bc",
            "\u25bd",
            "\u25c6",
            "\u25c7",
            "\u25cf",
            "\u25cb",
        }

    def is_unicode_problematic(self, text: str)  bool:
        """Check if text contains problematic Unicode characters."""
        # Check for any non-ASCII characters
        try:
            text.encode("ascii")
        except UnicodeEncodeError:
            return True

        # Check for known problematic characters
        for char in self.problematic_unicode:
            if char in text:
                return True

        return False

    def extract_terminal_output(
        self, content: str, file_extension: str
    )  List[Tuple[int, str, str]]:
        """Extract terminal output strings from file content."""
        results: List[Tuple[int, str, str]] = []
        lines = content.split("\n")

        if file_extension in [".sh", ".bash"]:
            patterns = self.shell_output_patterns
        elif file_extension in [".py"]:
            patterns = self.python_output_patterns
        else:
            return results

        for line_num, line in enumerate(lines, 1):
            for pattern in patterns:
                matches = re.finditer(pattern, line)
                for match in matches:
                    # Extract text content (group 1 if exists, else full match)
                    text_content = match.group(1) if match.groups() else match.group(0)
                    if text_content:
                        results.append((line_num, line.strip(), text_content))

        return results

    def validate_file(self, file_path: Path)  List[Tuple[int, str, str, str]]:
        """Validate a single file for Unicode terminal output."""
        violations = []

        try:
            content = file_path.read_text(encoding="utf-8")
            file_extension = file_path.suffix

            terminal_outputs = self.extract_terminal_output(content, file_extension)

            for line_num, full_line, text_content in terminal_outputs:
                if self.is_unicode_problematic(text_content):
                    violations.append(
                        (line_num, full_line, text_content, str(file_path))
                    )

        except (UnicodeDecodeError, OSError) as e:
            print(f"Error reading {file_path}: {e}", file=sys.stderr)

        return violations

    def find_files_to_check(self, root_path: Path)  List[Path]:
        """Find all shell and Python files to check."""
        files: List[Path] = []

        # Check shell scripts
        for pattern in ["**/*.sh", "**/*.bash"]:
            files.extend(root_path.glob(pattern))

        # Check Python scripts
        files.extend(root_path.glob("**/*.py"))

        # Filter out virtual environment and node_modules
        filtered_files = []
        for file in files:
            parts = file.parts
            excludes = [".venv", "node_modules", ".git", "__pycache__"]
            if any(exclude in parts for exclude in excludes):
                continue
            filtered_files.append(file)

        return filtered_files

    def validate_directory(self, directory: Path)  int:
        """Validate all files in a directory."""
        violations_count = 0
        files = self.find_files_to_check(directory)

        print(
            f"Checking {len(files)} files for Unicode terminal output " "violations..."
        )

        for file_path in files:
            violations = self.validate_file(file_path)
            if violations:
                violations_count = len(violations)
                print(f"\nVIOLATIONS in {file_path}:")
                for line_num, full_line, text_content, _ in violations:
                    print(f"  Line {line_num}: {full_line}")
                    print(f"    Problematic text: {repr(text_content)}")

        return violations_count

    def suggest_fixes(self, text_content: str)  str:
        """Suggest ASCII alternatives for Unicode characters."""
        fixes = {
            "\u2705": "OK",
            "\u274c": "FAILED",
            "\U0001f3af": "TARGET",
            "\U0001f680": "LAUNCH",
            "\U0001f4cb": "LIST",
            "\U0001f50d": "SEARCH",
            "\U0001f4dd": "NOTE",
            "\U0001f4a1": "IDEA",
            "\u26a0\ufe0f": "WARNING",
            "\U0001f9f9": "CLEAN",
            "\U0001f4ca": "STATS",
            "\U0001f504": "REFRESH",
            "\u2b50": "STAR",
            "\U0001f389": "SUCCESS",
            "\U0001f41b": "BUG",
            "\U0001f527": "FIX",
            "\U0001f7e2": "GREEN",
            "\U0001f534": "RED",
            "\u2192": "",
            "\u2190": "<-",
            "\u2191": "^",
            "\u2193": "v",
            "\u25a0": "[X]",
            "\u25a1": "[ ]",
        }

        suggested = text_content
        for unicode_char, ascii_replacement in fixes.items():
            suggested = suggested.replace(unicode_char, ascii_replacement)

        return suggested


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description=(
            "Validate terminal output for Unicode characters that " "cause hanging"
        )
    )
    parser.add_argument(
        "path",
        nargs="?",
        default=".",
        help="Path to validate (file or directory, default: current directory)",
    )
    parser.add_argument(
        "--fix-suggestions",
        action="store_true",
        help="Show ASCII alternatives for Unicode characters",
    )

    args = parser.parse_args()
    path = Path(args.path)

    validator = UnicodeTerminalValidator()

    if path.is_file():
        violations = validator.validate_file(path)
        violations_count = len(violations)
        if violations:
            print(f"VIOLATIONS in {path}:")
            for line_num, full_line, text_content, _ in violations:
                print(f"  Line {line_num}: {full_line}")
                print(f"    Problematic text: {repr(text_content)}")
                if args.fix_suggestions:
                    suggestion = validator.suggest_fixes(text_content)
                    if suggestion != text_content:
                        print(f"    Suggested fix: {repr(suggestion)}")
    else:
        violations_count = validator.validate_directory(path)

    if violations_count > 0:
        print(
            f"\nCRITICAL: Found {violations_count} Unicode terminal output "
            "violations!"
        )
        print("These WILL cause terminal hanging in DevOnboarder environment.")
        print("Fix by replacing Unicode characters with plain ASCII " "alternatives.")
        print("See .github/copilot-instructions.md for requirements.")
        sys.exit(1)
    else:
        print("All terminal output uses safe ASCII characters.")
        sys.exit(0)


if __name__ == "__main__":
    main()
