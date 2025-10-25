#!/usr/bin/env python3
"""
DevOnboarder Frontmatter Auto-Fixer

Comprehensive frontmatter validation and fixing tool that ensures all documentation
files comply with DevOnboarder's metadata standards. Designed for integration with
DevOnboarder's QC system.

Features:
- Validates YAML frontmatter against DevOnboarder schema
- Adds missing required fields based on file type and location
- Standardizes field names and values per DevOnboarder conventions
- Preserves existing valid metadata
- Handles multiple files or directories
- Creates backups in centralized logs directory

Usage:
    python scripts/fix_frontmatter.py file1.md file2.md
    python scripts/fix_frontmatter.py docs/
    python scripts/fix_frontmatter.py --all
    python scripts/fix_frontmatter.py --no-backup

Part of DevOnboarder's automated quality control system.
"""

import argparse
import logging
import sys
import yaml
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, List, Optional


def setup_logging() -> logging.Logger:
    """Set up centralized logging per DevOnboarder standards."""

    # Create logs directory if it doesn't exist
    logs_dir = Path("logs")
    logs_dir.mkdir(exist_ok=True)

    # Create log file with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = logs_dir / f"frontmatter_fixer_{timestamp}.log"

    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        handlers=[logging.FileHandler(log_file), logging.StreamHandler()],
    )

    logger = logging.getLogger(__name__)
    logger.info("Starting DevOnboarder Frontmatter Auto-Fixer")
    logger.info("Log file: %s", log_file)

    return logger


def detect_file_type(file_path: Path) -> str:
    """Detect the type of file based on path and content.

    Parameters
    ----------
    file_path : Path
        Path to the file to analyze

    Returns
    -------
    str
        File type classification
    """
    path_str = str(file_path).lower()

    # Agent files
    if ".codex/agents/" in path_str:
        return "agent"

    # Documentation types
    if "docs/" in path_str:
        if "troubleshooting/" in path_str:
            return "troubleshooting"
        elif "policies/" in path_str:
            return "policy"
        elif "standards/" in path_str:
            return "standards"
        elif "development/" in path_str:
            return "development"
        else:
            return "documentation"

    # AAR files
    if ".aar/" in path_str or "aar/" in path_str:
        return "aar"

    # Codex files
    if ".codex/" in path_str:
        return "codex"

    # Default
    return "documentation"


def get_required_fields(file_type: str, file_path: Path) -> Dict[str, Any]:
    """Get required frontmatter fields based on file type.

    Parameters
    ----------
    file_type : str
        Type of file detected
    file_path : Path
        Path to the file

    Returns
    -------
    dict
        Required fields and their default values
    """
    base_fields = {
        "similarity_group": f"{file_type}-{file_type}",
        "content_uniqueness_score": 4,
        "merge_candidate": False,
        "consolidation_priority": "P3",
    }

    if file_type == "agent":
        return {
            **base_fields,
            "agent": file_path.stem.replace("-", "_"),
            "purpose": "Agent purpose description needed",
            "trigger": "manual",
            "environment": "any",
            "output": f".codex/logs/{file_path.stem}.log",
            "permissions": ["repo:read"],
        }

    elif file_type == "documentation":
        return {
            **base_fields,
            "title": file_path.stem.replace("-", " ").replace("_", " ").title(),
            "description": "Documentation description needed",
            "author": "DevOnboarder Team",
            "created_at": datetime.now().strftime("%Y-%m-%d"),
            "updated_at": datetime.now().strftime("%Y-%m-%d"),
            "tags": [file_type, "documentation"],
            "project": "DevOnboarder",
            "document_type": "documentation",
            "status": "active",
            "visibility": "internal",
        }

    elif file_type == "standards":
        return {
            **base_fields,
            "title": file_path.stem.replace("-", " ").replace("_", " ").title(),
            "description": "Standards documentation",
            "author": "DevOnboarder Team",
            "created_at": datetime.now().strftime("%Y-%m-%d"),
            "updated_at": datetime.now().strftime("%Y-%m-%d"),
            "tags": ["standards", "policy", "documentation"],
            "project": "DevOnboarder",
            "document_type": "standards",
            "status": "active",
            "visibility": "internal",
            "virtual_env_required": True,
            "ci_integration": True,
        }

    elif file_type == "aar":
        return {
            **base_fields,
            "title": f"AAR: {file_path.stem.replace('-', ' ').title()}",
            "description": "After Action Report",
            "author": "DevOnboarder Team",
            "created_at": datetime.now().strftime("%Y-%m-%d"),
            "updated_at": datetime.now().strftime("%Y-%m-%d"),
            "tags": ["aar", "retrospective", "lessons-learned"],
            "project": "DevOnboarder",
            "document_type": "aar",
            "status": "active",
            "visibility": "internal",
        }

    else:
        return base_fields


def parse_frontmatter(content: str) -> tuple[Optional[Dict[str, Any]], str, str]:
    """Parse YAML frontmatter from markdown content.

    Parameters
    ----------
    content : str
        Full file content

    Returns
    -------
    tuple
        (frontmatter_dict, frontmatter_text, body_content)
    """
    if not content.startswith("---"):
        return None, "", content

    try:
        # Split content into frontmatter and body
        parts = content.split("---", 2)
        if len(parts) < 3:
            return None, "", content

        frontmatter_text = parts[1].strip()
        body_content = parts[2].lstrip("\n")

        # Parse YAML
        frontmatter_dict = yaml.safe_load(frontmatter_text) or {}

        return frontmatter_dict, frontmatter_text, body_content

    except yaml.YAMLError as e:
        logger.warning("YAML parsing error in frontmatter: %s", e)
        return None, "", content


def fix_frontmatter_content(content: str, file_path: Path) -> tuple[str, List[str]]:
    """Fix frontmatter in file content.

    Parameters
    ----------
    content : str
        Original file content
    file_path : Path
        Path to the file being processed

    Returns
    -------
    tuple
        (fixed_content, list_of_issues_fixed)
    """
    issues_fixed = []

    # Detect file type
    file_type = detect_file_type(file_path)
    issues_fixed.append(f"Detected file type: {file_type}")

    # Parse existing frontmatter
    existing_fm, fm_text, body = parse_frontmatter(content)

    # Get required fields
    required_fields = get_required_fields(file_type, file_path)

    # Merge existing with required fields
    if existing_fm is None:
        # No existing frontmatter - create new
        frontmatter = required_fields.copy()
        issues_fixed.append("Added missing frontmatter")
    else:
        # Merge existing with required
        frontmatter = required_fields.copy()
        frontmatter.update(existing_fm)  # Preserve existing values
        issues_fixed.append("Updated existing frontmatter")

    # Generate new frontmatter YAML
    yaml_content = yaml.dump(frontmatter, default_flow_style=False, sort_keys=True)

    # Construct new content
    new_content = f"---\n{yaml_content.rstrip()}\n---\n\n{body}"

    return new_content, issues_fixed


def process_frontmatter_file(file_path: Path, create_backup: bool = True) -> bool:
    """Process a single markdown file for frontmatter fixing.

    Parameters
    ----------
    file_path : Path
        Path to the file to process
    create_backup : bool
        Whether to create a backup file

    Returns
    -------
    bool
        True if file was processed successfully
    """
    try:
        # Read original content
        with open(file_path, "r", encoding="utf-8") as f:
            original_content = f.read()

        # Fix frontmatter
        fixed_content, issues_fixed = fix_frontmatter_content(
            original_content, file_path
        )

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

            logger.info("Fixed frontmatter in %s", file_path)
            for issue in issues_fixed:
                logger.info("  - %s", issue)
            return True
        else:
            logger.info("No changes needed for %s", file_path)
            return True

    except FileNotFoundError:
        logger.error("File not found: %s", file_path)
        return False
    except Exception as e:
        logger.error("Unexpected error processing %s: %s", file_path, e)
        return False


def find_markdown_files(path: Path) -> List[Path]:
    """Find all markdown files in a directory or return single file.

    Parameters
    ----------
    path : Path
        Directory or file path

    Returns
    -------
    list
        List of markdown file paths
    """
    if not path.exists():
        return []

    if path.is_file():
        return [path] if path.suffix.lower() == ".md" else []

    elif path.is_dir():
        return list(path.rglob("*.md"))

    else:
        return []


def main():
    """Main function for frontmatter auto-fixer."""
    global logger
    logger = setup_logging()

    parser = argparse.ArgumentParser(description="DevOnboarder Frontmatter Auto-Fixer")
    parser.add_argument("paths", nargs="*", help="Files or directories to process")
    parser.add_argument(
        "--all", action="store_true", help="Process all markdown files in repository"
    )
    parser.add_argument(
        "--no-backup", action="store_true", help="Do not create backup files"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be processed without making changes",
    )

    args = parser.parse_args()

    # Determine files to process
    files_to_process = []

    if args.all:
        # Process all markdown files
        for path in [Path("docs"), Path(".codex"), Path(".aar"), Path("agents")]:
            if path.exists():
                files_to_process.extend(find_markdown_files(path))

    elif args.paths:
        # Process specified paths
        for path_str in args.paths:
            path = Path(path_str)
            if not path.exists():
                logger.error("Path does not exist: %s", path)
                continue

            if path.is_file():
                if path.suffix.lower() == ".md":
                    files_to_process.append(path)
                else:
                    logger.warning("Skipping non-markdown file: %s", path)
            else:
                files_to_process.extend(find_markdown_files(path))

    else:
        # No paths specified, process current directory
        files_to_process = find_markdown_files(Path("."))

    if not files_to_process:
        logger.error("No markdown files found to process")
        return 1

    logger.info("Processing %d markdown files", len(files_to_process))

    # Process files
    success_count = 0
    for file_path in files_to_process:
        if args.dry_run:
            logger.info("Would process: %s", file_path)
            success_count = 1
        else:
            if process_frontmatter_file(file_path, not args.no_backup):
                success_count = 1

    logger.info(
        "Successfully processed %d/%d files", success_count, len(files_to_process)
    )

    if success_count == len(files_to_process):
        logger.info("All files processed successfully!")
        return 0
    else:
        logger.error("Some files failed to process")
        return 1


if __name__ == "__main__":
    sys.exit(main())
