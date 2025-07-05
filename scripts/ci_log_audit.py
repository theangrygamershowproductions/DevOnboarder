#!/usr/bin/env python
"""Summarize common errors from CI logs."""
from __future__ import annotations

import re
import sys
from collections import Counter
from pathlib import Path

PATTERNS = [
    re.compile(r"Traceback"),
    re.compile(r"npm ERR", re.IGNORECASE),
    re.compile(r"ERROR"),
    re.compile(r"FAIL"),
]


def extract_errors(path: Path) -> list[str]:
    """Return lines matching error patterns from ``path``."""
    if not path.exists():
        return []
    matches: list[str] = []
    with path.open() as handle:
        for line in handle:
            if any(p.search(line) for p in PATTERNS):
                matches.append(line.strip())
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
