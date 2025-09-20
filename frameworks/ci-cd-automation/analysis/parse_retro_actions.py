#!/usr/bin/env python
"""Extract open retrospective action items and owners."""
from __future__ import annotations

import argparse
import re
from pathlib import Path

ACTION_RE = re.compile(r"^\s*-\s*\[\s*\]\s*(.*)")
USER_RE = re.compile(r"@[A-Za-z0-9_-]+")


def parse_actions(directory: Path) -> list[str]:
    """Return unresolved action item lines under ``directory``."""
    actions: list[str] = []
    for file in sorted(directory.glob("*.md")):
        for line in file.read_text(encoding="utf-8").splitlines():
            if ACTION_RE.match(line):
                actions.append(f"{file}:{line}")
    return actions


def extract_usernames(actions: list[str]) -> list[str]:
    """Return unique GitHub usernames mentioned in ``actions``."""
    users = set()
    for line in actions:
        users.update(USER_RE.findall(line))
    return sorted(users)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "path",
        nargs="?",
        default="docs/checklists/retros",
        help="Directory containing retrospective files",
    )
    parser.add_argument(
        "--owners",
        action="store_true",
        help="Print unique GitHub usernames instead of action lines",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print actions and owners for validation and exit",
    )
    args = parser.parse_args(argv)

    actions = parse_actions(Path(args.path))
    output = extract_usernames(actions) if args.owners else actions
    if output:
        print("\n".join(output))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
