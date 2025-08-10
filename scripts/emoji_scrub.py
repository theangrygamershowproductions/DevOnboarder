#!/usr/bin/env python3
"""
DevOnboarder Emoji Scrub Tool
Replaces emojis in echo statements with ASCII equivalents to fix policy.
"""

import sys
import shutil
from pathlib import Path

# Emoji replacements for terminal output
EMOJI_REPLACEMENTS = {
    "SUCCESS": "SUCCESS",
    "FAILED": "FAILED",
    "TARGET": "TARGET",
    "DEPLOY": "DEPLOY",
    "SYMBOL_CHECKLIST": "CHECKLIST",
    "SEARCH": "SEARCH",
    "EDIT": "LOG",
    "IDEA": "TIP",
    "WARNING": "WARNING",
    "STATS": "STATS",
    "SYMBOL_BUILD": "BUILD",
    "CONFIG": "CONFIG",
    "SYMBOL_STAR": "STAR",
    "SYMBOL_SECURE": "SECURE",
    "SYMBOL_METRICS": "METRICS",
    "SYMBOL_COMPLETE": "COMPLETE",
    "SYMBOL_REFRESH": "REFRESH",
    "SYMBOL_FAST": "FAST",
    "SYMBOL_FORMAT": "FORMAT",
    "SYMBOL_LOCKED": "LOCKED",
    "SYMBOL_PACKAGE": "PACKAGE",
    "SYMBOL_FEATURE": "FEATURE",
    "SYMBOL_DEMO": "DEMO",
    "🧹": "CLEANUP",
    "SYMBOL_TEST": "TEST",
    "SUCCESS_WIN": "WIN",
    "SYMBOL_GAME": "GAME",
    "SYMBOL_HOT": "HOT",
    "SYMBOL_SYSTEM": "SYSTEM",
    "SYMBOL_MOBILE": "MOBILE",
    "SYMBOL_SETTINGS": "SETTINGS",
    "SYMBOL_NETWORK": "NETWORK",
    "LINK": "LINK",
}


def replace_emojis_in_content(content):
    """Replace emojis in echo statements with ASCII equivalents."""
    lines = content.split("\n")
    modified_lines = []
    changes_made = False

    for line in lines:
        # Check if line contains echo and emojis
        if "echo" in line and any(emoji in line for emoji in EMOJI_REPLACEMENTS.keys()):
            # Replace emojis in the line
            for emoji, replacement in EMOJI_REPLACEMENTS.items():
                if emoji in line:
                    line = line.replace(emoji, replacement)
                    changes_made = True

        modified_lines.append(line)

    return "\n".join(modified_lines), changes_made


def process_file(file_path):
    """Process a single file to replace emojis."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        modified_content, changes_made = replace_emojis_in_content(content)

        if changes_made:
            # Create backup
            backup_path = f"{file_path}.emoji_backup"
            shutil.copy2(file_path, backup_path)

            # Write modified content
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(modified_content)

            return True, f"Modified {file_path} (backup: {backup_path})"
        else:
            return False, f"No changes needed for {file_path}"

    except (IOError, OSError, UnicodeDecodeError) as e:
        return False, f"Error processing {file_path}: {e}"


def main():
    """Main function to process files."""
    if len(sys.argv) < 2:
        print("Usage: python3 emoji_scrub.py <file_or_directory>")
        print("Example: python3 emoji_scrub.py scripts/")
        sys.exit(1)

    target = sys.argv[1]
    path = Path(target)

    if not path.exists():
        print(f"Error: {target} does not exist")
        sys.exit(1)

    files_to_process = []

    if path.is_file():
        files_to_process.append(path)
    elif path.is_dir():
        # Find shell scripts and YAML files
        files_to_process.extend(path.glob("**/*.sh"))
        files_to_process.extend(path.glob("**/*.yml"))
        files_to_process.extend(path.glob("**/*.yaml"))

    print(f"Processing {len(files_to_process)} files...")

    modified_count = 0
    for file_path in files_to_process:
        modified, message = process_file(file_path)
        print(message)
        if modified:
            modified_count += 1

    print(f"\nEmoji scrub complete: {modified_count} files modified")


if __name__ == "__main__":
    main()
