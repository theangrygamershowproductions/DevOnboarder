#!/usr/bin/env python3
"""Validate environment variable docs against .env examples."""

from __future__ import annotations

import re
from pathlib import Path

DOC_PATH = Path("agents/index.md")
ENV_FILES = [
    Path(".env.example"),
    Path("frontend/src/.env.example"),
    Path("bot/.env.example"),
    Path("auth/.env.example"),
]


def read_doc_vars(path: Path) -> set[str]:
    """Return variable names listed in the docs table."""
    pattern = re.compile(r"^\|\s*([A-Z0-9_]+)\b")
    vars: set[str] = set()
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            m = pattern.match(line)
            if m:
                vars.add(m.group(1))
    return vars


def read_env_vars(paths: list[Path]) -> set[str]:
    """Return variable names from example .env files."""
    pattern = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)=")
    vars: set[str] = set()
    for p in paths:
        with p.open("r", encoding="utf-8") as f:
            for line in f:
                m = pattern.match(line)
                if m:
                    vars.add(m.group(1))
    return vars


def main() -> int:
    doc_vars = read_doc_vars(DOC_PATH)
    env_vars = read_env_vars(ENV_FILES)

    missing_in_docs = sorted(env_vars - doc_vars)
    missing_in_files = sorted(doc_vars - env_vars)

    if missing_in_docs:
        print("Variables missing from agents/index.md:")
        for name in missing_in_docs:
            print(name)
        print()

    if missing_in_files:
        print("Variables missing from .env examples:")
        for name in missing_in_files:
            print(name)
        print()

    if missing_in_docs or missing_in_files:
        return 1

    print("Environment variable docs match example files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
