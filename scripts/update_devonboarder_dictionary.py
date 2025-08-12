#!/usr/bin/env python3
"""Update DevOnboarder project dictionary for spell checking and technical.

This script manages the .codespell-ignore file for DevOnboarder-specific
terminology, technical terms, and project-specific words. It follows the
project's "quiet reliability" philosophy with comprehensive logging and
virtual environment integration.

Usage:
    python scripts/update_devonboarder_dictionary.py [options]

Options:
    --add WORD     Add a word to the dictionary
    --remove WORD  Remove a word from the dictionary
    --audit        Show dictionary analysis
    --core         Add missing core DevOnboarder terms

Examples:
    # Add a new technical term
    python scripts/update_devonboarder_dictionary.py --add "FastAPI"

    # Remove an outdated term
    python scripts/update_devonboarder_dictionary.py --remove "oldterm"

    # Audit current dictionary and generate report
    python scripts/update_devonboarder_dictionary.py --audit

    # Interactive mode for bulk updates
    python scripts/update_devonboarder_dictionary.py

Requirements:
    - Virtual environment must be activated (.venv)
    - Project dependencies installed: pip install -e .[test]
    - Write access to .codespell-ignore file
"""

from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Set

# DevOnboarder project standards
PROJECT_ROOT = Path(__file__).parent.parent
CODESPELL_IGNORE_FILE = PROJECT_ROOT / ".codespell-ignore"
LOGS_DIR = PROJECT_ROOT / "logs"
LOG_FILE = LOGS_DIR / (
    f"dictionary_update_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
)

# DevOnboarder-specific technical terms that should always be in dictionary
DEVONBOARDER_CORE_TERMS = {
    # Project identity
    "DevOnboarder",
    "DevOnboarder's",
    "theangrygamershowproductions",
    # Technology stack
    "FastAPI",
    "SQLAlchemy",
    "Discord.js",
    "TypeScript",
    "PostgreSQL",
    "JWT",
    "OAuth",
    "CORS",
    "WebSocket",
    "webhook",
    "webhooks",
    # DevOps/CI terms
    "devcontainer",
    "devcontainers",
    "pytest",
    "pyproject",
    "markdownlint",
    "codespell",
    "pre-commit",
    "GitHub",
    "GitLab",
    "Docker",
    "Dockerfile",
    "containerization",
    "YAML",
    "TOML",
    "JSON",
    "regex",
    "argv",
    "env",
    "venv",
    "virtualenv",
    "pip",
    "npm",
    "npx",
    "mise",
    "nodeenv",
    "pyenv",
    # Discord/Gaming
    "Discord",
    "bot",
    "bots",
    "guilds",
    "ephemeral",
    "slash",
    "gamification",
    "XP",
    # Security/Potato Policy terms
    "Potato",
    "Potato.md",
    "pem",
    "ssh",
    "keys",
    "secrets",
    "configuration",
    "configurations",
    # Development workflow
    "PR",
    "PRs",
    "CI",
    "CD",
    "linting",
    "formatter",
    "formatters",
    "linter",
    "linters",
    "ESLint",
    "Prettier",
    "Ruff",
    "mypy",
    "Vale",
    "LanguageTool",
    "changelog",
    "changelogs",
    "retro",
    "retros",
    "retrospective",
    "KPI",
    "KPIs",
    "SLA",
    "SLAs",
    "API",
    "endpoint",
    "endpoints",
    "middleware",
    "auth",
    "unauth",
    "unauthorized",
    "frontend",
    "backend",
    "fullstack",
    "codebase",
    "repo",
    "repos",
    "repository",
    "workflow",
    "workflows",
    # Technical acronyms
    "HTTP",
    "HTTPS",
    "URL",
    "URLs",
    "URI",
    "URIs",
    "UUID",
    "UUIDs",
    "XML",
    "HTML",
    "CSS",
    "JS",
    "TS",
    "SQL",
    "NoSQL",
    "CRUD",
    "REST",
    "RESTful",
    "GraphQL",
    "SDK",
    "CLI",
    "GUI",
    "UI",
    "UX",
    "SPA",
    "SSR",
    "CSR",
    "SEO",
    "CDN",
    "DNS",
    "SSL",
    "TLS",
    "MFA",
    "2FA",
    "RBAC",
    "ACL",
    # Organization roles (from agent system)
    "COO",
    "CEO",
    "CTO",
    "CFO",
    "CMO",
    "CHRO",
    "DevSecOps",
    "SRE",
    "QA",
    "DevOps",
    # File extensions and patterns
    "md",
    "py",
    "js",
    "ts",
    "jsx",
    "tsx",
    "yml",
    "yaml",
    "toml",
    "json",
    "envfile",
    "gitignore",
    "dockerignore",
    "dockerfile",
    "makefile",
    "requirements",
    # Common technical abbreviations
    "arg",
    "args",
    "kwargs",
    "params",
    "util",
    "utils",
    "lib",
    "libs",
    "deps",
    "dev",
    "prod",
    "staging",
    "localhost",
    "enum",
    "enums",
    "bool",
    "str",
    "int",
    "float",
    "dict",
    "list",
    "tuple",
    "async",
    "await",
    "sync",
    "TODO",
    "FIXME",
    "NOTE",
    "WARNING",
    "ERROR",
    "INFO",
    "DEBUG",
}

# Protected file patterns that should never be spell-checked
PROTECTED_PATTERNS = {
    "*.env*",
    "*.key",
    "*.pem",
    "*.p12",
    "Potato.md",
    "secrets.*",
    "auth.db",
    ".codex/private/*",
    ".codex/cache/*",
    "id_rsa*",
    "nodeenv",
    "pyenv",
    "secrets.yaml",
    "secrets.yml",
    "webhook-config.json",
    ".codex/private/",
    ".codex/cache/",
}


def ensure_virtual_environment() -> None:
    """Ensure script is running in virtual environment (DevOnboarder req)."""
    if not os.environ.get("VIRTUAL_ENV"):
        print("FAILED ERROR: Virtual environment not detected")
        print("CONFIG SOLUTION: Activate virtual environment first:")
        print("   source .venv/bin/activate")
        print("   pip install -e .[test]")
        sys.exit(1)

    # Verify we can import project dependencies
    try:
        # Simple check to verify Python environment is working
        import pathlib  # Standard library check

        pathlib.Path(".")  # Basic test
    except ImportError:
        print("FAILED ERROR: Python environment not properly configured")
        print("CONFIG SOLUTION: Install dependencies:")
        print("   pip install -e .[test]")
        sys.exit(1)


def setup_logging() -> None:
    """Setup logging directory and file (DevOnboarder logging standards)."""
    LOGS_DIR.mkdir(exist_ok=True)


def log_message(message: str, level: str = "INFO") -> None:
    """Log message to file and optionally print to console."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_entry = f"[{timestamp}] [{level}] {message}\n"

    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(log_entry)

    if level in ["ERROR", "WARNING"]:
        print(f"SEARCH {level}: {message}")


def load_current_dictionary() -> Set[str]:
    """Load current .codespell-ignore entries."""
    if not CODESPELL_IGNORE_FILE.exists():
        log_message("No .codespell-ignore file found, creating new one", "WARNING")
        return set()

    with open(CODESPELL_IGNORE_FILE, "r", encoding="utf-8") as f:
        lines = f.readlines()

    # Separate file patterns from word entries
    entries = set()
    for line in lines:
        line = line.strip()
        if line and not line.startswith("#"):
            entries.add(line)

    log_message(f"Loaded {len(entries)} entries from .codespell-ignore")
    return entries


def save_dictionary(entries: Set[str]) -> None:
    """Save entries back to .codespell-ignore with DevOnboarder formatting."""
    # Separate file patterns from words
    file_patterns = set()
    words = set()

    for entry in entries:
        has_special_chars = any(char in entry for char in ["*", "/", "."])
        is_not_simple_word = not (entry.replace(".", "").replace("_", "").isalnum())
        if has_special_chars and is_not_simple_word:
            file_patterns.add(entry)
        else:
            words.add(entry)

    with open(CODESPELL_IGNORE_FILE, "w", encoding="utf-8") as f:
        f.write("# DevOnboarder Codespell Ignore List\n")
        f.write("# This file contains project-specific terms and file patterns\n")
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        f.write(f"# Last updated: {timestamp}\n")
        f.write("#\n")
        f.write("# Protected file patterns (Potato Policy compliance)\n")

        for pattern in sorted(file_patterns):
            f.write(f"{pattern}\n")

        f.write("#\n")
        f.write("# Technical terms and project-specific words\n")

        for word in sorted(words):
            f.write(f"{word}\n")

    log_message(f"Saved {len(entries)} entries to .codespell-ignore")


def audit_dictionary() -> Dict[str, Any]:
    """Audit current dictionary and return analysis."""
    current_entries = load_current_dictionary()

    missing_core_terms = DEVONBOARDER_CORE_TERMS - current_entries
    extra_terms = current_entries - DEVONBOARDER_CORE_TERMS - PROTECTED_PATTERNS

    # Count categories
    file_patterns = {
        e for e in current_entries if any(char in e for char in ["*", "/"])
    }
    words = current_entries - file_patterns

    analysis = {
        "total_entries": len(current_entries),
        "file_patterns": len(file_patterns),
        "words": len(words),
        "missing_core_terms": missing_core_terms,
        "extra_terms": extra_terms,
        "protected_patterns_count": len(file_patterns & PROTECTED_PATTERNS),
    }

    log_message(f"Dictionary audit completed: {analysis['total_entries']} entries")
    return analysis


def print_audit_report(analysis: Dict[str, Any]) -> None:
    """Print comprehensive audit report."""
    print("\nSTATS DevOnboarder Dictionary Audit Report")
    print("=" * 50)
    print(f"EDIT Total entries: {analysis['total_entries']}")
    print(f"FOLDER File patterns: {analysis['file_patterns']}")
    print(f"SYMBOL Word entries: {analysis['words']}")
    print(f"SYMBOL Protected patterns: {analysis['protected_patterns_count']}")

    if analysis["missing_core_terms"]:
        missing_count = len(analysis["missing_core_terms"])
        print(f"\nWARNING  Missing {missing_count} core DevOnboarder terms:")
        # Show first 10
        for term in sorted(analysis["missing_core_terms"])[:10]:
            print(f"   • {term}")
        if len(analysis["missing_core_terms"]) > 10:
            remaining = len(analysis["missing_core_terms"]) - 10
            print(f"   ... and {remaining} more")

    if analysis["extra_terms"]:
        extra_count = len(analysis["extra_terms"])
        print(f"\nSYMBOL {extra_count} additional project terms found")

    print(f"\nSTATS Log file: {LOG_FILE}")


def add_core_terms() -> int:
    """Add all missing DevOnboarder core terms."""
    current_entries = load_current_dictionary()
    missing_terms = DEVONBOARDER_CORE_TERMS - current_entries

    if not missing_terms:
        log_message("All core DevOnboarder terms already present")
        return 0

    updated_entries = current_entries | missing_terms
    save_dictionary(updated_entries)

    log_message(f"Added {len(missing_terms)} missing core terms")
    return len(missing_terms)


def add_term(term: str) -> bool:
    """Add a single term to dictionary."""
    current_entries = load_current_dictionary()

    if term in current_entries:
        log_message(f"Term '{term}' already in dictionary", "WARNING")
        return False

    current_entries.add(term)
    save_dictionary(current_entries)

    log_message(f"Added term: {term}")
    return True


def remove_term(term: str) -> bool:
    """Remove a term from dictionary (with protection for core terms)."""
    current_entries = load_current_dictionary()

    if term not in current_entries:
        log_message(f"Term '{term}' not found in dictionary", "WARNING")
        return False

    if term in DEVONBOARDER_CORE_TERMS:
        log_message(f"Cannot remove core DevOnboarder term: {term}", "ERROR")
        return False

    current_entries.remove(term)
    save_dictionary(current_entries)

    log_message(f"Removed term: {term}")
    return True


def interactive_mode() -> None:
    """Interactive mode for bulk dictionary management."""
    print("\nCONFIG DevOnboarder Dictionary Interactive Mode")
    print("Commands: add <term>, remove <term>, audit, core, quit")

    while True:
        try:
            command = input("\nEDIT Dictionary > ").strip().lower()

            if command == "quit" or command == "q":
                break
            elif command == "audit":
                analysis = audit_dictionary()
                print_audit_report(analysis)
            elif command == "core":
                added = add_core_terms()
                print(f"SUCCESS Added {added} core DevOnboarder terms")
            elif command.startswith("add "):
                term = command[4:].strip()
                if add_term(term):
                    print(f"SUCCESS Added: {term}")
                else:
                    print(f"WARNING  Already exists: {term}")
            elif command.startswith("remove "):
                term = command[7:].strip()
                if remove_term(term):
                    print(f"SYMBOL  Removed: {term}")
                else:
                    print(f"FAILED Cannot remove: {term}")
            elif command == "help" or command == "?":
                print("Available commands:")
                print("  add <term>    - Add a term to dictionary")
                print("  remove <term> - Remove a term from dictionary")
                print("  audit         - Show dictionary analysis")
                print("  core          - Add missing core DevOnboarder terms")
                print("  quit          - Exit interactive mode")
            else:
                print("SYMBOL Unknown command. Type 'help' for available commands.")

        except (KeyboardInterrupt, EOFError):
            print("\nSYMBOL Goodbye!")
            break
        except (OSError, IOError, ValueError) as e:
            log_message(f"Interactive mode error: {e}", "ERROR")
            print(f"FAILED Error: {e}")


def main() -> None:
    """Main entry point following DevOnboarder script patterns."""
    parser = argparse.ArgumentParser(
        description=("Update DevOnboarder project dictionary for spell checking"),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --audit                    # Show dictionary analysis
  %(prog)s --add "FastAPI"           # Add technical term
  %(prog)s --remove "oldterm"        # Remove outdated term
  %(prog)s --core                    # Add missing core terms
  %(prog)s                           # Interactive mode

DevOnboarder Requirements:
  • Virtual environment must be activated (.venv)
  • Project dependencies installed (pip install -e .[test])
  • Follows "quiet reliability" philosophy with comprehensive logging
        """,
    )

    parser.add_argument("--add", metavar="TERM", help="Add a term to dictionary")
    parser.add_argument(
        "--remove", metavar="TERM", help="Remove a term from dictionary"
    )
    parser.add_argument("--audit", action="store_true", help="Audit current dictionary")
    parser.add_argument("--core", action="store_true", help="Add missing core terms")

    args = parser.parse_args()

    # DevOnboarder standards: Always check virtual environment
    ensure_virtual_environment()
    setup_logging()

    log_message("DevOnboarder dictionary update session started")

    try:
        if args.audit:
            analysis = audit_dictionary()
            print_audit_report(analysis)
        elif args.add:
            if add_term(args.add):
                print(f"SUCCESS Added term: {args.add}")
            else:
                print(f"WARNING  Term already exists: {args.add}")
        elif args.remove:
            if remove_term(args.remove):
                print(f"SYMBOL  Removed term: {args.remove}")
            else:
                print(f"FAILED Cannot remove term: {args.remove}")
        elif args.core:
            added = add_core_terms()
            print(f"SUCCESS Added {added} missing core DevOnboarder terms")
            if added > 0:
                print("IDEA Run --audit to see updated statistics")
        else:
            # No arguments: enter interactive mode
            interactive_mode()

    except (OSError, IOError, ValueError) as e:
        log_message(f"Script error: {e}", "ERROR")
        print(f"FAILED Error: {e}")
        print(f"STATS Check log: {LOG_FILE}")
        sys.exit(1)

    log_message("DevOnboarder dictionary update session completed")
    print(f"STATS Session log: {LOG_FILE}")


if __name__ == "__main__":
    main()
