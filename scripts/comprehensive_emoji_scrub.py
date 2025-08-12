#!/usr/bin/env python3
"""
Comprehensive Emoji Scrubber for DevOnboarder
Removes ALL emoji instances from shell scripts and workflows.
"""

import pathlib
import re
import shutil
from typing import Tuple

# Files that should NEVER be modified (enforcement tools and their dependencies)
EXCLUSION_LIST = [
    "scripts/agent_policy_enforcer.py",
    "scripts/comprehensive_emoji_scrub.py",
    "scripts/validate_terminal_output_simple.sh",
    "scripts/terminal_zero_tolerance_validator.sh",
    ".pre-commit-config.yaml",
    "tests/test_issue_1008.py",  # Test file for enforcement validation
]

# Comprehensive emoji pattern matching all Unicode ranges
EMOJI_PATTERN = re.compile(
    r"[\U0001F600-\U0001F64F"  # emoticons
    r"\U0001F300-\U0001F5FF"  # misc symbols
    r"\U0001F680-\U0001F6FF"  # transport
    r"\U0001F1E0-\U0001F1FF"  # flags (iOS)
    r"\U00002702-\U000027B0"  # dingbats
    r"\U000024C2-\U0001F251"  # enclosed chars
    r"\uFE0F"  # variation selector
    r"]+"
)

# Common emoji to ASCII mappings
EMOJI_REPLACEMENTS = {
    "Bot": "Bot",
    "GREEN": "GREEN",
    "YELLOW": "YELLOW",
    "RED": "RED",
    "SUCCESS": "SUCCESS",
    "FAILED": "FAILED",
    "WARNING": "WARNING",
    "FOLDER": "FOLDER",
    "FILE": "FILE",
    "EDIT": "EDIT",
    "SEARCH": "SEARCH",
    "CONFIG": "CONFIG",
    "TOOLS": "TOOLS",
    "IDEA": "IDEA",
    "TARGET": "TARGET",
    "DEPLOY": "DEPLOY",
    "FIRST": "FIRST",
    "POTATO": "POTATO",
    "BRAIN": "BRAIN",
    "ORANGE": "ORANGE",
    "THINKING": "THINKING",
    "WIZARD": "WIZARD",
    "HOOK": "HOOK",
    "USER": "USER",
    "LINK": "LINK",
    "MEASURE": "MEASURE",
    "STATS": "STATS",
}


def scrub_line(line: str) -> Tuple[str, bool]:
    """Scrub a single line of emojis."""
    original = line

    # First pass: known replacements
    for emoji, replacement in EMOJI_REPLACEMENTS.items():
        line = line.replace(emoji, replacement)

    # Second pass: remove any remaining emojis
    line = EMOJI_PATTERN.sub("SYMBOL", line)

    return line, line != original


def main():
    """Main entry point."""
    root = pathlib.Path(".")

    # Files to process
    script_patterns = ["*.sh", "*.py", "*.yml", "*.yaml"]
    target_files = []

    for pattern in script_patterns:
        target_files.extend(root.glob(f"scripts/{pattern}"))
        target_files.extend(root.glob(f".github/workflows/{pattern}"))

    processed = 0
    changed = 0

    for file_path in target_files:
        if not file_path.is_file():
            continue

        # Skip files in exclusion list to prevent self-modification
        if str(file_path) in EXCLUSION_LIST:
            continue

        try:
            with open(file_path, "r", encoding="utf-8") as f:
                lines = f.readlines()

            new_lines = []
            file_changed = False

            for line in lines:
                new_line, line_changed = scrub_line(line)
                new_lines.append(new_line)
                if line_changed:
                    file_changed = True

            if file_changed:
                # Create backup
                backup_path = file_path.with_suffix(file_path.suffix + ".emoji_backup")
                shutil.copy2(file_path, backup_path)

                # Write cleaned content
                with open(file_path, "w", encoding="utf-8") as f:
                    f.writelines(new_lines)

                print(f"Cleaned {file_path}")
                changed += 1

            processed += 1

        except Exception as e:
            print(f"Error processing {file_path}: {e}")

    print(f"Processed {processed} files, changed {changed}")


if __name__ == "__main__":
    main()
