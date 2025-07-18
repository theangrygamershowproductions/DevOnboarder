#!/usr/bin/env python
"""Summarize common errors from CI logs."""
from __future__ import annotations

import re
import sys
from collections import Counter
from pathlib import Path

PATTERNS = [
    re.compile(r"Traceback"),
    re.compile(r"AssertionError"),
    re.compile(r"ModuleNotFoundError"),
    re.compile(r"npm ERR", re.IGNORECASE),
    re.compile(r"yarn.*err", re.IGNORECASE),
    re.compile(r"error Command failed", re.IGNORECASE),
    re.compile(r"Cannot find module", re.IGNORECASE),
    re.compile(r"ERROR"),
    re.compile(r"FAIL"),
]


def extract_errors(path: Path) -> list[str]:
    """Return lines matching error patterns from ``path`` with context."""
    if not path.exists():
        return []

    matches: list[str] = []
    prev_line = ""
    with path.open() as handle:
        for line in handle:
            stripped = line.strip()
            if any(p.search(stripped) for p in PATTERNS):
                if prev_line:
                    matches.append(f"{prev_line} | {stripped}")
                else:
                    matches.append(stripped)
            else:
                prev_line = stripped
    return matches


def main() -> None:
    files = [Path(p) for p in sys.argv[1:]]
    if not files:
        files = [Path("ci.log")]

    counts: Counter[str] = Counter()
    for file in files:
        counts.update(extract_errors(file))

    if not counts:
        print("No error patterns found.")
        return

    print("# CI Log Audit\n")
    for line, count in counts.most_common(20):
        prefix = f"{count}x" if count > 1 else "-"
        print(f"{prefix} {line}")


if __name__ == "__main__":
    main()
