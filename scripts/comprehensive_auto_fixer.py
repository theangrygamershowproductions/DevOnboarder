#!/usr/bin/env python3
"""
DevOnboarder Comprehensive Auto-Fixer

Integrates all auto-fixing capabilities for comprehensive quality control.
Automatically fixes common issues across different file types.

Features:
- Markdown formatting (markdownlint compliance)
- Shell script improvements (shellcheck compliance)
- Python code formatting integration
- Centralized logging and reporting
- Integration with DevOnboarder QC system

Usage:
    python scripts/comprehensive_auto_fixer.py --markdown docs/
    python scripts/comprehensive_auto_fixer.py --shell scripts/
    python scripts/comprehensive_auto_fixer.py --all
    python scripts/comprehensive_auto_fixer.py --pre-commit

Part of DevOnboarder's automated quality control system.
"""

import argparse
import subprocess
import sys
from pathlib import Path
from typing import List, Dict, Any


def setup_logging()  None:
    """Set up centralized logging per DevOnboarder standards."""
    import logging

    # Create logs directory if it doesn't exist
    logs_dir = Path("logs")
    logs_dir.mkdir(exist_ok=True)

    # Set up logging to centralized location
    log_file = logs_dir / "comprehensive_auto_fixer.log"
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[logging.FileHandler(log_file), logging.StreamHandler()],
    )


def run_subprocess(cmd: List[str], description: str)  Dict[str, Any]:
    """
    Run a subprocess and return results.

    Parameters
    ----------
    cmd : List[str]
        Command to run
    description : str
        Description for logging

    Returns
    -------
    Dict[str, Any]
        Results including returncode, stdout, stderr
    """
    import logging

    logger = logging.getLogger(__name__)

    logger.info("Running: %s", description)
    logger.debug("Command: %s", " ".join(cmd))

    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=300  # 5 minute timeout
        )

        return {
            "success": result.returncode == 0,
            "returncode": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "description": description,
        }
    except subprocess.TimeoutExpired:
        logger.error("Command timed out: %s", description)
        return {
            "success": False,
            "returncode": -1,
            "stdout": "",
            "stderr": "Command timed out",
            "description": description,
        }
    except Exception as e:
        logger.error("Error running command %s: %s", description, e)
        return {
            "success": False,
            "returncode": -1,
            "stdout": "",
            "stderr": str(e),
            "description": description,
        }


def fix_markdown_files(paths: List[str], dry_run: bool = False)  bool:
    """Fix markdown files using our markdown auto-fixer."""
    cmd = [sys.executable, "scripts/fix_markdown_formatting.py"]
    if dry_run:
        cmd.append("--dry-run")
    cmd.extend(paths)

    result = run_subprocess(cmd, "Fix markdown formatting")
    return result["success"]


def fix_shell_scripts(paths: List[str], dry_run: bool = False)  bool:
    """Fix shell scripts using our shell script auto-fixer."""
    cmd = [sys.executable, "scripts/fix_shell_scripts.py"]
    if dry_run:
        cmd.append("--dry-run")
    cmd.extend(paths)

    result = run_subprocess(cmd, "Fix shell script issues")
    return result["success"]


def fix_frontmatter(paths: List[str], dry_run: bool = False)  bool:
    """Fix frontmatter using our frontmatter auto-fixer."""
    cmd = [sys.executable, "scripts/fix_frontmatter.py"]
    if dry_run:
        cmd.append("--dry-run")
    cmd.extend(paths)

    result = run_subprocess(cmd, "Fix frontmatter metadata")
    return result["success"]


def run_python_formatters(dry_run: bool = False)  bool:
    """Run Python formatters (black, ruff)."""
    import logging

    logger = logging.getLogger(__name__)

    success = True

    # Run black
    black_cmd = [sys.executable, "-m", "black"]
    if dry_run:
        black_cmd.append("--check")
    black_cmd.extend(["--line-length=88", "--target-version=py312", "src/", "scripts/"])

    result = run_subprocess(black_cmd, "Black code formatting")
    if not result["success"]:
        logger.warning("Black formatting issues found")
        success = False

    # Run ruff
    ruff_cmd = [sys.executable, "-m", "ruff", "check"]
    if not dry_run:
        ruff_cmd.append("--fix")
    ruff_cmd.extend(["src/", "scripts/"])

    result = run_subprocess(ruff_cmd, "Ruff linting and fixes")
    if not result["success"]:
        logger.warning("Ruff linting issues found")
        success = False

    return success


def run_pre_commit_fixes()  bool:
    """Run pre-commit auto-fixes."""
    cmd = ["pre-commit", "run", "--all-files"]
    result = run_subprocess(cmd, "Pre-commit auto-fixes")
    return result["success"]


def generate_report(results: List[Dict[str, Any]])  None:
    """Generate a comprehensive report of all fixes applied."""
    import logging

    logger = logging.getLogger(__name__)

    logger.info("=== DevOnboarder Auto-Fixer Report ===")

    successful_fixes = [r for r in results if r["success"]]
    failed_fixes = [r for r in results if not r["success"]]

    logger.info("Successful fixes: %d", len(successful_fixes))
    for fix in successful_fixes:
        logger.info("   %s", fix["description"])

    if failed_fixes:
        logger.warning("Failed fixes: %d", len(failed_fixes))
        for fix in failed_fixes:
            logger.warning("   %s", fix["description"])
            if fix["stderr"]:
                logger.warning("     Error: %s", fix["stderr"])

    logger.info("=== Report Complete ===")


def main()  int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="DevOnboarder Comprehensive Auto-Fixer",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )

    parser.add_argument(
        "--markdown", nargs="*", help="Fix markdown files in specified paths"
    )

    parser.add_argument(
        "--shell", nargs="*", help="Fix shell scripts in specified paths"
    )

    parser.add_argument(
        "--frontmatter", nargs="*", help="Fix frontmatter metadata in specified paths"
    )

    parser.add_argument(
        "--python", action="store_true", help="Run Python formatters (black, ruff)"
    )

    parser.add_argument(
        "--pre-commit", action="store_true", help="Run pre-commit auto-fixes"
    )

    parser.add_argument(
        "--all", action="store_true", help="Run all auto-fixers on entire repository"
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be changed without making changes",
    )

    args = parser.parse_args()

    # Set up logging
    setup_logging()
    import logging

    logger = logging.getLogger(__name__)

    logger.info("Starting DevOnboarder Comprehensive Auto-Fixer")

    results = []

    if args.all:
        # Run all fixers on entire repository
        logger.info("Running all auto-fixers on entire repository")

        # Fix markdown files
        if fix_markdown_files(["--all"], args.dry_run):
            results.append(
                {"success": True, "description": "Markdown formatting (all files)"}
            )
        else:
            results.append(
                {
                    "success": False,
                    "description": "Markdown formatting (all files)",
                    "stderr": "",
                }
            )

        # Fix shell scripts
        if fix_shell_scripts(["--all"], args.dry_run):
            results.append(
                {"success": True, "description": "Shell script fixes (all files)"}
            )
        else:
            results.append(
                {
                    "success": False,
                    "description": "Shell script fixes (all files)",
                    "stderr": "",
                }
            )

        # Fix frontmatter metadata
        if fix_frontmatter(["--all"], args.dry_run):
            results.append(
                {
                    "success": True,
                    "description": "Frontmatter metadata fixes (all files)",
                }
            )
        else:
            results.append(
                {
                    "success": False,
                    "description": "Frontmatter metadata fixes (all files)",
                    "stderr": "",
                }
            )

        # Run Python formatters
        if run_python_formatters(args.dry_run):
            results.append(
                {"success": True, "description": "Python formatting (black, ruff)"}
            )
        else:
            results.append(
                {
                    "success": False,
                    "description": "Python formatting (black, ruff)",
                    "stderr": "",
                }
            )

        # Run pre-commit
        if not args.dry_run:
            if run_pre_commit_fixes():
                results.append(
                    {"success": True, "description": "Pre-commit auto-fixes"}
                )
            else:
                results.append(
                    {
                        "success": False,
                        "description": "Pre-commit auto-fixes",
                        "stderr": "",
                    }
                )

    else:
        # Run specific fixers
        if args.markdown is not None:
            paths = args.markdown if args.markdown else ["--all"]
            if fix_markdown_files(paths, args.dry_run):
                results.append(
                    {"success": True, "description": f"Markdown formatting ({paths})"}
                )
            else:
                results.append(
                    {
                        "success": False,
                        "description": f"Markdown formatting ({paths})",
                        "stderr": "",
                    }
                )

        if args.shell is not None:
            paths = args.shell if args.shell else ["--all"]
            if fix_shell_scripts(paths, args.dry_run):
                results.append(
                    {"success": True, "description": f"Shell script fixes ({paths})"}
                )
            else:
                results.append(
                    {
                        "success": False,
                        "description": f"Shell script fixes ({paths})",
                        "stderr": "",
                    }
                )

        if args.frontmatter is not None:
            paths = args.frontmatter if args.frontmatter else ["--all"]
            if fix_frontmatter(paths, args.dry_run):
                results.append(
                    {"success": True, "description": f"Frontmatter fixes ({paths})"}
                )
            else:
                results.append(
                    {
                        "success": False,
                        "description": f"Frontmatter fixes ({paths})",
                        "stderr": "",
                    }
                )

        if args.python:
            if run_python_formatters(args.dry_run):
                results.append(
                    {"success": True, "description": "Python formatting (black, ruff)"}
                )
            else:
                results.append(
                    {
                        "success": False,
                        "description": "Python formatting (black, ruff)",
                        "stderr": "",
                    }
                )

        if args.pre_commit:
            if run_pre_commit_fixes():
                results.append(
                    {"success": True, "description": "Pre-commit auto-fixes"}
                )
            else:
                results.append(
                    {
                        "success": False,
                        "description": "Pre-commit auto-fixes",
                        "stderr": "",
                    }
                )

        if not any(
            [
                args.markdown is not None,
                args.shell is not None,
                args.python,
                args.pre_commit,
            ]
        ):
            logger.error("No fixers specified. Use --all or specify individual fixers.")
            parser.print_help()
            return 1

    # Generate report
    generate_report(results)

    # Return appropriate exit code
    failed_count = len([r for r in results if not r["success"]])
    if failed_count > 0:
        logger.warning("Completed with %d failures", failed_count)
        return 1
    else:
        logger.info("All auto-fixes completed successfully")
        return 0


if __name__ == "__main__":
    sys.exit(main())
