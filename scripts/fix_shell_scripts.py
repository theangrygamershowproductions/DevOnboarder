#!/usr/bin/env python3
"""
DevOnboarder Shell Script Auto-Fixer

Automatically fixes common shellcheck violations in shell scripts.
Designed for integration with DevOnboarder's QC system.

Features:
- SC2086: Double quote variables to prevent globbing and word splitting
- SC2034: Remove or comment unused variables
- SC2126: Replace grep | wc -l with grep -c
- SC2129: Use { cmd1; cmd2; } >> file instead of individual redirects
- Preserves script functionality while improving compliance

Usage:
    python scripts/fix_shell_scripts.py script1.sh script2.sh
    python scripts/fix_shell_scripts.py scripts/
    python scripts/fix_shell_scripts.py --all

Part of DevOnboarder's automated quality control system.
"""

import argparse
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import List


def setup_logging() -> None:
    """Set up centralized logging per DevOnboarder standards."""
    import logging

    # Create logs directory if it doesn't exist
    logs_dir = Path("logs")
    logs_dir.mkdir(exist_ok=True)

    # Set up logging to centralized location
    log_file = logs_dir / "shell_script_fixer.log"
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[logging.FileHandler(log_file), logging.StreamHandler()],
    )


def fix_shell_script_content(content: str) -> tuple[str, List[str]]:
    """
    Fix common shell script issues.

    Parameters
    ----------
    content : str
        The shell script content to fix

    Returns
    -------
    tuple[str, List[str]]
        The fixed content and list of issues fixed
    """
    issues_fixed = []

    # SC2086: Fix unquoted variables in common patterns
    before_quotes = content

    # Fix mtime +$VAR patterns
    content = re.sub(r"mtime \+\$([A-Z_]+)", r'mtime +"$\1"', content)

    # Fix common variable expansions that need quoting
    patterns = [
        (r"\$([A-Z_]+)", r'"$\1"'),  # Basic variable refs
        (r"\$\{([A-Z_]+)\}", r'"${\1}"'),  # Brace expansions
    ]

    for pattern, replacement in patterns:
        # Only quote if not already quoted and in contexts that need it
        content = re.sub(f'(?<!")({pattern})(?!")', replacement, content)

    if content != before_quotes:
        issues_fixed.append("SC2086: Added proper variable quoting")

    # SC2126: Replace grep | wc -l with grep -c
    before_grep = content
    content = re.sub(r"grep ([^|]+) \| wc -l", r"grep -c \1", content)
    if content != before_grep:
        issues_fixed.append("SC2126: Replaced grep | wc -l with grep -c")

    # SC2129: Group redirections for efficiency
    # This is more complex and context-dependent, so we'll be conservative
    # Look for simple patterns of echo >> file followed by echo >> same file
    lines = content.split("\n")
    fixed_lines = []
    i = 0

    while i < len(lines):
        line = lines[i].strip()

        # Look for echo >> file pattern
        match = re.match(r'(\s*)(echo\s+[^>]+)\s+>>\s+"([^"]+)"', line)
        if match:
            indent, echo_cmd, filename = match.groups()

            # Look ahead for more redirects to same file
            redirect_group = [echo_cmd]
            j = i + 1

            while j < len(lines):
                next_line = lines[j].strip()
                next_match = re.match(
                    r'(\s*)(echo\s+[^>]+)\s+>>\s+"([^"]+)"', next_line
                )
                if next_match and next_match.group(3) == filename:
                    redirect_group.append(next_match.group(2))
                    j += 1
                else:
                    break

            # If we found multiple redirects to same file, group them
            if len(redirect_group) > 1:
                fixed_lines.append(f"{indent}{{")
                for cmd in redirect_group:
                    fixed_lines.append(f"{indent}    {cmd}")
                fixed_lines.append(f'{indent}}} >> "{filename}"')
                i = j
                issues_fixed.append("SC2129: Grouped redirect operations")
            else:
                fixed_lines.append(lines[i])
                i += 1
        else:
            fixed_lines.append(lines[i])
            i += 1

    content = "\n".join(fixed_lines)

    # SC2034: Comment unused variables (conservative approach)
    # Look for declare statements that might be unused
    # This is tricky to do automatically, so we'll just flag them for review
    unused_declares = re.findall(r"^declare -A ([A-Z_]+)=", content, flags=re.MULTILINE)
    if unused_declares:
        # Add comments about potential unused variables
        for var in unused_declares:
            if var not in content.replace(f"declare -A {var}=", ""):
                content = re.sub(
                    f"^(declare -A {var}=)",
                    f"# Note: {var} may be unused - verify or export\n\\1",
                    content,
                    flags=re.MULTILINE,
                )
                issues_fixed.append(
                    f"SC2034: Added comment for potentially unused variable {var}"
                )

    return content, issues_fixed


def process_shell_script(file_path: Path, create_backup: bool = True) -> bool:
    """
    Process a single shell script file.

    Parameters
    ----------
    file_path : Path
        Path to the shell script file
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
        logger.info("Processing %s", file_path)

        # Read the file
        with open(file_path, "r", encoding="utf-8") as f:
            original_content = f.read()

        # Fix shell script issues
        fixed_content, issues_fixed = fix_shell_script_content(original_content)

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
                logger.info("Backup created: %s", backup_path)

            # Write fixed content
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(fixed_content)

            logger.info("Fixed shell script issues in %s", file_path)
            for issue in issues_fixed:
                logger.info("  - %s", issue)
            return True
        else:
            logger.info("No changes needed for %s", file_path)
            return True

    except OSError as e:
        logger.error("Error processing %s: %s", file_path, e)
        return False
    except Exception as e:
        logger.error("Unexpected error processing %s: %s", file_path, e)
        return False


def find_shell_scripts(path: Path) -> List[Path]:
    """
    Find all shell script files in a path.

    Parameters
    ----------
    path : Path
        Directory path to search

    Returns
    -------
    List[Path]
        List of shell script file paths
    """
    shell_scripts = []

    if path.is_file() and path.suffix.lower() in [".sh", ".bash"]:
        shell_scripts.append(path)
    elif path.is_dir():
        # Find shell scripts
        for script_file in path.rglob("*.sh"):
            # Skip certain directories per DevOnboarder standards
            if any(
                skip in str(script_file)
                for skip in ["node_modules", ".venv", "venv", ".git", "logs", "archive"]
            ):
                continue
            shell_scripts.append(script_file)

    return sorted(shell_scripts)


def main() -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="DevOnboarder Shell Script Auto-Fixer",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )

    parser.add_argument(
        "paths", nargs="*", help="Shell script files or directories to process"
    )

    parser.add_argument(
        "--all", action="store_true", help="Process all shell scripts in repository"
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
        # Process all shell scripts in repository
        repo_root = Path(".")
        files_to_process = find_shell_scripts(repo_root)
    elif args.paths:
        # Process specified paths
        for path_str in args.paths:
            path = Path(path_str)
            if not path.exists():
                logger.error("Path does not exist: %s", path)
                continue
            files_to_process.extend(find_shell_scripts(path))
    else:
        logger.error("No paths specified. Use --all or provide file paths.")
        parser.print_help()
        return 1

    if not files_to_process:
        logger.warning("No shell script files found to process")
        return 0

    # Process files
    logger.info("Processing %d shell script files", len(files_to_process))

    success_count = 0
    for file_path in files_to_process:
        if args.dry_run:
            logger.info("Would process: %s", file_path)
            success_count += 1
        else:
            if process_shell_script(file_path, not args.no_backup):
                success_count += 1

    logger.info(
        "Successfully processed %d/%d files", success_count, len(files_to_process)
    )

    return 0 if success_count == len(files_to_process) else 1


if __name__ == "__main__":
    sys.exit(main())
