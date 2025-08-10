#!/usr/bin/env python3
"""
Intelligent Markdown Auto-Fixer for DevOnboarder
"Quiet Reliability" Philosophy: Fix obvious patterns automatically

This tool goes beyond basic markdownlint --fix by using context-aware
pattern recognition to handle common documentation patterns intelligently.
"""

import re
import argparse
from pathlib import Path
from typing import List, Dict


class IntelligentMarkdownFixer:
    """Context-aware markdown fixer that handles obvious patterns."""

    def __init__(self):
        self.language_patterns = {
            "bash": [
                r"npm (install|run|test|start|build)",
                r"pip install",
                r"git (clone|add|commit|push)",
                r"docker (run|build|exec)",
                r"curl -",
                r'echo ["\']',
                r"cd \w+",
                r"mkdir",
                r"chmod",
                r"source ",
                r"\./scripts/",
                r"# [A-Z]",  # Comments starting with uppercase
            ],
            "python": [
                r"def \w+\(",
                r"class \w+",
                r"import \w+",
                r"from \w+ import",
                r'if __name__ == ["\']__main__["\']',
                r"@\w+",  # Decorators
                r"print\(",
                r"return \w+",
            ],
            "javascript": [
                r"function \w+\(",
                r"const \w+ =",
                r"let \w+ =",
                r"var \w+ =",
                r"import .* from",
                r"export ",
                r"console\.log\(",
                r"=> {",
            ],
            "typescript": [
                r"interface \w+",
                r"type \w+ =",
                r": \w+\[\]",
                r": Promise<",
                r"async function",
                r"implements \w+",
            ],
            "json": [
                r"^\s*{",
                r"^\s*\[",
                r'["\'][^"\']+["\']\s*:',
            ],
            "yaml": [
                r"^\w+:",
                r"^\s+-\s+\w+",
                r'version:\s*["\']?\d',
            ],
            "dockerfile": [
                r"^FROM \w+",
                r"^RUN ",
                r"^COPY ",
                r"^WORKDIR ",
                r"^EXPOSE \d+",
                r"^ENV \w+",
            ],
            "sql": [
                r"^SELECT ",
                r"^INSERT INTO",
                r"^UPDATE \w+",
                r"^CREATE TABLE",
                r"^DROP TABLE",
            ],
        }

    def detect_language(self, code_block: str) -> str:
        """Detect programming language from code block content."""
        lines = code_block.strip().split("\n")

        # Score each language
        language_scores = {}
        for lang, patterns in self.language_patterns.items():
            score = 0
            for line in lines[:5]:  # Check first 5 lines
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                for pattern in patterns:
                    if re.search(pattern, line, re.IGNORECASE):
                        score += 1
            if score > 0:
                language_scores[lang] = score

        # Return highest scoring language
        if language_scores:
            return max(language_scores, key=language_scores.get)

        # Fallback heuristics
        full_text = code_block.lower()
        if "npm " in full_text or "git " in full_text or "echo " in full_text:
            return "bash"
        if "{" in full_text and '"' in full_text:
            return "json"

        return "text"  # Safe fallback

    def fix_fenced_code_language(self, content: str) -> str:
        """Fix MD040: Add language to fenced code blocks."""
        # First, fix closing fences that incorrectly have language identifiers
        content = re.sub(r"\n```\w+\s*$", r"\n```", content, flags=re.MULTILINE)

        # Then add language to opening fences that don't have it
        pattern = r"```(\n)(.*?)\n```"

        def replace_code_block(match):
            code_content = match.group(2)
            if not code_content.strip():
                return match.group(0)  # Keep empty blocks as-is

            detected_lang = self.detect_language(code_content)
            return f"```{detected_lang}\n{code_content}\n```"

        return re.sub(pattern, replace_code_block, content, flags=re.DOTALL)

    def fix_emphasis_as_heading(self, content: str) -> str:
        """Fix MD036: Convert obvious emphasis to headings."""
        lines = content.split("\n")
        fixed_lines = []

        for i, line in enumerate(lines):
            # Pattern: **Heading Text** on its own line
            match = re.match(r"^(\s*)\*\*([^*]+)\*\*\s*$", line)
            if match:
                indent, text = match.groups()

                # Check context to determine heading level
                next_line = lines[i + 1] if i < len(lines) - 1 else ""

                # If next line is code block or list, this is likely a subheading
                if (
                    next_line.strip().startswith("```")
                    or next_line.strip().startswith("- ")
                    or next_line.strip().startswith("1. ")
                ):
                    level = "####"
                else:
                    level = "###"

                fixed_lines.append(f"{indent}{level} {text}")
            else:
                fixed_lines.append(line)

        return "\n".join(fixed_lines)

    def fix_blanks_around_elements(self, content: str) -> str:
        """Fix MD022, MD031, MD032: Add blank lines around elements."""
        lines = content.split("\n")
        fixed_lines = []

        for i, line in enumerate(lines):
            current = line.strip()
            prev_line = lines[i - 1].strip() if i > 0 else ""
            next_line = lines[i + 1].strip() if i < len(lines) - 1 else ""

            # Add blank line before headings (MD022)
            if current.startswith("#") and prev_line and not prev_line.startswith("#"):
                if fixed_lines and fixed_lines[-1].strip():
                    fixed_lines.append("")

            fixed_lines.append(line)

            # Add blank line after headings (MD022)
            if current.startswith("#") and next_line and not next_line.startswith("#"):
                if i < len(lines) - 1 and not next_line == "":
                    fixed_lines.append("")

            # Add blank lines around code blocks (MD031)
            if current.startswith("```") and not prev_line == "":
                if len(fixed_lines) >= 2 and fixed_lines[-2].strip():
                    fixed_lines.insert(-1, "")

            if current.startswith("```") and next_line and not next_line == "":
                fixed_lines.append("")

        return "\n".join(fixed_lines)

    def fix_file(self, filepath: Path) -> bool:
        """Fix a single markdown file. Returns True if changes were made."""
        try:
            original_content = filepath.read_text(encoding="utf-8")
            content = original_content

            # Apply fixes in order
            content = self.fix_fenced_code_language(content)
            content = self.fix_emphasis_as_heading(content)
            content = self.fix_blanks_around_elements(content)

            # Check if changes were made
            if content != original_content:
                filepath.write_text(content, encoding="utf-8")
                return True

            return False

        except (IOError, UnicodeDecodeError) as e:
            print(f"Error processing {filepath}: {e}")
            return False

    def fix_files(self, file_patterns: List[str]) -> Dict[str, bool]:
        """Fix multiple markdown files."""
        results = {}

        for pattern in file_patterns:
            if "*" in pattern:
                # Handle glob patterns
                base_path = Path(".")
                for filepath in base_path.glob(pattern):
                    if filepath.suffix == ".md":
                        results[str(filepath)] = self.fix_file(filepath)
            else:
                # Handle direct file paths
                filepath = Path(pattern)
                if filepath.exists() and filepath.suffix == ".md":
                    results[str(filepath)] = self.fix_file(filepath)

        return results


def main():
    parser = argparse.ArgumentParser(
        description="Intelligent Markdown Auto-Fixer for DevOnboarder"
    )
    parser.add_argument(
        "files",
        nargs="+",
        help='Markdown files or patterns to fix (e.g., "**/*.md" "docs/README.md")',
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be changed without making modifications",
    )
    parser.add_argument("--verbose", action="store_true", help="Show detailed output")

    args = parser.parse_args()

    fixer = IntelligentMarkdownFixer()

    if args.dry_run:
        print("DRY RUN: Would fix the following files:")

    results = fixer.fix_files(args.files)

    changed_files = [f for f, changed in results.items() if changed]
    unchanged_files = [f for f, changed in results.items() if not changed]

    if args.verbose:
        for filepath, changed in results.items():
            status = (
                "WOULD CHANGE"
                if args.dry_run and changed
                else ("CHANGED" if changed else "NO CHANGES")
            )
            print(f"{status}: {filepath}")

    print("\nSummary:")
    print(f"Files processed: {len(results)}")
    print(f"Files {'would be ' if args.dry_run else ''}changed: {len(changed_files)}")
    print(f"Files unchanged: {len(unchanged_files)}")

    if changed_files and not args.dry_run:
        print("\nFixed files:")
        for f in changed_files:
            print(f"  ✅ {f}")


if __name__ == "__main__":
    main()
