#!/usr/bin/env python3
"""
DevOnboarder Markdown Auto-Formatter

Comprehensive markdown formatting tool that fixes common markdownlint violations
automatically. Designed for integration with DevOnboarder's QC system.

Features:
- MD022: Ensures blank lines around headings
- MD032: Ensures blank lines around lists
- MD031: Ensures blank lines around fenced code blocks
- MD026: Removes trailing punctuation from headings
- MD009: Removes trailing spaces
- Preserves existing content structure
- Handles multiple files or directories

Usage:
    python scripts/fix_markdown_formatting.py file1.md file2.md
    python scripts/fix_markdown_formatting.py docs/
    python scripts/fix_markdown_formatting.py --all

Part of DevOnboarder's automated quality control system.
"""

import argparse
import os
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import List


def setup_logging()  None:
    """Set up centralized logging per DevOnboarder standards."""
    import logging

    # Create logs directory if it doesn't exist
    logs_dir = Path("logs")
    logs_dir.mkdir(exist_ok=True)

    # Set up logging to centralized location
    log_file = logs_dir / "markdown_formatter.log"
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[logging.FileHandler(log_file), logging.StreamHandler()],
    )


def fix_markdown_content(content: str)  tuple[str, List[str]]:
    """
    Fix common markdown formatting issues in content.

    Parameters
    ----------
    content : str
        The markdown content to fix

    Returns
    -------
    tuple[str, List[str]]
        The fixed content and list of issues fixed
    """
    issues_fixed = []

    # Fix MD026: Remove trailing punctuation from headings
    before_punctuation = content
    content = re.sub(r"^(#\s.*[^:]):$", r"\1", content, flags=re.MULTILINE)
    if content != before_punctuation:
        issues_fixed.append("MD026: Removed trailing punctuation from headings")

    # Remove trailing spaces (MD009)
    before_spaces = len(re.findall(r" $", content, flags=re.MULTILINE))
    content = re.sub(r" $", "", content, flags=re.MULTILINE)
    if before_spaces > 0:
        issues_fixed.append(f"MD009: Fixed {before_spaces} trailing space issues")

    # Fix MD022: Add blank lines around headings
    before_headings = content
    # Add blank line before headings (but not at start of file)
    content = re.sub(r"(?<!^)(?<!\n)\n(#{1,6}\s[^\n])", r"\n\n\1", content)
    # Add blank line after headings
    content = re.sub(r"(#{1,6}\s[^\n])\n(?!\n)([^\n#])", r"\1\n\n\2", content)
    if content != before_headings:
        issues_fixed.append("MD022: Fixed heading spacing issues")

    # Fix MD032: Add blank lines around lists
    before_lists = content
    # Add blank line before lists
    content = re.sub(r"(?<!\n)\n([-*]\s[^\n])", r"\n\n\1", content)
    content = re.sub(r"(?<!\n)\n(\d\.\s[^\n])", r"\n\n\1", content)
    # Add blank line after lists (before non-list content)
    content = re.sub(r"([-*]\s[^\n])\n(?!\n)(?![-*\d]\s)", r"\1\n\n", content)
    content = re.sub(r"(\d\.\s[^\n])\n(?!\n)(?![-*\d]\s)", r"\1\n\n", content)
    if content != before_lists:
        issues_fixed.append("MD032: Fixed list spacing issues")

    # Fix MD031: Add blank lines around fenced code blocks
    before_fenced = content
    # Add blank line before code blocks
    content = re.sub(r"(?<!\n)\n(```[^\n]*)", r"\n\n\1", content)
    # Add blank line after code blocks
    content = re.sub(r"(```)\n(?!\n)([^`\n])", r"\1\n\n\2", content)
    if content != before_fenced:
        issues_fixed.append("MD031: Fixed fenced code block spacing")

    # Clean up multiple consecutive blank lines (more than 2)
    before_cleanup = content
    content = re.sub(r"\n{3,}", "\n\n", content)
    if content != before_cleanup:
        issues_fixed.append("Cleaned up excessive blank lines")

    # Ensure file ends with single newline
    content = content.rstrip()  "\n"

    return content, issues_fixed


def process_markdown_file(file_path: Path, create_backup: bool = True)  bool:
    """
    Process a single markdown file.

    Parameters
    ----------
    file_path : Path
        Path to the markdown file
    create_backup : bool
        Whether to create a backup file

    Returns
    -------
    bool
        True if file was successfully processed, False otherwise
    """
    import logging

    logger = logging.getLogger(__name__)

    try:
        logger.info(f"Processing {file_path}")

        # Read the file
        with open(file_path, "r", encoding="utf-8") as f:
            original_content = f.read()

        # Fix formatting
        fixed_content, issues_fixed = fix_markdown_content(original_content)

        # Only write if content changed
        if fixed_content != original_content:
            # Create backup in centralized logs directory if requested
            if create_backup:
                logs_dir = Path("logs")
                logs_dir.mkdir(exist_ok=True)
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                backup_filename = f"backup_{file_path.name}_{timestamp}.bak"
                backup_path = logs_dir / backup_filename
                with open(backup_path, "w", encoding="utf-8") as f:
                    f.write(original_content)
                logger.info(f"Backup created: {backup_path}")

            # Write fixed content
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(fixed_content)

            logger.info(f"Fixed formatting in {file_path}")
            for issue in issues_fixed:
                logger.info(f"  - {issue}")
            return True
        else:
            logger.info(f"No changes needed for {file_path}")
            return True

    except OSError as e:
        logger.error(f"Error processing {file_path}: {e}")
        return False
    except Exception as e:
        logger.error(f"Unexpected error processing {file_path}: {e}")
        return False


def find_markdown_files(path: Path)  List[Path]:
    """
    Find all markdown files in a path.

    Parameters
    ----------
    path : Path
        Directory path to search

    Returns
    -------
    List[Path]
        List of markdown file paths
    """
    markdown_files = []

    if path.is_file() and path.suffix.lower() in [".md", ".markdown"]:
        markdown_files.append(path)
    elif path.is_dir():
        # Recursively find markdown files
        for md_file in path.rglob("*.md"):
            # Skip certain directories per DevOnboarder standards
            if any(
                skip in str(md_file)
                for skip in ["node_modules", ".venv", "venv", ".git", "logs", "archive"]
            ):
                continue
            markdown_files.append(md_file)

    return sorted(markdown_files)


def main()  int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="DevOnboarder Markdown Auto-Formatter",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )

    parser.add_argument(
        "paths", nargs="*", help="Markdown files or directories to process"
    )

    parser.add_argument(
        "--all", action="store_true", help="Process all markdown files in repository"
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be changed without making changes",
    )

    parser.add_argument(
        "--no-backup", action="store_true", help="Do not create backup files"
    )

    args = parser.parse_args()

    # Set up logging
    setup_logging()
    import logging

    logger = logging.getLogger(__name__)

    # Determine files to process
    files_to_process = []

    if args.all:
        # Process all markdown files in repository
        repo_root = Path(".")
        files_to_process = find_markdown_files(repo_root)
    elif args.paths:
        # Process specified paths
        for path_str in args.paths:
            path = Path(path_str)
            if not path.exists():
                logger.error(f"Path does not exist: {path}")
                continue
            files_to_process.extend(find_markdown_files(path))
    else:
        # Legacy single-file mode for backward compatibility
        if len(sys.argv) == 2 and not sys.argv[1].startswith("-"):
            # Old usage: python script.py file.md
            filepath = sys.argv[1]
            if os.path.isfile(filepath):
                files_to_process = [Path(filepath)]
            else:
                logger.error(f"File does not exist: {filepath}")
                return 1
        else:
            logger.error("No paths specified. Use --all or provide file paths.")
            parser.print_help()
            return 1

    if not files_to_process:
        logger.warning("No markdown files found to process")
        return 0

    # Process files
    logger.info(f"Processing {len(files_to_process)} markdown files")

    success_count = 0
    for file_path in files_to_process:
        if args.dry_run:
            logger.info(f"Would process: {file_path}")
            success_count = 1
        else:
            if process_markdown_file(file_path, not args.no_backup):
                success_count = 1

    logger.info(f"Successfully processed {success_count}/{len(files_to_process)} files")

    return 0 if success_count == len(files_to_process) else 1


if __name__ == "__main__":
    sys.exit(main())
