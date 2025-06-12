"""
inject_metadata_and_log.py

Project: TAGS
Module: Documentation Tools
Phase: Maintenance Automation
Tags: [metadata, markdown, automation, indexing]
Updated: 26 May 2025 22:55 (EST)
Version: v1.2.7
Author: Chad Allan Reesey (Mr. Potato)
Email: education@thenagrygamershow.com

Description:
This script scans all Markdown documents in the local project directory.
If a file is missing the required YAML metadata block, it prepends a default
metadata template (from a local metadata_template.json) and logs the file to
TODO-Documentation-Updates-Required.md for manual review.

Note:
Avoid using raw escape sequences like "\n\" in docstrings. Triple quotes
already support multiline strings without needing escape characters.
"""

from pathlib import Path
from datetime import datetime
import json

# Config
BASE_DIR = Path(".")
OUTPUT_LOG = BASE_DIR / "TODO-Documentation-Updates-Required.md"
METADATA_PATH = Path(__file__).parent / "metadata.json"

# Current time formatted for 'updated' field
now = datetime.now().strftime("%d %B %Y %H:%M (EST)")

# Load metadata from JSON and validate
try:
    with open(METADATA_PATH, "r", encoding="utf-8") as f:
        content = f.read().strip()
        if not content:
            raise ValueError("metadata.json is empty.")
        meta = json.loads(content)
        required_keys = ["project", "module", "phase", "tags", "version"]
        for key in required_keys:
            if key not in meta:
                raise KeyError(f"Missing required key: '{key}'")
except (json.JSONDecodeError, ValueError, KeyError, FileNotFoundError) as e:
    print("❌ metadata.json failed validation or is unreadable.")
    print(f"    Reason: {type(e).__name__} – {e}")
    exit(1)

# Construct default YAML block from JSON + current time
DEFAULT_METADATA = f"""---
project: "{meta['project']}"
module: "{meta['module']}"
phase: "{meta['phase']}"
tags: {json.dumps(meta['tags'])}
updated: "{now}"
version: "{meta['version']}"
author: "{meta.get('author', 'Unknown')}"
email: "{meta.get('email', 'noreply@example.com')}"
description: "{meta.get('description', 'No description provided')}"
---

# {meta['module']} – {meta['phase']}
"""


def has_metadata_block(lines):
    """Check if the given list of lines starts with a YAML metadata block."""
    return lines and lines[0].strip() == "---"


def inject_metadata_if_missing(file_path, log_entries):
    """Injects default metadata into a Markdown file if missing,
    and logs the update in the provided log_entries list."""
    with file_path.open("r", encoding="utf-8") as infile:
        lines = infile.readlines()

    if not has_metadata_block(lines):
        print(f"⚠️  Inserting metadata into: {file_path}")
        new_content = DEFAULT_METADATA + "".join(lines)
        file_path.write_text(new_content, encoding="utf-8")
        rel_path = file_path.relative_to(BASE_DIR)
        log_entries.append(
            f"- [ ] [{file_path.stem}]"
            f"({rel_path.as_posix()}) – default metadata inserted"
        )


def scan_docs_and_inject():
    """Scans the /docs directory for Markdown files,
    injects metadata where needed, and logs any updates.
    Ensures the output log directory exists before writing.
    """
    log_entries = ["# TODO – Documentation Updates Required\n"]

    for md_file in BASE_DIR.rglob("*.md"):
        if md_file.name == OUTPUT_LOG.name:
            continue  # Skip the log file itself
        inject_metadata_if_missing(md_file, log_entries)

        OUTPUT_LOG.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_LOG.write_text("\n".join(log_entries), encoding="utf-8")
    print(f"\n✅ Log written to: {OUTPUT_LOG}")


if __name__ == "__main__":
    scan_docs_and_inject()


__version__ = "1.3.1"
__updated__ = "26 May 2025 23:07 (EST)"
__tags__ = ["metadata", "markdown", "automation", "indexing"]
__project__ = "TAGS"
__module__ = "Documentation Tools"
__phase__ = "Maintenance Automation"
__author__ = "Chad Allan Reesey (Mr. Potato)"
__email__ = "education@thenagrygamershow.com"
# End of inject_metadata_and_log.py
# End of file
